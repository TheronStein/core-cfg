#!/bin/bash
# Qutebrowser Configuration Menu
# Location: ~/.tmux/modules/menus/apps/qutebrowser-config-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="apps/qutebrowser-config-menu.sh"
PARENT=$(get_parent "app-management.sh")

TOOL_NAME="qutebrowser"
CFG_DIR="$HOME/.config/qutebrowser"

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Qutebrowser Configuration' $MENU_TITLE_APP)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Edit')" "" "" \
  " Edit Config" e "run-shell 'source $TMUX_CONF/lib/config-session.sh && edit_config $TOOL_NAME \"$CFG_DIR\"'" \
  " Claude Code" c "run-shell 'source $TMUX_CONF/lib/ai-session.sh && ai_session $TOOL_NAME \"$CFG_DIR\"'"
