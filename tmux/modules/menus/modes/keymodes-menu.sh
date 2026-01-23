#!/bin/bash
# Key Modes Menu
# Location: ~/.tmux/modules/menus/modes/keymodes-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="modes/keymodes-menu.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰌌' 'Key Modes' $MENU_TITLE_TMUX)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Enter Mode')" "" "" \
  " Copy Mode" c "run-shell '$TMUX_MENUS/modes/copy-mode.sh'" \
  " Resize Mode" r "run-shell '$TMUX_MENUS/mux/pane-resize-select.sh'"
