#!/bin/bash
# Layouts Menu
# Location: ~/.tmux/modules/menus/tmux/layouts-menu.sh

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "tmux-menu.sh")

tmux display-menu -x C -y P -T "#[fg=#f9e2af,bold]   Layouts   " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Presets ━━━" "" "" \
  " Even Horizontal" h "select-layout even-horizontal" \
  " Even Vertical" v "select-layout even-vertical" \
  " Tiled" t "select-layout tiled" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Main Layouts ━━━" "" "" \
  " Main Horizontal" H "select-layout main-horizontal" \
  " Main Vertical" V "select-layout main-vertical" \
  "󰕰 Main H (mirrored)" 1 "select-layout main-horizontal-mirrored" \
  "󰕰 Main V (mirrored)" 2 "select-layout main-vertical-mirrored" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Adjust ━━━" "" "" \
  " Spread Evenly" e "select-layout -E" \
  " Rotate Layout" r "next-layout"
