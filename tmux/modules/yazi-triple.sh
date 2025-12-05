#!/usr/bin/env bash

SESSION="yazi-triple"

tmux new-session -d -s "$SESSION" \
  "yazi --layout='[0,10,0]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose"

tmux split-window -h -l 15% -t "$SESSION" \
  "yazi --layout='[0,10,0]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose"

tmux split-window -h -l 35% -t "$SESSION" \
  "yazi --layout='[0,0,10]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose"

# Start the main interactive yazi instance in the middle pane
tmux send-keys -t "$SESSION":0.1 \
  "yazi --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" C-m

tmux attach-session -t "$SESSION"
