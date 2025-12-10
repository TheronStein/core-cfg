#!/usr/bin/env bash
# modules/lib/tmux-core.sh
# Shared tmux option management functions
#
# This library provides core functions for getting, setting, and clearing
# tmux options (both global and window-scoped).

get_tmux_option() {
    local option="$1"
    local default="${2:-}"
    local value

    value=$(tmux show-option -gqv "$option" 2>/dev/null)

    if [ -z "$value" ]; then
        echo "$default"
    else
        echo "$value"
    fi
}

set_tmux_option() {
    local option="$1"
    local value="$2"
    tmux set-option -gq "$option" "$value"
}

clear_tmux_option() {
    local option="$1"
    tmux set-option -guq "$option" 2>/dev/null
}

get_window_option() {
    local option="$1"
    local default="${2:-}"
    local value

    value=$(tmux show-option -wqv "$option" 2>/dev/null)
    echo "${value:-$default}"
}

set_window_option() {
    local option="$1"
    local value="$2"
    tmux set-option -wq "$option" "$value"
}

clear_window_option() {
    local option="$1"
    tmux set-option -wuq "$option" 2>/dev/null
}

get_current_window() {
    tmux display-message -p '#{window_id}'
}

# Export functions for subshells
export -f get_tmux_option set_tmux_option clear_tmux_option
export -f get_window_option set_window_option clear_window_option
export -f get_current_window
