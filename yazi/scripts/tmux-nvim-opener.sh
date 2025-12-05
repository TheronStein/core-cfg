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

# Source sidebar helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../tmux/scripts/sidebar-helpers.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../tmux/modules/yazibar/scripts/yazibar-utils.sh" 2>/dev/null || true

CURRENT_WINDOW=$(tmux display-message -p '#{window_id}')

# Get content panes (exclude sidebars)
if type get_content_panes &>/dev/null; then
    CONTENT_PANES=($(get_content_panes "$CURRENT_WINDOW"))
else
    # Fallback if helpers not available
    CONTENT_PANES=($(tmux list-panes -t "$CURRENT_WINDOW" -F '#{pane_id}'))
fi

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
    # First file with :e, subsequent files with :badd to add to buffer list
    FIRST_FILE="${FILES[0]}"
    tmux send-keys -t "$NVIM_PANE" ":e $(printf '%q' "$FIRST_FILE")" C-m
    # Add remaining files to buffer list
    for ((i=1; i<${#FILES[@]}; i++)); do
        tmux send-keys -t "$NVIM_PANE" ":badd $(printf '%q' "${FILES[$i]}")" C-m
    done
    tmux select-pane -t "$NVIM_PANE"
else
    # No nvim found - create smart split
    # Prefer full-width horizontal split at bottom

    # Get window dimensions
    WINDOW_WIDTH=$(tmux display-message -p '#{window_width}')
    WINDOW_HEIGHT=$(tmux display-message -p '#{window_height}')

    # Get bottommost content pane
    BOTTOM_PANE=$(tmux list-panes -t "$CURRENT_WINDOW" -F '#{pane_id} #{pane_bottom}' | sort -k2 -nr | head -1 | awk '{print $1}')

    # Check if bottom pane is a sidebar
    IS_SIDEBAR=false
    if type is_sidebar_pane &>/dev/null && is_sidebar_pane "$BOTTOM_PANE"; then
        IS_SIDEBAR=true
        # Use first content pane instead
        BOTTOM_PANE="${CONTENT_PANES[0]}"
    fi

    # Temporarily disable layout restore hooks during split
    tmux set-hook -gu after-split-window
    tmux set-hook -gu window-resized

    # Build properly quoted file arguments for nvim
    NVIM_ARGS=""
    for f in "${FILES[@]}"; do
        NVIM_ARGS="$NVIM_ARGS $(printf '%q' "$f")"
    done

    # Determine optimal split: horizontal if width > height, else vertical
    if [ "$WINDOW_WIDTH" -gt "$WINDOW_HEIGHT" ]; then
        # Prefer full-width horizontal split (40% of window height for nvim)
        NVIM_HEIGHT=$((WINDOW_HEIGHT * 40 / 100))
        [ $NVIM_HEIGHT -lt 20 ] && NVIM_HEIGHT=20  # Minimum 20 lines

        # Split horizontally from bottom pane
        NEW_PANE=$(tmux split-window -t "$BOTTOM_PANE" -v -l "$NVIM_HEIGHT" -P -F '#{pane_id}' "nvim $NVIM_ARGS")
    else
        # Vertical split (60% width for nvim)
        NVIM_WIDTH=$((WINDOW_WIDTH * 60 / 100))
        [ $NVIM_WIDTH -lt 80 ] && NVIM_WIDTH=80  # Minimum 80 columns

        # Split vertically from first content pane
        NEW_PANE=$(tmux split-window -t "${CONTENT_PANES[0]}" -h -l "$NVIM_WIDTH" -P -F '#{pane_id}' "nvim $NVIM_ARGS")
    fi

    # Re-enable layout restore hooks
    tmux set-hook -g after-split-window 'run-shell "$CORE_CFG/tmux/scripts/layout-manager.sh restore"'
    tmux set-hook -g window-resized 'run-shell "$CORE_CFG/tmux/scripts/layout-manager.sh restore"'

    # Select the new nvim pane
    tmux select-pane -t "$NEW_PANE"
fi
