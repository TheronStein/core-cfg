#!/usr/bin/env bash
# modules/lib/tmux-windows.sh
# Window query and manipulation functions
#
# Provides functions for checking window existence and querying
# window properties.

# Source core library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/tmux-core.sh"

window_exists() {
    local window_id="$1"
    local session="${2:-}"

    if [ -n "$session" ]; then
        tmux list-windows -t "$session" -F "#{window_id}" 2>/dev/null | \
            grep -q "^${window_id}$"
    else
        tmux list-windows -a -F "#{window_id}" 2>/dev/null | \
            grep -q "^${window_id}$"
    fi
}

get_window_name() {
    local window_id="${1:-$(get_current_window)}"
    tmux display-message -p -t "$window_id" '#{window_name}' 2>/dev/null
}

get_window_index() {
    local window_id="${1:-$(get_current_window)}"
    tmux display-message -p -t "$window_id" '#{window_index}' 2>/dev/null
}

get_window_id() {
    local window_index="$1"
    local session="${2:-$(get_current_session)}"
    tmux list-windows -t "$session" -F "#{window_index} #{window_id}" 2>/dev/null | \
        awk -v idx="$window_index" '$1 == idx {print $2}'
}

list_windows() {
    local session="${1:-}"
    if [ -n "$session" ]; then
        tmux list-windows -t "$session" -F "#{window_index} #{window_id} #{window_name}" 2>/dev/null
    else
        tmux list-windows -a -F "#{session_name} #{window_index} #{window_id} #{window_name}" 2>/dev/null
    fi
}

get_window_layout() {
    local window_id="${1:-$(get_current_window)}"
    tmux display-message -p -t "$window_id" '#{window_layout}' 2>/dev/null
}

# Export functions
export -f window_exists get_window_name get_window_index get_window_id
export -f list_windows get_window_layout
