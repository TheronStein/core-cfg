#!/bin/bash

# Get the current time
timestamp=$(date '+%H:%M:%S')

# Show tmux display message
if tmux has-session 2>/dev/null; then
    tmux display-message "💾 Auto-saved at $timestamp"
fi

# Optional: Also show desktop notification if available
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Tmux Continuum" "Session auto-saved at $timestamp" --icon=dialog-information --expire-time=2000
fi

# Optional: Log to file for debugging
echo "$(date): Tmux session auto-saved" >>~/.tmux/continuum.log
