#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="mux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#f9e2af,bold] Layout Presets " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " Even Horizontal" h "select-layout even-horizontal" \
  " Even Vertical" v "select-layout even-vertical" \
  "" \
  " Main Horizontal" H "select-layout main-horizontal" \
  " Main Vertical" V "select-layout main-vertical" \
  "" \
  "󰕰 Main Horiz (mirrored)" 1 "select-layout main-horizontal-mirrored" \
  "󰕰 Main Vert (mirrored)" 2 "select-layout main-vertical-mirrored" \
  "" \
  " Tiled" t "select-layout tiled" \
  " Even Panes" e "select-layout -E"
