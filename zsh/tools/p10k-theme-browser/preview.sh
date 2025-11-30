#!/usr/bin/env bash
# Preview script for Powerlevel10k themes
# Shows what a theme will look like with colored blocks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_FILE="$SCRIPT_DIR/data/themes.json"

theme_name="$1"

# Get theme data
theme_data=$(jq -r --arg name "$theme_name" \
    '.themes[] | select(.name == $name)' \
    "$THEMES_FILE")

if [[ -z "$theme_data" ]]; then
    echo "Theme not found: $theme_name"
    exit 1
fi

# Extract colors
dir_bg=$(echo "$theme_data" | jq -r '.colors.dir_background')
dir_fg=$(echo "$theme_data" | jq -r '.colors.dir_foreground')
vcs_clean_bg=$(echo "$theme_data" | jq -r '.colors.vcs_clean_background')
vcs_modified_bg=$(echo "$theme_data" | jq -r '.colors.vcs_modified_background')
vcs_untracked_bg=$(echo "$theme_data" | jq -r '.colors.vcs_untracked_background')
prompt_ok=$(echo "$theme_data" | jq -r '.colors.prompt_char_ok')
prompt_err=$(echo "$theme_data" | jq -r '.colors.prompt_char_error')
description=$(echo "$theme_data" | jq -r '.description')
category=$(echo "$theme_data" | jq -r '.category')

# Extract VCS foreground colors (with fallback to white)
vcs_clean_fg=$(echo "$theme_data" | jq -r '.colors.vcs_clean_foreground // "254"')
vcs_modified_fg=$(echo "$theme_data" | jq -r '.colors.vcs_modified_foreground // "254"')
vcs_untracked_fg=$(echo "$theme_data" | jq -r '.colors.vcs_untracked_foreground // "254"')

# Function to create colored block
color_block() {
    local bg=$1
    local fg=$2
    local text=$3
    printf "\033[48;5;%sm\033[38;5;%sm %s \033[0m" "$bg" "$fg" "$text"
}

# Function to create prompt character
prompt_char() {
    local fg=$1
    local char=$2
    printf "\033[38;5;%sm%s\033[0m" "$fg" "$char"
}

echo ""
echo "╭─────────────────────────────────────────────────╮"
echo "│  Theme Preview: $theme_name"
echo "│  Category: $category"
echo "│  $description"
echo "╰─────────────────────────────────────────────────╯"
echo ""

# Show directory segment
echo "Directory Segment:"
color_block "$dir_bg" "$dir_fg" "~/.config/nvim"
echo ""
echo ""

# Show git segments
echo "Git Status Segments:"
echo -n "  Clean:      "
color_block "$vcs_clean_bg" "$vcs_clean_fg" " master"
echo ""

echo -n "  Modified:   "
color_block "$vcs_modified_bg" "$vcs_modified_fg" " main !2 ?3"
echo ""

echo -n "  Untracked:  "
color_block "$vcs_untracked_bg" "$vcs_untracked_fg" " dev ?5"
echo ""
echo ""

# Show prompt characters
echo "Prompt Characters:"
echo -n "  Success:    "
prompt_char "$prompt_ok" "❯"
echo "  (exit code 0)"

echo -n "  Error:      "
prompt_char "$prompt_err" "❯"
echo "  (exit code 1)"
echo ""

# Show example prompt line
echo "Example Prompt:"
echo ""
color_block "$dir_bg" "$dir_fg" "~/.config/nvim"
echo -n " "
color_block "$vcs_modified_bg" "$vcs_modified_fg" " main !2 ?3"
echo ""
prompt_char "$prompt_ok" "❯"
echo -n " "
echo ""
echo ""

# Color reference
echo "Color Codes:"
echo "  Directory:        bg=$dir_bg fg=$dir_fg"
echo "  Git Clean:        bg=$vcs_clean_bg fg=$vcs_clean_fg"
echo "  Git Modified:     bg=$vcs_modified_bg fg=$vcs_modified_fg"
echo "  Git Untracked:    bg=$vcs_untracked_bg fg=$vcs_untracked_fg"
echo "  Prompt Success:   fg=$prompt_ok"
echo "  Prompt Error:     fg=$prompt_err"
echo ""
