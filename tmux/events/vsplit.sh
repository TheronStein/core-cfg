#!/bin/bash
# Vertical split (left/right)

if tmux display-message -p '#{session_name}' | grep -q 'floating'; then
    # In floating session - join back to last session
    tmux set -uw pane-border-status
    ~/.core/env/bin/fzf-panes.tmux update_mru_pane_ids
    last_session=$(tmux show -gvq '@last_session_name')
    tmux joinp -h -s floating -t "${last_session}:"
else
    # Normal vertical split
    tmux splitw -h -c "#{pane_current_path}"
fi
