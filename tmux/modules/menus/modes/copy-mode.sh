#!/bin/bash
# Copy Mode with status bar indication

# Save current status-left and status-right settings
ORIGINAL_STATUS_LEFT=$(tmux show-option -gv status-left)
ORIGINAL_STATUS_RIGHT=$(tmux show-option -gv status-right)
tmux set-option -g @copy_mode_status_left "$ORIGINAL_STATUS_LEFT"
tmux set-option -g @copy_mode_status_right "$ORIGINAL_STATUS_RIGHT"

# Save current pane border colors
ORIGINAL_PANE_BORDER=$(tmux show-option -gv pane-border-style 2>/dev/null || echo "default")
ORIGINAL_PANE_ACTIVE_BORDER=$(tmux show-option -gv pane-active-border-style 2>/dev/null || echo "default")
tmux set-option -g @copy_mode_pane_border "$ORIGINAL_PANE_BORDER"
tmux set-option -g @copy_mode_pane_active_border "$ORIGINAL_PANE_ACTIVE_BORDER"

# Set up hook to restore status bar when copy mode exits
tmux set-hook -g pane-mode-changed "run-shell 'if [ \"\$(tmux display-message -p \"#{pane_mode}\")\" != \"copy-mode\" ]; then $TMUX_MENUS/exit-copy-mode.sh; fi'"

# Set status bar to show COPY mode
# Using a greenish color for COPY mode to differentiate from RESIZE
tmux set-option -g status-left "#[bg=#C3E88D,fg=#000000,bold] COPY #[bg=default,fg=default] "
tmux set-option -g status-right "#[bg=#C3E88D,fg=#000000,bold] Navigate:hjkl Search:/ Exit:q "

# Set pane border colors
# Active pane: #C3E88D (green)
# Inactive pane: #A8C99B (desaturated green)
tmux set-option -g pane-active-border-style "fg=#C3E88D"
tmux set-option -g pane-border-style "fg=#A8C99B"

# Enter copy mode
tmux copy-mode
