#!/usr/bin/env bash
# Yazi preview pane - synchronized with left sidebar
# Shows file/directory previews: directories as native lists, files as syntax-highlighted content

# Use the yazi-sidebar-right config (current + preview columns)
export YAZI_CONFIG_HOME="${YAZI_CONFIG_HOME:-$CORE_CFG/yazi}/profiles/sidebar-right"

# Set yazibar side for sync
export YAZIBAR_SIDE="right"

# Get sidebar pane for syncing
SIDEBAR_PANE=$(tmux show-option -qv "@yazi-sidebar-pane-id")
CURRENT_PANE="$TMUX_PANE"

START_DIR="${1:-$PWD}"

# Start sync watcher in background if sidebar exists
if [ -n "$SIDEBAR_PANE" ] && tmux list-panes -F "#{pane_id}" | grep -q "^${SIDEBAR_PANE}$"; then
    # Launch sync watcher detached (survives exec)
    nohup "$TMUX_MODULES/yazibar/scripts/yazibar-sync-watcher.sh" "$SIDEBAR_PANE" "$CURRENT_PANE" >/dev/null 2>&1 &
    WATCHER_PID=$!

    # Save watcher PID for cleanup
    tmux set -g "@yazibar-sync-watcher-pid" "$WATCHER_PID"
    tmux set -g "@yazibar-sync-active" "1"

    # Give it a moment to start
    sleep 0.1
fi

# Run yazi with current + preview columns
# It will be synced with left sidebar navigation
exec yazi "$START_DIR"
