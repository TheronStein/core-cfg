#!/usr/bin/env bash
# Powerlevel10k Theme Browser with Live Preview
# Browse and apply p10k color themes interactively

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
THEMES_FILE="$DATA_DIR/themes.json"
P10K_CONFIG="$HOME/.p10k.zsh"

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Check dependencies
for cmd in fzf jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}Error: $cmd is not installed${RESET}" >&2
        exit 1
    fi
done

# Check if themes file exists
if [[ ! -f "$THEMES_FILE" ]]; then
    echo -e "${RED}Error: Themes file not found at $THEMES_FILE${RESET}" >&2
    exit 1
fi

# Check if p10k config exists
if [[ ! -f "$P10K_CONFIG" ]]; then
    echo -e "${RED}Error: Powerlevel10k config not found at $P10K_CONFIG${RESET}" >&2
    exit 1
fi

# Function to apply theme to p10k config
apply_theme() {
    local theme_name="$1"
    local backup="${P10K_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"

    # Get theme colors
    local theme_data
    theme_data=$(jq -r --arg name "$theme_name" \
        '.themes[] | select(.name == $name)' \
        "$THEMES_FILE")

    if [[ -z "$theme_data" ]]; then
        echo -e "${RED}Error: Theme not found${RESET}" >&2
        return 1
    fi

    # Extract colors
    local dir_bg=$(echo "$theme_data" | jq -r '.colors.dir_background')
    local dir_fg=$(echo "$theme_data" | jq -r '.colors.dir_foreground')
    local vcs_clean=$(echo "$theme_data" | jq -r '.colors.vcs_clean_background')
    local vcs_modified=$(echo "$theme_data" | jq -r '.colors.vcs_modified_background')
    local vcs_untracked=$(echo "$theme_data" | jq -r '.colors.vcs_untracked_background')
    local prompt_ok=$(echo "$theme_data" | jq -r '.colors.prompt_char_ok')
    local prompt_err=$(echo "$theme_data" | jq -r '.colors.prompt_char_error')

    # Extract VCS foreground colors (with fallback to white/black)
    local vcs_clean_fg=$(echo "$theme_data" | jq -r '.colors.vcs_clean_foreground // "254"')
    local vcs_modified_fg=$(echo "$theme_data" | jq -r '.colors.vcs_modified_foreground // "254"')
    local vcs_untracked_fg=$(echo "$theme_data" | jq -r '.colors.vcs_untracked_foreground // "254"')

    # Backup current config
    echo -e "${CYAN}Creating backup: $backup${RESET}"
    cp "$P10K_CONFIG" "$backup"

    # Apply changes using sed
    echo -e "${CYAN}Applying theme: $theme_name${RESET}"

    sed -i "s/^  typeset -g POWERLEVEL9K_DIR_BACKGROUND=.*/  typeset -g POWERLEVEL9K_DIR_BACKGROUND=$dir_bg/" "$P10K_CONFIG"
    sed -i "s/^  typeset -g POWERLEVEL9K_DIR_FOREGROUND=.*/  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$dir_fg/" "$P10K_CONFIG"
    sed -i "s/^  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=.*/  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$vcs_clean/" "$P10K_CONFIG"
    sed -i "s/^  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=.*/  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$vcs_modified/" "$P10K_CONFIG"
    sed -i "s/^  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=.*/  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$vcs_untracked/" "$P10K_CONFIG"
    sed -i "s/^  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_.*_FOREGROUND=.*/  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$prompt_ok/" "$P10K_CONFIG"
    sed -i "s/^  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_.*_FOREGROUND=.*/  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$prompt_err/" "$P10K_CONFIG"

    # Add/update VCS foreground colors (insert after VCS background if not present)
    if grep -q "^  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=" "$P10K_CONFIG"; then
        sed -i "s/^  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=.*/  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$vcs_clean_fg/" "$P10K_CONFIG"
    else
        sed -i "/^  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=/a\\  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$vcs_clean_fg" "$P10K_CONFIG"
    fi

    if grep -q "^  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=" "$P10K_CONFIG"; then
        sed -i "s/^  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=.*/  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$vcs_modified_fg/" "$P10K_CONFIG"
    else
        sed -i "/^  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=/a\\  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$vcs_modified_fg" "$P10K_CONFIG"
    fi

    if grep -q "^  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=" "$P10K_CONFIG"; then
        sed -i "s/^  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=.*/  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$vcs_untracked_fg/" "$P10K_CONFIG"
    else
        sed -i "/^  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=/a\\  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$vcs_untracked_fg" "$P10K_CONFIG"
    fi

    echo -e "${GREEN}✓ Theme applied successfully!${RESET}"
    echo -e "${YELLOW}Restart your shell or run: exec zsh${RESET}"

    return 0
}

