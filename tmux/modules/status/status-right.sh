#!/usr/bin/env bash
# Generate tmux status-right with conditional Claude indicator
# Claude usage only shows on AI workspace

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get server name to check if we're on AI workspace
server_name=$(tmux show-environment -g TMUX_SERVER_NAME 2>/dev/null | cut -d= -f2)

# Colors
STATUS_BG_COLOR="#292D3E"
TAB_BG_COLOR="#313244"

# Build right side output
output=""

# Claude usage - only on AI workspace
if [ "$server_name" = "ai" ]; then
  claude_output=$(bash "$SCRIPT_DIR/claude/claude-usage.sh" display)
  output+="${claude_output}"
fi

# Date/time segment
output+="#[fg=#987aff,bg=#444267] %I:%M %p "

# GitHub user
output+="#{tmux_gh_uname}"

echo "$output"
