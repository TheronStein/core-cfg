#!/usr/bin/env bash
# Simple test script to verify split layout works

set -euo pipefail

# Check if we're in tmux
if [[ -z "${TMUX:-}" ]]; then
  echo "Error: This script must be run from within tmux" >&2
  exit 1
fi

echo "Creating split layout..."
echo "Left pane: You're here"
echo "Right pane: Preview (40%)"
echo

# Get current pane ID before split
ORIGINAL_PANE=$(tmux display-message -p '#{pane_id}')
echo "Original pane: $ORIGINAL_PANE"

# Split with -d to keep focus here
tmux split-window -h -d -p 40

# Find the new pane
RIGHT_PANE=$(tmux list-panes -F '#{pane_id}' | grep -v "$ORIGINAL_PANE" | head -1)

if [[ -z "$RIGHT_PANE" ]]; then
  echo "ERROR: Could not create split!"
  tmux list-panes
  exit 1
fi

echo "Right pane created: $RIGHT_PANE"
echo
echo "Sending content to right pane..."

# Send content to right pane
tmux send-keys -t "$RIGHT_PANE" "clear" Enter
sleep 0.2
tmux send-keys -t "$RIGHT_PANE" "echo 'This is the PREVIEW PANE'" Enter
tmux send-keys -t "$RIGHT_PANE" "echo 'It should be visible on the right!'" Enter
tmux send-keys -t "$RIGHT_PANE" "echo ''" Enter
tmux send-keys -t "$RIGHT_PANE" "ls --color=always" Enter

echo
echo "✓ Split created successfully!"
echo "You should see two panes side by side now."
echo
echo "Press Enter to clean up (kill right pane)..."
read

tmux kill-pane -t "$RIGHT_PANE"
echo "Cleaned up!"
