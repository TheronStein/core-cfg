#!/usr/bin/env bash
# Renumber panes in the current window to be sequential starting from 1

# Get the current window's panes sorted by their index
pane_ids=$(tmux list-panes -F "#{pane_index} #{pane_id}" | sort -n | awk '{print $2}')

# Counter for new pane numbers
counter=0

# Swap panes to renumber them sequentially
for pane_id in $pane_ids; do
    current_index=$(tmux display-message -p -t "$pane_id" "#{pane_index}")

    if [ "$current_index" != "$counter" ]; then
        # Swap the pane at position counter with this pane
        tmux swap-pane -s "$pane_id" -t "$counter" 2>/dev/null || true
    fi

    counter=$((counter + 1))
done
