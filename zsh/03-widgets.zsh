# ~/.core/zsh/03-widgets.zsh
# ZLE (Zsh Line Editor) Widgets - custom interactive command-line widgets
# ~/.config/zsh/widgets/universal-fzf-overlay.zsh

#=============================================================================
# WIDGET CLEANUP HELPER
#=============================================================================
# Ensures background jobs are cleaned up when widgets exit
_widget_cleanup() {
  # Kill any background jobs spawned by this widget
  local pids=$(jobs -p 2>/dev/null)
  [[ -n "$pids" ]] && kill $pids 2>/dev/null
}

#=============================================================================
# TMUX POPUP FZF WRAPPER
#=============================================================================
# Runs fzf in a tmux popup when inside tmux, otherwise runs directly.
# Usage: echo "items" | _fzf_in_tmux_popup [fzf-args...]
# The popup is 90% width/height with a border.
_fzf_in_tmux_popup() {
    if [[ -n "$TMUX" ]]; then
        # Use fzf-tmux if available (official fzf tmux integration)
        if (( $+commands[fzf-tmux] )); then
            fzf-tmux -p 90%,90% "$@"
        else
            # Fallback: run fzf in tmux popup manually
            local input_file=$(mktemp)
            local result_file=$(mktemp)

            # Capture stdin to file
            cat > "$input_file"

            # Build command with proper escaping
            # Use print -r to avoid interpretation, then eval in popup
            local -a escaped_args
            local arg
            for arg in "$@"; do
                escaped_args+=("${(q)arg}")
            done

            # Run fzf in popup with explicit bash
            tmux display-popup -E -w 90% -h 90% \
                "bash -c 'cat \"$input_file\" | fzf ${escaped_args[*]} > \"$result_file\" 2>/dev/null'"

            # Output result
            cat "$result_file" 2>/dev/null
            rm -f "$input_file" "$result_file"
        fi
    else
        fzf "$@"
    fi
}

widget::universal-overlay() {
  # Setup cleanup trap
  trap _widget_cleanup EXIT INT TERM
  local choice

  choice=$(printf '%s\n' \
    "Files           :: Find & insert file" \
    "Directories     :: Find & cd/insert directory" \
    "History         :: Enhanced history search" \
    "Kill Process    :: Fuzzy kill processes" \
    "Git Status      :: Select changed files" \
    "Git Branch      :: Checkout branch" \
    "Git Commits     :: Browse & insert commit" \
    "Tmux Sessions   :: Switch/attach session" \
    "Tmux Windows    :: Switch window" \
    "SSH Hosts       :: Connect to host" \
    "Env Vars        :: Insert environment variable" \
    "Command Palette :: Run common commands" \
    "Yazi Picker     :: Choose files via Yazi" \
    "Yazi CD         :: Change dir via Yazi" \
    "Bookmarks       :: Jump to bookmarked dir" \
    "Quick Note      :: Add timestamped note" \
    "Calculator      :: Evaluate expression" \
  | _fzf_in_tmux_popup \
      --reverse \
      --border=rounded \
      --border-label=" Universal Command Palette " \
      --prompt="Action ❯ " \
      --preview='echo "Select an action above"' \
      --preview-window=down:1:wrap \
      --color="$(_fzf_colors)")

  [[ -z "$choice" ]] && return

  case "$choice" in
    "Files           :: "*)
      selected=$(fd --type f --hidden --follow --exclude .git | _fzf_in_tmux_popup $(_fzf_base_opts) --preview 'bat --style=numbers --color=always {}')
      [[ -n "$selected" ]] && LBUFFER+="${(q)selected}"
      ;;
    "Directories     :: "*)
      selected=$(fd --type d --hidden --follow --exclude .git | _fzf_in_tmux_popup $(_fzf_base_opts) --preview 'eza -la --color=always --icons {}')
      [[ -n "$selected" ]] && { [[ -z "$BUFFER" ]] && cd "$selected" || LBUFFER+="${(q)selected}" }
      ;;
    "History         :: "*)
      selected=$(fc -rl 1 | awk '!seen[$0]++' | _fzf_in_tmux_popup $(_fzf_base_opts) --tiebreak=index --preview 'echo {2..}' --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort')
      [[ -n "$selected" ]] && zle vi-fetch-history -n $(echo "$selected" | awk '{print $1}')
      ;;
    "Kill Process    :: "*)
      pid=$(ps aux | sed 1d | _fzf_in_tmux_popup $(_fzf_base_opts) -m --preview 'echo {}' | awk '{print $2}')
      [[ -n "$pid" ]] && echo "$pid" | xargs -r kill -9
      ;;
    "Git Status      :: "*)
      git rev-parse --is-inside-work-tree >/dev/null || return
      selected=$(git status --short | _fzf_in_tmux_popup $(_fzf_base_opts) -m --ansi --preview 'git diff --color=always -- {-1} | delta' | awk '{print $2}')
      [[ -n "$selected" ]] && LBUFFER+="$selected"
      ;;
    "Git Branch      :: "*)
      git rev-parse --is-inside-work-tree >/dev/null || return
      branch=$(git branch --all --color=always --format='%(refname:short)' | grep -v HEAD | _fzf_in_tmux_popup $(_fzf_base_opts) --ansi --preview 'git log --oneline --graph {}' | sed 's#remotes/origin/##')
      [[ -n "$branch" ]] && { [[ -z "$BUFFER" ]] && git checkout "$branch" || LBUFFER+="$branch" }
      ;;
    # … add the rest exactly like your old widgets …
    "Quick Note      :: "*)
      local note; vared -p "Note: " note
      [[ -n "$note" ]] && echo "- [$(date +%H:%M)] $note" >> "${XDG_DATA_HOME:-$HOME/.local/share}/notes/$(date +%Y-%m-%d).md"
      zle -M "Note saved"
      ;;
    *)
      zle -M "Not implemented yet: $choice"
      ;;
  esac

  # Cleanup before exit
  _widget_cleanup
  trap - EXIT INT TERM

  zle reset-prompt
}

