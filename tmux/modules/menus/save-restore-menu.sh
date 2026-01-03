#!/bin/bash
tmux display-menu -x W -y S \
  "Save State" s "run-shell $TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh && tmux display-message \'Session saved at \$(date +%H:%M:%S)\'" \
  "Restore Session" r "run-shell '$TMUX_CONF/utils/workspace/restore-session.sh'" \
  "Back" ESC "run-shell '$TMUX_MENUS/main-menu.sh'"
