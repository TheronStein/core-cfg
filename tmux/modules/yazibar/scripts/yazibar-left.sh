#!/usr/bin/env bash
# Yazibar - Left Sidebar Manager
# Manages the yazi file browser sidebar

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# CONFIGURATION
# ============================================================================

YAZI_CONFIG_DIR="${YAZI_CONFIG_HOME:-$CORE_CFG/yazi}/profiles/sidebar-left"
LEFT_SIDEBAR_TITLE="yazibar-left"

# ============================================================================
# SIDEBAR CREATION
# ============================================================================

create_left_sidebar() {
    local start_dir="${1:-$(get_current_dir)}"

    debug_log "Creating left sidebar from: $start_dir"

    # Ensure session exists
    "$SCRIPT_DIR/yazibar-session-manager.sh" ensure-left

    # Get saved or default width
    local width=$("$SCRIPT_DIR/yazibar-width.sh" get-left "$start_dir")

    debug_log "Using width: $width"

    # Store current pane to return focus
    local current_pane=$(get_current_pane)

    # Create left split (full height, before current pane)
    local new_pane_id=$(tmux split-window -fhb -l "$width" -c "$start_dir" -P -F "#{pane_id}" "
        # Set pane title
        printf '\033]2;%s\033\\\\' '$LEFT_SIDEBAR_TITLE'

        # Set yazi config location
        export YAZI_CONFIG_HOME='$YAZI_CONFIG_DIR'

        # Get nvim address for current window
        NVIM_ADDR=\$('$SCRIPT_DIR/yazibar-nvim.sh' get-current)
        if [ -n \"\$NVIM_ADDR\" ]; then
            export NVIM_LISTEN_ADDRESS=\"\$NVIM_ADDR\"
        fi

        # Run yazi with CWD sync
        exec '$SCRIPT_DIR/yazibar-run-yazi.sh' left '$start_dir'
    ")

    # Save pane ID
    set_left_pane "$new_pane_id"
    set_left_enabled "1"

    # Lock width with layout manager
    if [ -x "$LAYOUT_MANAGER" ]; then
        "$LAYOUT_MANAGER" lock-width "$new_pane_id" "$width"
        debug_log "Locked pane width: $new_pane_id = $width"
    fi

    # Return to previous pane
    tmux select-pane -t "$current_pane"

    display_info "Left sidebar enabled"
    debug_log "Created left sidebar: $new_pane_id"
}

# ============================================================================
# SIDEBAR DESTRUCTION
# ============================================================================

destroy_left_sidebar() {
    local left_pane=$(get_left_pane)

    if [ -z "$left_pane" ]; then
        debug_log "No left sidebar to destroy"
        return 1
    fi

    if ! pane_exists "$left_pane"; then
        debug_log "Left sidebar pane doesn't exist, clearing state"
        clear_left_pane
        set_left_enabled "0"
        return 1
    fi

    debug_log "Destroying left sidebar: $left_pane"

    # Save current width before destroying
    "$SCRIPT_DIR/yazibar-width.sh" save-current "$left_pane" "left"

    # Unlock width
    if [ -x "$LAYOUT_MANAGER" ]; then
        "$LAYOUT_MANAGER" unlock "$left_pane"
    fi

    # If right sidebar exists and depends on left, destroy it too
    if is_right_enabled && [ "$(get_tmux_option "@yazibar-right-needs-left" "1")" = "1" ]; then
        "$SCRIPT_DIR/yazibar-right.sh" disable
    fi

    # Kill the pane
    tmux kill-pane -t "$left_pane"

    # Clear state
    clear_left_pane
    set_left_enabled "0"

    display_info "Left sidebar disabled"
}

# ============================================================================
# SIDEBAR OPERATIONS
# ============================================================================

toggle_left_sidebar() {
    if is_left_enabled && pane_exists "$(get_left_pane)"; then
        destroy_left_sidebar
    else
        create_left_sidebar
    fi
}

focus_left_sidebar() {
    local left_pane=$(get_left_pane)

    if [ -z "$left_pane" ] || ! pane_exists "$left_pane"; then
        # Sidebar doesn't exist, create it
        create_left_sidebar
        left_pane=$(get_left_pane)
    fi

    if [ -n "$left_pane" ] && pane_exists "$left_pane"; then
        tmux select-pane -t "$left_pane"
    fi
}

ensure_left_sidebar() {
    # Called by hooks to ensure sidebar exists if enabled
    if is_left_enabled; then
        local left_pane=$(get_left_pane)

        if [ -z "$left_pane" ] || ! pane_exists "$left_pane"; then
            debug_log "Left sidebar missing, recreating"
            create_left_sidebar
        fi
    fi
}

# ============================================================================
# WIDTH ADJUSTMENT
# ============================================================================

resize_left_sidebar() {
    local new_width="$1"
    local left_pane=$(get_left_pane)

    if [ -z "$left_pane" ] || ! pane_exists "$left_pane"; then
        display_error "Left sidebar not active"
        return 1
    fi

    # Resize the pane
    tmux resize-pane -t "$left_pane" -x "$new_width"

    # Update lock
    if [ -x "$LAYOUT_MANAGER" ]; then
        "$LAYOUT_MANAGER" lock-width "$left_pane" "$new_width"
    fi

    # Save new width
    local dir=$(tmux display-message -p -t "$left_pane" '#{pane_current_path}')
    "$SCRIPT_DIR/yazibar-width.sh" save "$dir" "left" "$new_width"

    display_info "Left sidebar resized to $new_width"
}

# ============================================================================
# STATUS
# ============================================================================

status_left() {
    echo "=== Left Sidebar Status ==="
    echo "Enabled: $(is_left_enabled && echo "YES" || echo "NO")"

    local left_pane=$(get_left_pane)
    echo "Pane ID: ${left_pane:-"none"}"

    if [ -n "$left_pane" ]; then
        if pane_exists "$left_pane"; then
            echo "Pane exists: YES"
            echo "Width: $(get_pane_width "$left_pane")"
            echo "Current path: $(tmux display-message -p -t "$left_pane" '#{pane_current_path}')"
        else
            echo "Pane exists: NO (stale reference)"
        fi
    fi
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-help}" in
    enable)
        create_left_sidebar "$2"
        ;;
    disable)
        destroy_left_sidebar
        ;;
    toggle)
        toggle_left_sidebar
        ;;
    focus)
        focus_left_sidebar
        ;;
    ensure)
        ensure_left_sidebar
        ;;
    resize)
        resize_left_sidebar "$2"
        ;;
    status)
        status_left
        ;;
    help|*)
        cat <<EOF
Yazibar Left Sidebar Manager

COMMANDS:
  enable [dir]          Create left sidebar
  disable               Destroy left sidebar
  toggle                Toggle left sidebar
  focus                 Focus left sidebar (create if needed)
  ensure                Ensure sidebar exists if enabled
  resize <width>        Resize sidebar to new width
  status                Show sidebar status

USAGE:
  $0 toggle
  $0 focus
  $0 resize 40
  $0 status
EOF
        ;;
esac
