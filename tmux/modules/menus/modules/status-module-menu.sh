#!/bin/bash
# Status Module Configuration Menu (Placeholder)

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "modules-management.sh")

STATUS_DIR="$HOME/.core/.sys/cfg/tmux/modules/status"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] Status Module " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ STATUS SCRIPTS ━━━" "" "" \
  "󰈔 Explore Status Module" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$STATUS_DIR\" yazi'" \
  "󰘧 Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$STATUS_DIR\" claude'"
