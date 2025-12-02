#!/usr/bin/env bash
# Preview generator for WezTerm nerd font browser

set -euo pipefail

MODE="${1:-category}"
ITEM="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

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

# Get icon glyph by looking up unicode and rendering it
get_icon_from_unicode() {
    local unicode="$1"
    # Convert \uXXXX to actual glyph
    printf "$unicode"
}

# Get icon glyph by name from the mapping file
get_icon() {
    local name="$1"
    local mapping_file="$DATA_DIR/icon-name-to-glyph.txt"

    if [[ -f "$mapping_file" ]]; then
        # Look up the icon name in the mapping file (format: name<TAB>glyph)
        local glyph=$(grep "^${name}[[:space:]]" "$mapping_file" | cut -f2)
        if [[ -n "$glyph" ]]; then
            echo "$glyph"
            return
        fi
    fi

    # Fallback
    echo "?"
}

# Show category preview
show_category_preview() {
    local full_line="$1"
    # Extract category name (everything before ' | ')
    local category_name="${full_line%% | *}"
    local json_file="$DATA_DIR/categories.json"

    local category_info=$(jq -r --arg name "$category_name" \
        '.categories[] | select(.name == $name)' "$json_file" 2>/dev/null)

    if [[ -z "$category_info" ]]; then
        echo -e "${RED}Category not found: $category_name${RESET}"
        return 1
    fi

    local file=$(echo "$category_info" | jq -r '.file')
    local description=$(echo "$category_info" | jq -r '.description')
    local count=$(echo "$category_info" | jq -r '.count')
    local icon_name=$(echo "$category_info" | jq -r '.icon_name')

    # Get sample icon
    local icon=$(get_icon "$icon_name")

    # Header
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║${RESET} ${BOLD}${BRIGHT_WHITE}$icon  $category_name${RESET}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${BOLD}${CYAN}📋 Description:${RESET} $description"
    echo -e "${BOLD}${CYAN}📊 Total Icons:${RESET} ${YELLOW}$count${RESET}"
    echo -e "${BOLD}${CYAN}📁 Source File:${RESET} ${DIM}$file${RESET}"
    echo
    echo -e "${BOLD}${CYAN}━━━ Sample Icons ━━━${RESET}"
    echo

    # Show first 20 icons from this category using the data file
    local file_path="$DATA_DIR/$file"
    local mapping_file="$DATA_DIR/icon-name-to-glyph.txt"

    if [[ -f "$file_path" ]]; then
        # Get icon names, skip comments and empty lines, take first 30 to ensure we get 20 valid ones
        grep -v '^#' "$file_path" | grep -v '^$' | head -30 | while read -r icon_name; do
            # Look up glyph from mapping file
            local glyph=$(grep "^${icon_name}	" "$mapping_file" 2>/dev/null | cut -f2 || echo "?")
            [[ -z "$glyph" ]] && glyph="?"

            # Extract name after underscore
            local short_name="${icon_name#*_}"
            echo -e "${CYAN}$glyph${RESET}  ${DIM}$short_name${RESET}"
        done | head -20
    fi

    echo
    echo -e "${DIM}${ITALIC}Press ENTER to browse icons • ESC to go back${RESET}"
}

# Show icon preview
show_icon_preview() {
    local full_line="$1"

    # Parse the line: format is "glyph  icon_name"
    # Extract icon_name (everything after the first two spaces)
    local icon_name=$(echo "$full_line" | sed 's/^[^ ]*  //')

    # Extract glyph (first field before double space)
    local glyph=$(echo "$full_line" | awk '{print $1}')

    # Extract prefix from icon name (everything before first underscore)
    local prefix="${icon_name%%_*}"

    # Look up category from abbreviation file
    local abbrev_file="$DATA_DIR/abbreviation-to-category.txt"
    local category_name="Unknown Category"

    if [[ -f "$abbrev_file" ]]; then
        # Parse the file and extract the category description
        local lookup=$(grep "^${prefix}=" "$abbrev_file" | cut -d'=' -f2 | tr -d '"')
        [[ -n "$lookup" ]] && category_name="$lookup"
    fi

    # Large icon display
    echo
    echo -e "${BOLD}${BRIGHT_CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${BRIGHT_CYAN}║${RESET}                                                              ${BOLD}${BRIGHT_CYAN}║${RESET}"
    printf "${BOLD}${BRIGHT_CYAN}║${RESET}  %-60s${BOLD}${BRIGHT_CYAN}║${RESET}\n" "$category_name"
    echo -e "${BOLD}${BRIGHT_CYAN}║${RESET}                                                              ${BOLD}${BRIGHT_CYAN}║${RESET}"
    echo -e "${BOLD}${BRIGHT_CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${BOLD}${YELLOW}━━━ Icon Information ━━━${RESET}"
    echo
    echo -e "${CYAN}Name:${RESET}       ${BRIGHT_WHITE}$icon_name${RESET}"
    echo -e "${CYAN}Glyph:${RESET}      ${BRIGHT_WHITE}$glyph${RESET}"
    echo
    echo -e "${BOLD}${YELLOW}━━━ Usage ━━━${RESET}"
    echo
    echo -e "${DIM}WezTerm Lua:${RESET}"
    echo -e "  ${GREEN}local icon = wt.nerdfonts.$icon_name${RESET}"
    echo
    echo -e "${DIM}Picker (F9):${RESET}"
    echo -e "  ${GREEN}Search for: $icon_name${RESET}"
    echo
    echo -e "${BOLD}${GREEN}━━━ Actions ━━━${RESET}"
    echo -e "${DIM}${ITALIC}Press ENTER to copy glyph • ESC to go back${RESET}"
}

# Main logic
case "$MODE" in
    category)
        show_category_preview "$ITEM"
        ;;
    icon)
        show_icon_preview "$ITEM"
        ;;
    *)
        echo "Invalid mode: $MODE"
        exit 1
        ;;
esac
