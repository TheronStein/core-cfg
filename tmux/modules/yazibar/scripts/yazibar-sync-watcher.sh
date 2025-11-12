#!/usr/bin/env bash
# Yazibar - Sync Watcher
# Background process that mirrors DDS events from left to right yazi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

LEFT_PANE="$1"
RIGHT_PANE="$2"

if [ -z "$LEFT_PANE" ] || [ -z "$RIGHT_PANE" ]; then
    echo "Usage: $0 <left-pane-id> <right-pane-id>"
    exit 1
fi

debug_log "Sync watcher started: $LEFT_PANE -> $RIGHT_PANE"

# ============================================================================
# LOCAL HELPER FUNCTIONS
# ============================================================================

# Get window ID from pane
get_pane_window() {
    local pane_id="$1"
    tmux display-message -p -t "$pane_id" '#{window_id}' 2>/dev/null
}

is_sync_enabled() {
    local window_id=$(get_pane_window "$LEFT_PANE")
    [ -z "$window_id" ] && return 1
    local key="@yazibar-sync-active-${window_id}"
    [ "$(get_tmux_option "$key" "0")" = "1" ]
}

# ============================================================================
# SYNC LOOP
# ============================================================================

last_dir=""
last_file=""

while true; do
    # Check if panes still exist
    if ! pane_exists "$LEFT_PANE" || ! pane_exists "$RIGHT_PANE"; then
        debug_log "Pane disappeared, stopping watcher"
        break
    fi

    # Check if sync is still enabled
    if ! is_sync_enabled; then
        debug_log "Sync disabled, stopping watcher"
        break
    fi

    # Get hovered file from left sidebar (published by yazibar-sync plugin)
    current_file=$(get_tmux_option "@yazibar-hovered" "")

    # Only sync if file changed
    if [ -n "$current_file" ] && [ "$current_file" != "$last_file" ]; then
        debug_log "Syncing to: $current_file"

        # Use reveal to navigate to the file and show its preview
        # This works even with [0, 0, 1] ratio - yazi shows preview of revealed file
        tmux send-keys -t "$RIGHT_PANE" ":reveal '$current_file'" Enter

        last_file="$current_file"
    fi

    # Sleep briefly to avoid busy-waiting
    sleep 0.1
done

debug_log "Sync watcher stopped"
