#!/bin/bash
# Buffers Menu
# Location: ~/.tmux/modules/menus/tmux/buffers-menu.sh

source "$TMUX_CONF/lib/menu-utils.sh"

CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$(get_parent "$CURRENT_MENU" "tmux/management-menu.sh")

tmux display-menu -x C -y P -T "#[fg=#94e2d5,bold]   Buffers   " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "󰒍 List Buffers" l "$(fzf_popup 'buffer-picker.sh --action=paste')" \
  "󰆒 Paste Buffer" p "paste-buffer" \
  "󰆴 Delete Buffer" d "$(fzf_popup 'buffer-picker.sh --action=delete')" \
  " Copy to Clipboard" c "$(fzf_popup 'buffer-picker.sh --action=copy')" \
  "󰃨 Clear History" h "clear-history"
