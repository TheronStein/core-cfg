#!/bin/bash
tmux display-menu -x W -y S \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "Copy Mode" C-c "run-shell '$TMUX_MENUS/copy-mode.sh'" \
  "Resize Mode" C-r "set -g @custom_mode 'mode:RESIZE:orange' \\; refresh-client -S \\; run-shell '$TMUX_MENUS/pane-resize-select.sh'"
