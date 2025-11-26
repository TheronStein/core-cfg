#!/usr/bin/env bash
# Opens file in existing Neovim session or creates new one

FILE="$1"

# Get current pane's command
PANE_CMD=$(tmux display-message -p '#{pane_current_command}')

if [[ "$PANE_CMD" == "nvim" ]]; then
    # Send file to existing Neovim
    tmux send-keys Escape ":e ${FILE}" Enter
else
    # Check if Neovim is running in any pane in current window
    NVIM_PANE=$(tmux list-panes -F '#{pane_id} #{pane_current_command}' | grep nvim | head -1 | cut -d' ' -f1)

    if [[ -n "$NVIM_PANE" ]]; then
        # Switch to Neovim pane and open file
        tmux select-pane -t "$NVIM_PANE"
        tmux send-keys -t "$NVIM_PANE" Escape ":e ${FILE}" Enter
    else
        # Open new Neovim instance in current pane
        nvim "$FILE"
    fi
fi
