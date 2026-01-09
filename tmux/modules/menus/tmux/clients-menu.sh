#!/bin/bash
# Clients Menu
# Location: ~/.tmux/modules/menus/tmux/clients-menu.sh

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "tmux/management-menu.sh")

tmux display-menu -x C -y P -T "#[fg=#f9e2af,bold] 󰀘  Clients  󰀘 " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "󰀘 List Clients" l "display-popup -E -w 80% -h 50% 'tmux list-clients; read -p \"Press Enter...\"'" \
  "󰩈 Detach" d "detach-client" \
  "󰆴 Detach Others" D "detach-client -a" \
  "󰅙 Kill Server" K "confirm-before -p 'Kill tmux server? (y/n)' kill-server"
