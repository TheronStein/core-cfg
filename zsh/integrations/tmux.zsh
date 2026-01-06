# ~/.core/zsh/integrations/tmux.zsh
# TMUX Integration - Advanced session, window, and pane management
# Dependencies: tmux, fzf, yazi (optional), neovim (optional)
#
# NOTE: Core tmux utilities are sourced from global libraries:
#   - session.sh: Session management (session::*)
#   - tmux.sh: Pane/window operations (tmux::*)
#   - fzf-config.sh: FZF styling (fzf::*)
# This file provides ZSH-specific wrappers, aliases, and completions.

#=============================================================================
# GLOBAL LIBRARIES
#=============================================================================
# Source cortex libraries via compatibility layer
if [[ -f "${HOME}/.core/.cortex/lib/compat.zsh" ]]; then
    source "${HOME}/.core/.cortex/lib/compat.zsh"
    cortex::source session 2>/dev/null    # session::* functions
    cortex::source tmux 2>/dev/null       # tmux::* functions
    cortex::source fzf-config 2>/dev/null # fzf::* functions
fi

#=============================================================================
# TMUX ENVIRONMENT
#=============================================================================
export TMUX_CONFIG="${CORE_CFG}/tmux"
export TMUX_PLUGIN_MANAGER_PATH="${CORE_CFG}/tmux/plugins"

#=============================================================================
# TMUX AUTO-START (optional, uncomment to enable)
#=============================================================================
# Auto-start tmux if:
# - Not already in tmux
# - Not in SSH session (unless forced)
# - Interactive shell
# - Terminal supports it
# if [[ -z "$TMUX" && -z "$INSIDE_EMACS" && -z "$VIM" && -z "$NVIM" ]]; then
#     if [[ -z "$SSH_CONNECTION" || -n "$TMUX_AUTO_START_SSH" ]]; then
#         tmux new-session -A -s main
#     fi
# fi

#=============================================================================
# CORE FUNCTIONS
#=============================================================================

# Function: tmux-sessionizer
# Description: Create or switch to project-based tmux sessions
function tmux-sessionizer() {
  local selected
  local session_name

  # Get directories from multiple sources
  local search_dirs=(
    "$CORE_PROJ/active"
    "$CORE_PROJ/learning"
    "$HOME/projects"
    "$HOME/work"
    "$HOME/.config"
    "$CORE_CFG"
  )

  # Find all git repositories and important directories
  selected=$(fd . "${search_dirs[@]}" -t d -d 2 2>/dev/null \
    | fzf --preview 'eza -la --color=always --icons {}' \
      --header 'Select project directory')

  [[ -z "$selected" ]] && return

  # Generate session name from directory
  session_name=$(basename "$selected" | tr '.' '_')

  # Check if we're in tmux
  if [[ -z "$TMUX" ]]; then
    # Not in tmux, create new session or attach
    tmux new-session -A -s "$session_name" -c "$selected"
  else
    # In tmux, create session if doesn't exist, then switch
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
      tmux new-session -d -s "$session_name" -c "$selected"

      # Optional: Set up default windows for specific project types
      if [[ -f "$selected/package.json" ]]; then
        tmux new-window -t "$session_name:2" -n "server" -c "$selected"
        tmux new-window -t "$session_name:3" -n "logs" -c "$selected"
      elif [[ -f "$selected/Cargo.toml" ]]; then
        tmux new-window -t "$session_name:2" -n "build" -c "$selected"
        tmux new-window -t "$session_name:3" -n "test" -c "$selected"
      elif [[ -f "$selected/go.mod" ]]; then
        tmux new-window -t "$session_name:2" -n "test" -c "$selected"
      fi
    fi
    tmux switch-client -t "$session_name"
  fi
}

# Function: tmux-workspace
# Description: Create predefined workspace layouts
function tmux-workspace() {
  local workspace_type="${1:-dev}"
  local session_name="${2:-workspace}"

  case "$workspace_type" in
    dev)
      tmux new-session -d -s "$session_name" -n "editor"
      tmux split-window -h -p 30
      tmux select-pane -t 0
      tmux new-window -n "terminal"
      tmux new-window -n "logs"
      ;;

    monitoring)
      tmux new-session -d -s "$session_name" -n "system"
      tmux split-window -h
      tmux split-window -v
      tmux select-pane -t 0
      tmux split-window -v
      tmux send-keys -t 0 'btm' C-m
      tmux send-keys -t 1 'watch -n 1 "docker ps"' C-m
      tmux send-keys -t 2 'journalctl -f' C-m
      tmux send-keys -t 3 'watch -n 1 "ss -tulpn | grep LISTEN"' C-m
      ;;

    database)
      tmux new-session -d -s "$session_name" -n "query"
      tmux new-window -n "schema"
      tmux new-window -n "monitor"
      ;;

    notes)
      tmux new-session -d -s "$session_name" -n "notes" -c "$CORTEX_INBOX"
      tmux send-keys "nvim ." C-m
      tmux new-window -n "reference" -c "$CORTEX_REFERENCES"
      tmux new-window -n "tasks" -c "$LIFE_TASKS"
      ;;

    *)
      echo "Unknown workspace type: $workspace_type"
      echo "Available: dev, monitoring, database, notes"
      return 1
      ;;
  esac

  if [[ -z "$TMUX" ]]; then
    tmux attach-session -t "$session_name"
  else
    tmux switch-client -t "$session_name"
  fi
}

