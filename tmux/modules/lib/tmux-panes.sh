#!/usr/bin/env bash
# modules/lib/tmux-panes.sh
# DEPRECATED: Use ~/.core/.sys/cfg/tmux/lib/pane-utils.sh instead
#
# This file now sources the canonical library to maintain backward compatibility.

# Source canonical libraries
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"
source "$TMUX_CONF/lib/pane-utils.sh"
source "$TMUX_CONF/lib/layout-utils.sh"

# Legacy function wrappers for backward compatibility
get_current_pane() {
    get_pane_id
}

get_current_pane_path() {
    get_pane_cwd
}

get_current_dir() {
    get_pane_cwd
}

pane_exists_globally() {
    pane_exists "$1"
}

get_pane_tty() {
    local pane_id="${1:-$(get_pane_id)}"
    tmux display-message -p -t "$pane_id" '#{pane_tty}' 2>/dev/null
}

get_pane_pid() {
    local pane_id="${1:-$(get_pane_id)}"
    tmux display-message -p -t "$pane_id" '#{pane_pid}' 2>/dev/null
}

get_pane_info() {
    local pane_id="${1:-$(get_pane_id)}"
    tmux display-message -p -t "$pane_id" \
        '#{pane_id} #{pane_index} #{pane_title} #{pane_current_path} #{pane_current_command}' \
        2>/dev/null
}

# Export functions for backward compatibility
export -f pane_exists
export -f get_pane_id get_pane_cwd get_current_dir
export -f get_pane_width get_pane_height get_pane_tty get_pane_pid get_pane_index
export -f is_pane_zoomed get_pane_info
export -f get_current_pane get_current_pane_path pane_exists_globally
