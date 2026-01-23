#!/bin/bash
# Clients Menu
# Location: ~/.tmux/modules/menus/tmux/clients-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/clients-menu.sh"
PARENT=$(get_parent "tmux/management-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰀘' 'Clients' $MENU_TITLE_CONFIG)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'View')" "" "" \
  "󰀘 List Clients" l "display-popup -E -w 80% -h 50% 'tmux list-clients; read -p \"Press Enter...\"'" \
  "" \
  "$(menu_sep 'Actions')" "" "" \
  "󰩈 Detach" d "detach-client" \
  "󰆴 Detach Others" D "detach-client -a" \
  "󰅙 Kill Server" K "confirm-before -p 'Kill tmux server? (y/n)' kill-server"
