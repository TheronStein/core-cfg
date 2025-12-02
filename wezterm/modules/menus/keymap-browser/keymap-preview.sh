#!/usr/bin/env bash
# Preview generator for WezTerm keymap browser

set -euo pipefail

MODE="${1:-category}"
ITEM="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
KEYMAPS_FILE="$DATA_DIR/keymaps.json"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BRIGHT_CYAN='\033[0;96m'
BRIGHT_WHITE='\033[0;97m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
RESET='\033[0m'

# Show category preview
show_category_preview() {
    local full_line="$1"

    # Remove icon and extract category name (everything before ' | ')
    local category_display="${full_line%% | *}"
    local category_name="${category_display#* }"

    local category_info=$(jq -r --arg name "$category_name" \
        '.categories[] | select(.name == $name)' "$KEYMAPS_FILE" 2>/dev/null)

    if [[ -z "$category_info" ]]; then
        echo -e "${RED}Category not found: $category_name${RESET}"
        return 1
    fi

    local id=$(echo "$category_info" | jq -r '.id')
    local description=$(echo "$category_info" | jq -r '.description')
    local count=$(echo "$category_info" | jq -r '.count')
    local is_key_table=$(echo "$category_info" | jq -r '.is_key_table')
    local icon="⌨"
    [[ "$is_key_table" == "true" ]] && icon="⚡"

    # Header
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET} ${BOLD}${BRIGHT_WHITE}$icon  $category_name${RESET}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${BOLD}${CYAN}📋 Description:${RESET} $description"
    echo -e "${BOLD}${CYAN}📊 Total Keybinds:${RESET} ${YELLOW}$count${RESET}"

    if [[ "$is_key_table" == "true" ]]; then
        echo -e "${BOLD}${CYAN}⚡ Type:${RESET} ${MAGENTA}Key Table (Modal Mode)${RESET}"
        echo -e "${DIM}  This is a modal keymap activated by a trigger${RESET}"
    else
        echo -e "${BOLD}${CYAN}⌨  Type:${RESET} ${GREEN}Modifier Combination${RESET}"
        echo -e "${DIM}  These keybinds are always active${RESET}"
    fi

    echo
    echo -e "${BOLD}${CYAN}━━━ Sample Keybinds ━━━${RESET}"
    echo

    # Show first 15 keybinds from this category
    echo "$category_info" | jq -r '.keybinds[0:15][] | "\(.display)|\(.description)"' |
        while IFS='|' read -r display description; do
            printf "${YELLOW}%-25s${RESET}  ${DIM}%s${RESET}\n" "$display" "$description"
        done

    if [[ $count -gt 15 ]]; then
        echo
        echo -e "${DIM}${ITALIC}  ... and $((count - 15)) more${RESET}"
    fi

    echo
    echo -e "${DIM}${ITALIC}Press ENTER to browse all keybinds • ESC to go back${RESET}"
}

# Show keybind preview
show_keybind_preview() {
    local full_line="$1"

    # Parse the line: format is "display  description"
    # Extract display (first field, left-aligned with padding)
    local display=$(echo "$full_line" | awk '{print $1}')

    # Extract description (rest of line after display)
    local description=$(echo "$full_line" | sed 's/^[^[:space:]]*[[:space:]]*//')

    # Get leader key info
    local leader_key=$(jq -r '.leader_key.key' "$KEYMAPS_FILE")
    local leader_mods=$(jq -r '.leader_key.mods' "$KEYMAPS_FILE")
    local leader_timeout=$(jq -r '.leader_key.timeout' "$KEYMAPS_FILE")

    # Large display
    echo
    echo -e "${BOLD}${BRIGHT_CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${BRIGHT_CYAN}║${RESET}                                                              ${BOLD}${BRIGHT_CYAN}║${RESET}"
    printf "${BOLD}${BRIGHT_CYAN}║${RESET}  %-60s${BOLD}${BRIGHT_CYAN}║${RESET}\n" "Keybind: $display"
    echo -e "${BOLD}${BRIGHT_CYAN}║${RESET}                                                              ${BOLD}${BRIGHT_CYAN}║${RESET}"
    echo -e "${BOLD}${BRIGHT_CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${BOLD}${YELLOW}━━━ Action ━━━${RESET}"
    echo
    echo -e "${GREEN}$description${RESET}"
    echo

    # Show context based on the modifier
    if [[ "$display" == *"leader"* ]]; then
        echo -e "${BOLD}${YELLOW}━━━ Leader Key Info ━━━${RESET}"
        echo
        echo -e "${CYAN}Leader Key:${RESET}     ${BRIGHT_WHITE}$leader_mods + $leader_key${RESET}"
        echo -e "${CYAN}Timeout:${RESET}        ${BRIGHT_WHITE}${leader_timeout}ms${RESET}"
        echo
        echo -e "${DIM}Press leader key, then this keybind within the timeout${RESET}"
        echo
    elif [[ "$display" == *"ctrl"* ]] || [[ "$display" == *"super"* ]] || [[ "$display" == *"shift"* ]]; then
        echo -e "${BOLD}${YELLOW}━━━ Usage ━━━${RESET}"
        echo
        echo -e "${DIM}Hold modifier(s) and press the key simultaneously${RESET}"
        echo
    else
        echo -e "${BOLD}${YELLOW}━━━ Usage ━━━${RESET}"
        echo
        echo -e "${DIM}Press the key directly (no modifiers needed)${RESET}"
        echo
    fi

    echo -e "${BOLD}${GREEN}━━━ Navigation ━━━${RESET}"
    echo -e "${DIM}${ITALIC}Navigate with ↑↓ • ESC to go back • Ctrl-/ to toggle this preview${RESET}"
}

# Main logic
case "$MODE" in
    category)
        show_category_preview "$ITEM"
        ;;
    keybind)
        show_keybind_preview "$ITEM"
        ;;
    *)
        echo "Invalid mode: $MODE"
        exit 1
        ;;
esac
