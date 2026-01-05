#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

QUTE_CFG="$HOME/.config/qutebrowser"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]Qutebrowser Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$QUTE_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$QUTE_CFG\" claude'" \
  "" \
  "config.py" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$QUTE_CFG\" \"\\$EDITOR config.py\"'" \
  "Keybindings" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$QUTE_CFG\" \"\\$EDITOR keys.py\"'" \
  "Quickmarks" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$QUTE_CFG\" \"\\$EDITOR quickmarks\"'" \
  "Bookmarks" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$QUTE_CFG\" \"\\$EDITOR bookmarks/urls\"'" \
  "Userscripts" 5 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$QUTE_CFG/userscripts\" yazi'"
