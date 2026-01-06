#!/bin/bash
# Menus Module Configuration Menu (Placeholder)

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "modules-management.sh")

MENUS_DIR="$HOME/.core/.sys/cfg/tmux/modules/menus"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] Menus Module " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ MENU SCRIPTS ━━━" "" "" \
  "󰈔 Explore Menus Module" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MENUS_DIR\" yazi'" \
  "󰘧 Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MENUS_DIR\" claude'"
