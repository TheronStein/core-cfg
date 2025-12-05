#!/usr/bin/env bash
# Opens file(s) in existing Neovim session or creates new one
# Supports opening multiple files at once

FILES=("$@")

# Get current pane's command
PANE_CMD=$(tmux display-message -p '#{pane_current_command}')

if [[ "$PANE_CMD" == "nvim" ]]; then
    # Send files to existing Neovim
    # First file with :e, remaining with :badd
    FIRST_FILE="${FILES[0]}"
    tmux send-keys Escape ":e $(printf '%q' "$FIRST_FILE")" Enter
    for ((i=1; i<${#FILES[@]}; i++)); do
        tmux send-keys ":badd $(printf '%q' "${FILES[$i]}")" Enter
    done
else
    # Check if Neovim is running in any pane in current window
    NVIM_PANE=$(tmux list-panes -F '#{pane_id} #{pane_current_command}' | grep nvim | head -1 | cut -d' ' -f1)

    if [[ -n "$NVIM_PANE" ]]; then
        # Switch to Neovim pane and open files
        tmux select-pane -t "$NVIM_PANE"
        FIRST_FILE="${FILES[0]}"
        tmux send-keys -t "$NVIM_PANE" Escape ":e $(printf '%q' "$FIRST_FILE")" Enter
        for ((i=1; i<${#FILES[@]}; i++)); do
            tmux send-keys -t "$NVIM_PANE" ":badd $(printf '%q' "${FILES[$i]}")" Enter
        done
    else
        # Open new Neovim instance in current pane with all files
        nvim "${FILES[@]}"
    fi
fi
