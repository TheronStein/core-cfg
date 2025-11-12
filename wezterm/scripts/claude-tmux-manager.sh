#!/usr/bin/env bash

# Claude Tmux Manager
# Manages tmux session "ai" with directory-aware windows for Claude
# Usage: claude-tmux-manager.sh <directory>

set -euo pipefail

SESSION_NAME="ai"
TARGET_DIR="${1:-$HOME}"
CLAUDE_CMD="claude"

# Normalize the target directory path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Function to get window name from directory (parent/directory format)
get_window_name() {
    local dir="$1"
    local parent_dir=$(basename "$(dirname "$dir")")
    local current_dir=$(basename "$dir")

    # Special case for home directory
    if [ "$dir" = "$HOME" ]; then
        echo "~"
    # Special case for root directory
    elif [ "$dir" = "/" ]; then
        echo "/"
    else
        echo "${parent_dir}/${current_dir}"
    fi
}

# Function to check if tmux session exists
session_exists() {
    tmux has-session -t "$SESSION_NAME" 2>/dev/null
}

# Function to find window index by directory
find_window_by_dir() {
    local dir="$1"

    if ! session_exists; then
        return 1
    fi

    # List all windows with their pane working directories
    # Format: window_index:pane_current_path
    while IFS=: read -r win_idx pane_path; do
        if [ "$pane_path" = "$dir" ]; then
            echo "$win_idx"
            return 0
        fi
    done < <(tmux list-windows -t "$SESSION_NAME" -F "#{window_index}:#{pane_current_path}" 2>/dev/null)

    return 1
}

# Function to check if claude is running in a window
is_claude_running() {
    local win_idx="$1"
    local cmd

    cmd=$(tmux list-panes -t "${SESSION_NAME}:${win_idx}" -F "#{pane_current_command}" 2>/dev/null | head -1)

    if [[ "$cmd" == *"claude"* ]]; then
        return 0
    fi
    return 1
}

# Main logic
main() {
    # Create session if it doesn't exist
    if ! session_exists; then
        tmux new-session -d -s "$SESSION_NAME" -n "$(get_window_name "$TARGET_DIR")" -c "$TARGET_DIR"
        tmux send-keys -t "${SESSION_NAME}:0" "$CLAUDE_CMD" C-m
    fi

    # Check if there's already a window for this directory
    local existing_window
    if existing_window=$(find_window_by_dir "$TARGET_DIR"); then
        # Check if claude is running in that window
        if ! is_claude_running "$existing_window"; then
            tmux send-keys -t "${SESSION_NAME}:${existing_window}" "$CLAUDE_CMD" C-m
        fi

        # Select that window
        tmux select-window -t "${SESSION_NAME}:${existing_window}"
    else
        # Create new window for this directory
        local win_name
        win_name=$(get_window_name "$TARGET_DIR")
        tmux new-window -t "$SESSION_NAME" -n "$win_name" -c "$TARGET_DIR"
        local new_win_idx
        new_win_idx=$(tmux list-windows -t "$SESSION_NAME" -F "#{window_index}" | tail -1)
        tmux send-keys -t "${SESSION_NAME}:${new_win_idx}" "$CLAUDE_CMD" C-m
        tmux select-window -t "${SESSION_NAME}:${new_win_idx}"
    fi

    # Attach to the session (this keeps the pane alive and shows tmux)
    tmux attach-session -t "$SESSION_NAME"
}

main
