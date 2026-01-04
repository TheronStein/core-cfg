#!/usr/bin/env bash
# Custom Layout Manager - Preserves fixed-dimension panes
# Handles pane operations while maintaining static pane dimensions

# Source canonical libraries
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"
source "$TMUX_CONF/lib/pane-utils.sh"
source "$TMUX_CONF/lib/layout-utils.sh"
source "$TMUX_CONF/lib/state-utils.sh"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Session variable to store locked pane configurations
LOCKED_PANES_VAR="@locked-panes"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Get list of locked panes (format: pane_id:dimension:value)
get_locked_panes() {
    tmux show-option -qv "$LOCKED_PANES_VAR" | tr ',' '\n'
}

# Set locked panes list
set_locked_panes() {
    local panes_list="$1"
    if [ -z "$panes_list" ]; then
        tmux set-option -qu "$LOCKED_PANES_VAR"
    else
        tmux set-option -q "$LOCKED_PANES_VAR" "$panes_list"
    fi
}

# Add a pane to the locked list
lock_pane() {
    local pane_id="$1"
    local dimension="$2"  # width or height
    local value="$3"      # e.g., "30%", "80", etc.

    local locked=$(get_locked_panes | grep -v "^${pane_id}:")
    local new_entry="${pane_id}:${dimension}:${value}"

    if [ -n "$locked" ]; then
        set_locked_panes "${locked},${new_entry}"
    else
        set_locked_panes "$new_entry"
    fi
}

# Remove a pane from the locked list
unlock_pane() {
    local pane_id="$1"
    local locked=$(get_locked_panes | grep -v "^${pane_id}:")
    set_locked_panes "$(echo "$locked" | tr '\n' ',' | sed 's/,$//')"
}

# Check if a pane is locked
is_pane_locked() {
    local pane_id="$1"
    get_locked_panes | grep -q "^${pane_id}:"
}

# Get locked dimension info for a pane (returns "dimension:value")
get_pane_lock_info() {
    local pane_id="$1"
    get_locked_panes | grep "^${pane_id}:" | cut -d: -f2-
}

# Note: pane_exists() now from pane-utils.sh

# Check if a pane exists in current window (local function)
_layout_pane_exists_in_window() {
    local pane_id="$1"
    local window_id="${2:-$(get_window_id)}"
    tmux list-panes -t "$window_id" -F "#{pane_id}" 2>/dev/null | grep -q "^${pane_id}$"
}

# Cleanup: Remove non-existent panes from locked list
cleanup_locked_panes() {
    local cleaned=""
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        local pane_id=$(echo "$entry" | cut -d: -f1)
        if pane_exists "$pane_id"; then
            cleaned="${cleaned}${entry},"
        fi
    done < <(get_locked_panes)

    cleaned="${cleaned%,}"  # Remove trailing comma
    set_locked_panes "$cleaned"
}

# ============================================================================
# DIMENSION RESTORATION
# ============================================================================

# Restore dimensions for all locked panes
restore_locked_dimensions() {
    local current_window=$(tmux display-message -p '#{window_id}')

    while IFS= read -r entry; do
        [ -z "$entry" ] && continue

        local pane_id=$(echo "$entry" | cut -d: -f1)
        local dimension=$(echo "$entry" | cut -d: -f2)
        local value=$(echo "$entry" | cut -d: -f3)

        # Skip if pane doesn't exist
        pane_exists "$pane_id" || continue

        # Check if pane is in current window
        local pane_window=$(tmux display-message -p -t "$pane_id" '#{window_id}')
        [ "$pane_window" != "$current_window" ] && continue

        # Restore dimension
        case "$dimension" in
            width)
                tmux resize-pane -t "$pane_id" -x "$value"
                ;;
            height)
                tmux resize-pane -t "$pane_id" -y "$value"
                ;;
        esac
    done < <(get_locked_panes)
}

# Get current pane dimensions (uses canonical library functions)
get_pane_dimensions() {
    local pane_id="$1"
    local width=$(get_pane_width "$pane_id")
    local height=$(get_pane_height "$pane_id")
    echo "${width}x${height}"
}

# ============================================================================
# SMART SPLIT OPERATIONS
# ============================================================================

# Smart split that preserves locked pane dimensions
smart_split() {
    local split_direction="$1"  # h or v
    local split_size="$2"       # optional size
    local split_target="$3"     # optional target pane

    # Perform the split
    local split_cmd="tmux split-window -${split_direction}"
    [ -n "$split_size" ] && split_cmd="$split_cmd -l $split_size"
    [ -n "$split_target" ] && split_cmd="$split_cmd -t $split_target"

    eval "$split_cmd"

    # Restore locked dimensions after split
    restore_locked_dimensions
}

# ============================================================================
# LAYOUT OPERATIONS
# ============================================================================

# Apply layout while preserving locked dimensions
apply_layout() {
    local layout_type="$1"  # tiled, even-horizontal, even-vertical, main-horizontal, main-vertical

    # Get dimensions before layout change
    local locked_dims=""
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        local pane_id=$(echo "$entry" | cut -d: -f1)
        pane_exists "$pane_id" || continue
        local dims=$(get_pane_dimensions "$pane_id")
        locked_dims="${locked_dims}${pane_id}:${dims},"
    done < <(get_locked_panes)

    # Apply the layout
    tmux select-layout "$layout_type"

    # Restore locked dimensions
    restore_locked_dimensions
}

