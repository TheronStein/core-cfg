#!/bin/bash
# Move current window after the next window

current=$(tmux display -p '#{window_index}')
max=$(tmux list-windows | wc -l)
target=$((current + 1))

if [ $target -ge $max ]; then
  tmux display "Cannot move window right - already at last position"
else
  tmux move-window -r -t ":$target"
  tmux display "Moved window to index $(tmux display -p '#{window_index}')"
fi
