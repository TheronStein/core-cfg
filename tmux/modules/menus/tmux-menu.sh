#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '\$TMUX_MENUS/$1'"
}

tmux display-menu -x C -y C -T "#[fg=#73daca,bold]󰙀 TMUX Management " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "󰑓 Reload Configuration" R "source-file $TMUX_CONF/tmux.conf ; display 'Tmux config reloaded'" \
  "" \
  "󰹬 Sessions" s "$(om tmux/session-menu.sh)" \
  " Plugins" p "$(om tmux/plugin-menu.sh)" \
  "󰆓 Save/Restore" S "$(om session/save-restore-menu.sh)" \
  "" \
  "󰒫 Kill Server" K "confirm-before -p 'Kill tmux server? (y/n)' 'kill-server'"
