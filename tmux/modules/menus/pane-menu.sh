#!/bin/bash

# Robust menu positioning - fallback to center if edge positioning fails
tmux display-menu -x W -y S \
  "" \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "Kill Pane" x "kill-pane" \
  "Vertical Split" v "run-shell '$TMUX_CONF/events/split.sh v'" \
  "Horizontal Split" d "run-shell '$TMUX_CONF/events/split.sh h'" \
  "" \
  "Swap with selected" q "display-panes { swapp -t '%%' }" \
  "Rotate Clockwise" r "rotate-window" \
  "Rotate Counter-Clockwise" R "rotate-window -D" \
  "" \
  "Break Pane (follow)" b "break-pane" \
  "Break Pane (don't follow)" B "break-pane -d" \
  "Move to Previous Window" m "move-pane -t :-1" \
  "Move to Next Window" m "move-pane -t :+1" \
  "" \
  "Toggle pane sync" y "if -F '#{pane_synchronized}' 'set -w synchronize-panes off; display \"Sync off\"' 'set -w synchronize-panes on; display \"Sync on\"'"

# Needs target pane

# "Swap Pane" s "swap-pane -t :+1" \
# "Move Pane Up" U "swap-pane -U" \
# "Move Pane Down" D "swap-pane -D" \
# "Swap Panes/Windows (interactive)" P "run-shell '$TMUX_MENUS/pane-swap-menu.sh'" \
# "Insert Pane Above" k "display-panes { join-pane -vb -s '%%' }" \
# "Insert Pane Below" j "display-panes { join-pane -v -s '%%' }" \
# "Insert Pane Left" H "display-panes { join-pane -hb -s '%%' }" \
# "Insert Pane Right" L "display-panes { join-pane -h -s '%%' }" \

# "Select Pane" o "display-panes" \
# "Switch Pane" S "display-popup -E -w 95% -h 95% '~/.core/cfg/tmux/scripts/tmux-switch-pane.sh'" \
# "Join Pane (interactive)" J "run-shell '$TMUX_MENUS/pane-join-menu.sh'" \
