#!/bin/bash
# Main Menu - Top level navigation

MENU_NAV="$TMUX_MENUS/menu-nav.sh"

# Helper to open submenu with parent tracking
om() {
  "$MENU_NAV" set "$(basename "$1")" "main-menu.sh"
  echo "run-shell '$TMUX_MENUS/$1'"
}

tmux display-menu -x C -y P -T "#[fg=#e0af68,bold] Main Menu " \
  " Zoom Toggle" z "resize-pane -Z" \
  " Resize Mode" r "run-shell '$TMUX_MENUS/modes/pane-resize-select.sh'" \
  " Copy Mode" / "run-shell '$TMUX_MENUS/modes/copy-mode.sh'" \
  "" \
  "󰒓 Config Management" c "$(om config-management.sh)" \
  " Modules Management" m "$(om modules-management.sh)" \
  "󰂮 Pane Management" a "$(om mux/pane-menu.sh)" \
  "󰖯 Window Management" w "$(om mux/window-menu.sh)" \
  " Layout Management" l "$(om mux/layout-menu.sh)" \
  "󰏘 Theme Selector" T "run-shell '$TMUX_CONF/modules/themes/theme-switcher.sh'" \
  "" \
  " Keybind References" k "$(om reference/keybinds-menu.sh)" \
  "󱂬 Popup Windows" e "$(om popups/popup-menu.sh)" \
  " Sidebar Menu" b "$(om mux/sidebar-menu.sh)" \
  "" \
  "󰙀 TMUX Management" t "$(om tmux-menu.sh)" \
  "󰹬 Session Management" s "$(om tmux/session-menu.sh)" \
  " Plugin Management" p "$(om tmux/plugin-menu.sh)" \
  " App Management" A "$(om app-management.sh)" \
  "" \
  " Git Operations" g "$(om dev/git-menu.sh)" \
  " SSH Connections" S "$(om connect/ssh-menu.sh)" \
  " Process Manager" x "$(om tools/process-menu.sh)"
