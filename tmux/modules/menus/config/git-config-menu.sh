#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

GIT_CFG="$HOME/.config/git"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]Git Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$GIT_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$GIT_CFG\" claude'" \
  "" \
  ".gitconfig" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME\" \"\\$EDITOR .gitconfig\"'" \
  "Global Ignore" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$GIT_CFG\" \"\\$EDITOR ignore\"'" \
  "Git Aliases" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$GIT_CFG\" \"\\$EDITOR aliases\"'" \
  "Git Attributes" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME\" \"\\$EDITOR .gitattributes\"'"
