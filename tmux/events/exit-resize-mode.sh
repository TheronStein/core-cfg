#!/bin/bash
# Restore status bar and pane borders when exiting resize mode

# Restore status bar
SAVED_LEFT=$(tmux show-option -gv @resize_mode_status_left 2>/dev/null)
SAVED_RIGHT=$(tmux show-option -gv @resize_mode_status_right 2>/dev/null)

if [ -n "$SAVED_LEFT" ]; then
    tmux set-option -g status-left "$SAVED_LEFT"
fi

if [ -n "$SAVED_RIGHT" ]; then
    tmux set-option -g status-right "$SAVED_RIGHT"
fi

# Restore pane border colors
SAVED_PANE_BORDER=$(tmux show-option -gv @resize_mode_pane_border 2>/dev/null)
SAVED_PANE_ACTIVE_BORDER=$(tmux show-option -gv @resize_mode_pane_active_border 2>/dev/null)

if [ -n "$SAVED_PANE_BORDER" ] && [ "$SAVED_PANE_BORDER" != "default" ]; then
    tmux set-option -g pane-border-style "$SAVED_PANE_BORDER"
else
    tmux set-option -gu pane-border-style
fi

if [ -n "$SAVED_PANE_ACTIVE_BORDER" ] && [ "$SAVED_PANE_ACTIVE_BORDER" != "default" ]; then
    tmux set-option -g pane-active-border-style "$SAVED_PANE_ACTIVE_BORDER"
else
    tmux set-option -gu pane-active-border-style
fi

# Clean up saved options
tmux set-option -gu @resize_mode_status_left
tmux set-option -gu @resize_mode_status_right
tmux set-option -gu @resize_mode_pane_border
tmux set-option -gu @resize_mode_pane_active_border

# Clear custom mode and refresh status bar
tmux set-option -gu @custom_mode
tmux refresh-client -S
