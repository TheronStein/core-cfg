     STDIN
   1 #!/usr/bin/env bash
   2 # Development workspace
   3 tmux new-session -d -s dev -n editor
   4 tmux split-window -h -p 30
   5 tmux new-window -n terminal
   6 tmux new-window -n logs
   7 tmux select-window -t 1
