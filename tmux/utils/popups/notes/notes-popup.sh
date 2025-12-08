#!/usr/bin/env bash

NOTES_DIR="$HOME/.core/docs/doc"
NOTES_SESSION="notes"

# Ensure notes directory exists
mkdir -p "$NOTES_DIR"

# Create notes session if it doesn't exist
if ! tmux has-session -t "$NOTES_SESSION" 2>/dev/null; then
    tmux new-session -d -s "$NOTES_SESSION" -c "$NOTES_DIR"
fi

# Get existing windows in notes session
get_windows() {
    tmux list-windows -t "$NOTES_SESSION" -F "#{window_name}" 2>/dev/null | sort
}

# Get existing directories in notes
get_directories() {
    find "$NOTES_DIR" -maxdepth 1 -type d -not -path "$NOTES_DIR" -exec basename {} \; | sort
}

# Combine windows and directories, preferring windows if both exist
get_window_options() {
    local windows=$(get_windows)
    local dirs=$(get_directories)

    # Use associative array to track what we've added
    declare -A added

    # Add all windows first
    while IFS= read -r window; do
        [ -n "$window" ] && echo "$window" && added["$window"]=1
    done <<<"$windows"

    # Add directories that don't have corresponding windows
    while IFS= read -r dir; do
        [ -n "$dir" ] && [ "${added[$dir]}" != "1" ] && echo "$dir"
    done <<<"$dirs"

    # Add create new option
    echo "[+] Create new window/directory"
}

# Create preview script
cat >/tmp/notes-preview-dir.sh <<'EOF'
#!/usr/bin/env bash
NOTES_DIR="$1"
DIR="$2"

if [ "$DIR" = "[+] Create new window/directory" ]; then
    echo "Select to create a new window/directory"
    exit 0
fi

FULL_PATH="$NOTES_DIR/$DIR"
if [ -d "$FULL_PATH" ]; then
    echo "=== Files in $DIR ==="
    echo
    find "$FULL_PATH" -name "*.md" -type f -exec basename {} \; | sort
else
    echo "Directory will be created: $FULL_PATH"
fi
EOF
chmod +x /tmp/notes-preview-dir.sh

# Select or create window/directory
select_window() {
    local selected=$(get_window_options | fzf \
        --header="Select or create window/directory" \
        --preview="/tmp/notes-preview-dir.sh '$NOTES_DIR' {}" \
        --preview-window=right:40%)

    if [ -z "$selected" ]; then
        exit 0
    fi

    if [ "$selected" = "[+] Create new window/directory" ]; then
        # Exit fzf and prompt
        exec </dev/tty
        echo -n "Enter new window/directory name: "
        read -r new_name

        if [ -z "$new_name" ]; then
            echo "No name provided"
            exit 1
        fi

        # Create directory
        mkdir -p "$NOTES_DIR/$new_name"

        # Create window if it doesn't exist
        if ! tmux list-windows -t "$NOTES_SESSION" -F "#{window_name}" | grep -q "^$new_name$"; then
            tmux new-window -t "$NOTES_SESSION" -n "$new_name" -c "$NOTES_DIR/$new_name"
        fi

        echo "$new_name"
    else
        # Ensure directory exists
        mkdir -p "$NOTES_DIR/$selected"

        # Create window if it doesn't exist
        if ! tmux list-windows -t "$NOTES_SESSION" -F "#{window_name}" | grep -q "^$selected$"; then
            tmux new-window -t "$NOTES_SESSION" -n "$selected" -c "$NOTES_DIR/$selected"
        fi

        echo "$selected"
    fi
}

# Main execution
window_name=$(select_window)

if [ -z "$window_name" ]; then
    exit 0
fi

# Clean up
rm -f /tmp/notes-preview-dir.sh

# Now run the file selection in the same popup
exec "$HOME/.core/cfg/tmux/scripts/notes-select-file.sh" "$window_name"
