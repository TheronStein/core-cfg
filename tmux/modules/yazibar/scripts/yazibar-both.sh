#!/usr/bin/env bash
# Yazibar - Dual Sidebar Toggle
# Manages both sidebars as a single unit for convenient toggling

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Check if dual-toggle mode is enabled (user setting)
is_dual_toggle_enabled() {
    [ "$(get_tmux_option "@yazibar-toggle-both" "1")" = "1" ]
}

# ============================================================================
# DUAL SIDEBAR OPERATIONS
# ============================================================================

# Check if any sidebar is currently visible
any_sidebar_visible() {
    local left_pane=$(get_left_pane)
    local right_pane=$(get_right_pane)

    if [ -n "$left_pane" ] && pane_exists_globally "$left_pane"; then
        return 0
    fi

    if [ -n "$right_pane" ] && pane_exists_globally "$right_pane"; then
        return 0
    fi

    return 1
}

# Enable both sidebars with sync
enable_both() {
    debug_log "Enabling both sidebars"

    # Get starting directory from current pane
    local start_dir=$(tmux display-message -p '#{pane_current_path}')
    start_dir="${start_dir:-$HOME}"

    # SPAWN ORDER: LEFT first, then RIGHT, then activate sync
    # This matches the original working implementation where:
    # 1. Left sidebar spawns first (initially without sync)
    # 2. Right sidebar spawns second
    # 3. Sync is explicitly activated after both exist

    # Enable left sidebar first (navigator)
    if ! is_left_enabled || ! pane_exists_globally "$(get_left_pane)"; then
        debug_log "Creating left sidebar first (navigator)"
        "$SCRIPT_DIR/yazibar-left.sh" enable "$start_dir"

        # Wait for left sidebar yazi to complete terminal negotiation
        sleep 1.0

        # Verify yazi is actually running before proceeding
        local left_pane=$(get_left_pane)
        if [ -n "$left_pane" ]; then
            for i in {1..20}; do
                local cmd=$(tmux display-message -p -t "$left_pane" '#{pane_current_command}' 2>/dev/null)
                if [ "$cmd" = "yazi" ]; then
                    debug_log "Left sidebar yazi verified running"
                    break
                fi
                sleep 0.1
            done
        fi
    fi

    # Temporarily disable the right-needs-left check (it's already satisfied)
    local orig_needs_left=$(get_tmux_option "@yazibar-right-needs-left" "1")
    set_tmux_option "@yazibar-right-needs-left" "0"

    # Enable right sidebar second (preview)
    if ! is_right_enabled || ! pane_exists_globally "$(get_right_pane)"; then
        debug_log "Creating right sidebar (preview)"
        "$SCRIPT_DIR/yazibar-right.sh" enable "$start_dir"

        # Wait for right sidebar yazi to complete terminal negotiation
        sleep 1.0

        # Verify yazi is actually running before proceeding
        local right_pane=$(get_right_pane)
        if [ -n "$right_pane" ]; then
            for i in {1..20}; do
                local cmd=$(tmux display-message -p -t "$right_pane" '#{pane_current_command}' 2>/dev/null)
                if [ "$cmd" = "yazi" ]; then
                    debug_log "Right sidebar yazi verified running"
                    break
                fi
                sleep 0.1
            done
        fi
    fi

    # Restore right-needs-left setting
    set_tmux_option "@yazibar-right-needs-left" "$orig_needs_left"

    # Wait for both yazi instances to fully initialize before activating sync
    # This is critical - yazi needs time to complete terminal negotiation
    # Without this delay, the 'q' (quit) command sent by enable_sync
    # would be interpreted as a keystroke before yazi is ready
    sleep 1.5

    # Now that BOTH sidebars exist and are stable, activate sync
    # This restarts left yazi with --local-events to stream to right
    debug_log "Activating sync between sidebars"
    "$SCRIPT_DIR/yazibar-sync.sh" enable

    display_info "Both sidebars enabled with sync"
}

# Disable both sidebars
disable_both() {
    debug_log "Disabling both sidebars"

    # Disable right first (it depends on left)
    if is_right_enabled; then
        "$SCRIPT_DIR/yazibar-right.sh" disable
    fi

    # Disable left
    if is_left_enabled; then
        "$SCRIPT_DIR/yazibar-left.sh" disable
    fi

    display_info "Both sidebars disabled"
}

# Toggle both sidebars
toggle_both() {
    if any_sidebar_visible; then
        debug_log "At least one sidebar visible - closing both"
        disable_both
    else
        debug_log "No sidebars visible - opening both"
        enable_both
    fi
}

# ============================================================================
# STATUS
# ============================================================================

status_both() {
    echo "=== Yazibar Dual Sidebar Status ==="
    echo ""
    echo "Dual Toggle Mode: $(is_dual_toggle_enabled && echo "ENABLED" || echo "DISABLED")"
    echo ""

    local left_pane=$(get_left_pane)
    local right_pane=$(get_right_pane)

    echo "Left Sidebar:"
    if [ -n "$left_pane" ] && pane_exists_globally "$left_pane"; then
        echo "  Status: ACTIVE ($left_pane)"
    else
        echo "  Status: INACTIVE"
    fi

    echo ""
    echo "Right Sidebar:"
    if [ -n "$right_pane" ] && pane_exists_globally "$right_pane"; then
        echo "  Status: ACTIVE ($right_pane)"
    else
        echo "  Status: INACTIVE"
    fi

}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-toggle}" in
    toggle)
        toggle_both
        ;;
    enable)
        enable_both
        ;;
    disable)
        disable_both
        ;;
    status)
        status_both
        ;;
    help|*)
        cat <<EOF
Yazibar Dual Sidebar Manager

COMMANDS:
  toggle           Toggle both sidebars on/off (default)
  enable           Open both sidebars with sync
  disable          Close both sidebars
  status           Show dual sidebar status

CONFIGURATION:
  @yazibar-toggle-both  Enable dual toggle mode (default: 1)

USAGE:
  $0               Toggle both sidebars
  $0 enable        Enable both with sync
  $0 disable       Close both
  $0 status        Show status
EOF
        ;;
esac
