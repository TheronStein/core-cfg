#!/usr/bin/env bash
# ~/.core/cfg/tmux/conf/scripts/tmux-switch-pane.switch-client

# List all panes as session:target:title
#   $1 = session_name
#   $2 = window_index.pane_index
#   $3 = pane_title
tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}:#{pane_title}" |
    awk -F: '
    # color session (field1) yellow, title (field3) cyan, then tab+target for action
    { printf "\033[33m%s\033[0m \033[36m%s\033[0m\t%s:%s\n",
        $1, $3, $1, $2
    }
  ' |
    fzf --ansi \
        --delimiter=$'\t' \
        --with-nth=1,2 \
        --height=40% \
        --width=60% \
        --layout=reverse \
        --color=hl:2 |
    cut -f2 |
    xargs -r tmux select-pane -t
