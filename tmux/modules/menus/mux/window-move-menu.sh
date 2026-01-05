#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="mux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "mux/window-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#a6e3a1,bold] Move Window " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " Move before (follow)" "," "choose-tree { movew -bt '%%' }" \
  " Move after (follow)" "." "choose-tree { movew -at '%%' }" \
  " Move before (don't follow)" "<" "choose-tree { movew -dbt '%%' }" \
  " Move after (don't follow)" ">" "choose-tree { movew -dat '%%' }"
