#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

GH_CFG="$HOME/.config/gh"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]GitHub CLI Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$GH_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$GH_CFG\" claude'" \
  "" \
  "Config YAML" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$GH_CFG\" \"\\$EDITOR config.yml\"'" \
  "Hosts YAML" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$GH_CFG\" \"\\$EDITOR hosts.yml\"'"
