#!/usr/bin/env bash
# Window Directory Picker - FZF-based directory selection for new tmux windows
# Opens a new window in the selected directory with window name = directory basename

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

create_window() {
  local dir="$1"

  # Expand ~ back to $HOME
  [[ -n "$home_replacer" ]] && dir=$(echo "$dir" | sed -e "s|^~/|$HOME/|")

  # Get basename for window name, sanitize for tmux
  local window_name
  window_name=$(basename "$dir" | tr ' .:' '_')

  # Add to zoxide for future use
  zoxide add "$dir" &>/dev/null || true

  # Create new window with name and starting directory
  tmux new-window -n "$window_name" -c "$dir"
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
    --border-label "   New Window") || {
    local exit_code=$?
    # Exit code 130 means user cancelled (Ctrl-C/ESC), exit cleanly
    [[ $exit_code -eq 130 ]] && exit 0
    exit $exit_code
  }

  [[ -z "$result" ]] && exit 0

  create_window "$result"
}

main "$@"
