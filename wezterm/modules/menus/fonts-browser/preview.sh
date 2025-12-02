#!/usr/bin/env bash

# Preview generator for nerd font browser
set -euo pipefail

MODE="${1:-category}"
ITEM="${2:-}"
FONTS_DIR="${NERD_FONTS_DIR:-$HOME/.core/tbin/fonts}"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BRIGHT_RED='\033[0;91m'
BRIGHT_GREEN='\033[0;92m'
BRIGHT_YELLOW='\033[0;93m'
BRIGHT_BLUE='\033[0;94m'
BRIGHT_MAGENTA='\033[0;95m'
BRIGHT_CYAN='\033[0;96m'
BRIGHT_WHITE='\033[0;97m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# Function to get color code from name
get_color() {
    case "$1" in
    red) echo "$RED" ;;
    green) echo "$GREEN" ;;
    yellow) echo "$YELLOW" ;;
    blue) echo "$BLUE" ;;
    magenta) echo "$MAGENTA" ;;
    cyan) echo "$CYAN" ;;
    white) echo "$WHITE" ;;
    bright_red) echo "$BRIGHT_RED" ;;
    bright_green) echo "$BRIGHT_GREEN" ;;
    bright_yellow) echo "$BRIGHT_YELLOW" ;;
    bright_blue) echo "$BRIGHT_BLUE" ;;
    bright_magenta) echo "$BRIGHT_MAGENTA" ;;
    bright_cyan) echo "$BRIGHT_CYAN" ;;
    bright_white) echo "$BRIGHT_WHITE" ;;
    *) echo "$WHITE" ;;
    esac
}

# Function to display category preview
show_category_preview() {
    local category_name="$1"
    local json_file="$FONTS_DIR/categories.json"

    # Debug output
    # echo "Looking for category: '$category_name'" >&2

    # Extract category info using jq - trim whitespace from input
    category_name=$(echo "$category_name" | xargs)

    local category_info=$(jq -r --arg name "$category_name" \
        '.categories[] | select(.name == $name)' "$json_file")

    if [[ -z "$category_info" ]]; then
        echo -e "${RED}Category not found: $category_name${RESET}"
        echo
        echo "Available categories:"
        jq -r '.categories[].name' "$json_file"
        return 1
    fi

    local file=$(echo "$category_info" | jq -r '.file')
    local description=$(echo "$category_info" | jq -r '.description')
    local range=$(echo "$category_info" | jq -r '.range')
    local color_name=$(echo "$category_info" | jq -r '.color')
    local icon=$(echo "$category_info" | jq -r '.icon')
    local color=$(get_color "$color_name")

    # Header
    echo -e "${BOLD}${color}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${color}║${RESET} ${BOLD}${BRIGHT_WHITE}$icon  $category_name${RESET}"
    echo -e "${BOLD}${color}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo

    # Info section
    echo -e "${BOLD}${CYAN}📋 Description:${RESET} $description"
    echo -e "${BOLD}${CYAN}📊 Unicode Range:${RESET} ${YELLOW}$range${RESET}"
    echo -e "${BOLD}${CYAN}📁 Source File:${RESET} ${DIM}$file${RESET}"
    echo

    # Sample preview
    echo -e "${BOLD}${color}━━━ Sample Icons ━━━${RESET}"
    echo

    local file_path="$FONTS_DIR/$file"
    if [[ -f "$file_path" ]]; then
        # Display first 10 icons in a grid
        local count=0
        local line_buffer=""

        while IFS=' ' read -r decimal unicode glyph; do
            if [[ -n "$glyph" && "$count" -lt 40 ]]; then
                if [[ $((count % 8)) -eq 0 && $count -gt 0 ]]; then
                    echo -e "$line_buffer"
                    line_buffer=""
                fi
                line_buffer="${line_buffer}${color}$glyph${RESET}  "
                ((count++))
            fi
        done < <(grep -E '^[0-9]' "$file_path" 2>/dev/null || true)

        [[ -n "$line_buffer" ]] && echo -e "$line_buffer"
        echo
    else
        echo -e "${RED}File not found: $file_path${RESET}"
    fi

    # Stats
    if [[ -f "$file_path" ]]; then
        local total_icons=$(grep -c '^[0-9]' "$file_path" 2>/dev/null || echo "0")
        echo -e "${BOLD}${color}━━━ Statistics ━━━${RESET}"
        echo -e "${CYAN}Total Icons:${RESET} ${BRIGHT_WHITE}$total_icons${RESET}"
        echo
    fi

    # Instructions
    echo -e "${DIM}${ITALIC}Press ENTER to browse icons in this category${RESET}"
    echo -e "${DIM}${ITALIC}Press ESC to go back to categories${RESET}"
}

