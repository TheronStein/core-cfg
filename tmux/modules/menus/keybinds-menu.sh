#!/bin/bash
tmux display-menu -x W -y S \
  "Back" Bspace "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "Neomutt Keybinds" m "run-shell '~/.core/cfg/tmux/modules/previews/toggle-neomutt-keybinds.sh'"
