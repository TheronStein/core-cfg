#!/usr/bin/env bash
# WezTerm Theme Browser with Live Preview
# Features:
# - Live theme preview as you navigate
# - Workspace-specific theme persistence
# - Two preview modes: ghostty-style template or split pane
# - Filter by category (light/dark), temperature, etc.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
THEMES_FILE="$DATA_DIR/themes.json"
WEZTERM_CONFIG="$HOME/.core/cfg/wezterm"

# Runtime directories
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
WORKSPACE_NAME="${WEZTERM_WORKSPACE:-default}"
PREVIEW_FILE="$RUNTIME_DIR/wezterm_theme_preview_${WORKSPACE_NAME}.txt"
OPACITY_FILE="$RUNTIME_DIR/wezterm_backdrop_opacity_${WORKSPACE_NAME}.txt"

# Preview mode: "template" or "split"
PREVIEW_MODE="${THEME_BROWSER_PREVIEW_MODE:-template}"

# Initialize opacity tracking (default 0.85)
CURRENT_OPACITY="${BACKDROP_OPACITY:-0.85}"
echo "$CURRENT_OPACITY" > "$OPACITY_FILE"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Check dependencies
for cmd in fzf jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}Error: $cmd is not installed${RESET}" >&2
        exit 1
    fi
done

# Ensure theme data exists
if [[ ! -f "$THEMES_FILE" ]]; then
    echo -e "${YELLOW}Generating theme data...${RESET}" >&2
    wezterm --config-file "$SCRIPT_DIR/generate-themes-data.lua" || {
        echo -e "${RED}Failed to generate theme data${RESET}" >&2
        exit 1
    }
fi

# Initialize preview file
echo "INIT" >"$PREVIEW_FILE"

# Adjust backdrop opacity
adjust_opacity() {
    local direction="$1"  # "increase" or "decrease"
    local current=$(cat "$OPACITY_FILE" 2>/dev/null || echo "0.85")
    local step=0.05

    if [[ "$direction" == "increase" ]]; then
        current=$(echo "$current + $step" | bc)
    else
        current=$(echo "$current - $step" | bc)
    fi

    # Clamp between 0.0 and 1.0
    if (( $(echo "$current > 1.0" | bc -l) )); then
        current="1.0"
    elif (( $(echo "$current < 0.0" | bc -l) )); then
        current="0.0"
    fi

    echo "$current" > "$OPACITY_FILE"
    sync 2>/dev/null || true

    # Display current opacity
    echo "Backdrop opacity: $current" >&2
}

# Cleanup on exit
cleanup() {
    echo "CANCEL" >"$PREVIEW_FILE"
    sleep 0.2
    rm -f "$PREVIEW_FILE" "$OPACITY_FILE"
}
trap cleanup EXIT INT TERM

# Apply theme preview
apply_preview() {
    local theme="$1"
    [[ -z "$theme" ]] && return

    # Write theme to preview file (watched by theme_watcher.lua)
    echo "$theme" >"$PREVIEW_FILE"

    # Force sync
    sync 2>/dev/null || true
}

# Apply theme to workspace permanently
apply_to_workspace() {
    local theme="$1"
    local workspace="${2:-$WORKSPACE_NAME}"

    [[ -z "$theme" ]] && return

    echo -e "${GREEN}✓ Applied '$theme' to workspace '$workspace'${RESET}" >&2

    # Use wezterm cli to apply theme
    wezterm cli set-user-var "theme_applied" "$theme" 2>/dev/null || true

    # Also save to workspace themes JSON
    # This will be handled by the workspace_themes.lua module
}

# Generate theme list for fzf
generate_list() {
    local filter_category="${1:-}"
    local filter_temp="${2:-}"

    jq -r --arg cat "$filter_category" --arg temp "$filter_temp" '
        .themes[] |
        select(
            ($cat == "" or .category == $cat) and
            ($temp == "" or .temperature == $temp)
        ) |
        "\(.name)|\(.category)|\(.brightness)|\(.temperature)|\(.background)|\(.foreground)"
    ' "$THEMES_FILE" | while IFS='|' read -r name cat brightness temp bg fg; do
        # Category icon
        local cat_icon=""
        case "$cat" in
        light) cat_icon="☀" ;;
        dark) cat_icon="🌙" ;;
        esac

        # Temperature indicator
        local temp_icon=""
        case "$temp" in
        warm) temp_icon="🔥" ;;
        cool) temp_icon="❄️" ;;
        neutral) temp_icon="⚪" ;;
        esac

        printf "%s  %s %s  %s\n" "$cat_icon" "$temp_icon" "$name" "$brightness"
    done
}

