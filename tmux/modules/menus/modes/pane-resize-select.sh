#!/bin/bash
# Pane Resize & Select Keytable
# Enter mode, use keys, press Escape or Enter to exit

# Save current status-left and status-right settings
ORIGINAL_STATUS_LEFT=$(tmux show-option -gv status-left)
ORIGINAL_STATUS_RIGHT=$(tmux show-option -gv status-right)
tmux set-option -g @resize_mode_status_left "$ORIGINAL_STATUS_LEFT"
tmux set-option -g @resize_mode_status_right "$ORIGINAL_STATUS_RIGHT"

# Save current pane border colors
ORIGINAL_PANE_BORDER=$(tmux show-option -gv pane-border-style 2>/dev/null || echo "default")
ORIGINAL_PANE_ACTIVE_BORDER=$(tmux show-option -gv pane-active-border-style 2>/dev/null || echo "default")
tmux set-option -g @resize_mode_pane_border "$ORIGINAL_PANE_BORDER"
tmux set-option -g @resize_mode_pane_active_border "$ORIGINAL_PANE_ACTIVE_BORDER"

# Create the keytable (unbind first to avoid conflicts)
tmux unbind-key -T resize-select-mode -a

# Pane selection - must re-enter the table after each command
tmux bind-key -T resize-select-mode i "select-pane -U ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode k "select-pane -D ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode j "select-pane -L ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode l "select-pane -R ; switch-client -T resize-select-mode"

# Resize - small increments (2 cells)
tmux bind-key -T resize-select-mode w "resize-pane -U 2 ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode s "resize-pane -D 2 ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode a "resize-pane -L 2 ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode d "resize-pane -R 2 ; switch-client -T resize-select-mode"

# Resize - medium increments (5 cells) with Ctrl
tmux bind-key -T resize-select-mode C-w "resize-pane -U 5 ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode C-s "resize-pane -D 5 ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode C-a "resize-pane -L 5 ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode C-d "resize-pane -R 5 ; switch-client -T resize-select-mode"

# Resize - large increments (10 cells) with Shift
tmux bind-key -T resize-select-mode W "resize-pane -U 10 ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode S "resize-pane -D 10 ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode A "resize-pane -L 10 ; switch-client -T resize-select-mode"
tmux bind-key -T resize-select-mode D "resize-pane -R 10 ; switch-client -T resize-select-mode"

# Exit keys - restore status bar when exiting
EXIT_SCRIPT="$TMUX_CONF/events/exit-resize-mode.sh"
tmux bind-key -T resize-select-mode Escape run-shell "$EXIT_SCRIPT" \; switch-client -T root
tmux bind-key -T resize-select-mode Enter run-shell "$EXIT_SCRIPT" \; switch-client -T root
tmux bind-key -T resize-select-mode q run-shell "$EXIT_SCRIPT" \; switch-client -T root

# Set status bar to show RESIZE mode
tmux set-option -g status-left "#[bg=#F78C6C,fg=#000000,bold] RESIZE #[bg=default,fg=default] "
tmux set-option -g status-right "#[bg=#F78C6C,fg=#000000,bold] Select:i/j/k/l Resize:w/a/s/d Exit:Esc "

# Set pane border colors
# Active pane: #F78C6C (full saturation orange)
# Inactive pane: #C9A793 (desaturated version of #F78C6C)
tmux set-option -g pane-active-border-style "fg=#F78C6C"
tmux set-option -g pane-border-style "fg=#C9A793"

# Display help message and enter the mode
tmux display-message "Resize/Select Mode | Select: i/j/k/l | Resize: w/a/s/d (2) | Ctrl+w/a/s/d (5) | Shift+W/A/S/D (10) | Exit: Esc/Enter/q"
tmux switch-client -T resize-select-mode