# Function: tmux-save-session
# Description: Save current tmux session layout
function tmux-save-session() {
  local session_name="${1:-$(tmux display-message -p '#S')}"
  local save_dir="${XDG_DATA_HOME}/tmux/sessions"
  local save_file="$save_dir/${session_name}.sh"

  mkdir -p "$save_dir"

  cat >"$save_file" <<'EOF'
#!/usr/bin/env bash
# Tmux session restore script
EOF

  echo "SESSION_NAME=\"$session_name\"" >>"$save_file"
  echo "" >>"$save_file"

  # Save windows and panes
  tmux list-windows -t "$session_name" -F "#{window_index} #{window_name} #{window_layout} #{pane_current_path}" \
    | while read -r index name layout path; do
      echo "tmux new-window -t \"\$SESSION_NAME:$index\" -n \"$name\" -c \"$path\"" >>"$save_file"
      echo "tmux select-layout -t \"\$SESSION_NAME:$index\" \"$layout\"" >>"$save_file"
    done

  chmod +x "$save_file"
  echo "Session saved to: $save_file"
}

# Function: tmux-restore-session
# Description: Restore saved tmux session layout
function tmux-restore-session() {
  local save_dir="${XDG_DATA_HOME}/tmux/sessions"
  local session_file

  session_file=$(find "$save_dir" -name "*.sh" 2>/dev/null \
    | fzf --preview 'cat {}' \
      --header 'Select session to restore')

  if [[ -n "$session_file" && -f "$session_file" ]]; then
    bash "$session_file"
  fi
}

# Function: tmux-kill-session
# Description: Kill tmux sessions interactively
function tmux-kill-session() {
  local sessions
  sessions=$(tmux list-sessions -F "#{session_name}" \
    | fzf --multi --header 'Select sessions to kill')

  if [[ -n "$sessions" ]]; then
    echo "$sessions" | while read -r session; do
      tmux kill-session -t "$session"
      echo "Killed session: $session"
    done
  fi
}

# Function: tmux-switch-client
# Description: Switch tmux client to another session with preview
function tmux-switch-client() {
  [[ -z "$TMUX" ]] && {
    echo "Not in tmux"
    return 1
  }

  local session
  session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows#{?session_attached, (attached),}" \
    | fzf --preview 'tmux capture-pane -ep -t $(echo {} | cut -d: -f1)' \
      --preview-window 'right:60%:wrap' \
    | cut -d: -f1)

  [[ -n "$session" ]] && tmux switch-client -t "$session"
}

# Function: tmux-send-keys-all-panes
# Description: Send keys to all panes in current window
function tmux-send-keys-all-panes() {
  local cmd="$*"
  tmux list-panes -F '#{pane_id}' | xargs -I {} tmux send-keys -t {} "$cmd" Enter
}

# Function: tmux-send-keys-all-windows
# Description: Send keys to all windows in current session
function tmux-send-keys-all-windows() {
  local cmd="$*"
  tmux list-windows -F '#{window_id}' | xargs -I {} tmux send-keys -t {} "$cmd" Enter
}

# Function: tmux-capture-pane
# Description: Capture pane output to file or clipboard
function tmux-capture-pane() {
  local output_file="${1:-/tmp/tmux-capture-$(date +%Y%m%d-%H%M%S).txt}"

  tmux capture-pane -p >"$output_file"

  if command -v wl-copy &>/dev/null; then
    cat "$output_file" | wl-copy
    echo "Captured to: $output_file (and clipboard)"
  else
    echo "Captured to: $output_file"
  fi
}

# Function: tmux-zoom-pane
# Description: Toggle zoom for current pane
function tmux-zoom-pane() {
  tmux resize-pane -Z
}

