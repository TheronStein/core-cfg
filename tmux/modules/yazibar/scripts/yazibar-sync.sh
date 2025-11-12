#!/usr/bin/env bash
# Yazibar - Input Synchronization
# Synchronizes input from left sidebar to right sidebar

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# SYNC STATE (window-scoped)
# ============================================================================

get_sync_option_key() {
    local window_id=$(tmux display-message -p '#{window_id}')
    echo "@yazibar-sync-active-${window_id}"
}

get_sync_watcher_pid_key() {
    local window_id=$(tmux display-message -p '#{window_id}')
    echo "@yazibar-sync-watcher-pid-${window_id}"
}

is_sync_enabled() {
    local key=$(get_sync_option_key)
    [ "$(get_tmux_option "$key" "0")" = "1" ]
}

set_sync_enabled() {
    local key=$(get_sync_option_key)
    set_tmux_option "$key" "$1"
}

# ============================================================================
# INPUT MIRRORING
# ============================================================================

# Enable input synchronization
# This sets up hooks to mirror keystrokes from left to right pane
enable_sync() {
    local left_pane=$(get_left_pane)
    local right_pane=$(get_right_pane)

    if [ -z "$left_pane" ] || [ -z "$right_pane" ]; then
        debug_log "Cannot enable sync: missing panes"
        return 1
    fi

    if ! pane_exists "$left_pane" || ! pane_exists "$right_pane"; then
        debug_log "Cannot enable sync: panes don't exist"
        return 1
    fi

    debug_log "Enabling input sync: $left_pane -> $right_pane"

    # Enable synchronize-panes for these specific panes
    # Note: This is a simple approach, but affects ALL panes in window
    # Better approach: Use a background watcher script

    # Start watcher in background
    "$SCRIPT_DIR/yazibar-sync-watcher.sh" "$left_pane" "$right_pane" &
    local watcher_pid=$!

    # Save watcher PID for cleanup (window-scoped)
    local pid_key=$(get_sync_watcher_pid_key)
    set_tmux_option "$pid_key" "$watcher_pid"

    set_sync_enabled "1"
    debug_log "Sync enabled, watcher PID: $watcher_pid"
}

# Disable input synchronization
disable_sync() {
    if ! is_sync_enabled; then
        debug_log "Sync already disabled"
        return 0
    fi

    debug_log "Disabling input sync"

    # Kill watcher process (window-scoped)
    local pid_key=$(get_sync_watcher_pid_key)
    local watcher_pid=$(get_tmux_option "$pid_key" "")
    if [ -n "$watcher_pid" ]; then
        kill "$watcher_pid" 2>/dev/null
        debug_log "Killed watcher PID: $watcher_pid"
    fi

    clear_tmux_option "$pid_key"
    set_sync_enabled "0"
    debug_log "Sync disabled"
}

# Toggle synchronization
toggle_sync() {
    if is_sync_enabled; then
        disable_sync
        display_info "Input sync disabled"
    else
        enable_sync
        display_info "Input sync enabled"
    fi
}

# ============================================================================
# STATUS
# ============================================================================

sync_status() {
    if is_sync_enabled; then
        echo "enabled"
    else
        echo "disabled"
    fi
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-help}" in
    enable)
        enable_sync
        ;;
    disable)
        disable_sync
        ;;
    toggle)
        toggle_sync
        ;;
    status)
        sync_status
        ;;
    help|*)
        cat <<EOF
Yazibar Input Synchronization

COMMANDS:
  enable                Enable input sync (left -> right)
  disable               Disable input sync
  toggle                Toggle input sync
  status                Show sync status

USAGE:
  $0 enable
  $0 toggle
  $0 status
EOF
        ;;
esac
