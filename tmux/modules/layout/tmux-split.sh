#!/bin/bash
tmux new-session -d -s custom_layout
tmux split-window -h -p 70 # Creates left (70%) and right (30%) splits
tmux split-window -h -p 14 # Splits the 70% pane to make 10% left, 60% middle

# Run Yazi in the far left pane (10%)
tmux send-keys -t custom_layout:0.0 'yazi --config-file ~/.config/yazi/left_sidebar.toml' Enter

# Run Neovim/Shell in the middle pane (~60%)
tmux send-keys -t custom_layout:0.1 'nvim' Enter

# Run Yazi in the far right pane (30%)
tmux send-keys -t custom_layout:0.2 'yazi --config-file ~/.config/yazi/right_sidebar.toml' Enter

tmux attach-session -t custom_layout