# Function to display icon preview
show_icon_preview() {
    local line="$1"

    # Parse the line (format: "decimal unicode glyph")
    local decimal=$(echo "$line" | awk '{print $1}')
    local unicode=$(echo "$line" | awk '{print $2}')
    local glyph=$(echo "$line" | awk '{print $3}')

    if [[ -z "$glyph" ]]; then
        echo "Invalid icon data"
        return 1
    fi

    # Large icon display
    echo
    echo -e "${BOLD}${BRIGHT_CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${BRIGHT_CYAN}║${RESET}                                                              ${BOLD}${BRIGHT_CYAN}║${RESET}"
    printf "${BOLD}${BRIGHT_CYAN}║${RESET}                         %-5s                        ${BOLD}${BRIGHT_CYAN}║${RESET}\n" "$glyph"
    echo -e "${BOLD}${BRIGHT_CYAN}║${RESET}                                                              ${BOLD}${BRIGHT_CYAN}║${RESET}"
    echo -e "${BOLD}${BRIGHT_CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo

    # Information panel
    echo -e "${BOLD}${YELLOW}━━━ Icon Information ━━━${RESET}"
    echo
    echo -e "${CYAN}Glyph:${RESET}      ${BRIGHT_WHITE}$glyph${RESET}"
    echo -e "${CYAN}Unicode:${RESET}    ${YELLOW}$unicode${RESET}"
    echo -e "${CYAN}Decimal:${RESET}    ${GREEN}$decimal${RESET}"
    echo -e "${CYAN}Hex:${RESET}        ${MAGENTA}$(printf '0x%04x' $decimal)${RESET}"
    echo

    # Usage examples
    echo -e "${BOLD}${YELLOW}━━━ Usage Examples ━━━${RESET}"
    echo
    echo -e "${DIM}Vim/Neovim:${RESET}"
    echo -e "  ${GREEN}Insert mode:${RESET} ${BRIGHT_WHITE}<C-v>u${unicode#\\u}${RESET}"
    echo -e "  ${GREEN}Command:${RESET}     ${BRIGHT_WHITE}:normal i$glyph${RESET}"
    echo
    echo -e "${DIM}Shell:${RESET}"
    echo -e "  ${GREEN}Echo:${RESET}        ${BRIGHT_WHITE}echo -e '$unicode'${RESET}"
    echo -e "  ${GREEN}Printf:${RESET}      ${BRIGHT_WHITE}printf '$unicode\n'${RESET}"
    echo
    echo -e "${DIM}Programming:${RESET}"
    echo -e "  ${GREEN}Python:${RESET}      ${BRIGHT_WHITE}print('$unicode')${RESET}"
    echo -e "  ${GREEN}JavaScript:${RESET}  ${BRIGHT_WHITE}console.log('$unicode')${RESET}"
    echo -e "  ${GREEN}HTML:${RESET}        ${BRIGHT_WHITE}&#$decimal;${RESET}"
    echo

    # Size demonstrations
    echo -e "${BOLD}${YELLOW}━━━ Size Samples ━━━${RESET}"
    echo
    echo -e "  Normal:  $glyph"
    echo -e "  ${BOLD}Bold:    $glyph${RESET}"
    echo -e "  ${DIM}Dim:     $glyph${RESET}"
    echo

    # Copy instructions
    echo -e "${BOLD}${GREEN}━━━ Actions ━━━${RESET}"
    echo -e "${DIM}${ITALIC}Press ENTER to copy glyph to clipboard${RESET}"
    echo -e "${DIM}${ITALIC}Press CTRL-U to copy unicode${RESET}"
    echo -e "${DIM}${ITALIC}Press CTRL-D to copy decimal${RESET}"
    echo -e "${DIM}${ITALIC}Press ESC to go back${RESET}"
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
