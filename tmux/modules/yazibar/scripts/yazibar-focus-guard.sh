#!/usr/bin/env bash
# Yazibar - Focus Guard
# Bounces focus from right sidebar back to left sidebar
# Right sidebar is preview-only, all navigation happens in left

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# Get current context
current_pane="$1"
window_id=$(tmux display-message -p '#{window_id}')

# Get sidebar pane IDs for this window
right_pane=$(get_right_pane)
left_pane=$(get_left_pane)

# If we're focused on right sidebar and left exists, bounce to left
if [ -n "$right_pane" ] && [ "$current_pane" = "$right_pane" ] && [ -n "$left_pane" ]; then
    if pane_exists_globally "$left_pane"; then
        tmux select-pane -t "$left_pane"
    fi
fi
