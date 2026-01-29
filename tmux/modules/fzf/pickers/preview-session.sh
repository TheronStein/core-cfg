#!/usr/bin/env bash
# Preview script for session picker - FULL COLOR OUTPUT
# Uses capture-pane -ep to preserve terminal colors

line="$1"
# Remove marker (* or space) and extract session name (first word)
session_name=$(echo "$line" | sed 's/^[* ] //' | awk '{print $1}')

[[ -z "$session_name" ]] && { echo "No session selected"; exit 1; }

# Get the active pane of the session
active_pane=$(tmux list-panes -t "${session_name}" -F '#{pane_id} #{pane_active}' 2>/dev/null | awk '$2 == "1" {print $1}')

if [[ -z "${active_pane}" ]]; then
    echo "No active pane found for session ${session_name}"
    exit 1
fi

# Display the contents of the session's active pane WITH COLOR (-e flag)
tmux capture-pane -ep -t "${active_pane}"
