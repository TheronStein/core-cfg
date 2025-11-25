#!/usr/bin/env bash
# Theme Browser Session - Handles split layout inside popup
# Left pane: fzf theme list, Right pane: live preview

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
THEMES_FILE="$DATA_DIR/themes.json"

# Runtime directories
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
WORKSPACE_NAME="${WEZTERM_WORKSPACE:-default}"
PREVIEW_FILE="$RUNTIME_DIR/wezterm_theme_preview_${WORKSPACE_NAME}.txt"
ORIGINAL_THEME_FILE="$RUNTIME_DIR/wezterm_original_theme_${WORKSPACE_NAME}.txt"

# Check dependencies
for cmd in fzf jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done

# Ensure theme data exists
if [[ ! -f "$THEMES_FILE" ]]; then
  echo "Generating theme data..." >&2
  wezterm --config-file "$SCRIPT_DIR/generate-themes-data.lua" 2>/dev/null || {
    echo "Failed to generate theme data" >&2
    exit 1
  }
fi

# Save original theme for restoration
if [[ -f "$PREVIEW_FILE" ]]; then
  cp "$PREVIEW_FILE" "$ORIGINAL_THEME_FILE"
else
  echo "ORIGINAL" >"$ORIGINAL_THEME_FILE"
fi

# Initialize preview file
echo "INIT" >"$PREVIEW_FILE"

# Cleanup on exit
cleanup() {
  # Restore original theme
  if [[ -f "$ORIGINAL_THEME_FILE" ]]; then
    local original=$(cat "$ORIGINAL_THEME_FILE")
    if [[ "$original" != "ORIGINAL" ]]; then
      echo "$original" >"$PREVIEW_FILE"
    else
      echo "CANCEL" >"$PREVIEW_FILE"
    fi
    rm -f "$ORIGINAL_THEME_FILE"
  fi
}
trap cleanup EXIT INT TERM

# Get current pane ID before split
ORIGINAL_PANE=$(tmux display-message -p '#{pane_id}')

# Split the current pane - right pane will be the preview (40% width)
# The -d flag keeps focus on current pane
tmux split-window -h -d -p 40

# After split, the NEW pane is to the right
# Get list of panes and find the one that's NOT the original
LEFT_PANE="$ORIGINAL_PANE"
RIGHT_PANE=$(tmux list-panes -F '#{pane_id}' | grep -v "$ORIGINAL_PANE" | head -1)

if [[ -z "$RIGHT_PANE" ]]; then
  echo "Error: Could not create preview pane" >&2
  echo "Original pane: $ORIGINAL_PANE" >&2
  echo "Available panes:" >&2
  tmux list-panes >&2
  sleep 3
  exit 1
fi

# Debug: Show we created the split successfully
echo "✓ Created split layout:"
echo "  Left pane (fzf):     $LEFT_PANE"
echo "  Right pane (preview): $RIGHT_PANE"
sleep 1

# Populate the right pane with sample content
tmux send-keys -t "$RIGHT_PANE" "clear" Enter
sleep 0.2
tmux send-keys -t "$RIGHT_PANE" "echo ''" Enter
tmux send-keys -t "$RIGHT_PANE" "echo '  ╔════════════════════════════════╗'" Enter
tmux send-keys -t "$RIGHT_PANE" "echo '  ║      THEME PREVIEW PANE       ║'" Enter
tmux send-keys -t "$RIGHT_PANE" "echo '  ╚════════════════════════════════╝'" Enter
tmux send-keys -t "$RIGHT_PANE" "echo ''" Enter
tmux send-keys -t "$RIGHT_PANE" "echo '  Watch colors change here as you'" Enter
tmux send-keys -t "$RIGHT_PANE" "echo '  navigate themes on the left!'" Enter
tmux send-keys -t "$RIGHT_PANE" "echo ''" Enter
sleep 0.1
tmux send-keys -t "$RIGHT_PANE" "ls -la --color=always 2>/dev/null || ls -la" Enter
sleep 0.1
tmux send-keys -t "$RIGHT_PANE" "echo ''" Enter
tmux send-keys -t "$RIGHT_PANE" "printf '  \\033[31m■ Red \\033[32m■ Green \\033[34m■ Blue\\033[0m\\n'" Enter
tmux send-keys -t "$RIGHT_PANE" "printf '  \\033[33m■ Yellow \\033[35m■ Magenta \\033[36m■ Cyan\\033[0m\\n'" Enter
tmux send-keys -t "$RIGHT_PANE" "echo ''" Enter
tmux send-keys -t "$RIGHT_PANE" "echo '  Theme will update globally!'" Enter

# Make sure we're focused on left pane for fzf
tmux select-pane -t "$LEFT_PANE"

# Run the theme browser with simplified preview
"$SCRIPT_DIR/theme-browser-simple.sh"
