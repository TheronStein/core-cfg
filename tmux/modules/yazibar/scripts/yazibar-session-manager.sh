#!/usr/bin/env bash
# Yazibar - Session Manager
# Manages tmux sessions on the core-ide server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# SESSION LIFECYCLE
# ============================================================================

create_session() {
    local server="$1"
    local session="$2"

    debug_log "Creating session: $server:$session"

    if session_exists "$server" "$session"; then
        debug_log "Session already exists: $server:$session"
        return 0
    fi

    # Create session in detached mode with a dummy window
    tmux -L "$server" new-session -d -s "$session" -n "main" \
        "echo 'Yazibar session: $session ready'; exec bash"

    if [ $? -eq 0 ]; then
        debug_log "Session created successfully: $server:$session"
        return 0
    else
        debug_log "Failed to create session: $server:$session"
        return 1
    fi
}

ensure_session() {
    local server="$1"
    local session="$2"

    if ! session_exists "$server" "$session"; then
        create_session "$server" "$session"
    fi
}

destroy_session() {
    local server="$1"
    local session="$2"

    debug_log "Destroying session: $server:$session"

    if session_exists "$server" "$session"; then
        tmux -L "$server" kill-session -t "$session"
        debug_log "Session destroyed: $server:$session"
    else
        debug_log "Session doesn't exist: $server:$session"
    fi
}

# ============================================================================
# WINDOW MANAGEMENT
# ============================================================================

create_window_in_session() {
    local server="$1"
    local session="$2"
    local window_name="$3"
    local command="$4"
    local start_dir="${5:-$HOME}"

    debug_log "Creating window: $server:$session:$window_name"

    # Ensure session exists
    ensure_session "$server" "$session"

    # Create new window
    local window_id=$(tmux -L "$server" new-window -t "$session:" -n "$window_name" \
        -c "$start_dir" -P -F "#{window_id}" "$command")

    echo "$window_id"
}

get_session_window() {
    local server="$1"
    local session="$2"
    local window_index="${3:-0}"

    tmux -L "$server" list-windows -t "$session" -F "#{window_id}" | sed -n "$((window_index + 1))p"
}

# ============================================================================
# YAZIBAR-SPECIFIC SESSION MANAGEMENT
# ============================================================================

ensure_left_session() {
    local server=$(yazibar_server)
    local session=$(yazibar_left_session)

    ensure_session "$server" "$session"
}

ensure_right_session() {
    local server=$(yazibar_server)
    local session=$(yazibar_right_session)

    ensure_session "$server" "$session"
}

ensure_all_sessions() {
    ensure_left_session
    ensure_right_session
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup_sessions() {
    local server=$(yazibar_server)

    # Kill sessions if they exist
    destroy_session "$server" "$(yazibar_left_session)"
    destroy_session "$server" "$(yazibar_right_session)"

    display_info "Yazibar sessions cleaned up"
}

# ============================================================================
# STATUS
# ============================================================================

status() {
    local server=$(yazibar_server)
    local left_session=$(yazibar_left_session)
    local right_session=$(yazibar_right_session)

    echo "=== Yazibar Session Status ==="
    echo "Server: $server"
    echo ""

    if server_running "$server"; then
        echo "Server is running"
        echo ""

        echo "Left Sidebar Session: $left_session"
        if session_exists "$server" "$left_session"; then
            echo "  Status: EXISTS"
            local window_count=$(tmux -L "$server" list-windows -t "$left_session" | wc -l)
            echo "  Windows: $window_count"
        else
            echo "  Status: NOT FOUND"
        fi
        echo ""

        echo "Right Sidebar Session: $right_session"
        if session_exists "$server" "$right_session"; then
            echo "  Status: EXISTS"
            local window_count=$(tmux -L "$server" list-windows -t "$right_session" | wc -l)
            echo "  Windows: $window_count"
        else
            echo "  Status: NOT FOUND"
        fi
    else
        echo "Server is NOT running"
    fi
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-help}" in
    ensure-left)
        ensure_left_session
        ;;
    ensure-right)
        ensure_right_session
        ;;
    ensure-all)
        ensure_all_sessions
        ;;
    cleanup)
        cleanup_sessions
        ;;
    status)
        status
        ;;
    create-window)
        create_window_in_session "$2" "$3" "$4" "$5" "$6"
        ;;
    help|*)
        cat <<EOF
Yazibar Session Manager

COMMANDS:
  ensure-left               Ensure left sidebar session exists
  ensure-right              Ensure right sidebar session exists
  ensure-all                Ensure both sessions exist
  cleanup                   Destroy all yazibar sessions
  status                    Show session status
  create-window <srv> <ses> <name> <cmd> [dir]
                           Create window in session

USAGE:
  $0 ensure-all
  $0 status
  $0 cleanup
EOF
        ;;
esac