# Function: tmux-swap-pane
# Description: Swap current pane with another interactively
function tmux-swap-pane() {
  local pane
  pane=$(tmux list-panes -F "#{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height})" \
    | fzf --header 'Select pane to swap with' \
    | cut -d: -f1)

  [[ -n "$pane" ]] && tmux swap-pane -t "$pane"
}

# Function: tmux-link-window
# Description: Link window from another session
function tmux-link-window() {
  local window
  window=$(tmux list-windows -a -F "#{session_name}:#{window_index}: #{window_name}" \
    | fzf --header 'Select window to link' \
    | awk '{print $1}')

  if [[ -n "$window" ]]; then
    tmux link-window -s "$window"
  fi
}

# Function: tmux-monitor-activity
# Description: Toggle activity monitoring for current window
function tmux-monitor-activity() {
  local current=$(tmux show-window-options | grep monitor-activity | awk '{print $2}')
  if [[ "$current" == "on" ]]; then
    tmux set-window-option monitor-activity off
    echo "Activity monitoring disabled"
  else
    tmux set-window-option monitor-activity on
    echo "Activity monitoring enabled"
  fi
}

# Function: tmux-yazi-sidebar
# Description: Create yazi file manager in sidebar pane
function tmux-yazi-sidebar() {
  if ! tmux list-panes -F '#{pane_current_command}' | grep -q yazi; then
    tmux split-window -h -l 30% 'yazi'
  else
    # If yazi pane exists, kill it
    tmux list-panes -F '#{pane_id} #{pane_current_command}' \
      | grep yazi | awk '{print $1}' | xargs tmux kill-pane -t
  fi
}

# Function: tmux-popup
# Description: Create a tmux popup window with command
function tmux-popup() {
  local cmd="${1:-$SHELL}"
  local width="${2:-80%}"
  local height="${3:-80%}"

  if [[ -n "$TMUX" ]]; then
    tmux popup -w "$width" -h "$height" -E "$cmd"
  else
    echo "Not in tmux session"
  fi
}

# Function: tmux-float-term
# Description: Create floating terminal with specific command
function tmux-float-term() {
  local cmd="${1:-}"
  if [[ -n "$cmd" ]]; then
    tmux-popup "$cmd"
  else
    tmux-popup
  fi
}

# Function: tmux-sync-panes
# Description: Toggle synchronized input to all panes
function tmux-sync-panes() {
  local sync_state=$(tmux show-window-options | grep synchronize-panes | awk '{print $2}')
  if [[ "$sync_state" == "on" ]]; then
    tmux set-window-option synchronize-panes off
    echo "Pane synchronization disabled"
  else
    tmux set-window-option synchronize-panes on
    echo "Pane synchronization enabled"
  fi
}

#=============================================================================
# ALIASES
#=============================================================================
alias ts='tmux-sessionizer'
alias tws='tmux-workspace'
alias tks='tmux-kill-session'
alias tsc='tmux-switch-client'
alias tsave='tmux-save-session'
alias trestore='tmux-restore-session'
alias tpopup='tmux-popup'
alias tfloat='tmux-float-term'
alias tsync='tmux-sync-panes'
alias tyazi='tmux-yazi-sidebar'
alias tzoom='tmux-zoom-pane'

# Basic tmux aliases
alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'
alias tmuxconf='$EDITOR $TMUX_CONFIG/tmux.conf'

#=============================================================================
# HELPER FUNCTIONS FOR INTEGRATION
#=============================================================================

# Function: is-tmux
# Description: Check if we're inside tmux (wrapper for global lib)
function is-tmux() {
  # Use global lib if available, fallback to direct check
  if (( $+functions[session::in_tmux] )); then
    session::in_tmux
  else
    [[ -n "$TMUX" ]]
  fi
}

# Function: tmux-colors
# Description: Show tmux color palette
function tmux-colors() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m "
    if (((i + 1) % 16 == 0)); then
      echo
    fi
  done
}

#=============================================================================
# TMUX SESSION MANAGER (FZF-based with WezTerm integration)
#=============================================================================
# NOTE: Core session functions are provided by ~/.core/.cortex/lib/session.sh
# This section provides ZSH-specific wrappers and the interactive session manager.

# Configuration (used by global session.sh via TMUX_DEFAULT_SOCKET)
export TMUX_DEFAULT_SOCKET=""  # Empty = default socket

# Function: _tmux_get_socket_flag
# Description: Get socket flag for tmux commands (wrapper for global lib)
_tmux_get_socket_flag() {
  if (( $+functions[session::_socket_flag] )); then
    session::_socket_flag
  else
    [[ -n "$TMUX_DEFAULT_SOCKET" ]] && echo "-L $TMUX_DEFAULT_SOCKET" || echo ""
  fi
}

