#!/bin/bash
# Sessions Menu
# Location: ~/.tmux/modules/menus/tmux/sessions-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/sessions-menu.sh"
PARENT=$(get_parent "tmux-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰹬' 'Sessions' $MENU_TITLE_SESSION)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Navigate')" "" "" \
  "󰹬 Switch Session" s "$(fzf_popup 'session-picker.sh --action=switch')" \
  " Last Session" l "switch-client -l" \
  "" \
  "$(menu_sep 'Create & Rename')" "" "" \
  " New Session" n "$(fzf_popup 'session-dir-picker.sh')" \
  "󰑕 Rename" r "command-prompt -I '#S' 'rename-session %%'" \
  "" \
  "$(menu_sep 'Control')" "" "" \
  "󰩈 Detach" d "detach-client" \
  "󰒫 Kill Session" x "$(fzf_popup 'session-picker.sh --action=kill')"
