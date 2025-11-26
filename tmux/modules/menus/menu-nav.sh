#!/bin/bash
# Dynamic Menu Navigation System
# This allows menus to track their parent dynamically

STATE_DIR="$HOME/.local/state/tmux/menu-nav"
mkdir -p "$STATE_DIR"

# Store the current menu and its parent
set_menu_parent() {
  local current_menu="$1"
  local parent_menu="$2"
  echo "$parent_menu" > "$STATE_DIR/${current_menu}.parent"
}

# Get the parent menu
get_menu_parent() {
  local current_menu="$1"
  local default_parent="${2:-main-menu.sh}"

  if [[ -f "$STATE_DIR/${current_menu}.parent" ]]; then
    cat "$STATE_DIR/${current_menu}.parent"
  else
    echo "$default_parent"
  fi
}

# Navigate back to parent
back_to_parent() {
  local current_menu="$1"
  local parent_menu=$(get_menu_parent "$current_menu" "main-menu.sh")
  tmux run-shell "$TMUX_MENUS/$parent_menu"
}

# Clear navigation history
clear_nav_history() {
  rm -rf "$STATE_DIR"/*.parent
}

# Execute based on command
case "${1:-}" in
  set)
    set_menu_parent "$2" "$3"
    ;;
  get)
    get_menu_parent "$2" "$3"
    ;;
  back)
    back_to_parent "$2"
    ;;
  clear)
    clear_nav_history
    ;;
  *)
    echo "Usage: $0 {set|get|back|clear} [args...]"
    echo "  set CURRENT_MENU PARENT_MENU - Set parent for current menu"
    echo "  get CURRENT_MENU [DEFAULT]   - Get parent menu (with optional default)"
    echo "  back CURRENT_MENU            - Navigate back to parent"
    echo "  clear                        - Clear all navigation history"
    ;;
esac
