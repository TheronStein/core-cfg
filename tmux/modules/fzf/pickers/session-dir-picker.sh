#!/usr/bin/env bash
# Session Directory Picker - FZF-based directory selection for new tmux sessions
# Opens a new session in the selected directory with session name = directory basename

set -euo pipefail

# Source FZF configuration
source ~/.core/.cortex/lib/fzf-config.sh

# Configuration
readonly DEFAULT_FIND_PATH="$HOME/.core"
readonly MAX_DEPTH=3

# Preview script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Home path replacement for display
home_replacer=""
[[ "$HOME" =~ ^[a-zA-Z0-9_/.@-]+$ ]] && home_replacer="s|^$HOME/|~/|"

# FZF bindings for switching modes
zoxide_bind="ctrl-j:change-prompt(  )+reload(zoxide query -l | sed -e \"$home_replacer\")"
find_bind="ctrl-f:change-prompt(  )+reload(fd -H -d $MAX_DEPTH -t d . $DEFAULT_FIND_PATH | sed 's|/$||' | sed -e \"$home_replacer\")"

get_directories() {
  # Start with zoxide results (most relevant)
  zoxide query -l 2>/dev/null | sed -e "$home_replacer"
}

create_session() {
  local dir="$1"

  # Expand ~ back to $HOME
  [[ -n "$home_replacer" ]] && dir=$(echo "$dir" | sed -e "s|^~/|$HOME/|")

  # Get basename for session name, sanitize for tmux
  local session_name
  session_name=$(basename "$dir" | tr ' .:' '_')

  # Check if session already exists
  if tmux has-session -t "$session_name" 2>/dev/null; then
    # Session exists, switch to it
    tmux switch-client -t "$session_name"
    tmux display-message "Switched to existing session: $session_name"
    return 0
  fi

  # Add to zoxide for future use
  zoxide add "$dir" &>/dev/null || true

  # Create new session with name and starting directory
  # Use -d to create detached, then switch to it
  tmux new-session -d -s "$session_name" -c "$dir"
  tmux switch-client -t "$session_name"
}

main() {
  local result

  result=$(get_directories | fzf-tmux -p 90%,90% \
    --prompt "  " \
    --header "$FZF_HEADER_DIR" \
    --preview "$SCRIPT_DIR/preview-dir.sh {}" \
    --preview-window "right:70%:wrap" \
    --color="$(fzf::colors)" \
    --bind "$zoxide_bind" \
    --bind "$find_bind" \
    --bind "ctrl-/:toggle-preview" \
    --bind "tab:down,btab:up" \
    --no-sort \
    --cycle \
    --delimiter='/' \
    --with-nth="-2,-1" \
    --keep-right \
    --border-label "   New Session") || {
    local exit_code=$?
    # Exit code 130 means user cancelled (Ctrl-C/ESC), exit cleanly
    [[ $exit_code -eq 130 ]] && exit 0
    exit $exit_code
  }

  [[ -z "$result" ]] && exit 0

  create_session "$result"
}

main "$@"
