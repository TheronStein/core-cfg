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

    # IMPORTANT: Create RIGHT sidebar FIRST
    # Left sidebar checks for right at startup to enable DDS sync
    # If we create left first, it won't see right and won't sync

    # Temporarily disable the right-needs-left check
    local orig_needs_left=$(get_tmux_option "@yazibar-right-needs-left" "1")
    set_tmux_option "@yazibar-right-needs-left" "0"

    # Enable right sidebar first (preview pane)
    if ! is_right_enabled || ! pane_exists_globally "$(get_right_pane)"; then
        debug_log "Creating right sidebar first (for sync)"
        "$SCRIPT_DIR/yazibar-right.sh" enable "$start_dir"
        # Wait for right sidebar yazi to complete terminal negotiation
        # Yazi needs time to: send DSR queries → receive responses → parse capabilities
        # 1.0s prevents terminal response timeout when two instances start near-simultaneously
        sleep 1.0

        # Verify yazi is actually running before proceeding (max 2 seconds)
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

    # Enable left sidebar second (it will see right and start with DDS sync)
    if ! is_left_enabled || ! pane_exists_globally "$(get_left_pane)"; then
        debug_log "Creating left sidebar (will auto-sync to right)"
        "$SCRIPT_DIR/yazibar-left.sh" enable "$start_dir"
    fi

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
