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
  "󰏘 Theme Selector" T "run-shell '$TMUX_CONF/modules/themes/theme-switcher.sh'" \
  "" \
  "󱂬 Popup Windows" e "$(om popups/popup-menu.sh)" \
  " Sidebar Menu" b "$(om mux/sidebar-menu.sh)" \
  "" \
  " App Management" A "$(om app-management.sh)" \
  " Task Management" t "$(om modules/task-menu.sh)" \
  " Git Operations" g "$(om dev/git-menu.sh)" \
  " SSH Connections" S "$(om connect/ssh-menu.sh)" \
  " Process Manager" x "$(om tools/process-menu.sh)"
