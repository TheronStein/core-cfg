#!/usr/bin/env bash
# Renumber panes in the current window to be sequential starting from 1
# FIXED VERSION: Excludes locked (sidebar) panes from renumbering to prevent position disruption

# Get locked panes from layout-manager
get_locked_pane_ids() {
    tmux show-option -qv "@locked-panes" | tr ',' '\n' | cut -d: -f1 | sort -u
}

# Check if a pane is locked
is_pane_locked() {
    local pane_id="$1"
    local locked_panes
    locked_panes=$(get_locked_pane_ids)
    echo "$locked_panes" | grep -q "^${pane_id}$"
}

# Get the current window's panes sorted by their position (left to right, top to bottom)
# This uses pane_left and pane_top to determine visual order
pane_info=$(tmux list-panes -F "#{pane_left} #{pane_top} #{pane_index} #{pane_id}" | sort -n -k1,1 -k2,2)

# Build list of unlocked panes only (for renumbering)
unlocked_panes=""
while IFS= read -r line; do
    [ -z "$line" ] && continue
    pane_id=$(echo "$line" | awk '{print $4}')

    if ! is_pane_locked "$pane_id"; then
        unlocked_panes="${unlocked_panes}${line}"$'\n'
    fi
done <<< "$pane_info"

# Only renumber if we have unlocked panes to work with
if [ -z "$unlocked_panes" ]; then
    exit 0
fi

# Counter for new pane numbers
# Note: We only renumber unlocked panes to maintain their relative order
# Locked panes (sidebars) stay in their positions
counter=0
while IFS= read -r line; do
    [ -z "$line" ] && continue

    pane_id=$(echo "$line" | awk '{print $4}')
    current_index=$(echo "$line" | awk '{print $3}')

    # Skip if pane doesn't exist anymore
    if ! tmux list-panes -F "#{pane_id}" 2>/dev/null | grep -q "^${pane_id}$"; then
        continue
    fi

    # Only swap if the index needs to change
    if [ "$current_index" != "$counter" ]; then
        # Check that target position exists and is also unlocked
        target_pane=$(tmux list-panes -F "#{pane_index} #{pane_id}" | awk -v idx="$counter" '$1 == idx {print $2}')

        if [ -n "$target_pane" ] && ! is_pane_locked "$target_pane"; then
            tmux swap-pane -s "$pane_id" -t "$counter" 2>/dev/null || true
        fi
    fi

    counter=$((counter + 1))
done <<< "$unlocked_panes"
