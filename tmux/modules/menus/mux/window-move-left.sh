#!/bin/bash
# Move current window before the previous window

current=$(tmux display -p '#{window_index}')
target=$((current - 1))

if [ $target -lt 0 ]; then
  tmux display "Cannot move window left - already at first position"
else
  tmux move-window -r -t ":$target"
  tmux display "Moved window to index $(tmux display -p '#{window_index}')"
fi
