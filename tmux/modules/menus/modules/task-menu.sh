#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="modules/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "session/session-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#cba6f7,bold]  Session Tasks " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "New Task" n "run-shell '~/.core/.sys/cfg/tmux/scripts/utils/new-task.sh'" \
  "List Tasks" l "run-shell '~/.core/.sys/cfg/tmux/scripts/utils/list-tasks.sh'" \
  "Remove Task" r "run-shell '~/.core/.sys/cfg/tmux/scripts/utils/remove-tasks.sh'"

# bind-key M command-prompt -p "Set task for session:" "set -t '%%' @task '%%'"
# "command-prompt -p 'Set task for session:' \ set -t '%%' @task '%%'"
#"Attach Task" a "choose-tree -N -s -t @task -Z -F '#{session_name} #{session_id} #{session_task}' 'run-shell \"tmux attach-session -t %%\"'" \
