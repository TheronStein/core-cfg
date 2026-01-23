#!/usr/bin/env bash
# Generate complete tmux status-left with dynamic context and mode colors
# Format: [CONTEXT] > [MODE] > SESSION_NAME
# Mode segment only appears when a tmux mode is active

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get current context and mode (format: "ICON CONTEXT:color|MODE:color")
full_info=$(bash "$SCRIPT_DIR/modes/get-tmux-mode.sh")

# Split into context and mode portions
context_part="${full_info%%|*}"
mode_part="${full_info#*|}"

# Parse context (always present)
context_label="${context_part%:*}"
context_color="${context_part##*:}"

# Parse mode (may be empty)
if [ -n "$mode_part" ]; then
  mode_label="${mode_part%:*}"
  mode_color="${mode_part##*:}"
else
  mode_label=""
  mode_color=""
fi
# Color lookup function
get_bg_color() {
  case "$1" in
    red) echo "#FF5370" ;;    # Red for LEADER/SYNC
    yellow) echo "#f1fa8c" ;; # Yellow for copy mode
    orange) echo "#e0af68" ;; # Orange for resize
    tmux) echo "#18BA18" ;;   # Green for TMUX context
    neovim) echo "#1075B5" ;; # Blue for NEOVIM context
    purple) echo "#8470FF" ;; # Purple for WEZTERM context (archived)
    *) echo "#2ac3de" ;;      # Default purple
  esac
}

context_bg=$(get_bg_color "$context_color")

# Get session name from argument (passed by tmux format expansion) or fallback
default_session='#{session_name}'
raw_session="${1:-$default_session}"
session_name=$(echo " $raw_session " | sed 's/-view-.*//')

# Powerline divider character
# NOTE DO NOT TOUCH THIS! YOU CANT INPUT THESE SPECIAL CHARACTERS, I HAVE TO FIX IT EVERY TIME.
divider=""
# NOTE DO NOT TOUCH THIS! YOU CANT INPUT THESE SPECIAL CHARACTERS, I HAVE TO FIX IT EVERY TIME.
session_bg="#444267"

# Build the status-left: Context > [Mode] > Session
# Context segment (always shown) - with leading space for padding from edge
output="#[bold,fg=#292D3E,bg=${context_bg}] ${context_label}  "

# Mode segment (only when active)
if [ -n "$mode_label" ]; then
  mode_bg=$(get_bg_color "$mode_color")
  # Divider: context → mode
  output+="#[fg=${context_bg},bg=${mode_bg}]${divider}"
  output+="#[bold,fg=#292D3E,bg=${mode_bg}] ${mode_label} "
  # Divider: mode → session
  output+="#[fg=${mode_bg},bg=${session_bg}]${divider}"
else
  # Divider: context → session (no mode)
  output+="#[fg=${context_bg},bg=${session_bg}]${divider}"
fi

# Session segment
output+="#[bold,fg=${context_bg},bg=${session_bg}] ${session_name^} "
# Final divider: session → status bar background
output+="#[fg=${session_bg},bg=#292D3E]${divider}"

echo "$output"
