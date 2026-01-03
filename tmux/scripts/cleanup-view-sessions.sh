#!/usr/bin/env bash
# cleanup-view-sessions.sh
# Manual cleanup script for orphaned tmux view sessions
#
# This script finds and removes orphaned view sessions that:
# 1. Have no attached clients
# 2. Match the pattern *-view-<timestamp>-<random>
#
# Usage:
#   cleanup-view-sessions.sh [--dry-run] [--verbose] [--socket SOCKET_NAME]

set -euo pipefail

# Configuration
DRY_RUN=false
VERBOSE=false
SOCKET_NAME=""
AGE_THRESHOLD=300  # 5 minutes in seconds

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -s|--socket)
            SOCKET_NAME="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--verbose] [--socket SOCKET_NAME]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be deleted without actually deleting"
            echo "  -v, --verbose    Show detailed information"
            echo "  -s, --socket    Specify tmux socket name (default: all sockets)"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Function to log messages
log() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}[INFO]${NC} $*"
    fi
}

# Function to get current timestamp
now() {
    date +%s
}

# Function to format age
format_age() {
    local age=$1
    if [[ $age -lt 60 ]]; then
        echo "${age}s"
    elif [[ $age -lt 3600 ]]; then
        echo "$((age / 60))m"
    else
        echo "$((age / 3600))h"
    fi
}

# Function to cleanup view sessions
cleanup_sessions() {
    local socket_flag=""
    if [[ -n "$SOCKET_NAME" ]]; then
        socket_flag="-L '$SOCKET_NAME'"
    fi

    # Get all sessions with their info
    local sessions
    sessions=$(eval "tmux ${socket_flag} list-sessions -F '#{session_name}|#{session_attached}|#{session_created}|#{session_group}' 2>/dev/null" || true)

    if [[ -z "$sessions" ]]; then
        echo -e "${YELLOW}No tmux sessions found${NC}"
        return 0
    fi

    local cleaned_count=0
    local skipped_count=0
    local current_time=$(now)

    echo -e "${BLUE}Scanning for orphaned view sessions...${NC}"
    echo ""

    while IFS='|' read -r session_name attached created group; do
        # Check if this is a view session
        if [[ "$session_name" =~ -view-[0-9]+-[0-9]+ ]]; then
            # Calculate age
            local age=$((current_time - created))
            local age_str=$(format_age "$age")

            # Check if attached
            if [[ "$attached" == "0" ]]; then
                if [[ "$DRY_RUN" == true ]]; then
                    echo -e "${YELLOW}[DRY-RUN]${NC} Would delete: $session_name (age: $age_str, group: ${group:-none})"
                    ((cleaned_count++))
                else
                    echo -e "${RED}[DELETE]${NC} Killing: $session_name (age: $age_str, group: ${group:-none})"
                    if eval "tmux ${socket_flag} kill-session -t '$session_name' 2>/dev/null"; then
                        ((cleaned_count++))
                    else
                        echo -e "${RED}[ERROR]${NC} Failed to kill: $session_name"
                    fi
                fi
            else
                log "Skipping (attached): $session_name (age: $age_str, clients: $attached)"
                ((skipped_count++))
            fi
        fi
    done <<< "$sessions"

    echo ""
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${GREEN}Dry-run complete:${NC} Would clean up $cleaned_count session(s)"
    else
        echo -e "${GREEN}Cleanup complete:${NC} Removed $cleaned_count orphaned view session(s)"
    fi

    if [[ $skipped_count -gt 0 ]]; then
        log "Skipped $skipped_count active view session(s)"
    fi

    return 0
}

# Main execution
echo -e "${BLUE}=== Tmux View Session Cleanup ===${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}Running in DRY-RUN mode (no changes will be made)${NC}"
    echo ""
fi

cleanup_sessions

echo ""
echo -e "${GREEN}Done!${NC}"
