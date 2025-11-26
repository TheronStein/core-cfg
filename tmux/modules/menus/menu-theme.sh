#!/bin/bash
# ChaosCore Menu Theme
# Source this file in menu scripts for consistent styling

# Menu position (centered)
MENU_POS_X="C"
MENU_POS_Y="C"

# ChaosCore color palette
MENU_BG="#1e1e2e"
MENU_FG="#c0caf5"
MENU_SELECT_BG="#24283B"
MENU_SELECT_FG="#01F9C6"
MENU_TITLE_FG="#e0af68"
MENU_SEPARATOR_FG="#01F9C6"
MENU_BORDER_FG="#2ac3de"

# Style strings for tmux display-menu
MENU_STYLE="fg=${MENU_FG},bg=${MENU_BG}"
MENU_SELECT_STYLE="fg=${MENU_SELECT_FG},bg=${MENU_SELECT_BG},bold"

# Helper function to create styled menu title
menu_title() {
    local icon="$1"
    local text="$2"
    echo "#[fg=${MENU_TITLE_FG},bold]${icon} ${text} "
}

# Helper function to create section separator
menu_separator() {
    local text="$1"
    echo "#[fg=${MENU_SEPARATOR_FG},bold]${text}"
}

# Base menu command template
# Usage: display_menu "Title" "Icon"
display_menu() {
    local title="$1"
    local icon="$2"
    echo "tmux display-menu -x ${MENU_POS_X} -y ${MENU_POS_Y} -T \"$(menu_title "$icon" "$title")\" -s \"${MENU_STYLE}\" -S \"${MENU_SELECT_STYLE}\""
}
