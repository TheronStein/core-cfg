#!/usr/bin/env bash
# Get fzf colors for the currently previewed theme

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
THEMES_FILE="$DATA_DIR/themes.json"

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
WORKSPACE_NAME="${WEZTERM_WORKSPACE:-default}"
PREVIEW_FILE="$RUNTIME_DIR/wezterm_theme_preview_${WORKSPACE_NAME}.txt"

# Get the currently previewed theme
current_theme=""
if [[ -f "$PREVIEW_FILE" ]]; then
    current_theme=$(cat "$PREVIEW_FILE" 2>/dev/null || echo "")
    # Ignore special states
    if [[ "$current_theme" == "INIT" ]] || [[ "$current_theme" == "CANCEL" ]]; then
        current_theme=""
    fi
fi

# Generate fzf colors from theme
generate_fzf_colors() {
    local theme_name="$1"

    # Extract theme colors from JSON
    local theme_data=$(jq -r --arg name "$theme_name" '
        .themes[] | select(.name == $name)
    ' "$THEMES_FILE" 2>/dev/null)

    if [[ -z "$theme_data" ]]; then
        # Fallback to Catppuccin Mocha colors
        echo "bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,border:#89b4fa,label:#89b4fa,query:#cdd6f4"
        return
    fi

    # Extract color values
    local bg=$(echo "$theme_data" | jq -r '.background // "#1e1e2e"')
    local fg=$(echo "$theme_data" | jq -r '.foreground // "#cdd6f4"')
    local category=$(echo "$theme_data" | jq -r '.category // "dark"')

    # Get ANSI colors if available
    local color_0=$(echo "$theme_data" | jq -r '.ansi[0] // "#45475a"')
    local color_1=$(echo "$theme_data" | jq -r '.ansi[1] // "#f38ba8"')
    local color_2=$(echo "$theme_data" | jq -r '.ansi[2] // "#a6e3a1"')
    local color_3=$(echo "$theme_data" | jq -r '.ansi[3] // "#f9e2af"')
    local color_4=$(echo "$theme_data" | jq -r '.ansi[4] // "#89b4fa"')
    local color_5=$(echo "$theme_data" | jq -r '.ansi[5] // "#cba6f7"')
    local color_6=$(echo "$theme_data" | jq -r '.ansi[6] // "#94e2d5"')
    local color_8=$(echo "$theme_data" | jq -r '.ansi[8] // "#585b70"')
    local color_9=$(echo "$theme_data" | jq -r '.ansi[9] // "#f38ba8"')
    local color_15=$(echo "$theme_data" | jq -r '.ansi[15] // "#cdd6f4"')

    # Derive selection background (slightly lighter/darker than bg)
    local bg_plus="${color_8}"

    # Build fzf color scheme
    echo "bg+:${bg_plus},bg:${bg},spinner:${color_6},hl:${color_1},fg:${fg},header:${color_1},info:${color_5},pointer:${color_6},marker:${color_6},fg+:${color_15},prompt:${color_5},hl+:${color_9},border:${color_4},label:${color_4},query:${fg}"
}

# Output the colors
generate_fzf_colors "$current_theme"
