#!/usr/bin/env bash
# Tmux-aware Neovim opener for Yazi
# Sidebar-aware: creates smart splits in content area
# Supports opening multiple files at once

# Handle multiple files - store all arguments
FILES=("$@")

# Check if we're in tmux
if [ -z "$TMUX" ]; then
    nvim "${FILES[@]}"
    exit 0
fi

# Source yazibar utilities for sidebar detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"
source "$TMUX_CONF/modules/yazibar/scripts/yazibar-utils.sh" 2>/dev/null || true

CURRENT_WINDOW=$(tmux display-message -p '#{window_id}')

# Get sidebar pane IDs for exclusion (window-scoped)
LEFT_SIDEBAR=""
RIGHT_SIDEBAR=""
if type get_left_pane &>/dev/null && type get_right_pane &>/dev/null; then
    LEFT_SIDEBAR=$(get_left_pane)
    RIGHT_SIDEBAR=$(get_right_pane)
fi

# Get content panes (exclude sidebars)
CONTENT_PANES=()
while IFS= read -r pane; do
    # Skip sidebar panes
    if [ "$pane" = "$LEFT_SIDEBAR" ] || [ "$pane" = "$RIGHT_SIDEBAR" ]; then
        continue
    fi
    CONTENT_PANES+=("$pane")
done < <(tmux list-panes -t "$CURRENT_WINDOW" -F '#{pane_id}')

# Find existing nvim pane in content area
NVIM_PANE=""
for pane in "${CONTENT_PANES[@]}"; do
    CMD=$(tmux display-message -p -t "$pane" '#{pane_current_command}')
    if [[ "$CMD" == "nvim" ]]; then
        NVIM_PANE="$pane"
        break
    fi
done

if [ -n "$NVIM_PANE" ]; then
    # Found nvim - open all files there
    # Focus the nvim pane first
    tmux select-pane -t "$NVIM_PANE"

    # Escape to normal mode first (C-\ C-n works from any mode)
    tmux send-keys -t "$NVIM_PANE" C-\\ C-n

    # Small delay to ensure mode switch completes
    sleep 0.05

    # First file with :e, subsequent files with :badd to add to buffer list
    FIRST_FILE="${FILES[0]}"
    # Escape special characters for vim command line
    escaped_file="${FIRST_FILE//\'/\'\'}"
    tmux send-keys -t "$NVIM_PANE" ":e ${escaped_file}" Enter

    # Add remaining files to buffer list
    for ((i=1; i<${#FILES[@]}; i++)); do
        escaped_file="${FILES[$i]//\'/\'\'}"
        tmux send-keys -t "$NVIM_PANE" ":badd ${escaped_file}" Enter
    done
else
    # No nvim found - create horizontal split (side by side)

    # Find a suitable target pane (first content pane)
    TARGET_PANE="${CONTENT_PANES[0]}"
    if [ -z "$TARGET_PANE" ]; then
        # Fallback to current pane if no content panes found
        TARGET_PANE=$(tmux display-message -p '#{pane_id}')
    fi

    # Get first file's directory for working directory
    FIRST_FILE="${FILES[0]}"
    FILE_DIR=$(dirname "$FIRST_FILE")

    # Build properly quoted file arguments for nvim
    NVIM_ARGS=""
    for f in "${FILES[@]}"; do
        NVIM_ARGS="$NVIM_ARGS $(printf '%q' "$f")"
    done

    # Create horizontal split (side by side, -h flag)
    # Use 50% width for the new nvim pane
    NEW_PANE=$(tmux split-window -t "$TARGET_PANE" -h -p 50 -c "$FILE_DIR" -P -F '#{pane_id}' "nvim $NVIM_ARGS")

    # Select the new nvim pane
    tmux select-pane -t "$NEW_PANE"
fi