# ============================================================================
# RESIZE OPERATIONS
# ============================================================================

# Smart resize that respects locked panes
smart_resize() {
    local target_pane="$1"
    local direction="$2"  # L, R, U, D
    local amount="$3"

    # Check if target pane is locked
    if is_pane_locked "$target_pane"; then
        tmux display-message "Cannot resize locked pane $target_pane"
        return 1
    fi

    # Perform resize
    tmux resize-pane -t "$target_pane" -"$direction" "$amount"

    # Restore locked dimensions (this will undo resize if it affected locked panes)
    restore_locked_dimensions
}

# ============================================================================
# PANE LOCKING API
# ============================================================================

# Lock a pane's width
lock_pane_width() {
    local pane_id="${1:-$(tmux display-message -p '#{pane_id}')}"
    local width="${2:-$(tmux display-message -p -t "$pane_id" '#{pane_width}')}"

    unlock_pane "$pane_id"  # Remove any existing lock
    lock_pane "$pane_id" "width" "$width"
    tmux display-message "Locked pane $pane_id width to $width"
}

# Lock a pane's height
lock_pane_height() {
    local pane_id="${1:-$(tmux display-message -p '#{pane_id}')}"
    local height="${2:-$(tmux display-message -p -t "$pane_id" '#{pane_height}')}"

    unlock_pane "$pane_id"  # Remove any existing lock
    lock_pane "$pane_id" "height" "$height"
    tmux display-message "Locked pane $pane_id height to $height"
}

# Lock both dimensions
lock_pane_full() {
    local pane_id="${1:-$(tmux display-message -p '#{pane_id}')}"
    local width="${2:-$(tmux display-message -p -t "$pane_id" '#{pane_width}')}"
    local height="${3:-$(tmux display-message -p -t "$pane_id" '#{pane_height}')}"

    unlock_pane "$pane_id"  # Remove any existing lock
    lock_pane "$pane_id" "width" "$width"
    lock_pane "$pane_id" "height" "$height"
    tmux display-message "Locked pane $pane_id dimensions to ${width}x${height}"
}

# Toggle lock on current pane
toggle_pane_lock() {
    local pane_id="$(tmux display-message -p '#{pane_id}')"

    if is_pane_locked "$pane_id"; then
        unlock_pane "$pane_id"
        tmux display-message "Unlocked pane $pane_id"
    else
        lock_pane_width "$pane_id"
        tmux display-message "Locked pane $pane_id width"
    fi
}

# List all locked panes
list_locked_panes() {
    echo "Locked panes:"
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        local pane_id=$(echo "$entry" | cut -d: -f1)
        local dimension=$(echo "$entry" | cut -d: -f2)
        local value=$(echo "$entry" | cut -d: -f3)

        if pane_exists "$pane_id"; then
            local title=$(tmux display-message -p -t "$pane_id" '#{pane_title}')
            echo "  $pane_id ($title): $dimension = $value"
        else
            echo "  $pane_id: $dimension = $value (pane no longer exists)"
        fi
    done < <(get_locked_panes)
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-help}" in
    # Locking commands
    lock-width)
        lock_pane_width "$2" "$3"
        ;;
    lock-height)
        lock_pane_height "$2" "$3"
        ;;
    lock-full)
        lock_pane_full "$2" "$3" "$4"
        ;;
    unlock)
        unlock_pane "${2:-$(tmux display-message -p '#{pane_id}')}"
        tmux display-message "Unlocked pane ${2:-current}"
        ;;
    toggle-lock)
        toggle_pane_lock
        ;;

    # Dimension restoration
    restore)
        restore_locked_dimensions
        ;;
    cleanup)
        cleanup_locked_panes
        ;;

    # Smart operations
    split-h)
        smart_split h "$2" "$3"
        ;;
    split-v)
        smart_split v "$2" "$3"
        ;;
    layout)
        apply_layout "$2"
        ;;
    resize)
        smart_resize "$2" "$3" "$4"
        ;;

    # Information
    list)
        list_locked_panes
        ;;
    is-locked)
        if is_pane_locked "${2:-$(tmux display-message -p '#{pane_id}')}"; then
            echo "yes"
            exit 0
        else
            echo "no"
            exit 1
        fi
        ;;

    # Help
    help|*)
        cat <<EOF
Layout Manager - Fixed Dimension Pane System

LOCKING COMMANDS:
  lock-width [pane-id] [width]    Lock pane width (default: current pane)
  lock-height [pane-id] [height]  Lock pane height (default: current pane)
  lock-full [pane-id] [w] [h]     Lock both dimensions (default: current)
  unlock [pane-id]                Unlock pane (default: current pane)
  toggle-lock                     Toggle lock on current pane

SMART OPERATIONS:
  split-h [size] [target]         Split horizontally, preserve locks
  split-v [size] [target]         Split vertically, preserve locks
  layout <type>                   Apply layout, preserve locks
  resize <pane> <dir> <amount>    Resize pane (LRUD), preserve locks

MAINTENANCE:
  restore                         Restore all locked dimensions
  cleanup                         Remove non-existent panes from locks
  list                            List all locked panes
  is-locked [pane-id]             Check if pane is locked

USAGE EXAMPLES:
  # Lock sidebar width
  $0 lock-width %1 50

  # Split vertically while preserving sidebar
  $0 split-v

  # Restore all locked dimensions after manual changes
  $0 restore

  # List locked panes
  $0 list
EOF
        ;;
esac
