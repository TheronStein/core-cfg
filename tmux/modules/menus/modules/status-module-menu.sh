#!/bin/bash
# Status Module Configuration Menu
# Location: ~/.tmux/modules/menus/modules/status-module-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="modules/status-module-menu.sh"
PARENT=$(get_parent "tmux/modules-menu.sh")

TOOL_NAME="status-module"
CFG_DIR="$HOME/.core/.sys/cfg/tmux/modules/status"

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Status Module' $MENU_TITLE_MODULE)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Edit')" "" "" \
  " Edit Module" e "run-shell 'source $TMUX_CONF/lib/config-session.sh && edit_config $TOOL_NAME \"$CFG_DIR\"'" \
  " Claude Code" c "run-shell 'source $TMUX_CONF/lib/ai-session.sh && ai_session $TOOL_NAME \"$CFG_DIR\"'"
