#!/usr/bin/env bash
# tmux-fzf-move-window

# 1) get the current session name
current_sess=$(tmux display-message -p '#{session_name}')

# 2) list all windows (session:idx:name), let fzf pick one
#    fzf returns lines like "sess:1:editor"
selection=$(tmux list-windows -a -F "#{session_name}:#{window_index}:#{window_name}" \
  | fzf --prompt="Move window into [$current_sess] → " \
    --border \
    --height=40% \
  ) || exit 0

# 3) extract session:idx
src=$(printf '%s' "$selection" | cut -d: -f1,2)

# 4) move it into the current session (appended as new window)
tmux move-window -s "$src" -t "$current_sess"
