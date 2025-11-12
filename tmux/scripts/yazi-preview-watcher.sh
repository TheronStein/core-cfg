#!/usr/bin/env bash
# Yazi preview pane - syncs with sidebar using DDS (Data Distribution Service)
# Listens to hover/cd events from the sidebar and displays file previews

# Use a separate config that shows only the preview column
export YAZI_CONFIG_HOME="$HOME/.core/cfg/yazi-preview"

# Create the preview-only config if it doesn't exist
if [ ! -d "$YAZI_CONFIG_HOME" ]; then
    mkdir -p "$YAZI_CONFIG_HOME"

    # Create a minimal yazi.toml for preview-only mode
    cat > "$YAZI_CONFIG_HOME/yazi.toml" <<'EOF'
#:schema ../.schemas/yazi.json

[mgr]
# Preview-only mode: show only the preview column
ratio = [0, 0, 1]
sort_by = "alphabetical"
sort_sensitive = false
sort_reverse = false
sort_dir_first = true
sort_translit = false
linemode = "size"
show_hidden = true
show_symlink = true
scrolloff = 5
mouse_events = []
title_format = "Yazi Preview"

[image]
protocol = "inline"

[tasks]
micro_workers = 5
macro_workers = 10
bizarre_retry = 5
image_alloc = 1073741824
EOF

    # Symlink the other configs
    ln -sf "$HOME/.core/cfg/yazi/init.lua" "$YAZI_CONFIG_HOME/init.lua"
    ln -sf "$HOME/.core/cfg/yazi/keymap.toml" "$YAZI_CONFIG_HOME/keymap.toml"
    ln -sf "$HOME/.core/cfg/yazi/theme.toml" "$YAZI_CONFIG_HOME/theme.toml"
    ln -sf "$HOME/.core/cfg/yazi/plugins" "$YAZI_CONFIG_HOME/plugins"
    ln -sf "$HOME/.core/cfg/yazi/flavors" "$YAZI_CONFIG_HOME/flavors"
fi

# Get the starting directory from yazi sidebar
START_DIR="${1:-$PWD}"

# Display header
clear
echo "╔════════════════════════════════════════╗"
echo "║      Yazi Preview (DDS Synced)         ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Listening for events from sidebar..."
echo "Alt+Shift+F to toggle this pane"
echo ""

# Cleanup on exit
cleanup() {
    pkill -P $$ 2>/dev/null
}
trap cleanup EXIT

# Check if ya command is available
if ! command -v ya >/dev/null 2>&1; then
    echo "ERROR: 'ya' command not found!"
    echo "Please ensure yazi is properly installed."
    sleep 3
    exit 1
fi

# Subscribe to DDS events using ya sub
# This will receive hover and cd events from all yazi instances
ya sub hover,cd | while IFS=',' read -r kind sender receiver payload; do
    # Parse the event
    # Format: hover,sender_id,receiver_id,{"tab":0,"url":"Url(\"/path/to/file\")"}

    # Extract the file path from the JSON payload
    if [[ "$kind" == "hover" ]] || [[ "$kind" == "cd" ]]; then
        # Extract URL using multiple methods for robustness
        file_path=$(echo "$payload" | grep -oP '(?<=url":")(/[^"]+)' || echo "$payload" | grep -oP 'Url\("([^"]+)"\)' | sed 's/Url("//; s/")//')

        if [ -n "$file_path" ] && [ -e "$file_path" ]; then
            # Clear screen and show preview
            clear
            echo "═══════════════════════════════════════════"
            basename_path=$(basename "$file_path")
            echo "Preview: $basename_path"
            echo "═══════════════════════════════════════════"
            echo ""

            # Use bat for text files, or file info for others
            if [ -f "$file_path" ]; then
                # Check file type
                mime_type=$(file -b --mime-type "$file_path" 2>/dev/null)

                if [[ "$mime_type" =~ ^text/ ]] || [[ "$mime_type" =~ ^application/(json|xml|javascript) ]]; then
                    # Text file - use bat if available
                    if command -v bat >/dev/null 2>&1; then
                        bat --style=plain --color=always --paging=never --terminal-width=$((COLUMNS - 4)) "$file_path" 2>/dev/null || cat "$file_path"
                    else
                        head -n 100 "$file_path"
                    fi
                elif [[ "$mime_type" =~ ^image/ ]]; then
                    # Image file
                    echo "📷 Image: $mime_type"
                    ls -lh "$file_path"
                    echo ""
                    file "$file_path"
                else
                    # Other file types
                    echo "📄 File type: $mime_type"
                    ls -lh "$file_path"
                    echo ""
                    file "$file_path"
                fi
            elif [ -d "$file_path" ]; then
                echo "📁 Directory contents:"
                echo ""
                if command -v eza >/dev/null 2>&1; then
                    eza -lah --color=always --icons "$file_path" 2>/dev/null | head -n 30
                else
                    ls -lah --color=always "$file_path" 2>/dev/null | head -n 30
                fi
            fi
        fi
    fi
done

# If ya sub exits, show message
echo ""
echo "DDS connection closed."
echo "Press Ctrl+C or close this pane."
sleep infinity
