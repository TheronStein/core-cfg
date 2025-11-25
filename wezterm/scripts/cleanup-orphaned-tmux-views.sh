#!/usr/bin/env bash
# Cleanup orphaned tmux view sessions
# This script can be run manually or triggered automatically

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if tmux is available
if ! command -v tmux &>/dev/null; then
    echo -e "${RED}Error: tmux not found${NC}" >&2
    exit 1
fi

# Get list of all tmux sockets (workspaces)
get_tmux_sockets() {
    local sockets=()

    # Add default socket
    sockets+=("")

    # Add workspace sockets from XDG_RUNTIME_DIR
    if [ -d "${XDG_RUNTIME_DIR:-/run/user/$UID}" ]; then
        while IFS= read -r socket; do
            local socket_name=$(basename "$socket" | sed 's/^tmux-[0-9]*\///')
            if [ -n "$socket_name" ] && [ "$socket_name" != "default" ]; then
                sockets+=("$socket_name")
            fi
        done < <(find "${XDG_RUNTIME_DIR:-/run/user/$UID}" -maxdepth 1 -type d -name "tmux-*" 2>/dev/null || true)
    fi

    printf '%s\n' "${sockets[@]}"
}

# Get all view sessions from a socket
get_view_sessions() {
    local socket_flag="$1"

    if [ -n "$socket_flag" ]; then
        tmux -L "$socket_flag" list-sessions -F '#{session_name}|#{session_attached}|#{session_group}' 2>/dev/null || true
    else
        tmux list-sessions -F '#{session_name}|#{session_attached}|#{session_group}' 2>/dev/null || true
    fi
}

# Main cleanup logic
cleanup_orphaned_views() {
    local total_cleaned=0

    echo -e "${YELLOW}Scanning for orphaned tmux view sessions...${NC}"

    # Check each socket
    while IFS= read -r socket; do
        local socket_info=""
        local socket_flag=""

        if [ -n "$socket" ]; then
            socket_info=" [socket: $socket]"
            socket_flag="$socket"
        fi

        # Get all sessions from this socket
        while IFS='|' read -r session_name attached group; do
            # Check if this is a view session (matches *-view-<timestamp>-<random>)
            if [[ "$session_name" =~ -view-[0-9]+-[0-9]+$ ]]; then
                # Only cleanup if NOT attached
                if [ "$attached" = "0" ]; then
                    echo -e "${GREEN}Cleaning up: ${session_name}${socket_info}${NC}"

                    if [ -n "$socket_flag" ]; then
                        tmux -L "$socket_flag" kill-session -t "$session_name" 2>/dev/null || {
                            echo -e "${RED}Failed to kill: ${session_name}${NC}" >&2
                        }
                    else
                        tmux kill-session -t "$session_name" 2>/dev/null || {
                            echo -e "${RED}Failed to kill: ${session_name}${NC}" >&2
                        }
                    fi

                    ((total_cleaned++)) || true
                else
                    echo -e "${YELLOW}Skipping attached view: ${session_name}${socket_info}${NC}"
                fi
            fi
        done < <(get_view_sessions "$socket_flag")

    done < <(get_tmux_sockets)

    if [ "$total_cleaned" -gt 0 ]; then
        echo -e "${GREEN}✓ Cleaned up ${total_cleaned} orphaned view session(s)${NC}"
    else
        echo -e "${YELLOW}No orphaned view sessions found${NC}"
    fi

    return 0
}

# Run cleanup
cleanup_orphaned_views
