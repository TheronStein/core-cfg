#!/usr/bin/env bash
# Persistent yazi sidebar with neovim integration
# Stays open after file selection - toggle with Alt+F to close

START_DIR="${1:-$PWD}"
CHOOSER_FILE="/tmp/yazi-sidebar-chooser-$$"
CWD_FILE="/tmp/yazi-sidebar-cwd-$$"

# Send file to neovim without exiting yazi
send_to_nvim() {
    local file="$1"

    # Find nvim pane in current window
    local nvim_pane=$(tmux list-panes -F '#{pane_id} #{pane_current_command}' | \
                      grep -iE 'n?vim' | head -1 | awk '{print $1}')

    if [ -n "$nvim_pane" ]; then
        if [ -f "$file" ]; then
            # Send file to neovim
            tmux send-keys -t "$nvim_pane" Escape
            tmux send-keys -t "$nvim_pane" ":e $file" Enter
            tmux display-message "Opened: $(basename "$file")"
        elif [ -d "$file" ]; then
            # Change directory in neovim
            tmux send-keys -t "$nvim_pane" Escape
            tmux send-keys -t "$nvim_pane" ":cd $file" Enter
            tmux display-message "Changed dir: $(basename "$file")"
        fi
        # Switch focus to nvim
        tmux select-pane -t "$nvim_pane"
    else
        tmux display-message "No neovim pane found"
    fi
}

# Main loop - keep yazi running in persistent mode
cd "$START_DIR" || exit 1

# Enable sidebar mode for any custom behavior in init.lua
export YAZI_SIDEBAR_MODE=1

while true; do
    # Clean up old temp files
    rm -f "$CHOOSER_FILE" "$CWD_FILE"

    # Run yazi with chooser file for file selection
    # DDS will automatically broadcast hover/cd events to remote instances
    yazi \
        --chooser-file="$CHOOSER_FILE" \
        --cwd-file="$CWD_FILE" \
        "$PWD"

    yazi_exit=$?

    # Check if user quit yazi (q key)
    if [ $yazi_exit -ne 0 ]; then
        # User pressed q or quit - exit the loop
        break
    fi

    # Check if a file was chosen
    if [ -f "$CHOOSER_FILE" ]; then
        chosen=$(cat "$CHOOSER_FILE")
        if [ -n "$chosen" ]; then
            # Send each selected file to neovim
            while IFS= read -r file; do
                send_to_nvim "$file"
            done <<< "$chosen"
        fi
        rm -f "$CHOOSER_FILE"
    fi

    # Update current directory if changed
    if [ -f "$CWD_FILE" ]; then
        new_dir=$(cat "$CWD_FILE")
        if [ -d "$new_dir" ]; then
            cd "$new_dir" || continue
        fi
        rm -f "$CWD_FILE"
    fi

    # If we got here, yazi was closed with Enter (file selected)
    # Restart yazi to keep the sidebar persistent
done

# Cleanup
rm -f "$CHOOSER_FILE" "$CWD_FILE"
exit 0
