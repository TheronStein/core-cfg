#!/bin/bash

# Get all windows across all sessions with details
WINDOWS=$(tmux list-windows -a -F "#{session_name}:#{window_index} #{window_name} #{pane_current_path}")

# Check if there are any windows
if [ -z "$WINDOWS" ]; then
    echo "No windows found"
    sleep 2
    exit 1
fi

# Use fzf to select a window with preview
SELECTED=$(echo "$WINDOWS" | fzf \
    --height=100% \
    --layout=reverse \
    --border \
    --preview='
        window_id=$(echo {} | cut -d" " -f1)
        session=$(echo $window_id | cut -d":" -f1)
        index=$(echo $window_id | cut -d":" -f2)
        
        echo "=== Window Preview ==="
        echo "Session: $session"
        echo "Window: #$index"
        echo ""
        echo "=== Panes in this window ==="
        tmux list-panes -t "$session:$index" -F "  Pane #{pane_index}: #{pane_current_command}"
        echo ""
        echo "=== Last 20 lines from active pane ==="
        tmux capture-pane -t "$session:$index" -p -S -20 -E -1 2>/dev/null || echo "Unable to capture pane content"
    ' \
    --preview-window=right:60% \
    --header="Select window to switch to (ESC to cancel)" \
    --prompt="Window> " \
    --bind="esc:cancel")

# If a window was selected, switch to it
if [ -n "$SELECTED" ]; then
    WINDOW_ID=$(echo "$SELECTED" | cut -d' ' -f1)
    tmux switch-client -t "$WINDOW_ID"
fi
