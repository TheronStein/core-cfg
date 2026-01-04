#!/usr/bin/env bash
# Yazibar - Right Sidebar Manager
# Manages the preview/synchronized yazi sidebar

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# CONFIGURATION
# ============================================================================

YAZI_CONFIG_DIR="${YAZI_CONFIG_HOME:-$CORE_CFG/yazi}/profiles/sidebar-right"
RIGHT_SIDEBAR_TITLE="yazibar-right"

# ============================================================================
# DEPENDENCY CHECK
# ============================================================================

check_left_sidebar() {
    local require_left=$(get_tmux_option "@yazibar-right-needs-left" "1")

    if [ "$require_left" = "1" ]; then
        if ! is_left_enabled; then
            display_error "Left sidebar must be active first (Alt+f)"
            return 1
        fi

        local left_pane=$(get_left_pane)
        if [ -z "$left_pane" ] || ! pane_exists_globally "$left_pane"; then
            display_error "Left sidebar pane not found"
            return 1
        fi
    fi

    return 0
}

# ============================================================================
# SIDEBAR CREATION
# ============================================================================

create_right_sidebar() {
    local start_dir="${1:-$(get_current_dir)}"
    local window_id=$(get_current_window)

    debug_log "Creating right sidebar from: $start_dir"

    # Check dependencies
    if ! check_left_sidebar; then
        return 1
    fi

    # Ensure session exists
    "$SCRIPT_DIR/yazibar-session-manager.sh" ensure-right

    # Get saved or default width
    local width=$("$SCRIPT_DIR/yazibar-width.sh" get-right "$start_dir")

    debug_log "Using width: $width"

    # Store current pane to return focus
    local current_pane=$(get_current_pane)

    # Set guard flag to prevent recursive hook execution (window-scoped)
    tmux set-option -gq "@layout-restore-in-progress-${window_id}" 1

    # Create right split (full height, after current pane)
    local new_pane_id=$(tmux split-window -fh -l "$width" -c "$start_dir" -P -F "#{pane_id}" "
        # Set pane title
        printf '\033]2;%s\033\\\\' '$RIGHT_SIDEBAR_TITLE'

        # Set yazi config location
        export YAZI_CONFIG_HOME='$YAZI_CONFIG_DIR'

        # Run yazi in preview mode
        exec '$SCRIPT_DIR/yazibar-run-yazi.sh' right '$start_dir'
    ")

    # Save pane ID
    set_right_pane "$new_pane_id"
    set_right_enabled "1"

    # Lock width with layout manager
    if [ -x "$LAYOUT_MANAGER" ]; then
        "$LAYOUT_MANAGER" lock-width "$new_pane_id" "$width"
        debug_log "Locked pane width: $new_pane_id = $width"
    fi

    # Clear guard flag now that sidebar is fully created (window-scoped)
    tmux set-option -gu "@layout-restore-in-progress-${window_id}"

    # Return to previous pane immediately
    tmux select-pane -t "$current_pane"

    # Note: Sync is NOT auto-enabled here to avoid restart issues
    # User should toggle left sidebar (Alt+f twice) to activate DDS sync
    # Or manually enable: ~/.core/.sys/cfg/tmux/modules/yazibar/scripts/yazibar-sync.sh enable

    display_info "Right sidebar enabled - toggle left sidebar to activate sync"
    debug_log "Created right sidebar: $new_pane_id"
}

# ============================================================================
# SIDEBAR DESTRUCTION
# ============================================================================

destroy_right_sidebar() {
    local right_pane=$(get_right_pane)

    if [ -z "$right_pane" ]; then
        debug_log "No right sidebar to destroy"
        return 1
    fi

    if ! pane_exists_globally "$right_pane"; then
        debug_log "Right sidebar pane doesn't exist, clearing state"
        clear_right_pane
        set_right_enabled "0"
        return 1
    fi

    debug_log "Destroying right sidebar: $right_pane"

    # Save current width before destroying
    "$SCRIPT_DIR/yazibar-width.sh" save-current "$right_pane" "right"

    # Disable input synchronization
    "$SCRIPT_DIR/yazibar-sync.sh" disable

    # Unlock width
    if [ -x "$LAYOUT_MANAGER" ]; then
        "$LAYOUT_MANAGER" unlock "$right_pane"
    fi

    # Kill the pane
    tmux kill-pane -t "$right_pane"

    # Clear state
    clear_right_pane
    set_right_enabled "0"

    display_info "Right sidebar disabled"
}

# ============================================================================
# SIDEBAR OPERATIONS
# ============================================================================

toggle_right_sidebar() {
    if is_right_enabled && pane_exists_globally "$(get_right_pane)"; then
        destroy_right_sidebar
    else
        create_right_sidebar
    fi
}

focus_right_sidebar() {
    local right_pane=$(get_right_pane)

    if [ -z "$right_pane" ] || ! pane_exists_globally "$right_pane"; then
        # Sidebar doesn't exist, create it
        create_right_sidebar
        right_pane=$(get_right_pane)
    fi

    if [ -n "$right_pane" ] && pane_exists_globally "$right_pane"; then
        tmux select-pane -t "$right_pane"
    fi
}

ensure_right_sidebar() {
    # Called by hooks to ensure sidebar exists if enabled
    if is_right_enabled; then
        local right_pane=$(get_right_pane)

        if [ -z "$right_pane" ] || ! pane_exists_globally "$right_pane"; then
            debug_log "Right sidebar missing, recreating"
            create_right_sidebar
        fi
    fi
}

# Auto-disable right sidebar if left is disabled
check_dependency() {
    if is_right_enabled && [ "$(get_tmux_option "@yazibar-right-needs-left" "1")" = "1" ]; then
        if ! is_left_enabled || ! pane_exists_globally "$(get_left_pane)"; then
            debug_log "Left sidebar gone, disabling right sidebar"
            destroy_right_sidebar
        fi
    fi
}

# ============================================================================
# WIDTH ADJUSTMENT
# ============================================================================

resize_right_sidebar() {
    local new_width="$1"
    local right_pane=$(get_right_pane)

    if [ -z "$right_pane" ] || ! pane_exists_globally "$right_pane"; then
        display_error "Right sidebar not active"
        return 1
    fi

    # Resize the pane
    tmux resize-pane -t "$right_pane" -x "$new_width"

    # Update lock
    if [ -x "$LAYOUT_MANAGER" ]; then
        "$LAYOUT_MANAGER" lock-width "$right_pane" "$new_width"
    fi

    # Save new width
    local dir=$(tmux display-message -p -t "$right_pane" '#{pane_current_path}')
    "$SCRIPT_DIR/yazibar-width.sh" save "$dir" "right" "$new_width"

    display_info "Right sidebar resized to $new_width"
}

# ============================================================================
# STATUS
# ============================================================================

status_right() {
    echo "=== Right Sidebar Status ==="
    echo "Enabled: $(is_right_enabled && echo "YES" || echo "NO")"

    local right_pane=$(get_right_pane)
    echo "Pane ID: ${right_pane:-"none"}"

    if [ -n "$right_pane" ]; then
        if pane_exists_globally "$right_pane"; then
            echo "Pane exists: YES"
            echo "Width: $(get_pane_width "$right_pane")"
            echo "Current path: $(tmux display-message -p -t "$right_pane" '#{pane_current_path}')"
        else
            echo "Pane exists: NO (stale reference)"
        fi
    fi

    echo "Sync enabled: $("$SCRIPT_DIR/yazibar-sync.sh" status)"
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-help}" in
    enable)
        create_right_sidebar "$2"
        ;;
    disable)
        destroy_right_sidebar
        ;;
    toggle)
        toggle_right_sidebar
        ;;
    focus)
        focus_right_sidebar
        ;;
    ensure)
        ensure_right_sidebar
        ;;
    check-dependency)
        check_dependency
        ;;
    resize)
        resize_right_sidebar "$2"
        ;;
    status)
        status_right
        ;;
    help|*)
        cat <<EOF
Yazibar Right Sidebar Manager

COMMANDS:
  enable [dir]          Create right sidebar
  disable               Destroy right sidebar
  toggle                Toggle right sidebar
  focus                 Focus right sidebar (create if needed)
  ensure                Ensure sidebar exists if enabled
  check-dependency      Check if left sidebar still active
  resize <width>        Resize sidebar to new width
  status                Show sidebar status

USAGE:
  $0 toggle
  $0 focus
  $0 resize 30
  $0 status
EOF
        ;;
esac