# Generate preview for fzf preview window
generate_preview() {
    local line="$1"

    # Extract theme name (remove icons and brightness at end)
    # More robust parsing: remove leading emoji/icons, then trim the last field (brightness number)
    local theme_name=$(echo "$line" | sed -E 's/^[^A-Za-z0-9(]+//' | sed -E 's/[[:space:]]+[0-9]+$//')

    [[ -z "$theme_name" ]] && return

    # Apply the preview
    apply_preview "$theme_name"

    if [[ "$PREVIEW_MODE" == "template" ]]; then
        # Show ghostty-style preview template
        "$SCRIPT_DIR/theme-preview-template.sh" "$theme_name"
    else
        # Show theme info
        local theme_data=$(jq -r --arg name "$theme_name" '
            .themes[] | select(.name == $name)
        ' "$THEMES_FILE")

        if [[ -n "$theme_data" ]]; then
            local category=$(echo "$theme_data" | jq -r '.category')
            local brightness=$(echo "$theme_data" | jq -r '.brightness')
            local temperature=$(echo "$theme_data" | jq -r '.temperature')
            local bg=$(echo "$theme_data" | jq -r '.background')
            local fg=$(echo "$theme_data" | jq -r '.foreground')

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
}

# Export functions for fzf
export -f apply_preview generate_preview apply_to_workspace adjust_opacity
export PREVIEW_FILE THEMES_FILE SCRIPT_DIR WORKSPACE_NAME PREVIEW_MODE OPACITY_FILE
export RED GREEN YELLOW BLUE CYAN MAGENTA BOLD DIM RESET

# Main browser
main() {
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}  WezTerm Theme Browser - Workspace: ${YELLOW}$WORKSPACE_NAME${RESET}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${RESET}"
    echo
    echo -e "  Preview Mode: ${MAGENTA}$PREVIEW_MODE${RESET}"
    echo -e "  Total Themes: ${GREEN}$(jq '.theme_count' "$THEMES_FILE")${RESET}"
    echo
    echo -e "${DIM}  Navigation: ↑↓  |  Apply: Enter  |  Cancel: Esc${RESET}"
    echo -e "${DIM}  Filters: Ctrl+L (light) | Ctrl+D (dark) | Ctrl+W (warm) | Ctrl+C (cool)${RESET}"
    echo -e "${DIM}  Opacity: [ (decrease) | ] (increase)${RESET}"
    echo

    # Run fzf
    local selected
    selected=$(
        generate_list | fzf \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ Theme Browser ╠" \
            --prompt="Theme ❯ " \
            --pointer="▶" \
            --marker="✓" \
            --ansi \
            --cycle \
            --preview-window="right:50%:wrap:rounded" \
            --preview="$SCRIPT_DIR/preview.sh {}" \
            --bind="ctrl-l:reload(bash -c 'generate_list light')" \
            --bind="ctrl-d:reload(bash -c 'generate_list dark')" \
            --bind="ctrl-w:reload(bash -c 'generate_list \"\" warm')" \
            --bind="ctrl-c:reload(bash -c 'generate_list \"\" cool')" \
            --bind="ctrl-r:reload(bash -c 'generate_list')" \
            --bind="ctrl-/:toggle-preview" \
            --bind="[:execute-silent(adjust_opacity decrease)" \
            --bind="]:execute-silent(adjust_opacity increase)" \
            --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
            --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
            --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
            --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4"
    ) || true

    if [[ -n "$selected" ]]; then
        # Extract theme name (same logic as generate_preview)
        local theme_name=$(echo "$selected" | sed -E 's/^[^A-Za-z0-9(]+//' | sed -E 's/[[:space:]]+[0-9]+$//')

        echo
        echo -e "${GREEN}✅ Selected: $theme_name${RESET}"
        echo -e "${CYAN}   Applying to workspace: $WORKSPACE_NAME${RESET}"

        # Apply to workspace
        apply_to_workspace "$theme_name"

        # Keep the theme applied (don't send CANCEL)
        echo "$theme_name" >"$PREVIEW_FILE"
    else
        echo
        echo -e "${YELLOW}❌ Cancelled - Original theme restored${RESET}"
    fi
}

main "$@"
