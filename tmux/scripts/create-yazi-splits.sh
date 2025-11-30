#!/bin/bash

# Ensure you have 'jq' installed (e.g., sudo apt install jq or brew install jq)

# 1. Define unique IDs for the instances
RIGHT_ID="YAZI_RIGHT_$$"
LEFT_ID="YAZI_LEFT_$$"

# 2. Start a tmux session and create the vertical split
tmux new-session -d -s yazi_synced_view

# 3. Start the RIGHT (file list) instance in pane 0 (left pane of the tmux split)
# We pipe its stdout events into our sync script
tmux send-keys -t yazi_synced_view:0 "
    yazi --config-file ~/.config/yazi/right_filelist.toml \
         --client-id $RIGHT_ID \
         --local-events=hover,cd \
         | ./sync_yazi.sh $RIGHT_ID $LEFT_ID
" Enter

# 4. Create the vertical split (moves the second pane to the right)
tmux split-window -h -t yazi_synced_view:0

# 5. Start the LEFT (preview) instance in pane 1 (right pane of the tmux split)
# This instance just listens for commands
tmux send-keys -t yazi_synced_view:0.1 "
    yazi --config-file ~/.config/yazi/left_preview.toml \
         --client-id $LEFT_ID
" Enter

# 6. Attach to the session
tmux attach-session -t yazi_synced_view