# Browse themes with categories
browse_themes() {
    local category="${1:-all}"

    # Build theme list
    local theme_list
    if [[ "$category" == "all" ]]; then
        theme_list=$(jq -r '.themes[] | "\(.name)|\(.description)|\(.category)"' "$THEMES_FILE")
    else
        theme_list=$(jq -r --arg cat "$category" \
            '.themes[] | select(.category == $cat) | "\(.name)|\(.description)|\(.category)"' \
            "$THEMES_FILE")
    fi

    # Format for fzf with TAB delimiter (preserves exact theme names)
    echo "$theme_list" | while IFS='|' read -r name desc cat; do
        # Use TAB as delimiter: name<TAB>formatted display
        printf "%s\t%-25s  %-50s  [%s]\n" "$name" "$name" "$desc" "$cat"
    done | \
    fzf \
        --ansi \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --border-label="╣ Powerlevel10k Theme Browser ╠" \
        --prompt="Theme ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --delimiter=$'\t' \
        --with-nth=2.. \
        --header=$'↑↓: Navigate | Enter: Apply | Ctrl-C: Cancel | Tab: Toggle Category\n─────────────────────────────────────────────────────────────' \
        --preview-window="right:60%:wrap:rounded:~0" \
        --preview="$SCRIPT_DIR/preview.sh {1}" \
        --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
        --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
        --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
        --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
        --bind="ctrl-/:toggle-preview" \
        --bind="tab:execute(echo toggle-category)+abort"
}

# Browse categories
browse_categories() {
    jq -r '.categories[] | "\(.id)|\(.name)"' "$THEMES_FILE" | \
    while IFS='|' read -r id name; do
        local count=$(jq -r --arg cat "$id" \
            '.themes[] | select(.category == $cat or $cat == "all") | .name' \
            "$THEMES_FILE" | wc -l)
        printf "%-20s  (%d themes)\n" "$name" "$count"
    done | \
    fzf \
        --ansi \
        --height=40% \
        --layout=reverse \
        --border=rounded \
        --border-label="╣ Select Category ╠" \
        --prompt="Category ❯ " \
        --pointer="▶" \
        --header=$'Select a category or press Esc for all themes\n────────────────────────────────────────────' \
        --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
        --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
        --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
        --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4"
}

# Main function
main() {
    local category="all"

    # Show welcome message
    echo -e "${BOLD}${CYAN}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║   Powerlevel10k Theme Browser                  ║"
    echo "║   Live preview and apply color themes          ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${RESET}"

    while true; do
        # Browse themes
        local selected
        selected=$(browse_themes "$category")

        # Check for special commands
        if [[ "$selected" == "toggle-category" ]]; then
            # Switch to category browser
            local cat_selected
            cat_selected=$(browse_categories || echo "")

            if [[ -n "$cat_selected" ]]; then
                category=$(echo "$cat_selected" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
            fi
            continue
        fi

        # If nothing selected, exit
        if [[ -z "$selected" ]]; then
            echo -e "${YELLOW}No theme selected. Exiting.${RESET}"
            exit 0
        fi

        # Extract theme name (first field before TAB)
        local theme_name=$(echo "$selected" | cut -f1)

        # Confirm application
        echo ""
        echo -e "${YELLOW}Apply theme: ${BOLD}$theme_name${RESET}${YELLOW}?${RESET}"
        echo -e "${CYAN}This will modify $P10K_CONFIG${RESET}"
        echo -n "Continue? [y/N] "
        read -r confirm

        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            apply_theme "$theme_name"
            exit 0
        else
            echo -e "${YELLOW}Theme not applied. Select another or press Ctrl-C to exit.${RESET}"
            echo ""
        fi
    done
}

main "$@"
