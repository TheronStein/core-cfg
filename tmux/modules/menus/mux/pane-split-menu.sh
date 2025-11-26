#!/bin/bash
tmux display-menu -x W -y S \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "Split Above" w "split-window -vb" \
  "Split Below" s "split-window -v" \
  "Split Left" a "split-window -hb" \
  "Split Right" d "split-window -h"
