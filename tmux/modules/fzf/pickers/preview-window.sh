#!/usr/bin/env bash
# Preview script for window picker - FULL COLOR OUTPUT
# Uses capture-pane -ep to preserve terminal colors

line="$1"
# Remove marker (* or space) and extract target (session:index)
target=$(echo "$line" | sed 's/^[* ] //' | awk '{print $1}')

[[ -z "$target" ]] && { echo "No window selected"; exit 1; }

# Get the active pane of the window
active_pane=$(tmux list-panes -t "${target}" -F '#{pane_id} #{pane_active}' 2>/dev/null | awk '$2 == "1" {print $1}')

if [[ -z "${active_pane}" ]]; then
    echo "No active pane found for window ${target}"
    exit 1
fi

# Display the contents of the window's active pane WITH COLOR (-e flag)
tmux capture-pane -ep -t "${active_pane}"
