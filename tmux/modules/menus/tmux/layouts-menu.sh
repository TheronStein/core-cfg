#!/bin/bash
# Layouts Menu
# Location: ~/.tmux/modules/menus/tmux/layouts-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/layouts-menu.sh"
PARENT=$(get_parent "tmux-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Layouts' $MENU_TITLE_WINDOW)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Presets')" "" "" \
  " Even Horizontal" h "select-layout even-horizontal" \
  " Even Vertical" v "select-layout even-vertical" \
  " Tiled" t "select-layout tiled" \
  "" \
  "$(menu_sep 'Main Layouts')" "" "" \
  " Main Horizontal" H "select-layout main-horizontal" \
  " Main Vertical" V "select-layout main-vertical" \
  "󰕰 Main H (mirrored)" 1 "select-layout main-horizontal-mirrored" \
  "󰕰 Main V (mirrored)" 2 "select-layout main-vertical-mirrored" \
  "" \
  "$(menu_sep 'Adjust')" "" "" \
  " Spread Evenly" e "select-layout -E" \
  " Rotate Layout" r "next-layout"
