#!/usr/bin/env bash
# Simplified WezTerm Theme Browser
# Just shows theme list and writes to preview file on navigation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
THEMES_FILE="$DATA_DIR/themes.json"

# Runtime directories
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
WORKSPACE_NAME="${WEZTERM_WORKSPACE:-default}"
PREVIEW_FILE="$RUNTIME_DIR/wezterm_theme_preview_${WORKSPACE_NAME}.txt"

# Colors
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
DIM='\033[2m'
RESET='\033[0m'

# Apply theme preview (just write to file)
apply_preview() {
    local line="$1"
    [[ -z "$line" ]] && return
    
    # Extract theme name (remove icons and brightness at end)
    local theme_name=$(echo "$line" | sed -E 's/^[^A-Za-z0-9(]+//' | sed -E 's/[[:space:]]+[0-9]+$//')
    
    [[ -z "$theme_name" ]] && return
    
    # Write to preview file - WezTerm watches this and recolors everything
    echo "$theme_name" > "$PREVIEW_FILE"
    sync 2>/dev/null || true
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
        "\(.name)|\(.category)|\(.brightness)|\(.temperature)"
    ' "$THEMES_FILE" | while IFS='|' read -r name cat brightness temp; do
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

# Export for fzf
export -f apply_preview
export PREVIEW_FILE SCRIPT_DIR

# Show header
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${RESET}       ${YELLOW}WezTerm Theme Browser${RESET} - Workspace: ${MAGENTA}$WORKSPACE_NAME${RESET}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${RESET}"
echo
echo -e "${DIM}  Navigation: ↑↓  |  Apply: Enter  |  Cancel: Esc"
echo -e "  Filters: Ctrl+L (light) | Ctrl+D (dark) | Ctrl+R (reset)"
echo -e "  Watch the right pane update as you navigate!${RESET}"
echo

# Run fzf
selected=$(
    generate_list | fzf \
        --height=100% \
        --layout=reverse \
        --border=none \
        --prompt="Theme ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --ansi \
        --cycle \
        --preview="apply_preview {}" \
        --preview-window="hidden" \
        --bind="ctrl-l:reload(bash -c 'source $0; generate_list light')" \
        --bind="ctrl-d:reload(bash -c 'source $0; generate_list dark')" \
        --bind="ctrl-w:reload(bash -c 'source $0; generate_list \"\" warm')" \
        --bind="ctrl-c:reload(bash -c 'source $0; generate_list \"\" cool')" \
        --bind="ctrl-r:reload(bash -c 'source $0; generate_list')" \
        --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
        --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
        --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
        --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4"
) || true

if [[ -n "$selected" ]]; then
    # Extract theme name
    theme_name=$(echo "$selected" | sed -E 's/^[^A-Za-z0-9(]+//' | sed -E 's/[[:space:]]+[0-9]+$//')
    
    echo
    echo -e "${GREEN}✅ Applied: $theme_name${RESET}"
    echo -e "${CYAN}   Workspace: $WORKSPACE_NAME${RESET}"
    
    # Keep theme applied
    echo "$theme_name" > "$PREVIEW_FILE"
else
    echo
    echo -e "${YELLOW}❌ Cancelled - restoring original theme${RESET}"
fi
