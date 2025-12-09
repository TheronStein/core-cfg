#!/bin/bash
REQUEST=$1
USE_FZF_PANES=true
VERTICAL_SPLIT="h"
HORIZONTAL_SPLIT="v"

if [ "$REQUEST" = "v" ]; then
  REQUEST=$VERTICAL_SPLIT
elif [ "$REQUEST" = "h" ]; then
  REQUEST=$HORIZONTAL_SPLIT
fi

split_pane() {
  local split_command=$1

  if [ "$USE_FZF_PANES" = true ]; then
    if tmux display-message -p '#{session_name}' | grep -q 'floating'; then
      # In floating session - join back to last session
      tmux set -uw pane-border-status
      ~/.core/env/bin/fzf-panes.tmux update_mru_pane_ids
      last_session=$(tmux show -gvq '@last_session_name')
      tmux joinp -${split_command} -s floating -t "${last_session}:"
    else
      # Normal split
      tmux splitw -${split_command} -c "#{pane_current_path}"
    fi
  else
    # Normal split without fzf-panes
    tmux splitw -${split_command} -c "#{pane_current_path}"
  fi
}

split_pane "$REQUEST"
