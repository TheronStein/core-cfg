#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

TBIN_DIR="$HOME/.local/tbin"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]TBin Scripts " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Scripts" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TBIN_DIR\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TBIN_DIR\" claude'"
