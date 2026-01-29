#!/usr/bin/env bash
# Generate context segment for bottom status bar
# Shows TMUX or NEOVIM context indicator

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get context from the existing mode detection script
full_info=$(bash "$SCRIPT_DIR/modes/get-tmux-mode.sh")
context_part="${full_info%%|*}"

# Parse context
context_label="${context_part%:*}"
context_color="${context_part##*:}"

# Color lookup
get_bg_color() {
  case "$1" in
    tmux) echo "#18BA18" ;;   # Green for TMUX
    neovim) echo "#1075B5" ;; # Blue for NEOVIM
    *) echo "#2ac3de" ;;      # Default cyan
  esac
}

context_bg=$(get_bg_color "$context_color")

# Powerline divider
# NOTE: DO NOT TOUCH THIS! Special character that must be preserved.
divider=""
status_bg="#292D3E"

# Build the segment
output="#[bold,fg=#292D3E,bg=${context_bg}] ${context_label} "
output+="#[fg=${context_bg},bg=${status_bg}]${divider}"

echo "$output"
