#!/bin/bash
tmux display-menu -x W -y S \
  "Back" Bspace "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "Reload Config" r "run-shell '~/.core/cfg/tmux/events/reload-config.sh'" \
  "Save" S "run-shell '~/.core/cfg/tmux/plugins/tmux-resurrect/scripts/save.sh && tmux display-message \"Session saved at \$(date +%H:%M:%S)\"'" \
  "Restore" R "display-popup -E -w 85% -h 85% '~/.core/cfg/tmux/plugins/tmux-resurrect/scripts/restore.sh'" \
  "" \
  "Restart" T "confirm-before -p 'Reset tmux (save, kill, relaunch)? (y/n)' 'display-popup -E -w 60% -h 40% ~/.core/cfg/tmux/events/reset-tmux.sh'" \
  "Quit/Kill" X "confirm-before -p 'Quit Tmux? (y/n)' 'kill-server'"
