#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="mux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "mux/pane-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#89b4fa,bold]󰓡 Swap Panes " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "󰓡 Swap with tree selection" P "choose-tree { swapp -t '%%' }" \
  " Swap with displayed pane" q "display-panes { swapp -t '%%' }"
