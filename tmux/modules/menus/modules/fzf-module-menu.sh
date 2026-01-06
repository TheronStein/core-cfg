#!/bin/bash
# FZF Module Configuration Menu (Placeholder)

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "modules-management.sh")

FZF_DIR="$HOME/.core/.sys/cfg/tmux/modules/fzf"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] FZF Module " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ FZF SCRIPTS ━━━" "" "" \
  "󰈔 Explore FZF Module" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$FZF_DIR\" yazi'" \
  "󰘧 Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$FZF_DIR\" claude'"