zle -N widget::universal-overlay
# NOTE: Keybinding moved to zvm_after_init to avoid conflicts with zsh-vi-mode
# See 02-zinit.zsh for the zvm_after_init_commands configuration

#=============================================================================
# WIDGET: FZF-POWERED FILE SELECTOR
# Usage: Ctrl+F to fuzzy-find files and insert at cursor
#=============================================================================
function widget::fzf-file-selector() {
    local selected
    selected=$(fd --type f --hidden --follow --exclude .git 2>/dev/null | \
        _fzf_in_tmux_popup $(_fzf_base_opts) \
            --header 'Files │ Enter: insert │ C-/: preview │ Esc: cancel' \
            --preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}')

    if [[ -n "$selected" ]]; then
        LBUFFER+="${(q)selected}"
    fi
    zle reset-prompt
}
zle -N widget::fzf-file-selector

#=============================================================================
# WIDGET: FZF-POWERED DIRECTORY SELECTOR
# Usage: Ctrl+D to fuzzy-find directories and cd or insert
#=============================================================================
function widget::fzf-directory-selector() {
    local selected
    selected=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | \
        _fzf_in_tmux_popup $(_fzf_base_opts) \
            --header 'Directories │ Enter: cd (empty) / insert │ C-/: preview' \
            --preview 'eza -la --color=always --icons {} 2>/dev/null')

    if [[ -n "$selected" ]]; then
        if [[ -z "$BUFFER" ]]; then
            # Empty buffer: cd to directory
            cd "$selected"
            zle accept-line
        else
            # Non-empty buffer: insert path
            LBUFFER+="${(q)selected}"
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-directory-selector

#=============================================================================
# WIDGET: UNIFIED HISTORY BROWSER WITH MODE SWITCHING
# Usage: Ctrl+R for history search with switchable contexts
# Modes: Global History, Local History, Clipboard, System Notifications
# Ctrl+] cycles through modes, Ctrl+Y copies selection (full content)
#=============================================================================

# Helper function to get global history
_hist_global() {
    local hist="${HISTFILE:-${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history}"
    [[ -f "$hist" ]] || hist="$HOME/.zsh_history"
    tac "$hist" 2>/dev/null | \
        sed 's/^: [0-9]*:[0-9]*;//' | awk '!seen[$0]++' | command head -n 2000
}

# Helper function to get local/directory history
_hist_local() {
    local hist_file="${HISTORY_BASE:-$HOME/.directory_history}${PWD}/history"
    if [[ -f "$hist_file" ]]; then
        tac "$hist_file" 2>/dev/null | \
            sed 's/^: [0-9]*:[0-9]*;//' | awk '!seen[$0]++' | command head -n 1000
    else
        echo "No local history for: $PWD"
    fi
}

