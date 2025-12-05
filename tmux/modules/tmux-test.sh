tmux new-session -d -s y3 \
  "yazi --layout='[0,10,0]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" \; \
  split-window -h -l 15% \; \
  split-window -h -l 35% "yazi --layout='[0,0,10]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" \; \
  send-keys "yazi --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" C-m \; \
  attach-session -t y3
