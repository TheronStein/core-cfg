#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

BW_CFG="$HOME/.config/Bitwarden"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]Bitwarden Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$BW_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$BW_CFG\" claude'" \
  "" \
  "Data JSON" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$BW_CFG\" \"\\$EDITOR data.json\"'"
