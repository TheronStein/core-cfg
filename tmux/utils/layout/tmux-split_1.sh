#!/bin/bash


SESSION="${1:-$(tmux display-message -p '#S')}" # use current session if not given

tmux new-session -d -s custom_layout
tmux split-window -h -p 70 # Creates left (70%) and right (30%) splits
tmux split-window -h -p 14 # Splits the 70% pane to make 10% left, 60% middle

# Run Yazi in the far left pane (10%)
tmux send-keys -t ${tmux display -S session_name} :0.0 'yazi --config-file ~/.config/yazi/left_sidebar.toml' Enter

# 5. Start the LEFT (preview) instance in pane 1 (right pane of the tmux split)
# This instance just listens for commands
tmux send-keys -t yazi_synced_view:0.1 "
    yazi --config-file ~/.config/yazi/left_preview.toml \
         --client-id $LEFT_ID
" Enter


# Run Neovim/Shell in the middle pane (~60%)
tmux send-keys -t custom_layout:0.1 'nvim' Enter

# Run Yazi in the far right pane (30%)
tmux send-keys -t custom_layout:0.2 'yazi --config-file ~/.config/yazi/right_sidebar.toml' Enter

tmux attach-session -t custom_layout


tmux send-keys -t yazi_synced_view:0 "
    yazi --config-file ~/.config/yazi/right_filelist.toml \
         --client-id $RIGHT_ID \
         --local-events=hover,cd \
         | ./sync_yazi.sh $RIGHT_ID $LEFT_ID
" Enter

