#!/usr/bin/env bash
# Toggle yazi preview pane in tmux
# Only works when yazi sidebar is active

YAZI_SIDEBAR_TITLE="yazi-sidebar"
YAZI_PREVIEW_TITLE="yazi-preview"
PREVIEW_WIDTH="25%"

# Preview mode: "dds", "native", or "dual"
# - dds: DDS event-based text preview (lightweight, custom)
# - native: Single-column yazi preview (just the preview pane)
# - dual: Two-column yazi (current dir + preview)
PREVIEW_MODE="${YAZI_PREVIEW_MODE:-dds}"

# Use tmux user options to track pane IDs
get_sidebar_pane() {
    tmux show-option -qv "@yazi-sidebar-pane-id"
}

get_preview_pane() {
    tmux show-option -qv "@yazi-preview-pane-id"
}

set_preview_pane() {
    tmux set-option -q "@yazi-preview-pane-id" "$1"
}

clear_preview_pane() {
    tmux set-option -qu "@yazi-preview-pane-id"
}

# Check if yazi sidebar exists
yazi_sidebar_id=$(get_sidebar_pane)

if [ -z "$yazi_sidebar_id" ]; then
    tmux display-message "Yazi sidebar not active. Open sidebar first (Alt+F)"
    exit 0
fi

# Verify sidebar still exists
if ! tmux list-panes -F "#{pane_id}" | grep -q "^${yazi_sidebar_id}$"; then
    tmux display-message "Yazi sidebar not found. Open sidebar first (Alt+F)"
    exit 0
fi

# Check if preview pane already exists
yazi_preview_id=$(get_preview_pane)
if [ -n "$yazi_preview_id" ]; then
    # Verify the preview pane still exists
    if ! tmux list-panes -F "#{pane_id}" | grep -q "^${yazi_preview_id}$"; then
        # Pane was closed, clear tracking
        clear_preview_pane
        yazi_preview_id=""
    fi
fi

if [ -n "$yazi_preview_id" ]; then
    # Preview pane exists - close it
    tmux kill-pane -t "$yazi_preview_id"
    clear_preview_pane
    tmux display-message "Yazi preview closed"
else
    # Get the current hovered file from yazi sidebar
    # We'll create a preview pane and watch the selected file

    # Find the rightmost pane (should be after the main pane)
    # We want to create the preview on the right side of the window

    # Store current pane to restore focus
    current_pane=$(tmux display-message -p '#{pane_id}')

    # Select preview script based on mode
    case "$PREVIEW_MODE" in
        native)
            preview_script="$TMUX_CONF/scripts/yazi-preview-native.sh"
            ;;
        dual)
            preview_script="$TMUX_CONF/scripts/yazi-preview-dual.sh"
            ;;
        *)
            preview_script="$TMUX_CONF/scripts/yazi-preview-watcher.sh"
            ;;
    esac

    # Create preview pane on the right side of the window
    # -f = full height (maintains geometry)
    # -h = horizontal split
    # -l = size of new pane
    tmux split-window -fh -l "$PREVIEW_WIDTH" "
        # Set pane title for identification
        printf '\033]2;%s\033\\' '$YAZI_PREVIEW_TITLE'

        # Run the selected preview script
        exec $preview_script
    "

    # Get the newly created preview pane ID (it's the last pane created)
    preview_pane=$(tmux list-panes -F "#{pane_id}" | tail -1)

    # Save the preview pane ID for tracking
    set_preview_pane "$preview_pane"

    # Return focus to original pane
    tmux select-pane -t "$current_pane"
    tmux display-message "Yazi preview opened (Alt+Shift+F to toggle)"
fi
