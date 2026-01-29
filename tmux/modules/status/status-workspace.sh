#!/usr/bin/env bash
# Generate workspace segment for tmux status bar
# Uses TMUX_WORKSPACE_DISPLAY or falls back to TMUX_SERVER_NAME
# Output: Powerline-styled segment with workspace name

# Get workspace display name
workspace_display=$(tmux show-environment -g TMUX_WORKSPACE_DISPLAY 2>/dev/null | cut -d= -f2)
server_name=$(tmux show-environment -g TMUX_SERVER_NAME 2>/dev/null | cut -d= -f2)

# Use display name if set, otherwise server name, otherwise "default"
workspace="${workspace_display:-${server_name:-default}}"

# Powerline divider
# NOTE: DO NOT TOUCH THIS! Special character that must be preserved.
divider=""

# Colors
workspace_bg="#7F38EC"  # Purple for workspace
workspace_fg="#FFFFFF"  # White text
session_bg="#444267"    # Session background (next segment)

# Build the segment
output="#[bold,fg=${workspace_fg},bg=${workspace_bg}] ${workspace} "
output+="#[fg=${workspace_bg},bg=${session_bg}]${divider}"

echo "$output"
