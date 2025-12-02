#!/bin/bash
# ~/.core/.sys/configs/wezterm/scripts/test-preview.sh
# Test script for theme preview

# Get current tmux session
CURRENT_SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo "default")
PREVIEW_FILE="/tmp/wezterm_preview_${CURRENT_SESSION}.txt"

echo "Testing theme preview for session: $CURRENT_SESSION"
echo "Preview file: $PREVIEW_FILE"
echo ""
echo "Writing themes to preview file..."
echo "Press Ctrl+C to stop"
echo ""

# Test themes
themes=(
    "Tokyo Night"
    "Dracula"
    "Gruvbox Dark"
    "Nord"
    "Catppuccin Mocha"
    "Solarized Dark"
    "One Dark"
)

while true; do
    for theme in "${themes[@]}"; do
        echo "Testing: $theme"
        echo "$theme" >"$PREVIEW_FILE"
        sleep 2
    done
done
