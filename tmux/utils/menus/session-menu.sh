#!/bin/bash
tmux display-menu -x W -y S \
  "Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "" \
  "Switch Session" s "choose-tree -s" \
  "Rename Session" r "command-prompt -I '#S' 'rename-session %%'" \
  "New Session" n "command-prompt -p 'New session name:' 'new-session -d -s %%'" \
  "Kill Session" x "confirm-before -p 'Kill session #S? (y/n)' kill-session" \
  "Session Task Management" t "run-shell '$TMUX_MENUS/task-menu.sh'"
