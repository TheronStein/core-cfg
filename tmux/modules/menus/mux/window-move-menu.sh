#!/bin/bash
# Window move submenu - move window to specific positions

tmux display-menu -x W -y S -T "Move Window Position" \
  "Move before selected, follow" ',' "choose-tree { movew -bt '%%' }" \
  "Move after selected, follow" '.' "choose-tree { movew -at '%%' }" \
  "Move before selected, don't follow" '<' "choose-tree { movew -dbt '%%' }" \
  "Move after selected, don't follow" '>' "choose-tree { movew -dat '%%' }" \
  "" \
  "Back" Tab "run-shell '$TMUX_MENUS/mux/window-menu.sh'"
