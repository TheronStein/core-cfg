#!/usr/bin/env bash

NOTES_SESSION="notes"
WINDOW_NUMBER="$1"

if ! tmux has-session -t "$NOTES_SESSION" 2>/dev/null; then
    echo "Notes session doesn't exist"
    sleep 2
    exit 1
fi

# Check if window exists
if ! tmux list-windows -t "$NOTES_SESSION" -F "#{window_index}" | grep -q "^$((WINDOW_NUMBER - 1))$"; then
    echo "Window $WINDOW_NUMBER doesn't exist in notes session"
    sleep 2
    exit 1
fi

# Attach to the specific window in a new tmux session within the popup
exec tmux new-session -A -s "popup-notes" \; \
    link-window -s "$NOTES_SESSION:$WINDOW_NUMBER" -t "popup-notes:1" \; \
    kill-window -t "popup-notes:0" \; \
    set-option -t "popup-notes" status off \; \
    attach-session -t "popup-notes"
