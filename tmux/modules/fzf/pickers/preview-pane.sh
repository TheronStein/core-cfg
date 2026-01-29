#!/usr/bin/env bash
# Preview script for pane picker - FULL COLOR OUTPUT
# Uses capture-pane -ep to preserve terminal colors

line="$1"
# Remove marker (* or space) and extract target (session:window.pane)
target=$(echo "$line" | sed 's/^[* ] //' | awk '{print $1}')

[[ -z "$target" ]] && { echo "No pane selected"; exit 1; }

# Display the contents of the pane WITH COLOR (-e flag)
tmux capture-pane -ep -t "${target}"
