#!/bin/bash
tmux display-menu -x W -y S \
  "New Task" n "run-shell '~/.core/cfg/tmux/scripts/utils/new-task.sh'" \
  "List Tasks" l "run-shell '~/.core/cfg/tmux/scripts/utils/list-tasks.sh" \
  "Remove Task" r "run-shell '~/.core/cfg/tmux/scripts/utils/remove-tasks.sh" \
  "Back" Tab "run-shell '$TMUX_MENUS/session-menu.sh'"

# bind-key M command-prompt -p "Set task for session:" "set -t '%%' @task '%%'"
# "command-prompt -p 'Set task for session:' \ set -t '%%' @task '%%'"
#"Attach Task" a "choose-tree -N -s -t @task -Z -F '#{session_name} #{session_id} #{session_task}' 'run-shell \"tmux attach-session -t %%\"'" \
