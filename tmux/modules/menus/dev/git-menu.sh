#!/bin/bash
# Git Operations Menu
# Location: ~/.tmux/modules/menus/dev/git-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="dev/git-menu.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Git Operations' $MENU_TITLE_APP)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'View')" "" "" \
  " Status" s "display-popup -E -w 80% -h 80% -T ' Git Status ' 'git status; read -n1'" \
  " Diff" d "display-popup -E -w 90% -h 90% -T ' Git Diff ' 'git diff --color | less -R'" \
  " Log" l "display-popup -E -w 90% -h 90% -T ' Git Log ' 'git log --oneline --graph --color -30 | less -R'" \
  "" \
  "$(menu_sep 'Actions')" "" "" \
  " Stage All" a "run-shell 'cd #{pane_current_path} && git add -A && tmux display-message \"All changes staged\"'" \
  " Commit" c "display-popup -E -w 60% -h 40% -T ' Git Commit ' 'git commit'" \
  " Push" p "run-shell 'cd #{pane_current_path} && git push && tmux display-message \"Pushed to remote\"'" \
  " Pull" P "run-shell 'cd #{pane_current_path} && git pull && tmux display-message \"Pulled from remote\"'" \
  "" \
  "$(menu_sep 'Browse')" "" "" \
  " Branches" b "display-popup -E -w 70% -h 60% -T ' Git Branches ' 'git branch -a --color | less -R'" \
  " Stash List" S "display-popup -E -w 70% -h 50% -T ' Git Stash ' 'git stash list; read -n1'" \
  "" \
  " Lazygit" g "display-popup -E -w 95% -h 95% -T ' Lazygit ' lazygit"
