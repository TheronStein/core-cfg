#!/usr/bin/env bash
# Enhanced yazi wrapper for neovim integration
# This script handles file selection and sends it to neovim

YAZI_CHOOSER_FILE="/tmp/yazi-chooser-$$"
YAZI_CWD_FILE="/tmp/yazi-cwd-$$"

# Run yazi with chooser file
yazi --chooser-file="$YAZI_CHOOSER_FILE" --cwd-file="$YAZI_CWD_FILE" "$@"

# Check if files were chosen
if [ -f "$YAZI_CHOOSER_FILE" ]; then
    chosen_files=$(cat "$YAZI_CHOOSER_FILE")

    if [ -n "$chosen_files" ]; then
        # Find nvim pane in current window
        nvim_pane=$(tmux list-panes -F '#{pane_id} #{pane_current_command}' | \
                    grep -iE 'n?vim' | head -1 | awk '{print $1}')

        if [ -n "$nvim_pane" ]; then
            # Send files to neovim
            while IFS= read -r file; do
                if [ -f "$file" ]; then
                    # Escape to normal mode and open file
                    tmux send-keys -t "$nvim_pane" Escape
                    tmux send-keys -t "$nvim_pane" ":e $file" Enter
                elif [ -d "$file" ]; then
                    # If it's a directory, cd to it
                    tmux send-keys -t "$nvim_pane" Escape
                    tmux send-keys -t "$nvim_pane" ":cd $file" Enter
                fi
            done <<< "$chosen_files"

            # Switch focus to nvim pane
            tmux select-pane -t "$nvim_pane"
        else
            # No nvim found, just print the files
            echo "Selected files:"
            echo "$chosen_files"
        fi
    fi

    rm -f "$YAZI_CHOOSER_FILE"
fi

# Handle directory changes
if [ -f "$YAZI_CWD_FILE" ]; then
    new_dir=$(cat "$YAZI_CWD_FILE")
    if [ -d "$new_dir" ]; then
        cd "$new_dir" || exit
    fi
    rm -f "$YAZI_CWD_FILE"
fi
