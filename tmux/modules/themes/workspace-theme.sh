#!/usr/bin/env bash

WORKSPACE="$1"
THEME_NAME="$2"

# Source the theme file for the workspace
source ~/.config/tmux/themes/${THEME_NAME}.conf

# Apply the theme to tmux
tmux set-option -g status-style "bg=${STATUS_BG},fg=${STATUS_FG}"
tmux set-option -g status-left "${STATUS_LEFT}"
tmux set-option -g status-right "${STATUS_RIGHT}"
tmux set-option -g status-left-length ${STATUS_LEFT_LENGTH}
tmux set-option -g status-right-length ${STATUS_RIGHT_LENGTH}

# Window status
tmux set-window-option -g window-status-style "bg=${WINDOW_STATUS_BG},fg=${WINDOW_STATUS_FG}"
tmux set-window-option -g window-status-current-style "bg=${WINDOW_STATUS_CURRENT_BG},fg=${WINDOW_STATUS_CURRENT_FG}"
tmux set-window-option -g window-status-format "${WINDOW_STATUS_FORMAT}"
tmux set-window-option -g window-status-current-format "${WINDOW_STATUS_CURRENT_FORMAT}"

# Pane borders
tmux set-option -g pane-border-style "fg=${PANE_BORDER_FG}"
tmux set-option -g pane-active-border-style "fg=${PANE_ACTIVE_BORDER_FG}"

# Message style
tmux set-option -g message-style "bg=${MESSAGE_BG},fg=${MESSAGE_FG}"
tmux set-option -g message-command-style "bg=${MESSAGE_COMMAND_BG},fg=${MESSAGE_COMMAND_FG}"

# Store current workspace and theme
tmux set-environment -g CURRENT_WORKSPACE_THEME "$THEME_NAME"
tmux set-environment -g CURRENT_WORKSPACE "$WORKSPACE"

# Also trigger the matrix theme change
~/.config/tmux/matrix-workspace.sh "$WORKSPACE"
