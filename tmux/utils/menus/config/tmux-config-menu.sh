#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

TMUX_CFG="$HOME/.core/.sys/cfg/tmux"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]  TMUX Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CFG\" claude'" \
  "" \
  "Main Config" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CFG\" \"\\$EDITOR tmux.conf\"'" \
  "Keymaps Core" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CFG\" \"\\$EDITOR keymaps/core.conf\"'" \
  "Keymaps Pane" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CFG\" \"\\$EDITOR keymaps/pane.conf\"'" \
  "Plugins" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CFG\" \"\\$EDITOR conf/plugins.conf\"'" \
  "Hooks" 5 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CFG\" \"\\$EDITOR conf/hooks.conf\"'" \
  "Panes Config" 6 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CFG\" \"\\$EDITOR conf/panes.conf\"'" \
  "Binds Config" 7 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CFG\" \"\\$EDITOR conf/archiv./binds.conf\"'"
