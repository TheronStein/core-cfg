#!/usr/bin/env bash
# Yazi Sidebar Manager - Session-scoped docked sidebar
# Maintains a persistent left sidebar with yazi that stays in position

SIDEBAR_WIDTH="30%"
SIDEBAR_SESSION_VAR="@yazi-sidebar-enabled"
SIDEBAR_PANE_VAR="@yazi-sidebar-pane-id"
SIDEBAR_LOCK_VAR="@yazi-sidebar-creating"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

get_sidebar_enabled() {
    tmux show-option -qv "$SIDEBAR_SESSION_VAR"
}

set_sidebar_enabled() {
    tmux set-option -q "$SIDEBAR_SESSION_VAR" "$1"
}

get_sidebar_pane() {
    tmux show-option -qv "$SIDEBAR_PANE_VAR"
}

set_sidebar_pane() {
    tmux set-option -q "$SIDEBAR_PANE_VAR" "$1"
}

clear_sidebar_pane() {
    tmux set-option -qu "$SIDEBAR_PANE_VAR"
}

# Lock/unlock to prevent recursion during sidebar creation
set_sidebar_lock() {
    tmux set-option -q "$SIDEBAR_LOCK_VAR" "1"
}

clear_sidebar_lock() {
    tmux set-option -qu "$SIDEBAR_LOCK_VAR"
}

is_sidebar_locked() {
    [ "$(tmux show-option -qv "$SIDEBAR_LOCK_VAR")" = "1" ]
}

# Check if a pane exists
pane_exists() {
    local pane_id="$1"
    tmux list-panes -F "#{pane_id}" | grep -q "^${pane_id}$"
}

# Get the leftmost pane in the current window
get_leftmost_pane() {
    tmux list-panes -F "#{pane_id} #{pane_left} #{pane_at_left}" | \
        awk '$2 == 0 || $3 == 1 {print $1; exit}'
}

# Check if sidebar is the leftmost pane
is_sidebar_leftmost() {
    local sidebar_id=$(get_sidebar_pane)
    [ -z "$sidebar_id" ] && return 1

    local leftmost=$(get_leftmost_pane)
    [ "$sidebar_id" = "$leftmost" ]
}

# Check if sidebar has full height
is_sidebar_full_height() {
    local sidebar_id=$(get_sidebar_pane)
    [ -z "$sidebar_id" ] && return 1

    local pane_height=$(tmux display-message -p -t "$sidebar_id" '#{pane_height}')
    local window_height=$(tmux display-message -p '#{window_height}')

    [ "$pane_height" = "$window_height" ]
}

# ============================================================================
# SIDEBAR OPERATIONS
# ============================================================================

create_sidebar() {
    local current_dir="${1:-$HOME}"

    # Set lock to prevent hook recursion
    set_sidebar_lock

    # Get current pane to determine split location
    local current_pane=$(tmux display-message -p '#{pane_id}')

    # Create sidebar on the leftmost position
    # -f = full height, -h = horizontal split, -b = before current pane, -l = width
    local new_pane_id=$(tmux split-window -fhb -l "$SIDEBAR_WIDTH" -c "$current_dir" -P -F "#{pane_id}" "
        # Set pane title for identification (even though it may be overwritten)
        printf '\033]2;yazi-sidebar\033\\\\'

        # Set yazi config location (uses parent + current columns for navigation)
        export YAZI_CONFIG_HOME=\"\${YAZI_CONFIG_HOME:-\$CORE_CFG/yazi}/profiles/sidebar-left\"

        # Set yazibar side for sync plugin
        export YAZIBAR_SIDE=\"left\"

        # Run yazi in persistent mode
        \$TMUX_CONF/scripts/yazi-sidebar-persistent.sh \"$current_dir\"
    ")

    # Save the pane ID
    set_sidebar_pane "$new_pane_id"

    # Lock the sidebar width to prevent other panes from affecting it
    "$TMUX_CONF/scripts/layout-manager.sh" lock-width "$new_pane_id" "$SIDEBAR_WIDTH"

    # Return to the previous pane
    tmux select-pane -t "$current_pane"

    # Clear lock after creation is complete
    clear_sidebar_lock

    echo "$new_pane_id"
}

ensure_sidebar() {
    # Prevent recursion - if we're already creating a sidebar, skip
    if is_sidebar_locked; then
        return 0
    fi

    local sidebar_id=$(get_sidebar_pane)

    # Check if sidebar pane exists
    if [ -n "$sidebar_id" ] && pane_exists "$sidebar_id"; then
        # Sidebar exists - for now, don't try to fix position automatically
        # This prevents the infinite loop. Users can manually toggle if needed.
        return 0
    else
        # Sidebar doesn't exist, create it if enabled
        if [ "$(get_sidebar_enabled)" = "1" ]; then
            local current_dir=$(tmux display-message -p '#{pane_current_path}')
            create_sidebar "$current_dir"
        fi
    fi

    # Always return 0 to prevent hook error messages
    # This function is called by hooks and should not fail
    return 0
}

fix_sidebar_position() {
    local sidebar_id=$(get_sidebar_pane)
    [ -z "$sidebar_id" ] || ! pane_exists "$sidebar_id" && return 1

    # Get sidebar's current working directory
    local sidebar_dir=$(tmux display-message -p -t "$sidebar_id" '#{pane_current_path}')

    # Kill the sidebar (will be recreated)
    tmux kill-pane -t "$sidebar_id"
    clear_sidebar_pane

    # Recreate sidebar in correct position
    create_sidebar "$sidebar_dir"
}

enable_sidebar() {
    set_sidebar_enabled "1"
    ensure_sidebar
    tmux display-message "Yazi sidebar enabled for this session"
}

disable_sidebar() {
    set_sidebar_enabled "0"

    local sidebar_id=$(get_sidebar_pane)
    if [ -n "$sidebar_id" ] && pane_exists "$sidebar_id"; then
        # Unlock the sidebar before killing it
        "$TMUX_CONF/scripts/layout-manager.sh" unlock "$sidebar_id"
        tmux kill-pane -t "$sidebar_id"
    fi

    clear_sidebar_pane
    tmux display-message "Yazi sidebar disabled for this session"
}

toggle_sidebar() {
    if [ "$(get_sidebar_enabled)" = "1" ]; then
        disable_sidebar
    else
        enable_sidebar
    fi
}

focus_sidebar() {
    local sidebar_id=$(get_sidebar_pane)

    if [ -z "$sidebar_id" ] || ! pane_exists "$sidebar_id"; then
        # Sidebar doesn't exist, enable it first
        enable_sidebar
        sidebar_id=$(get_sidebar_pane)
    fi

    if [ -n "$sidebar_id" ] && pane_exists "$sidebar_id"; then
        tmux select-pane -t "$sidebar_id"
    fi
}

# ============================================================================
# MAIN COMMAND DISPATCHER
# ============================================================================

case "${1:-toggle}" in
    enable)
        enable_sidebar
        ;;
    disable)
        disable_sidebar
        ;;
    toggle)
        toggle_sidebar
        ;;
    focus)
        focus_sidebar
        ;;
    ensure)
        ensure_sidebar
        ;;
    fix)
        fix_sidebar_position
        ;;
    *)
        echo "Usage: $0 {enable|disable|toggle|focus|ensure|fix}"
        exit 1
        ;;
esac