# Function: _tmux_list_sessions
# Description: List all tmux sessions with details (wrapper for global lib)
_tmux_list_sessions() {
  if (( $+functions[session::list] )); then
    session::list
  else
    local socket_flag="$(_tmux_get_socket_flag)"
    tmux $socket_flag list-sessions -F "#{session_name}|#{session_windows}w|#{session_attached}a|#{session_created}" 2>/dev/null | \
      awk -F'|' '{
        name = $1
        windows = $2
        attached = ($3 > 0) ? "●" : "○"
        printf "%-20s %s %3s  [%s]\n", name, attached, windows, $4
      }'
  fi
}

# Function: _tmux_session_preview
# Description: Generate preview for tmux session (wrapper for global lib)
_tmux_session_preview() {
  local session_name="$1"
  if (( $+functions[session::preview] )); then
    session::preview "$session_name"
  else
    local socket_flag="$(_tmux_get_socket_flag)"
    echo "Session: $session_name"
    echo "─────────────────────────────────────"
    tmux $socket_flag list-windows -t "$session_name" -F "  #{window_index}: #{window_name} #{window_panes}p #{?window_active,(active),}" 2>/dev/null
    echo ""
    echo "Preview:"
    echo "─────────────────────────────────────"
    tmux $socket_flag capture-pane -ep -t "$session_name" 2>/dev/null | head -30
  fi
}

# Function: _is_wezterm
# Description: Check if current terminal is WezTerm
_is_wezterm() {
  [[ -n "$WEZTERM_EXECUTABLE" ]] || [[ "$TERM_PROGRAM" == "WezTerm" ]]
}

# Function: tmux-session-open-wezterm-tab
# Description: Open tmux session in new WezTerm tab
tmux-session-open-wezterm-tab() {
  local session_name="$1"
  local socket_flag="$(_tmux_get_socket_flag)"

  if ! _is_wezterm; then
    echo "Not running in WezTerm"
    return 1
  fi

  # Use WezTerm CLI to open new tab with tmux attach command
  wezterm cli spawn --new-tab -- tmux $socket_flag attach-session -t "$session_name" 2>/dev/null || \
    wezterm cli spawn --new-tab -- tmux $socket_flag new-session -s "$session_name"
}

