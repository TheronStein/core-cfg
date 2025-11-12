#!/bin/bash

# Get current window info
CURRENT_WINDOW=$(tmux display-message -p '#S:#I')
CURRENT_SESSION=$(echo "$CURRENT_WINDOW" | cut -d':' -f1)

# Get all sessions except current one
SESSIONS=$(tmux list-sessions -F "#{session_name} (#{session_windows} windows) #{session_attached}" | grep -v "^$CURRENT_SESSION ")

# Use fzf to select target session
SELECTED=$(echo "$SESSIONS" | fzf \
    --height=60% \
    --layout=reverse \
    --border \
    --preview='
        session=$(echo {} | cut -d" " -f1)
        echo "=== Session: $session ==="
        echo ""
        echo "Windows in this session:"
        tmux list-windows -t "$session" -F "  #{window_index}: #{window_name} (#{window_panes} panes)"
        echo ""
        echo "Current window will be moved here as the last window"
    ' \
    --preview-window=right:50% \
    --header="Select target session for current window" \
    --prompt="Target Session> ")

# If a session was selected, move the window
if [ -n "$SELECTED" ]; then
    TARGET_SESSION=$(echo "$SELECTED" | cut -d' ' -f1)

    # Move window to target session
    tmux move-window -t "$TARGET_SESSION:"

    # Switch to the moved window in its new session
    # tmux switch-client -t "$TARGET_SESSION"

    # Display confirmation
    tmux display-message "Window moved to session: $TARGET_SESSION"
fi
