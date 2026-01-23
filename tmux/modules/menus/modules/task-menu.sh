#!/bin/bash
# Session Tasks Menu
# Location: ~/.tmux/modules/menus/modules/task-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="modules/task-menu.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Session Tasks' $MENU_TITLE_WINDOW)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Tasks')" "" "" \
  " New Task" n "run-shell '~/.core/.sys/cfg/tmux/scripts/utils/new-task.sh'" \
  " List Tasks" l "run-shell '~/.core/.sys/cfg/tmux/scripts/utils/list-tasks.sh'" \
  " Remove Task" r "run-shell '~/.core/.sys/cfg/tmux/scripts/utils/remove-tasks.sh'"
