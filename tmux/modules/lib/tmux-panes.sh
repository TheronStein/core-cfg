#!/usr/bin/env bash
# modules/lib/tmux-panes.sh
# Pane query and manipulation functions
#
# Provides comprehensive functions for checking pane existence,
# querying pane properties, and manipulating panes.

# Source core library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tmux-core.sh"

pane_exists() {
    local pane_id="$1"
    local window_id="${2:-$(get_current_window)}"

    [ -n "$pane_id" ] && \
        tmux list-panes -t "$window_id" -F "#{pane_id}" 2>/dev/null | \
        grep -q "^${pane_id}$"
}

pane_exists_globally() {
    local pane_id="$1"

    [ -n "$pane_id" ] && \
        tmux list-panes -a -F "#{pane_id}" 2>/dev/null | \
        grep -q "^${pane_id}$"
}

get_current_pane() {
    tmux display-message -p '#{pane_id}'
}

get_current_pane_path() {
    tmux display-message -p '#{pane_current_path}'
}

get_current_dir() {
    get_current_pane_path
}

get_pane_width() {
    local pane_id="${1:-$(get_current_pane)}"
    tmux display-message -p -t "$pane_id" '#{pane_width}' 2>/dev/null
}

get_pane_height() {
    local pane_id="${1:-$(get_current_pane)}"
    tmux display-message -p -t "$pane_id" '#{pane_height}' 2>/dev/null
}

get_pane_tty() {
    local pane_id="${1:-$(get_current_pane)}"
    tmux display-message -p -t "$pane_id" '#{pane_tty}' 2>/dev/null
}

get_pane_pid() {
    local pane_id="${1:-$(get_current_pane)}"
    tmux display-message -p -t "$pane_id" '#{pane_pid}' 2>/dev/null
}

get_pane_index() {
    local pane_id="${1:-$(get_current_pane)}"
    tmux display-message -p -t "$pane_id" '#{pane_index}' 2>/dev/null
}

is_pane_zoomed() {
    local pane_id="${1:-$(get_current_pane)}"
    local zoomed
    zoomed=$(tmux display-message -p -t "$pane_id" '#{window_zoomed_flag}' 2>/dev/null)
    [ "$zoomed" = "1" ]
}

get_pane_info() {
    local pane_id="${1:-$(get_current_pane)}"
    tmux display-message -p -t "$pane_id" \
        '#{pane_id} #{pane_index} #{pane_title} #{pane_current_path} #{pane_current_command}' \
        2>/dev/null
}

# Export functions
export -f pane_exists pane_exists_globally
export -f get_current_pane get_current_pane_path get_current_dir
export -f get_pane_width get_pane_height get_pane_tty get_pane_pid get_pane_index
export -f is_pane_zoomed get_pane_info
