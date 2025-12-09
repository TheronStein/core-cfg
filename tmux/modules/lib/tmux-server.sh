#!/usr/bin/env bash
# modules/lib/tmux-server.sh
# Server-level operations and queries
#
# Provides functions for checking tmux server status and
# server-level operations.

server_running() {
    tmux info &>/dev/null
}

get_socket_path() {
    local socket_path
    if [ -n "$TMUX" ]; then
        # Extract socket path from TMUX environment variable
        # Format: /tmp/tmux-1000/default,12345,0
        socket_path=$(echo "$TMUX" | cut -d',' -f1)
        echo "$socket_path"
    else
        # Try to find default socket
        tmux display-message -p '#{socket_path}' 2>/dev/null || \
            echo "/tmp/tmux-$(id -u)/default"
    fi
}

get_tmux_version() {
    tmux -V | cut -d' ' -f2
}

compare_version() {
    local version="$1"
    local target="$2"

    if [ "$(printf '%s\n' "$version" "$target" | sort -V | head -n1)" = "$target" ]; then
        return 0  # version >= target
    else
        return 1  # version < target
    fi
}

validate_tmux_version() {
    local required="$1"
    local current
    current=$(get_tmux_version)

    if ! compare_version "$current" "$required"; then
        echo "ERROR: tmux version $required or higher required (current: $current)" >&2
        return 1
    fi
    return 0
}

# Export functions
export -f server_running get_socket_path get_tmux_version
export -f compare_version validate_tmux_version
