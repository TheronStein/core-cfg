#!/usr/bin/env bash

# Popup Window Handler for Notes
# Opens neovim in the notes directory
# Auto-closes after 10 minutes of inactivity

SESSION="apps"
WINDOW_NAME="notes"
NOTES_DIR="$HOME/.core/docs/doc"
INACTIVITY_TIMEOUT=600 # 10 minutes in seconds

CURRENT_SESSION=$(tmux display-message -p '#{session_name}')

# Create apps session if it doesn't exist
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -n "$WINDOW_NAME"
  tmux set-option -t "$SESSION" status off
fi

# Check if notes window already exists
t_window=$(tmux list-windows -t "$SESSION" -F "#{window_index} #{window_name}" 2>/dev/null \
  | grep " $WINDOW_NAME$" | head -n 1 | awk '{print $1}')

if [ -z "$t_window" ]; then
  # Window doesn't exist, create it
  next_window=$(tmux list-windows -t "$SESSION" -F "#{window_index}" 2>/dev/null | sort -n | tail -1)
  next_window=$((next_window + 1))

  tmux new-window -t "$SESSION:$next_window" -n "$WINDOW_NAME" -c "$NOTES_DIR"
  tmux set-option -t "$SESSION" status off

  # Launch neovim with auto-close after 10 minutes of inactivity
  tmux send-keys -t "$SESSION:$next_window" "nvim \
    -c 'let g:last_activity = localtime()' \
    -c 'autocmd CursorMoved,CursorMovedI,InsertEnter * let g:last_activity = localtime()' \
    -c 'autocmd CursorHold,CursorHoldI * if (localtime() - g:last_activity) >= ${INACTIVITY_TIMEOUT} | qall! | endif' \
    -c 'set updatetime=10000'" C-m

  sleep 0.5
  target_window=$next_window
else
  # Window exists, reuse it
  target_window=$t_window
fi

# If we're already in the apps session, just switch windows
if [ "$CURRENT_SESSION" = "$SESSION" ]; then
  tmux select-window -t "$SESSION:$target_window"
else
  # Open popup
  tmux display-popup -E -w 90% -h 90% -x C -y C \
    -T " Notes " -b rounded -S "fg=#89b4fa,bg=#1e1e2e" \
    "tmux attach-session -t $SESSION:$target_window"
fi