# Helper function to get clipboard history
_hist_clipboard() {
    if (( $+commands[cliphist] )); then
        cliphist list 2>/dev/null | command head -n 500
    else
        echo "cliphist not installed"
    fi
}

# Helper function to get system notifications (dunst)
_hist_notifications() {
    if (( $+commands[dunstctl] )); then
        # Parse dunst history JSON - strip ANSI codes, extract fields
        # dunstctl outputs JSON with embedded ANSI color codes
        # gsub strips HTML tags, decodes entities, and joins lines
        dunstctl history 2>/dev/null | \
            sed 's/\x1b\[[0-9;]*m//g' | \
            jq -r '.data[0][0:100] | .[]? | "\(.id.data)\t[\(.appname.data)] \(.summary.data): \((.message.data // .body.data) | gsub("<[^>]*>"; "") | gsub("&lt;"; "<") | gsub("&gt;"; ">") | gsub("&amp;"; "&") | gsub("\n"; " "))"' 2>/dev/null
    elif (( $+commands[makoctl] )); then
        makoctl history 2>/dev/null | jq -r '.data[0][0:100] | .[]? | "\(.id)\t[\(.["app-name"])] \(.summary): \((.body) | gsub("<[^>]*>"; "") | gsub("&lt;"; "<") | gsub("&gt;"; ">") | gsub("&amp;"; "&") | gsub("\n"; " "))"' 2>/dev/null
    else
        echo "No notification daemon found (dunst/mako)"
    fi
}

