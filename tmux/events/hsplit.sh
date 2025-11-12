#!/bin/bash
# Horizontal split (top/bottom)

if tmux display-message -p '#{session_name}' | grep -q 'floating'; then
    # In floating session - join back to last session
    tmux set -uw pane-border-status
    ~/.core/env/bin/fzf-panes.tmux update_mru_pane_ids
    last_session=$(tmux show -gvq '@last_session_name')
    tmux joinp -v -s floating -t "${last_session}:"
else
    # Normal horizontal split
    tmux splitw -v -c "#{pane_current_path}"
fi
