#!/bin/bash
# Prefix Menu - Quick actions
# Location: ~/.tmux/modules/menus/prefix-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰙀' 'Prefix Mode' $MENU_TITLE_TMUX)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$(menu_sep 'Quick Actions')" "" "" \
  " Zoom Toggle" z "resize-pane -Z" \
  " Resize Mode" r "run-shell '$TMUX_MENUS/modes/resize.sh'" \
  " Copy Mode" / "copy-mode" \
  "󰑓 Reload Config" R "source-file $TMUX_CONF/tmux.conf ; display 'Config reloaded'"
