#!/usr/bin/env bash
# Toggle tmux context mode between TMUX and NEOVIM
# Sets manual override flag to prevent auto-detection from overwriting
# Location: ~/.tmux/modules/menus/modes/toggle-context.sh

# Get current context
current=$(tmux show-option -gqv @tmux-context-mode)
current="${current:-TMUX}"

# Toggle to the other context
if [ "$current" = "TMUX" ]; then
    new_context="NEOVIM"
else
    new_context="TMUX"
fi

# Set the manual override flag - prevents hook from auto-updating
tmux set-option -g @tmux-context-manual 1

# Set the new context
tmux set-option -g @tmux-context-mode "$new_context"

# Refresh status bar to show the change
tmux refresh-client -S

# Display notification
tmux display-message "Context: $new_context (manual override - use 'Reset Context' to return to auto)"
