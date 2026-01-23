#!/bin/bash
# Main Menu - Top level navigation
# Location: ~/.tmux/modules/menus/main-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="main-menu.sh"

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Main Menu' $MENU_TITLE_MAIN)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  " New Window" w "run-shell '$TMUX_CONF/modules/fzf/pickers/window-dir-picker.sh'" \
  " New Session" s "run-shell '$TMUX_CONF/modules/fzf/pickers/session-dir-picker.sh'" \
  "" \
  "$(menu_sep 'Navigation')" "" "" \
  "󰒓 Config Management" c "$(om config-management.sh)" \
  "󰏘 Theme Selector" T "run-shell '$TMUX_CONF/modules/themes/theme-switcher.sh'" \
  "" \
  "$(menu_sep 'Windows')" "" "" \
  "󱂬 Popup Windows" e "$(om popups/popup-menu.sh)" \
  " Sidebar Menu" b "$(om mux/sidebar-menu.sh)" \
  "" \
  "$(menu_sep 'Tools')" "" "" \
  " App Management" A "$(om app-management.sh)" \
  " Task Management" t "$(om modules/task-menu.sh)" \
  " Git Operations" g "$(om dev/git-menu.sh)" \
  " SSH Connections" S "$(om connect/ssh-menu.sh)" \
  " Process Manager" x "$(om tools/process-menu.sh)"
