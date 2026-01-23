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

# Enable synchronization by recreating left sidebar with event streaming
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

    # Get the left sidebar's current directory before recreation
    local left_dir=$(tmux display-message -p -t "$left_pane" '#{pane_current_path}' 2>/dev/null)
    left_dir="${left_dir:-$HOME}"

    # CRITICAL FIX: We cannot restart yazi in-place because:
    # 1. Left sidebar was started without sync (right pane didn't exist yet)
    # 2. Yazi was exec'd, so quitting it closes the pane entirely
    # 3. Trying to send commands to a closed pane fails silently
    #
    # Solution: Destroy and recreate the left sidebar pane
    # Now that right pane exists, the new left sidebar will have sync enabled

    debug_log "Recreating left sidebar for sync (destroy then create)..."

    # Store current pane to return focus after recreation
    local current_pane=$(get_current_pane)

    # Temporarily disable right-needs-left so destroying left doesn't destroy right
    local orig_needs_left=$(get_tmux_option "@yazibar-right-needs-left" "1")
    set_tmux_option "@yazibar-right-needs-left" "0"

    # Destroy old left sidebar (this kills yazi and clears state)
    "$SCRIPT_DIR/yazibar-left.sh" disable

    # Restore right-needs-left setting
    set_tmux_option "@yazibar-right-needs-left" "$orig_needs_left"

    # Small delay to ensure pane is fully destroyed
    sleep 0.3

    # Recreate left sidebar - yazibar-run-yazi.sh will now see right pane exists
    # and automatically enable DDS event streaming
    "$SCRIPT_DIR/yazibar-left.sh" enable "$left_dir"

    # Wait for yazi to fully initialize
    sleep 0.5

    # Verify yazi is running with sync
    left_pane=$(get_left_pane)
    if [ -n "$left_pane" ]; then
        local cmd=$(tmux display-message -p -t "$left_pane" '#{pane_current_command}' 2>/dev/null)
        if [ "$cmd" = "yazi" ]; then
            debug_log "Left sidebar recreated with sync enabled"
        else
            debug_log "WARNING: yazi not running in recreated left pane"
        fi
    fi

    # Return focus to original pane (if it still exists)
    if [ -n "$current_pane" ] && pane_exists_globally "$current_pane"; then
        tmux select-pane -t "$current_pane"
    fi

    display_info "Sync enabled - left sidebar recreated with event streaming"
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
