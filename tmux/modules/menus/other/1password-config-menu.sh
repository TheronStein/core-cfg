#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

OP_CFG="$HOME/.config/1Password"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]1Password Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$OP_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$OP_CFG\" claude'" \
  "" \
  "Settings" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$OP_CFG\" \"\\$EDITOR settings/settings.json\"'"
