#!/usr/bin/env bash
# Generate complete tmux status-left with workspace, session, and optional mode
# Format: [WORKSPACE] > [SESSION] > [MODE if active]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get workspace display name
workspace_display=$(tmux show-environment -g TMUX_WORKSPACE_DISPLAY 2>/dev/null | cut -d= -f2)
server_name=$(tmux show-environment -g TMUX_SERVER_NAME 2>/dev/null | cut -d= -f2)
workspace="${workspace_display:-${server_name:-default}}"

# Get mode info from existing script (only need the mode portion)
full_info=$(bash "$SCRIPT_DIR/modes/get-tmux-mode.sh")
mode_part="${full_info#*|}"

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
    *) echo "#2ac3de" ;;      # Default
  esac
}

# Get session name from argument (passed by tmux format expansion) or fallback
default_session='#{session_name}'
raw_session="${1:-$default_session}"
session_name=$(echo "$raw_session" | sed 's/-view-.*//')

# Powerline divider character
# NOTE: DO NOT TOUCH THIS! Special character that must be preserved.
divider=""

# Colors
workspace_bg="#7F38EC"  # Purple for workspace
workspace_fg="#FFFFFF"  # White text
session_bg="#444267"    # Session background
status_bg="#292D3E"     # Main status bar background

# Build the status-left: Workspace > Session > [Mode]
# Workspace segment
output="#[bold,fg=${workspace_fg},bg=${workspace_bg}] ${workspace} "
output+="#[fg=${workspace_bg},bg=${session_bg}]${divider}"

# Session segment
output+="#[bold,fg=#cdd6f4,bg=${session_bg}] ${session_name^} "

# Mode segment (only when active)
if [ -n "$mode_label" ]; then
  mode_bg=$(get_bg_color "$mode_color")
  # Divider: session → mode
  output+="#[fg=${session_bg},bg=${mode_bg}]${divider}"
  output+="#[bold,fg=#292D3E,bg=${mode_bg}] ${mode_label} "
  # Final divider: mode → status bar
  output+="#[fg=${mode_bg},bg=${status_bg}]${divider}"
else
  # Final divider: session → status bar
  output+="#[fg=${session_bg},bg=${status_bg}]${divider}"
fi

echo "$output"
