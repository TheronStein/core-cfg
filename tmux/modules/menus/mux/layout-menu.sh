#!/bin/bash
tmux display-menu -x W -y S \
  "Vertical Split" v "split-window -h" \
  "Horizontal Split" h "split-window -v" \
  "" \
  "Rotate Panes CW" o "rotate-window" \
  "Rotate Panes CCW" O "rotate-window -D" \
  "" \
  "Even Horizontal" 1 "select-layout even-vertical" \
  "Even Vertical" 2 "select-layout even-horizontal" \
  "" \
  "Main Horizontal" 3 "select-layout main-vertical" \
  "Main Vertical" 4 "select-layout main-horizontal" \
  "" \
  "Main Horizontal (Mirrored)" 6 "select-layout main-vertical-mirrored" \
  "Main Vertical (Mirrored)" 7 "select-layout main-horizontal-mirrored" \
  "" \
  "Tiled" 5 "select-layout tiled" \
  "Even Panes" E "select-layout -E" \
  "" \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'"
