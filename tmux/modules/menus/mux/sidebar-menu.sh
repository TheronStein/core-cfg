#!/bin/bash
# Sidebar Menu
# Location: ~/.tmux/modules/menus/mux/sidebar-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="mux/sidebar-menu.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Sidebar' $MENU_TITLE_WINDOW)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Browsers')" "" "" \
  "󰋊 Remote Mounts" r "display-popup -E -w 90% -h 90% -T ' Rclone Mount Manager ' '~/.core/.sys/cfg/tmux/modules/browsers/rclone-browser/browser.sh'" \
  "" \
  "$(menu_sep 'Yazibar')" "" "" \
  " Left Yazibar" l "run-shell '$TMUX_MODULES/yazibar/scripts/yazibar-left-simple.sh toggle'" \
  " Right Yazibar" R "display-message 'Right yazibar not yet implemented'" \
  "" \
  " Both Yazibars" y "run-shell '$TMUX_MODULES/yazibar/scripts/yazibar-both.sh toggle'"
