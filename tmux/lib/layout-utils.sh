#!/usr/bin/env bash
# ==============================================================================
# Tmux Layout Utilities
# ==============================================================================
# Functions for layout and dimension management.
#
# Usage:
#   source "$TMUX_CONF/lib/layout-utils.sh"
#   lock_pane_width
#   unlock_pane_width
#
# ==============================================================================

# Prevent double-sourcing
[[ -n "${_LAYOUT_UTILS_SH_LOADED:-}" ]] && return 0
_LAYOUT_UTILS_SH_LOADED=1

# Source dependencies
source "${BASH_SOURCE%/*}/tmux-utils.sh"
source "${BASH_SOURCE%/*}/state-utils.sh"

# ==============================================================================
# Dimension Locking
# ==============================================================================

# Lock pane width (prevent auto-resize)
lock_pane_width() {
    local pane_id="${1:-$(get_pane_id)}"
    local width
    width=$(tmux display-message -p -t "$pane_id" '#{pane_width}' 2>/dev/null)

    set_pane_option "locked-width" "$width" "$pane_id"
}

# Unlock pane width
unlock_pane_width() {
    local pane_id="${1:-$(get_pane_id)}"

    clear_pane_option "locked-width" "$pane_id"
}

# Check if pane width is locked
is_width_locked() {
    local pane_id="${1:-$(get_pane_id)}"
    local locked
    locked=$(get_pane_option "locked-width" "" "$pane_id")

    [[ -n "$locked" ]]
}

# Get locked width
get_locked_width() {
    local pane_id="${1:-$(get_pane_id)}"

    get_pane_option "locked-width" "" "$pane_id"
}

# ==============================================================================
# Pane Dimension Queries
# ==============================================================================

# Get pane width
get_pane_width() {
    local pane_id="${1:-$(get_pane_id)}"

    tmux display-message -p -t "$pane_id" '#{pane_width}' 2>/dev/null
}

# Get pane height
get_pane_height() {
    local pane_id="${1:-$(get_pane_id)}"

    tmux display-message -p -t "$pane_id" '#{pane_height}' 2>/dev/null
}

# Get window width
get_window_width() {
    tmux display-message -p '#{window_width}' 2>/dev/null
}

# Get window height
get_window_height() {
    tmux display-message -p '#{window_height}' 2>/dev/null
}

# ==============================================================================
# Layout Management
# ==============================================================================

# Get current layout
get_window_layout() {
    tmux display-message -p '#{window_layout}' 2>/dev/null
}

# Save current layout
save_layout() {
    local name="${1:-default}"

    set_window_option "@saved-layout-$name" "$(get_window_layout)"
}

# Restore saved layout
restore_layout() {
    local name="${1:-default}"
    local layout
    layout=$(get_window_option "@saved-layout-$name")

    if [[ -n "$layout" ]]; then
        tmux select-layout "$layout"
        return 0
    fi
    return 1
}

# ==============================================================================
# Layout Presets
# ==============================================================================

# Apply even-horizontal layout
layout_even_horizontal() {
    tmux select-layout even-horizontal
}

# Apply even-vertical layout
layout_even_vertical() {
    tmux select-layout even-vertical
}

# Apply main-horizontal layout (big pane on top)
layout_main_horizontal() {
    tmux select-layout main-horizontal
}

# Apply main-vertical layout (big pane on left)
layout_main_vertical() {
    tmux select-layout main-vertical
}

# Apply tiled layout
layout_tiled() {
    tmux select-layout tiled
}

# ==============================================================================
# Export Functions
# ==============================================================================

export -f lock_pane_width unlock_pane_width is_width_locked get_locked_width
export -f get_pane_width get_pane_height get_window_width get_window_height
export -f get_window_layout save_layout restore_layout
export -f layout_even_horizontal layout_even_vertical
export -f layout_main_horizontal layout_main_vertical layout_tiled
