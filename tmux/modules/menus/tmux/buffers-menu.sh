#!/bin/bash
# Buffers Menu
# Location: ~/.tmux/modules/menus/tmux/buffers-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/buffers-menu.sh"
PARENT=$(get_parent "tmux/management-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Buffers' $MENU_TITLE_MODULE)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Browse')" "" "" \
  "󰒍 List Buffers" l "$(fzf_popup 'buffer-picker.sh --action=paste')" \
  "" \
  "$(menu_sep 'Actions')" "" "" \
  "󰆒 Paste Buffer" p "paste-buffer" \
  "󰆴 Delete Buffer" d "$(fzf_popup 'buffer-picker.sh --action=delete')" \
  " Copy to Clipboard" c "$(fzf_popup 'buffer-picker.sh --action=copy')" \
  "󰃨 Clear History" h "clear-history"
