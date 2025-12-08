#!/usr/bin/env bash
# Toggle yazi sidebar pane in tmux
# This creates a persistent left-side pane for file navigation

YAZI_PANE_TITLE="yazi-sidebar"
SIDEBAR_WIDTH="30%"

# Use tmux user option to track the sidebar pane ID
# This is more reliable than pane titles which can be overwritten
get_sidebar_pane() {
    tmux show-option -qv "@yazi-sidebar-pane-id"
}

set_sidebar_pane() {
    tmux set-option -q "@yazi-sidebar-pane-id" "$1"
}

clear_sidebar_pane() {
    tmux set-option -qu "@yazi-sidebar-pane-id"
}

# Check if the tracked pane still exists and is running yazi
yazi_pane_id=$(get_sidebar_pane)
if [ -n "$yazi_pane_id" ]; then
    # Verify the pane still exists
    if ! tmux list-panes -F "#{pane_id}" | grep -q "^${yazi_pane_id}$"; then
        # Pane was closed, clear the tracking
        clear_sidebar_pane
        yazi_pane_id=""
    fi
fi

if [ -n "$yazi_pane_id" ]; then
    # Sidebar exists - check if it's currently focused
    current_pane=$(tmux display-message -p '#{pane_id}')

    if [ "$yazi_pane_id" = "$current_pane" ]; then
        # Already in sidebar, close it and return to main pane
        tmux select-pane -R
        tmux kill-pane -t "$yazi_pane_id"
        clear_sidebar_pane
        tmux display-message "Closed yazi sidebar"
    else
        # Not in sidebar, focus it
        tmux select-pane -t "$yazi_pane_id"
        tmux display-message "Focused yazi sidebar"
    fi
else
    # Get the current pane's working directory
    current_dir=$(tmux display-message -p '#{pane_current_path}')

    # Store the current pane ID to return focus
    current_pane=$(tmux display-message -p '#{pane_id}')

    # Create a left split with yazi
    # -h = horizontal split (side by side)
    # -b = create the new pane to the left (before current)
    # -l = size of new pane
    # -f = full height (not constrained by current pane)
    new_pane_id=$(tmux split-window -fh -b -l "$SIDEBAR_WIDTH" -c "$current_dir" -P -F "#{pane_id}" "
        # Set pane title for identification
        printf '\033]2;%s\033\\' '$YAZI_PANE_TITLE'

        # Set yazi config location (using sidebar-specific config)
        export YAZI_CONFIG_HOME=\"\${YAZI_CONFIG_HOME:-\$CORE_CFG/yazi}/profiles/sidebar-left\"

        # Run yazi with persistent mode
        \$TMUX_CONF/scripts/yazi-sidebar-persistent.sh \"$current_dir\"
    ")

    # Save the pane ID for tracking
    set_sidebar_pane "$new_pane_id"

    # Focus into the newly created sidebar pane
    tmux select-pane -t "$new_pane_id"
    tmux display-message "Yazi sidebar opened (Alt+F to toggle, Alt+Shift+F for preview)"
fi
