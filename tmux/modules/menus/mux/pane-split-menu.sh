#!/bin/bash
# Pane Split Menu
# Location: ~/.tmux/modules/menus/mux/pane-split-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="mux/pane-split-menu.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰂮' 'Split Pane' $MENU_TITLE_PANE)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Direction')" "" "" \
  " Split Above" w "split-window -vb" \
  " Split Below" s "split-window -v" \
  " Split Left" a "split-window -hb" \
  " Split Right" d "split-window -h"
