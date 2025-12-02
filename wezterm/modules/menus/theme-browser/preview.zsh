#!/usr/bin/env bash
# Preview wrapper for theme browser
# This is called by fzf for each line in the selection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
THEMES_FILE="$DATA_DIR/themes.json"

# Get environment variables
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
WORKSPACE_NAME="${WEZTERM_WORKSPACE:-default}"
PREVIEW_FILE="$RUNTIME_DIR/wezterm_theme_preview_${WORKSPACE_NAME}.txt"
PREVIEW_MODE="${THEME_BROWSER_PREVIEW_MODE:-template}"

line="$1"

# Extract theme name (remove icons and brightness at end)
theme_name=$(echo "$line" | sed -E 's/^[^A-Za-z0-9(]+//' | sed -E 's/[[:space:]]+[0-9]+$//')

[[ -z "$theme_name" ]] && exit 0

# Apply the preview by writing to preview file
echo "$theme_name" >"$PREVIEW_FILE"
sync 2>/dev/null || true

if [[ "$PREVIEW_MODE" == "template" ]]; then
    # Show ghostty-style preview template
    "$SCRIPT_DIR/theme-preview-template.sh" "$theme_name"
else
    # Show theme info
    theme_data=$(jq -r --arg name "$theme_name" '
        .themes[] | select(.name == $name)
    ' "$THEMES_FILE")

    if [[ -n "$theme_data" ]]; then
        category=$(echo "$theme_data" | jq -r '.category')
        brightness=$(echo "$theme_data" | jq -r '.brightness')
        temperature=$(echo "$theme_data" | jq -r '.temperature')
        bg=$(echo "$theme_data" | jq -r '.background')
        fg=$(echo "$theme_data" | jq -r '.foreground')

        cat <<EOF
═══════════════════════════════════════════════════
  Theme: $theme_name
═══════════════════════════════════════════════════

  Category:    $category
  Brightness:  $brightness
  Temperature: $temperature

  Background:  $bg
  Foreground:  $fg

  Workspace:   $WORKSPACE_NAME

═══════════════════════════════════════════════════
  Preview Mode: $PREVIEW_MODE

  The theme is being previewed in real-time
  in your current WezTerm window/pane.

  • Enter: Apply to workspace
  • Ctrl+F: Toggle favorites (TBD)
  • Ctrl+L: Filter light themes
  • Ctrl+D: Filter dark themes
  • Ctrl+W: Filter warm themes
  • Ctrl+C: Filter cool themes
  • Esc: Cancel and restore original
═══════════════════════════════════════════════════
EOF
    fi
fi
