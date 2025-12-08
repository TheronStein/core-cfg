#!/usr/bin/env bash

NOTES_DIR="$HOME/.core/docs/doc"
NOTES_SESSION="notes"
WINDOW_NAME="$1"

if [ -z "$WINDOW_NAME" ]; then
    echo "No window name provided"
    exit 1
fi

WINDOW_DIR="$NOTES_DIR/$WINDOW_NAME"

# Get existing markdown files
get_notes() {
    if [ -d "$WINDOW_DIR" ]; then
        find "$WINDOW_DIR" -name "*.md" -type f -exec basename {} \; | sort 2>/dev/null
    fi
}

# Create preview script
cat >/tmp/notes-preview-file.sh <<'EOF'
#!/usr/bin/env bash
WINDOW_DIR="$1"
NOTE="$2"

if [ "$NOTE" = "[+] Create new note" ]; then
    echo "Select to create a new note"
    exit 0
fi

FULL_PATH="$WINDOW_DIR/$NOTE"
if [ -f "$FULL_PATH" ]; then
    # Use bat if available, otherwise cat
    if command -v bat &> /dev/null; then
        bat --color=always --style=plain "$FULL_PATH" 2>/dev/null
    else
        cat "$FULL_PATH"
    fi
else
    echo "New file will be created: $FULL_PATH"
fi
EOF
chmod +x /tmp/notes-preview-file.sh

# Get note options
get_note_options() {
    local notes=$(get_notes)
    if [ -n "$notes" ]; then
        echo "$notes"
    fi
    echo "[+] Create new note"
}

# Select or create note
selected=$(get_note_options | fzf \
    --header="Select or create note in $WINDOW_NAME" \
    --preview="/tmp/notes-preview-file.sh '$WINDOW_DIR' {}" \
    --preview-window=right:60%)

if [ -z "$selected" ]; then
    rm -f /tmp/notes-preview-file.sh
    exit 0
fi

if [ "$selected" = "[+] Create new note" ]; then
    # Exit fzf and prompt
    exec </dev/tty
    clear
    echo "=== Create New Note in $WINDOW_NAME ==="
    echo
    echo -n "Enter new note name (without .md): "
    read -r note_name

    if [ -z "$note_name" ]; then
        echo "No name provided"
        rm -f /tmp/notes-preview-file.sh
        exit 1
    fi

    # Add .md extension if not present
    [[ "$note_name" != *.md ]] && note_name="${note_name}.md"
else
    note_name="$selected"
fi

# Clean up
rm -f /tmp/notes-preview-file.sh

# Change to the directory
cd "$WINDOW_DIR" || {
    echo "Failed to change to directory: $WINDOW_DIR"
    exit 1
}

# Set environment variable for nvim to know it's in a popup
export TMUX_POPUP=1

# Clear and open nvim
clear
exec nvim "$note_name"