function widget::fzf-history-search() {
    setopt localoptions noglobsubst noposixbuiltins pipefail no_xtrace 2>/dev/null

    local result tmpfile modefile
    local mode=1
    local total_modes=4
    tmpfile=$(mktemp) || return 1
    modefile=$(mktemp) || { rm -f "$tmpfile"; return 1; }
    trap "rm -f '$tmpfile' '$modefile'" EXIT

    local header="C-]: Cycle Mode │ C-y: Copy │ Enter: Select │ Esc: Cancel"
    local colors
    colors=$(_fzf_colors 2>/dev/null)

    while true; do
        local label preview_cmd yank_cmd
        local -a fzf_extra_opts=()
        preview_cmd='echo {} | bat --style=plain --color=always -l bash 2>/dev/null || echo {}'
        yank_cmd='echo -n {} | wl-copy'

        # Store mode for potential use by yank command
        echo "$mode" >| "$modefile"

        case $mode in
            1)
                label=" [CORE] GLOBAL SHELL HISTORY "
                _hist_global >| "$tmpfile" 2>/dev/null
                ;;
            2)
                label=" [CORE] LOCAL SHELL HISTORY "
                _hist_local >| "$tmpfile" 2>/dev/null
                ;;
            3)
                label=" [CORE] CLIPBOARD HISTORY "
                _hist_clipboard >| "$tmpfile" 2>/dev/null
                fzf_extra_opts=(--delimiter=$'\t' --with-nth=2..)
                preview_cmd='echo {} | cliphist decode 2>/dev/null || echo {}'
                # For clipboard mode, decode full content before copying
                yank_cmd='echo {} | cliphist decode 2>/dev/null | wl-copy'
                ;;
            4)
                label=" [CORE] SYSTEM NOTIFICATIONS "
                _hist_notifications >| "$tmpfile" 2>/dev/null
                fzf_extra_opts=(--delimiter=$'\t' --with-nth=2..)
                preview_cmd='echo {} | cut -f2- | fold -s -w 80'
                # For notifications, copy the message part (after tab)
                yank_cmd='echo {} | cut -f2- | wl-copy'
                ;;
        esac

        result=$(
            cat "$tmpfile" 2>/dev/null | _fzf_in_tmux_popup \
                --layout=reverse --border=rounded --info=inline \
                --color="$colors" \
                --border-label="$label" \
                --border-label-pos=2 \
                --tiebreak=index \
                --query="${LBUFFER}" \
                --header="$header" \
                --expect=ctrl-] \
                --bind="ctrl-y:execute-silent($yank_cmd)+abort" \
                --preview="$preview_cmd" \
                --preview-window='up:40%' \
                "${fzf_extra_opts[@]}"
        ) 2>/dev/null

        local key="${result%%$'\n'*}"
        local selection="${result#*$'\n'}"
        [[ "$result" != *$'\n'* ]] && selection=""

        if [[ "$key" == "ctrl-]" ]]; then
            mode=$(( (mode % total_modes) + 1 ))
        else
            result="$selection"
            break
        fi
    done

    rm -f "$tmpfile" "$modefile" 2>/dev/null
    trap - EXIT

    if [[ -n "$result" ]]; then
        local cmd="$result"
        case $mode in
            3)
                # Clipboard: decode full content
                (( $+commands[cliphist] )) && cmd=$(printf '%s' "$result" | cliphist decode 2>/dev/null)
                ;;
            4)
                # Notifications: extract message part (skip id)
                cmd=$(printf '%s' "$result" | cut -f2-)
                ;;
        esac
        [[ -n "$cmd" ]] && { BUFFER="$cmd"; CURSOR=${#BUFFER}; }
    fi
    zle reset-prompt
}
zle -N widget::fzf-history-search

#=============================================================================
# WIDGET: PROCESS KILLER
# Usage: Ctrl+K to fuzzy-find and kill processes
#=============================================================================
function widget::fzf-kill-process() {
    local pid
    pid=$(ps aux | sed 1d | _fzf_in_tmux_popup $(_fzf_base_opts) --multi \
        --header 'Select process(es) to kill' \
        --preview 'echo {}' \
        --preview-window 'down:3:wrap' | \
        awk '{print $2}')

    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs -r kill -9
        zle send-break
    fi
    zle reset-prompt
}
zle -N widget::fzf-kill-process

#=============================================================================
# WIDGET: GIT STATUS SELECTOR
# Usage: Ctrl+G to select git files
#=============================================================================
function widget::fzf-git-status() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && return

    local selected
    selected=$(git status --short | \
        _fzf_in_tmux_popup $(_fzf_base_opts) --multi --ansi \
            --preview 'git diff --color=always -- {-1} | delta' \
            --header 'Select files to add to buffer' | \
        awk '{print $2}')

    if [[ -n "$selected" ]]; then
        LBUFFER+="${selected}"
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-status

#=============================================================================
# WIDGET: GIT BRANCH SELECTOR
# Usage: Ctrl+B to switch git branches
#=============================================================================
function widget::fzf-git-branch() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && return

    local selected
    selected=$(git branch --all --color=always | \
        grep -v 'HEAD' | \
        _fzf_in_tmux_popup $(_fzf_base_opts) --ansi \
            --header 'Branches │ Enter: checkout (empty) / insert │ C-/: preview' \
            --preview 'git log --oneline --color=always --graph $(echo {} | sed "s/.* //")' | \
        sed 's/.* //' | sed 's#remotes/origin/##')

    if [[ -n "$selected" ]]; then
        if [[ -z "$BUFFER" ]]; then
            git checkout "$selected"
            zle accept-line
        else
            LBUFFER+="$selected"
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-branch

#=============================================================================
# WIDGET: GIT COMMIT BROWSER
# Usage: Ctrl+Alt+C to browse commits
#=============================================================================
function widget::fzf-git-commits() {
    [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && return

    local selected
    selected=$(git log --oneline --color=always --graph | \
        _fzf_in_tmux_popup $(_fzf_base_opts) --ansi --no-sort \
            --tiebreak=index \
            --header 'Commits │ Enter: insert hash │ C-o: show full │ C-/: preview' \
            --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1)' \
            --bind 'ctrl-o:execute(git show --color=always $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1) | less -R)')

    if [[ -n "$selected" ]]; then
        local hash=$(echo "$selected" | grep -o "[a-f0-9]\{7\}" | head -1)
        LBUFFER+="$hash"
    fi
    zle reset-prompt
}
zle -N widget::fzf-git-commits

#=============================================================================
# WIDGET: TMUX SESSION MANAGER
# Usage: Interactive session management with create/delete/rename
# Uses tmux popup when inside tmux for overlay experience
#=============================================================================
function widget::tmux-session-manager() {
    # Source global session library
    source "${HOME}/.core/.cortex/lib/session.sh"

    # Clear the command line
    BUFFER=""
    zle redisplay

    local selected
    local result_file="/tmp/session-picker-result-$$"
    rm -f "$result_file"

    if [[ -n "$TMUX" ]]; then
        # Inside tmux - use popup overlay
        tmux display-popup -E -w 85% -h 85% -T " Sessions " \
            "source ~/.core/.cortex/lib/session.sh && session::picker > $result_file"
        selected=$(cat "$result_file" 2>/dev/null)
        rm -f "$result_file"

        [[ -n "$selected" ]] && session::switch "$selected"
        zle reset-prompt
    else
        # Outside tmux - run picker directly
        selected=$(session::picker)

        if [[ -n "$selected" ]]; then
            BUFFER="tmux attach -t ${(q)selected}"
            zle accept-line
        else
            zle reset-prompt
        fi
    fi
}
zle -N widget::tmux-session-manager

#=============================================================================
# WIDGET: TMUX SESSION SELECTOR (Legacy - kept for compatibility)
# Usage: Quick session switch
#=============================================================================
function widget::fzf-tmux-session() {
    local session

    if [[ -n "$TMUX" ]]; then
        session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" 2>/dev/null | \
            _fzf_in_tmux_popup $(_fzf_base_opts) \
                --header "Current: $(tmux display-message -p '#S')" \
                --preview 'tmux capture-pane -ep -t $(echo {} | cut -d: -f1) 2>/dev/null' | \
            cut -d: -f1)

        if [[ -n "$session" ]]; then
            tmux switch-client -t "$session"
        fi
    else
        session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | \
            _fzf_in_tmux_popup $(_fzf_base_opts) \
                --header "Select session to attach" | \
            cut -d: -f1)

        if [[ -n "$session" ]]; then
            BUFFER="tmux attach -t ${(q)session}"
            zle accept-line
        fi
    fi
    zle reset-prompt
}
zle -N widget::fzf-tmux-session

