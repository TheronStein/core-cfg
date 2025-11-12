#!/usr/bin/env bash
# Yazibar - Layout Enforcement
# Ensures sidebars remain in correct positions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# POSITION VERIFICATION
# ============================================================================

# Check if a pane is in the leftmost position
is_leftmost_pane() {
    local pane_id="$1"
    local window_id=$(tmux display-message -p -t "$pane_id" '#{window_id}')
    local leftmost=$(tmux list-panes -t "$window_id" -F "#{pane_left} #{pane_id}" | sort -n | head -1 | awk '{print $2}')
    [ "$pane_id" = "$leftmost" ]
}

# Check if a pane is in the rightmost position
is_rightmost_pane() {
    local pane_id="$1"
    local window_id=$(tmux display-message -p -t "$pane_id" '#{window_id}')
    # Get pane with highest right edge (left + width)
    local rightmost=$(tmux list-panes -t "$window_id" -F "#{e|+:#{pane_left},#{pane_width}} #{pane_id}" | sort -rn | head -1 | awk '{print $2}')
    [ "$pane_id" = "$rightmost" ]
}

# ============================================================================
# POSITION ENFORCEMENT
# ============================================================================

# Move a pane to the leftmost position
move_to_left() {
    local pane_id="$1"

    if ! pane_exists "$pane_id"; then
        return 1
    fi

    # If already leftmost, nothing to do
    if is_leftmost_pane "$pane_id"; then
        debug_log "Pane $pane_id already leftmost"
        return 0
    fi

    debug_log "Moving $pane_id to leftmost position"

    # Save the width before moving
    local width=$(get_pane_width "$pane_id")

    # Break the pane out and move it left
    local window_id=$(tmux display-message -p '#{window_id}')
    tmux break-pane -d -s "$pane_id" -t "$window_id"
    tmux move-pane -h -b -s "$pane_id" -t "$window_id"

    # Restore width
    tmux resize-pane -t "$pane_id" -x "$width"

    # Re-lock width
    if [ -x "$LAYOUT_MANAGER" ]; then
        "$LAYOUT_MANAGER" lock-width "$pane_id" "$width"
    fi

    debug_log "Moved $pane_id to left"
}

# Move a pane to the rightmost position
move_to_right() {
    local pane_id="$1"

    if ! pane_exists "$pane_id"; then
        return 1
    fi

    # If already rightmost, nothing to do
    if is_rightmost_pane "$pane_id"; then
        debug_log "Pane $pane_id already rightmost"
        return 0
    fi

    debug_log "Moving $pane_id to rightmost position"

    # Save the width before moving
    local width=$(get_pane_width "$pane_id")

    # Break the pane out and move it right
    local window_id=$(tmux display-message -p '#{window_id}')
    tmux break-pane -d -s "$pane_id" -t "$window_id"
    tmux move-pane -h -s "$pane_id" -t "$window_id"

    # Restore width
    tmux resize-pane -t "$pane_id" -x "$width"

    # Re-lock width
    if [ -x "$LAYOUT_MANAGER" ]; then
        "$LAYOUT_MANAGER" lock-width "$pane_id" "$width"
    fi

    debug_log "Moved $pane_id to right"
}

# ============================================================================
# AUTO-ENFORCEMENT
# ============================================================================

# Ensure sidebars are in correct positions
enforce_sidebar_positions() {
    local left_pane=$(get_left_pane)
    local right_pane=$(get_right_pane)

    # Enforce left sidebar position
    if [ -n "$left_pane" ] && pane_exists "$left_pane"; then
        if ! is_leftmost_pane "$left_pane"; then
            debug_log "Left sidebar out of position, correcting"
            move_to_left "$left_pane"
        fi
    fi

    # Enforce right sidebar position
    if [ -n "$right_pane" ] && pane_exists "$right_pane"; then
        if ! is_rightmost_pane "$right_pane"; then
            debug_log "Right sidebar out of position, correcting"
            move_to_right "$right_pane"
        fi
    fi
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-help}" in
    enforce)
        enforce_sidebar_positions
        ;;
    move-left)
        move_to_left "$2"
        ;;
    move-right)
        move_to_right "$2"
        ;;
    help|*)
        cat <<EOF
Yazibar Layout Enforcement

COMMANDS:
  enforce           Ensure sidebars are in correct positions
  move-left <pane>  Move pane to leftmost position
  move-right <pane> Move pane to rightmost position

USAGE:
  $0 enforce
EOF
        ;;
esac
