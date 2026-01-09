#!/bin/bash
# Management Menu - Extensions and Resources
# Location: ~/.tmux/modules/menus/tmux/management-menu.sh

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "tmux-menu.sh")

om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '$TMUX_MENUS/$1'"
}

tmux display-menu -x C -y P -T "#[fg=#73daca,bold] 󰕥  Manage  󰕥 " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " Modules" m "$(om tmux/modules-menu.sh)" \
  " Plugins" p "$(om tmux/plugin-menu.sh)" \
  "󰖟 Workspaces" w "$(om tmux/workspaces-menu.sh)" \
  "󰀘 Clients" c "$(om tmux/clients-menu.sh)" \
  " Buffers" b "$(om tmux/buffers-menu.sh)"
