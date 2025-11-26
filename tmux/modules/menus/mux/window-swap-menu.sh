#!/bin/bash
# Window swap submenu - interactive swapping and moving operations

tmux display-menu -x W -y S -T "Window Swap & Move Operations" \
  "Swap windows, don't follow" C "choose-tree { swapw -t '%%' }" \
  "Swap windows, follow" W "choose-tree { swapw -dt '%%' }" \
  "" \
  "Move before selected, don't follow" '<' "choose-tree { movew -dbt '%%' }" \
  "Move after selected, don't follow" '>' "choose-tree { movew -dat '%%' }" \
  "Move before selected, follow" ',' "choose-tree { movew -bt '%%' }" \
  "Move after selected, follow" '.' "choose-tree { movew -at '%%' }" \
  "" \
  "Back" Tab "run-shell '$TMUX_MENUS/mux/window-menu.sh'"
