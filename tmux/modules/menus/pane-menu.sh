#!/bin/bash

# Robust menu positioning - fallback to center if edge positioning fails
tmux display-menu -x W -y S \
  "" \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "Break Pane (follow)" b "break-pane" \
  "Break Pane (don't follow)" B "break-pane -d" \
  "Kill Pane" x "kill-pane" \
  "" \
  "Move Pane" m "move-pane -t :+1" \
  "Select Pane" o "display-panes" \
  "Switch Pane" S "display-popup -E -w 95% -h 95% '~/.core/cfg/tmux/scripts/tmux-switch-pane.sh'" \
  "Join Pane (interactive)" J "run-shell '$TMUX_MENUS/pane-join-menu.sh'" \
  "" \
  "Swap Pane" s "swap-pane -t :+1" \
  "Swap with selected" q "display-panes { swapp -t '%%' }" \
  "Swap Panes/Windows (interactive)" P "run-shell '$TMUX_MENUS/pane-swap-menu.sh'" \
  "" \
  "Move Pane Up" U "swap-pane -U" \
  "Move Pane Down" D "swap-pane -D" \
  "Rotate Clockwise" r "rotate-window" \
  "Rotate Counter-Clockwise" R "rotate-window -D" \
  "" \
  "Split Pane" a "run-shell '$TMUX_MENUS/pane-split-menu.sh'" \
  "" \
  "Insert Pane Above" k "display-panes { join-pane -vb -s '%%' }" \
  "Insert Pane Below" j "display-panes { join-pane -v -s '%%' }" \
  "Insert Pane Left" H "display-panes { join-pane -hb -s '%%' }" \
  "Insert Pane Right" L "display-panes { join-pane -h -s '%%' }" \
  "" \
  "Toggle pane sync" y "if -F '#{pane_synchronized}' 'set -w synchronize-panes off; display \"Sync off\"' 'set -w synchronize-panes on; display \"Sync on\"'"
