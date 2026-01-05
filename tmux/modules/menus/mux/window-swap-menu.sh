#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="mux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "mux/window-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#a6e3a1,bold]󰓡 Swap Windows " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "󰓡 Swap (don't follow)" s "choose-tree { swapw -t '%%' }" \
  "󰓡 Swap (follow)" S "choose-tree { swapw -dt '%%' }" \
  "" \
  " Move before (don't follow)" "<" "choose-tree { movew -dbt '%%' }" \
  " Move after (don't follow)" ">" "choose-tree { movew -dat '%%' }" \
  " Move before (follow)" "," "choose-tree { movew -bt '%%' }" \
  " Move after (follow)" "." "choose-tree { movew -at '%%' }"