#=============================================================================
# WIDGET: TMUX WINDOW SELECTOR
# Usage: Ctrl+W to select tmux windows
#=============================================================================
function widget::fzf-tmux-window() {
    [[ -z "$TMUX" ]] && return

    local selected
    selected=$(tmux list-windows -F "#{window_index}: #{window_name} #{window_flags}" | \
        _fzf_in_tmux_popup $(_fzf_base_opts) \
            --header "Windows │ Current: $(tmux display-message -p '#I:#W') │ Enter: switch" | \
        cut -d: -f1)

    if [[ -n "$selected" ]]; then
        tmux select-window -t "$selected"
    fi
    zle reset-prompt
}
zle -N widget::fzf-tmux-window

#=============================================================================
# WIDGET: COMMAND PALETTE (run common commands)
# Usage: Ctrl+P for command palette
#=============================================================================
function widget::command-palette() {
    local commands=(
        "edit:nvim:Open Neovim"
        "files:yazi:Open Yazi file manager"
        "git-status:git status:Show git status"
        "git-log:git log --oneline -20:Show recent commits"
        "git-diff:git diff:Show git diff"
        "docker-ps:docker ps -a:List Docker containers"
        "docker-images:docker images:List Docker images"
        "ports:ss -tulpn:Show listening ports"
        "disk:df -h:Show disk usage"
        "memory:free -h:Show memory usage"
        "processes:procs:Show processes"
        "system:btm:Open system monitor"
        "update:paru -Syu:System update"
        "clean:paru -Sc:Clean package cache"
        "orphans:paru -Qtdq:List orphan packages"
    )

    local selected
    selected=$(printf '%s\n' "${commands[@]}" | \
        _fzf_in_tmux_popup $(_fzf_base_opts) \
            --delimiter ':' \
            --with-nth 1,3 \
            --header 'Command Palette │ Enter: execute │ Esc: cancel' \
            --preview 'echo "Command: $(echo {} | cut -d: -f2)"' \
            --preview-window 'down:1:wrap')

    if [[ -n "$selected" ]]; then
        local cmd=$(echo "$selected" | cut -d: -f2)
        BUFFER="$cmd"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::command-palette

#=============================================================================
# WIDGET: SSH HOST SELECTOR
# Usage: Alt+S to select SSH hosts
#=============================================================================
function widget::fzf-ssh() {
    local host
    host=$(grep -E "^Host [^*]" ~/.ssh/config 2>/dev/null | awk '{print $2}' | \
        _fzf_in_tmux_popup $(_fzf_base_opts) \
            --header 'SSH Hosts │ Enter: connect │ C-/: preview config' \
            --preview 'grep -A 10 "^Host {}" ~/.ssh/config 2>/dev/null')

    if [[ -n "$host" ]]; then
        BUFFER="ssh ${host}"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::fzf-ssh

#=============================================================================
# WIDGET: ENVIRONMENT VARIABLE BROWSER
# Usage: Alt+E to browse/insert env vars
#=============================================================================
function widget::fzf-env() {
    local selected
    selected=$(env | sort | \
        _fzf_in_tmux_popup $(_fzf_base_opts) \
            --header 'Environment │ Enter: insert ${VAR} │ C-/: preview value' \
            --preview 'echo {} | cut -d= -f2-' \
            --preview-window 'down:3:wrap')

    if [[ -n "$selected" ]]; then
        local var=$(echo "$selected" | cut -d= -f1)
        LBUFFER+="\${$var}"
    fi
    zle reset-prompt
}
zle -N widget::fzf-env

#=============================================================================
# WIDGET: EDIT COMMAND IN EDITOR
# Usage: Ctrl+X Ctrl+E to edit in $EDITOR
#=============================================================================
function widget::edit-command() {
    local tmpfile=$(mktemp)
    echo "$BUFFER" > "$tmpfile"
    ${EDITOR:-nvim} "$tmpfile"
    BUFFER=$(cat "$tmpfile")
    rm -f "$tmpfile"
    zle reset-prompt
}
zle -N widget::edit-command

#=============================================================================
# WIDGET: CLEAR SCREEN AND SCROLLBACK
# Usage: Ctrl+L (enhanced)
#=============================================================================
function widget::clear-scrollback() {
    clear
    printf '\033[3J'  # Clear scrollback
    zle reset-prompt
}
zle -N widget::clear-scrollback

#=============================================================================
# WIDGET: INSERT LAST COMMAND OUTPUT
# Usage: Alt+. to insert previous command's output
#=============================================================================
function widget::insert-last-output() {
    LBUFFER+="$(fc -e - -1 2>/dev/null)"
    zle reset-prompt
}
zle -N widget::insert-last-output

#=============================================================================
# WIDGET: TOGGLE SUDO PREFIX
# Usage: Escape Escape to toggle sudo
#=============================================================================
function widget::toggle-sudo() {
    if [[ "$BUFFER" == sudo\ * ]]; then
        BUFFER="${BUFFER#sudo }"
    else
        BUFFER="sudo $BUFFER"
    fi
    zle end-of-line
}
zle -N widget::toggle-sudo

#=============================================================================
# WIDGET: YAZI FILE PICKER
# Usage: Alt+Y to open yazi and insert selected files
#=============================================================================
function widget::yazi-picker() {
    local tmp="$(mktemp)"
    yazi --chooser-file="$tmp"
    if [[ -s "$tmp" ]]; then
        local selected=$(cat "$tmp" | tr '\n' ' ')
        LBUFFER+="$selected"
    fi
    rm -f "$tmp"
    zle reset-prompt
}
zle -N widget::yazi-picker

#=============================================================================
# WIDGET: YAZI CD (change to yazi's cwd on exit)
# Usage: Alt+Y in shell to use yazi for navigation
#=============================================================================
function widget::yazi-cd() {
    local tmp="$(mktemp)"
    yazi --cwd-file="$tmp"
    if [[ -f "$tmp" ]]; then
        local cwd=$(cat "$tmp")
        if [[ -d "$cwd" && "$cwd" != "$PWD" ]]; then
            cd "$cwd"
        fi
    fi
    rm -f "$tmp"
    zle reset-prompt
}
zle -N widget::yazi-cd

#=============================================================================
# WIDGET: COPY BUFFER TO CLIPBOARD
# Usage: Alt+C to copy command line to clipboard
#=============================================================================
function widget::copy-buffer() {
    if command -v wl-copy &>/dev/null; then
        echo -n "$BUFFER" | wl-copy
        zle -M "Copied to clipboard"
    elif command -v xclip &>/dev/null; then
        echo -n "$BUFFER" | xclip -selection clipboard
        zle -M "Copied to clipboard"
    fi
}
zle -N widget::copy-buffer

#=============================================================================
# WIDGET: PASTE FROM CLIPBOARD
# Usage: Alt+V to paste from clipboard
#=============================================================================
function widget::paste-clipboard() {
    local content
    if command -v wl-paste &>/dev/null; then
        content=$(wl-paste 2>/dev/null)
    elif command -v xclip &>/dev/null; then
        content=$(xclip -selection clipboard -o 2>/dev/null)
    fi
    LBUFFER+="$content"
    zle reset-prompt
}
zle -N widget::paste-clipboard

#=============================================================================
# WIDGET: QUICK CALCULATOR
# Usage: Alt+= to evaluate math expression
#=============================================================================
function widget::calculator() {
    if [[ -n "$BUFFER" ]]; then
        local result=$(echo "$BUFFER" | bc -l 2>/dev/null)
        if [[ -n "$result" ]]; then
            BUFFER="$result"
        fi
    else
        zle -M "Enter expression first"
    fi
    zle reset-prompt
}
zle -N widget::calculator

#=============================================================================
# WIDGET: EXPAND ALIAS UNDER CURSOR
# Usage: Ctrl+Space to expand alias
#=============================================================================
function widget::expand-alias() {
    zle _expand_alias
    zle expand-word
}
zle -N widget::expand-alias

#=============================================================================
# WIDGET: QUICK NOTE
# Usage: Alt+N to quickly save a note
#=============================================================================
function widget::quick-note() {
    local note_dir="${CORE}/.notes"
    mkdir -p "$note_dir"
    local note_file="$note_dir/$(date +%Y-%m-%d).md"
    
    local note
    vared -p "Note: " note
    
    if [[ -n "$note" ]]; then
        echo "- [$(date +%H:%M)] $note" >> "$note_file"
        zle -M "Note saved to $note_file"
    fi
    zle reset-prompt
}
zle -N widget::quick-note

#=============================================================================
# WIDGET: BITWARDEN
# Usage: Alt+B to open Bitwarden interactive menu
#=============================================================================
function widget::bitwarden() {
    bw::interactive
    zle reset-prompt
}
zle -N widget::bitwarden

#=============================================================================
# WIDGET: JUMP TO BOOKMARK
# Usage: Alt+J to jump to bookmarked directory
#=============================================================================
function widget::jump-bookmark() {
    local bookmark_file="${XDG_DATA_HOME}/zsh/bookmarks"
    [[ ! -f "$bookmark_file" ]] && { zle -M "No bookmarks"; return; }

    local selected
    selected=$(cat "$bookmark_file" | \
        _fzf_in_tmux_popup $(_fzf_base_opts) \
            --header 'Bookmarks │ Enter: cd │ C-/: preview' \
            --preview 'eza -la --color=always --icons {}')

    if [[ -n "$selected" && -d "$selected" ]]; then
        cd "$selected"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::jump-bookmark

#=============================================================================
# WIDGET: INSERT TIMESTAMP
# Usage: Alt+T to insert current timestamp
#=============================================================================
function widget::insert-timestamp() {
    LBUFFER+="$(date '+%Y-%m-%d %H:%M:%S')"
}
zle -N widget::insert-timestamp

#=============================================================================
# WIDGET: INSERT DATE
# Usage: Alt+D to insert current date
#=============================================================================
function widget::insert-date() {
    LBUFFER+="$(date '+%Y-%m-%d')"
}
zle -N widget::insert-date

#=============================================================================
# ZLE UTILITY FUNCTIONS
# Low-level helpers for building custom widgets
#=============================================================================

# Redraw prompt by running all precmd functions
function :@zredraw-prompt() {
    local precmd
    for precmd in "${precmd_functions[@]}"; do
        $precmd
    done
    zle reset-prompt
}
zle -N :@zredraw-prompt

# Add command to history without executing it
function :commit-to-history() {
    print -rs "${(z)BUFFER}"
    zle end-of-history
}
zle -N :commit-to-history

# Execute buffer content (helper for programmatic widget building)
function :@execute() {
    BUFFER="${(j:; :)@}"
    zle accept-line
}
zle -N :@execute

# Replace entire buffer with given content
function :@replace-buffer() {
    LBUFFER="${(j:; :)@}"
    RBUFFER=""
}
zle -N :@replace-buffer

# Append content to buffer
function :@append-to-buffer() {
    LBUFFER="${BUFFER}${(j:; :)@}"
}
zle -N :@append-to-buffer

# Open file(s) in editor
function :@edit-file() {
    local -a args
    args=("${(@q)@}")
    BUFFER="${EDITOR:-nvim} ${args}"
    zle accept-line
}
zle -N :@edit-file
