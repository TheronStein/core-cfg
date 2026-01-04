#!/usr/bin/env bash
# ==============================================================================
# Tmux Pane Utilities
# ==============================================================================
# Functions for pane management operations.
#
# Usage:
#   source "$TMUX_CONF/lib/pane-utils.sh"
#   if pane_exists "%5"; then
#     kill_pane_safe "%5"
#   fi
#
# ==============================================================================

# Prevent double-sourcing
[[ -n "${_PANE_UTILS_SH_LOADED:-}" ]] && return 0
_PANE_UTILS_SH_LOADED=1

# Source dependencies
source "${BASH_SOURCE%/*}/tmux-utils.sh"
source "${BASH_SOURCE%/*}/state-utils.sh"

# ==============================================================================
# Pane Existence Checks
# ==============================================================================

# Check if pane exists
pane_exists() {
    local pane_id="$1"

    [[ -z "$pane_id" ]] && return 1

    tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -q "^${pane_id}$"
}

# Check if pane exists in current window
pane_exists_in_window() {
    local pane_id="$1"

    [[ -z "$pane_id" ]] && return 1

    tmux list-panes -F '#{pane_id}' 2>/dev/null | grep -q "^${pane_id}$"
}

# ==============================================================================
# Pane Creation
# ==============================================================================

# Create horizontal split (pane to the right)
create_pane_right() {
    local cmd="${1:-}"
    local width="${2:-}"

    local args=(-h)
    [[ -n "$width" ]] && args+=(-l "$width")
    [[ -n "$cmd" ]] && args+=("$cmd")

    tmux split-window "${args[@]}"
    get_pane_id
}

# Create vertical split (pane below)
create_pane_below() {
    local cmd="${1:-}"
    local height="${2:-}"

    local args=(-v)
    [[ -n "$height" ]] && args+=(-l "$height")
    [[ -n "$cmd" ]] && args+=("$cmd")

    tmux split-window "${args[@]}"
    get_pane_id
}

# Create pane with specific working directory
create_pane_in_dir() {
    local dir="$1"
    local cmd="${2:-}"
    local split="${3:-h}"  # h for horizontal, v for vertical

    local args=("-$split" -c "$dir")
    [[ -n "$cmd" ]] && args+=("$cmd")

    tmux split-window "${args[@]}"
    get_pane_id
}

# ==============================================================================
# Pane Termination
# ==============================================================================

# Kill pane safely (with checks)
kill_pane_safe() {
    local pane_id="$1"

    [[ -z "$pane_id" ]] && return 1

    if pane_exists "$pane_id"; then
        tmux kill-pane -t "$pane_id"
        return 0
    fi
    return 1
}

# Kill all panes except current
kill_other_panes() {
    local current
    current=$(get_pane_id)

    tmux list-panes -F '#{pane_id}' | while read -r pane; do
        [[ "$pane" != "$current" ]] && tmux kill-pane -t "$pane"
    done
}

# ==============================================================================
# Pane Navigation
# ==============================================================================

# Select pane by ID
select_pane() {
    local pane_id="$1"

    if pane_exists "$pane_id"; then
        tmux select-pane -t "$pane_id"
        return 0
    fi
    return 1
}

# Select pane in direction (U/D/L/R)
select_pane_direction() {
    local direction="$1"  # U, D, L, R

    case "$direction" in
        U|u|up)    tmux select-pane -U ;;
        D|d|down)  tmux select-pane -D ;;
        L|l|left)  tmux select-pane -L ;;
        R|r|right) tmux select-pane -R ;;
        *)         return 1 ;;
    esac
}

# Get pane ID in direction
get_pane_in_direction() {
    local direction="$1"

    # Save current pane
    local current
    current=$(get_pane_id)

    # Try to move
    case "$direction" in
        U|u|up)    tmux select-pane -U ;;
        D|d|down)  tmux select-pane -D ;;
        L|l|left)  tmux select-pane -L ;;
        R|r|right) tmux select-pane -R ;;
        *)         echo "$current"; return 1 ;;
    esac

    # Get new pane ID
    local new
    new=$(get_pane_id)

    # Return to original
    tmux select-pane -t "$current"

    echo "$new"
}

# ==============================================================================
# Pane Information
# ==============================================================================

# List all panes in current window
list_panes() {
    tmux list-panes -F '#{pane_id}:#{pane_index}:#{pane_current_command}'
}

# List all panes in session
list_all_panes() {
    tmux list-panes -s -F '#{window_index}.#{pane_index}:#{pane_id}:#{pane_current_command}'
}

# Get pane running specific command
get_pane_by_command() {
    local cmd="$1"

    tmux list-panes -F '#{pane_id}:#{pane_current_command}' 2>/dev/null | \
        grep ":$cmd$" | cut -d: -f1 | head -1
}

# ==============================================================================
# Pane Actions
# ==============================================================================

# Send keys to pane
send_keys() {
    local pane_id="$1"
    shift
    local keys="$*"

    if pane_exists "$pane_id"; then
        tmux send-keys -t "$pane_id" "$keys"
        return 0
    fi
    return 1
}

# Zoom/unzoom pane
toggle_zoom() {
    tmux resize-pane -Z
}

# Swap panes
swap_panes() {
    local pane1="$1"
    local pane2="${2:-}"

    if [[ -z "$pane2" ]]; then
        # Swap with previous pane
        tmux swap-pane -t "$pane1"
    else
        tmux swap-pane -s "$pane1" -t "$pane2"
    fi
}
