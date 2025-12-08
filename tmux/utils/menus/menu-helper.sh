#!/bin/bash
# Menu Helper Functions
# Source this file in your menu scripts for dynamic navigation

MENU_NAV="$TMUX_MENUS/menu-nav.sh"

# Open a submenu and track navigation
open_menu() {
  local submenu="$1"
  local current_menu="$2"

  # Set parent relationship
  "$MENU_NAV" set "$(basename "$submenu")" "$(basename "$current_menu")"

  # Open the submenu
  tmux run-shell "$TMUX_MENUS/$submenu"
}

# Go back to parent menu
back_menu() {
  local current_menu="$1"
  "$MENU_NAV" back "$(basename "$current_menu")"
}

# Get the "Back" menu item for use in display-menu
# Usage: get_back_item "current-menu.sh" "Display Text" "Key"
get_back_item() {
  local current_menu="$(basename "$1")"
  local display_text="${2:-󰌑 Back}"
  local key="${3:-Tab}"
  local parent_menu=$("$MENU_NAV" get "$current_menu" "main-menu.sh")

  echo "\"$display_text\" $key \"run-shell '\$TMUX_MENUS/$parent_menu'\""
}

# Export functions for use in subshells
export -f open_menu back_menu get_back_item
