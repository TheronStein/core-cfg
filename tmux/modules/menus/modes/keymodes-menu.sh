#!/bin/bash
tmux display-menu -x W -y S \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "Copy Mode" c "run-shell '$TMUX_MENUS/modes/copy-mode.sh'" \
  "Resize Mode" r "run-shell '$TMUX_MENUS/modes/pane-resize-select.sh'"
