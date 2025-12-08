#!/bin/bash
tmux display-menu -x W -y S \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "Remote Mounts" M "run-shell -b 'tmux display-popup -E -w 90% -h 90% -x C -y C -T \" Rclone Mount Manager \" -b rounded -S \"fg=#89b4fa,bg=#1e1e2e\" \"~/.core/cfg/tmux/modules/browsers/rclone-browser/browser.sh\"'"
