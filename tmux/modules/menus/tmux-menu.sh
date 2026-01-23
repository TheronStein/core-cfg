#!/bin/bash
# TMUX Main Menu - Primary tmux menu entry point
# Location: ~/.tmux/modules/menus/tmux-menu.sh
# Binding: C-Space (root table)

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux-menu.sh"

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰙀' 'TMUX' $MENU_TITLE_TMUX)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  " Zoom" z "resize-pane -Z" \
  " Copy Mode" / "copy-mode" \
  " Resize Mode" r "run-shell '$TMUX_MENUS/modes/pane-resize-select.sh'" \
  "󰯌 Toggle Context" x "run-shell '$TMUX_MENUS/modes/toggle-context.sh'" \
  "󰑙 Reset Context" X "run-shell '$TMUX_MENUS/modes/reset-context.sh'" \
  "" \
  "$(menu_sep 'Interface')" "" "" \
  "󰂮 Panes" a "$(om tmux/panes-menu.sh)" \
  "󰖯 Windows" w "$(om tmux/windows-menu.sh)" \
  " Layouts" l "$(om tmux/layouts-menu.sh)" \
  "󰹬 Sessions" s "$(om tmux/sessions-menu.sh)" \
  "" \
  "$(menu_sep 'Environment')" "" "" \
  " Inspect" i "$(om tmux/inspect-menu.sh)" \
  "󰕥 Manage" m "$(om tmux/management-menu.sh)" \
  "" \
  "󰑓 Reload Config" R "source-file $TMUX_CONF/tmux.conf ; display 'Config reloaded'"
