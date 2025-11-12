#!/usr/bin/env bash

NOTES_SESSION="notes"

# Check if notes session exists
if ! tmux has-session -t "$NOTES_SESSION" 2>/dev/null; then
    echo "Notes session doesn't exist"
    exit 1
fi

echo -n "Enter new session name: "
read -r new_name

if [ -z "$new_name" ]; then
    echo "No name provided"
    exit 1
fi

# Rename the session
tmux rename-session -t "$NOTES_SESSION" "$new_name"
echo "Session renamed to: $new_name"
