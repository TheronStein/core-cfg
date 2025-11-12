#!/bin/bash
# Pane swap submenu - interactive pane and window swapping

tmux display-menu -x W -y S -T "Swap Panes & Windows" \
  "Swap panes/windows, don't follow" P "choose-tree { swapp -t '%%' }" \
  "Swap with selected pane" q "display-panes { swapp -t '%%' }" \
  "" \
  "Back" Tab "run-shell '$TMUX_MENUS/pane-menu.sh'"
