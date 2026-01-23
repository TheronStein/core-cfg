#!/usr/bin/env bash
# Reset context mode to auto-detection
# Clears manual override flag and re-detects based on current pane
# Location: ~/.tmux/modules/menus/modes/reset-context.sh

# Clear the manual override flag
tmux set-option -gu @tmux-context-manual

# Re-detect context based on current pane command
pane_cmd=$(tmux display-message -p '#{pane_current_command}')

if echo "$pane_cmd" | grep -iqE "^(n?vim|nvim)$"; then
    tmux set-option -g @tmux-context-mode NEOVIM
    new_context="NEOVIM"
else
    tmux set-option -g @tmux-context-mode TMUX
    new_context="TMUX"
fi

# Refresh status bar
tmux refresh-client -S

# Display notification
tmux display-message "Context: $new_context (auto-detection restored)"
