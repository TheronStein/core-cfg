#!/usr/bin/env bash
# Rclone Browser - Right Sidebar Preview Wrapper
# Continuously displays preview of selected remote with matching fzf style

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELECTION_FILE="/tmp/rclone-browser-selection"

# Catppuccin Mocha colors (matching browser fzf theme)
BG='\033[48;2;30;30;46m'           # #1e1e2e background
FG='\033[38;2;205;214;244m'        # #cdd6f4 foreground
RESET='\033[0m'

# Draw styled preview with background
draw_preview() {
  local selection="$1"

  # Set full terminal background and clear
  printf "${BG}${FG}"
  clear

  # Get terminal dimensions
  local height=$(tput lines)

  # Set FZF_PREVIEW_LINES for the preview script to scale content
  export FZF_PREVIEW_LINES=$height

  # Run preview and maintain background color, handle errors gracefully
  if ! bash "$SCRIPT_DIR/preview.sh" "$selection" 2>&1; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  Error generating preview"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Selection: $selection"
  fi

  # Keep background for the rest of the terminal
  printf "${RESET}"
}

# Draw initial waiting screen
draw_initial() {
  printf "${BG}${FG}"
  clear
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🌐  RCLONE BROWSER PREVIEW"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Select a remote in the left panel to view"
  echo "its details and folder contents here."
  echo ""
  echo "Waiting for selection..."
  printf "${RESET}"
}

# Initialize
draw_initial

LAST_SELECTION=""

# Watch for changes and update preview
while true; do
  if [ -f "$SELECTION_FILE" ]; then
    CURRENT_SELECTION=$(cat "$SELECTION_FILE" 2>/dev/null || echo "")

    if [ -n "$CURRENT_SELECTION" ] && [ "$CURRENT_SELECTION" != "$LAST_SELECTION" ]; then
      # Draw preview and catch any errors
      if draw_preview "$CURRENT_SELECTION"; then
        LAST_SELECTION="$CURRENT_SELECTION"
      else
        # Preview failed, show error but keep running
        printf "${BG}${FG}"
        clear
        echo ""
        echo "⚠️  Preview script failed"
        echo "Selection: $CURRENT_SELECTION"
        printf "${RESET}"
      fi
    fi
  fi

  # Check every 0.2 seconds
  sleep 0.2
done
