#!/usr/bin/env bash
# Yazibar - Sync State Manager
#
# Manages sidebar synchronization using Yazi's --local-events feature.
# When enabled, this restarts the left sidebar with event streaming to
# a handler that sends reveal commands to the right sidebar.
#
# Architecture:
#   Left Yazi (--local-events=hover,cd) -> fifo -> DDS Handler -> Right Yazi (reveal)

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
# SYNC CONTROL (local-events based)
# ============================================================================

# Enable synchronization by restarting left yazi with event streaming
enable_sync() {
    local left_pane=$(get_left_pane)
    local right_pane=$(get_right_pane)

    if [ -z "$left_pane" ] || [ -z "$right_pane" ]; then
        debug_log "Cannot enable sync: missing panes (left=$left_pane, right=$right_pane)"
        display_error "Both sidebars must be active to enable sync"
        return 1
    fi

    if ! pane_exists_globally "$left_pane" || ! pane_exists_globally "$right_pane"; then
        debug_log "Cannot enable sync: panes don't exist"
        display_error "Sidebar panes not found"
        return 1
    fi

    debug_log "Enabling sync: left=$left_pane -> right=$right_pane"

    # Set sync state first
    set_sync_enabled "1"

    # Get the left sidebar's current directory before restart
    local left_dir=$(tmux display-message -p -t "$left_pane" '#{pane_current_path}' 2>/dev/null)
    left_dir="${left_dir:-$HOME}"

    # The left sidebar will automatically detect the right pane and start
    # the DDS handler on next restart. Send SIGHUP to trigger yazi restart.
    # Actually, we need to fully restart yazi in left pane for it to pick up
    # the new right pane ID.

    debug_log "Restarting left sidebar yazi for sync..."

    # Send quit command to left yazi
    tmux send-keys -t "$left_pane" "q" 2>/dev/null

    # Brief pause for yazi to exit
    sleep 0.3

    # Restart yazi with the run script (which will now see the right pane)
    tmux send-keys -t "$left_pane" "'$SCRIPT_DIR/yazibar-run-yazi.sh' left '$left_dir'" Enter 2>/dev/null

    display_info "Sync enabled - left sidebar restarted with event streaming"
}

# Disable synchronization
disable_sync() {
    debug_log "Disabling sync"
    set_sync_enabled "0"

    # Kill any running DDS handler
    local window_id=$(tmux display-message -p '#{window_id}')
    local handler_pid=$(get_tmux_option "@yazibar-dds-handler-pid-${window_id}" "")
    if [ -n "$handler_pid" ]; then
        kill "$handler_pid" 2>/dev/null
        clear_tmux_option "@yazibar-dds-handler-pid-${window_id}"
        debug_log "Killed DDS handler PID: $handler_pid"
    fi

    # Clean up fifo
    local left_pane=$(get_left_pane)
    local fifo="/tmp/yazibar_events_${left_pane//\%/}"
    rm -f "$fifo"

    display_info "Sync disabled"
}

# Toggle synchronization
toggle_sync() {
    if is_sync_enabled; then
        disable_sync
    else
        enable_sync
    fi
}

# ============================================================================
# STATUS
# ============================================================================

sync_status() {
    local window_id=$(tmux display-message -p '#{window_id}')
    local handler_pid=$(get_tmux_option "@yazibar-dds-handler-pid-${window_id}" "")
    local left_pane=$(get_left_pane)
    local fifo="/tmp/yazibar_events_${left_pane//\%/}"

    echo "=== Yazibar Sync Status ==="
    echo ""
    echo "Sync State: $(is_sync_enabled && echo "ENABLED" || echo "DISABLED")"
    echo ""
    echo "DDS Handler PID: ${handler_pid:-(not running)}"
    echo "Event FIFO: $fifo ($([ -p "$fifo" ] && echo "exists" || echo "not found"))"
    echo ""
    echo "Last Hovered: $(get_tmux_option "@yazibar-hovered" "(none)")"
    echo "Current Dir:  $(get_tmux_option "@yazibar-current-dir" "(none)")"
    echo ""
    echo "Pane IDs:"
    echo "  Left:  $(get_left_pane || echo "(none)")"
    echo "  Right: $(get_right_pane || echo "(none)")"

    # Check if handler process is actually running
    if [ -n "$handler_pid" ]; then
        if kill -0 "$handler_pid" 2>/dev/null; then
            echo ""
            echo "Handler process: RUNNING"
        else
            echo ""
            echo "Handler process: DEAD (stale PID)"
        fi
    fi
}

# Test sync by manually sending a reveal command
test_sync() {
    local right_pane=$(get_right_pane)
    local test_path="${1:-/tmp}"

    if [ -z "$right_pane" ]; then
        display_error "Right sidebar not found"
        return 1
    fi

    echo "Testing sync to right pane: $right_pane"
    echo "Sending reveal command for: $test_path"

    tmux send-keys -t "$right_pane" ":reveal '$test_path'" Enter 2>/dev/null

    if [ $? -eq 0 ]; then
        display_info "Test command sent successfully"
    else
        display_error "Test command failed"
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
    test)
        test_sync "$2"
        ;;
    help|*)
        cat <<EOF
Yazibar Sync Manager

COMMANDS:
  enable           Enable hover sync between sidebars
  disable          Disable hover sync
  toggle           Toggle sync state
  status           Show detailed sync status
  test [path]      Test sync by sending reveal command

HOW IT WORKS:
  When sync is enabled, the left sidebar yazi is restarted with
  --local-events=hover,cd. Events are piped to a DDS handler script
  which sends reveal commands to the right sidebar via tmux send-keys.

  Event flow:
    Left Yazi -> fifo -> DDS Handler -> tmux send-keys -> Right Yazi

TROUBLESHOOTING:
  1. Both sidebars must be open for sync to work
  2. Check status with: $0 status
  3. Test manually: $0 test /home/user
  4. Enable debug: tmux set -g @yazibar-debug 1

USAGE:
  $0 enable
  $0 toggle
  $0 status
  $0 test /home/user
EOF
        ;;
esac
