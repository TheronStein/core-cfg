#!/usr/bin/env bash
# ==============================================================================
# Tmux State Utilities
# ==============================================================================
# Functions for reading/writing tmux options and user variables.
#
# Usage:
#   source "$TMUX_CONF/lib/state-utils.sh"
#   set_tmux_option "@my-option" "value"
#   value=$(get_tmux_option "@my-option" "default")
#
# ==============================================================================

# Prevent double-sourcing
[[ -n "${_STATE_UTILS_SH_LOADED:-}" ]] && return 0
_STATE_UTILS_SH_LOADED=1

# Source tmux-utils
source "${BASH_SOURCE%/*}/tmux-utils.sh"

# ==============================================================================
# Option Management
# ==============================================================================

# Get tmux option value with default
get_tmux_option() {
    local option="$1"
    local default="${2:-}"

    is_tmux || { echo "$default"; return; }

    local value
    value=$(tmux show-option -gqv "$option" 2>/dev/null)

    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Set tmux option value
set_tmux_option() {
    local option="$1"
    local value="$2"

    is_tmux && tmux set-option -g "$option" "$value"
}

# Clear (unset) tmux option
clear_tmux_option() {
    local option="$1"

    is_tmux && tmux set-option -gu "$option" 2>/dev/null
}

# ==============================================================================
# Window-Scoped Options
# ==============================================================================

# Get window option
get_window_option() {
    local option="$1"
    local default="${2:-}"

    is_tmux || { echo "$default"; return; }

    local value
    value=$(tmux show-window-option -qv "$option" 2>/dev/null)

    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Set window option
set_window_option() {
    local option="$1"
    local value="$2"

    is_tmux && tmux set-window-option "$option" "$value"
}

# Clear window option
clear_window_option() {
    local option="$1"

    is_tmux && tmux set-window-option -u "$option" 2>/dev/null
}

# ==============================================================================
# Pane-Scoped State (via user options on pane)
# ==============================================================================

# Get pane option (stored as @pane-{pane_id}-{option})
get_pane_option() {
    local option="$1"
    local default="${2:-}"
    local pane_id="${3:-$(get_pane_id)}"

    get_tmux_option "@pane-${pane_id}-${option}" "$default"
}

# Set pane option
set_pane_option() {
    local option="$1"
    local value="$2"
    local pane_id="${3:-$(get_pane_id)}"

    set_tmux_option "@pane-${pane_id}-${option}" "$value"
}

# Clear pane option
clear_pane_option() {
    local option="$1"
    local pane_id="${2:-$(get_pane_id)}"

    clear_tmux_option "@pane-${pane_id}-${option}"
}

# ==============================================================================
# User Variables (tmux 3.2+)
# ==============================================================================

# Get user variable
get_user_variable() {
    local var="$1"
    local default="${2:-}"
    local pane="${3:-%}"  # Default to current pane

    is_tmux || { echo "$default"; return; }

    local value
    value=$(tmux display-message -p -t "$pane" "#{@$var}" 2>/dev/null)

    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Set user variable
set_user_variable() {
    local var="$1"
    local value="$2"
    local pane="${3:-%}"

    is_tmux && tmux set-option -p -t "$pane" "@$var" "$value"
}

# ==============================================================================
# Boolean Helpers
# ==============================================================================

# Check if option is "true" or "1"
is_option_enabled() {
    local option="$1"
    local value
    value=$(get_tmux_option "$option")

    [[ "$value" == "1" ]] || [[ "$value" == "true" ]] || [[ "$value" == "on" ]]
}

# Toggle boolean option
toggle_option() {
    local option="$1"

    if is_option_enabled "$option"; then
        set_tmux_option "$option" "0"
    else
        set_tmux_option "$option" "1"
    fi
}
