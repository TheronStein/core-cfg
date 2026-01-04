#!/usr/bin/env bash
# lib/session-utils.sh
# Session query and manipulation functions
#
# Provides functions for checking session existence, querying session
# properties, and basic session operations.

session_exists() {
    local session_name="$1"
    tmux has-session -t "$session_name" 2>/dev/null
}

get_current_session() {
    tmux display-message -p '#{session_name}'
}

get_current_session_id() {
    tmux display-message -p '#{session_id}'
}

list_sessions() {
    tmux list-sessions -F "#{session_name} #{session_id} #{session_windows} #{session_attached}" 2>/dev/null
}

get_session_path() {
    local session="${1:-$(get_current_session)}"
    tmux display-message -p -t "$session" '#{session_path}' 2>/dev/null
}

create_detached_session() {
    local session_name="$1"
    local start_dir="${2:-$HOME}"

    if ! session_exists "$session_name"; then
        tmux new-session -d -s "$session_name" -c "$start_dir"
        return $?
    fi
    return 1
}

kill_session() {
    local session_name="$1"
    if session_exists "$session_name"; then
        tmux kill-session -t "$session_name"
        return $?
    fi
    return 1
}

# Export functions
export -f session_exists get_current_session get_current_session_id
export -f list_sessions get_session_path
export -f create_detached_session kill_session
