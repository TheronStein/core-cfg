#!/bin/bash
# SSH Connections Menu
# Location: ~/.tmux/modules/menus/connect/ssh-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="connect/ssh-menu.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'SSH Connections' $MENU_TITLE_MODULE)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Connect')" "" "" \
  " New SSH Connection" n "command-prompt -p 'SSH to:' 'new-window -n \"ssh-%1\" \"ssh %%\"'" \
  "" \
  "$(menu_sep 'Saved Hosts')" "" "" \
  " Browse SSH Config" c "display-popup -E -w 80% -h 70% -T ' SSH Config ' '\$EDITOR ~/.ssh/config'" \
  " FZF SSH Select" f "display-popup -E -w 60% -h 50% 'grep -E \"^Host \" ~/.ssh/config | cut -d\" \" -f2 | fzf --prompt=\"SSH to: \" | xargs -I{} tmux new-window -n \"ssh-{}\" \"ssh {}\"'"