# Function: tmux-session-manager
# Description: Interactive tmux session manager with FZF
# Actions:
#   Enter     - Switch to session (or attach if not in tmux)
#   Tab       - Mark session for bulk operations
#   Ctrl-D    - Kill marked sessions
#   Ctrl-N    - Create new session (uses query text as name)
#   Ctrl-R    - Rename session
#   Ctrl-T    - Open in new WezTerm tab (if in WezTerm)
tmux-session-manager() {
  local socket_flag="$(_tmux_get_socket_flag)"
  local in_tmux="$TMUX"
  local in_wezterm="$(_is_wezterm && echo "yes" || echo "no")"

  # Build header
  local header="Tmux Session Manager"
  [[ -n "$in_tmux" ]] && header="$header (Current: $(tmux display-message -p '#S'))"
  header="$header
───────────────────────────────────────────────
Enter: Switch/Attach │ Ctrl-N: New (uses query) │ Tab: Mark │ Ctrl-D: Kill marked │ Ctrl-R: Rename"
  [[ "$in_wezterm" == "yes" ]] && header="$header │ Ctrl-T: New WezTerm Tab"

  while true; do
    local fzf_output key query selections

    # Use --expect to capture key presses, --print-query to get typed text
    fzf_output=$(_tmux_list_sessions | \
      fzf --ansi \
          --multi \
          --height 60% \
          --border rounded \
          --header "$header" \
          --print-query \
          --expect=ctrl-n,ctrl-d,ctrl-r,ctrl-t \
          --preview 'session=$(echo {} | awk "{print \$1}"); echo "Session: $session" && echo "─────────────────────────────────────" && tmux list-windows -t "$session" -F "  #{window_index}: #{window_name} #{window_panes}p" 2>/dev/null && echo "" && tmux capture-pane -ep -t "$session" 2>/dev/null | head -30' \
          --preview-window 'right:60%:wrap')

    # Parse output: line 1 = query, line 2 = key pressed, line 3+ = selections
    query=$(echo "$fzf_output" | sed -n '1p')
    key=$(echo "$fzf_output" | sed -n '2p')
    selections=$(echo "$fzf_output" | sed -n '3,$p')

    # Handle escape/no selection
    [[ -z "$key" && -z "$selections" ]] && return 0

    case "$key" in
      ctrl-n)
        # Create new session using query text as name
        local new_name="$query"
        if [[ -z "$new_name" ]]; then
          echo -n "New session name: "
          read new_name
        fi
        if [[ -n "$new_name" ]]; then
          if tmux $socket_flag has-session -t "$new_name" 2>/dev/null; then
            echo "Session '$new_name' already exists"
          else
            tmux $socket_flag new-session -d -s "$new_name" 2>/dev/null && \
              echo "Created session: $new_name"
          fi
        fi
        continue
        ;;

      ctrl-d)
        # Kill all marked sessions
        local -a sessions_to_kill
        while IFS= read -r line; do
          local sess=$(echo "$line" | awk '{print $1}')
          [[ -n "$sess" ]] && sessions_to_kill+=("$sess")
        done <<< "$selections"

        if [[ ${#sessions_to_kill[@]} -eq 0 ]]; then
          echo "No sessions marked (use Tab to mark sessions first)"
          continue
        fi

        echo "Sessions to kill: ${sessions_to_kill[*]}"
        echo -n "Kill ${#sessions_to_kill[@]} session(s)? [y/N] "
        read confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
          for sess in "${sessions_to_kill[@]}"; do
            tmux $socket_flag kill-session -t "$sess" 2>/dev/null && \
              echo "Killed session: $sess"
          done
        fi
        continue
        ;;

      ctrl-r)
        # Rename selected session
        local old_name=$(echo "$selections" | head -1 | awk '{print $1}')
        if [[ -z "$old_name" ]]; then
          echo "No session selected"
          continue
        fi
        echo -n "Rename session '$old_name' to: "
        read new_name
        if [[ -n "$new_name" ]]; then
          tmux $socket_flag rename-session -t "$old_name" "$new_name" 2>/dev/null && \
            echo "Renamed: $old_name → $new_name"
        fi
        continue
        ;;

      ctrl-t)
        # Open in new WezTerm tab
        if [[ "$in_wezterm" == "yes" ]]; then
          local target=$(echo "$selections" | head -1 | awk '{print $1}')
          [[ -n "$target" ]] && tmux-session-open-wezterm-tab "$target"
        fi
        return 0
        ;;

      *)
        # Enter key - switch/attach to session
        local session_name=$(echo "$selections" | head -1 | awk '{print $1}')
        [[ -z "$session_name" ]] && return 0

        if [[ -n "$in_tmux" ]]; then
          tmux switch-client -t "$session_name"
        else
          tmux $socket_flag attach-session -t "$session_name" 2>/dev/null || \
            tmux $socket_flag new-session -s "$session_name"
        fi
        return 0
        ;;
    esac
  done
}

# Function: tmux-session-create
# Description: Create new tmux session with optional directory
tmux-session-create() {
  local session_name="$1"
  local directory="${2:-.}"
  local socket_flag="$(_tmux_get_socket_flag)"

  if [[ -z "$session_name" ]]; then
    echo -n "Session name: "
    read session_name
  fi

  [[ -z "$session_name" ]] && return 1

  # Create session
  if tmux $socket_flag has-session -t "$session_name" 2>/dev/null; then
    echo "Session '$session_name' already exists"
    return 1
  fi

  tmux $socket_flag new-session -d -s "$session_name" -c "$directory"
  echo "Created session: $session_name (in $directory)"

  # Ask if user wants to attach
  if [[ -z "$TMUX" ]]; then
    echo -n "Attach now? [Y/n] "
    read attach
    if [[ ! "$attach" =~ ^[Nn]$ ]]; then
      tmux $socket_flag attach-session -t "$session_name"
    fi
  fi
}

# Function: tmux-session-kill-all-except-current
# Description: Kill all tmux sessions except the current one
tmux-session-kill-all-except-current() {
  [[ -z "$TMUX" ]] && {
    echo "Not in tmux session"
    return 1
  }

  local current_session=$(tmux display-message -p '#S')
  local socket_flag="$(_tmux_get_socket_flag)"

  echo "Current session: $current_session"
  echo -n "Kill all other sessions? [y/N] "
  read confirm

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    tmux $socket_flag list-sessions -F "#{session_name}" | \
      grep -v "^${current_session}$" | \
      xargs -I {} tmux $socket_flag kill-session -t {}
    echo "Killed all sessions except: $current_session"
  fi
}

#=============================================================================
# AUTO-COMPLETION
#=============================================================================
# Add custom completion for workspace types
_tmux_workspace_complete() {
  local -a workspace_types
  workspace_types=(dev monitoring database notes)
  _describe 'workspace type' workspace_types
}

(( $+functions[compdef] )) && compdef _tmux_workspace_complete tmux-workspace
