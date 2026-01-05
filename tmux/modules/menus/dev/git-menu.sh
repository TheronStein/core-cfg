#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="dev/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#f38ba8,bold] Git Operations " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " Status" s "display-popup -E -w 80% -h 80% -T ' Git Status ' 'git status; read -n1'" \
  " Diff" d "display-popup -E -w 90% -h 90% -T ' Git Diff ' 'git diff --color | less -R'" \
  " Log" l "display-popup -E -w 90% -h 90% -T ' Git Log ' 'git log --oneline --graph --color -30 | less -R'" \
  "" \
  " Stage All" a "run-shell 'cd #{pane_current_path} && git add -A && tmux display-message \"All changes staged\"'" \
  " Commit" c "display-popup -E -w 60% -h 40% -T ' Git Commit ' 'git commit'" \
  " Push" p "run-shell 'cd #{pane_current_path} && git push && tmux display-message \"Pushed to remote\"'" \
  " Pull" P "run-shell 'cd #{pane_current_path} && git pull && tmux display-message \"Pulled from remote\"'" \
  "" \
  " Branches" b "display-popup -E -w 70% -h 60% -T ' Git Branches ' 'git branch -a --color | less -R'" \
  " Stash List" S "display-popup -E -w 70% -h 50% -T ' Git Stash ' 'git stash list; read -n1'" \
  "" \
  " Lazygit" g "display-popup -E -w 95% -h 95% -T ' Lazygit ' lazygit"
