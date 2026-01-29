#!/usr/bin/env bash
# Split Directory Picker - FZF-based directory selection for pane splits
# Location: ~/.tmux/modules/fzf/pickers/split-dir-picker.sh
# Usage: split-dir-picker.sh [--direction=h|v]
#
# Opens a new pane split in the selected directory
# On cancel (ESC/Ctrl-C) or empty selection: falls back to CWD split

set -euo pipefail

# Source FZF configuration
source ~/.core/.cortex/lib/fzf-config.sh

# Configuration
readonly DEFAULT_FIND_PATH="$HOME/.core"
readonly MAX_DEPTH=3

# Preview script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse direction argument (default: h for horizontal/right split)
DIRECTION="h"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --direction=*) DIRECTION="${1#*=}"; shift ;;
        -d) DIRECTION="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Validate direction
[[ "$DIRECTION" != "h" && "$DIRECTION" != "v" ]] && DIRECTION="h"

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

create_split() {
  local dir="$1"

  # Expand ~ back to $HOME
  [[ -n "$home_replacer" ]] && dir=$(echo "$dir" | sed -e "s|^~/|$HOME/|")

  # Add to zoxide for future use
  zoxide add "$dir" &>/dev/null || true

  # Create split pane in the selected directory
  # -h = horizontal split (pane to right), -v = vertical split (pane below)
  tmux split-window -${DIRECTION} -c "$dir"
}

fallback_split() {
  # Get current pane path and split there
  local current_path
  current_path=$(tmux display-message -p '#{pane_current_path}')
  tmux split-window -${DIRECTION} -c "$current_path"
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
    --border-label "   Split Pane") || {
    local exit_code=$?
    # Exit code 130 means user cancelled (Ctrl-C/ESC)
    # Fall back to CWD split
    if [[ $exit_code -eq 130 ]]; then
        fallback_split
        exit 0
    fi
    exit $exit_code
  }

  # Empty result = no selection, fall back to CWD
  if [[ -z "$result" ]]; then
    fallback_split
    exit 0
  fi

  create_split "$result"
}

main "$@"
