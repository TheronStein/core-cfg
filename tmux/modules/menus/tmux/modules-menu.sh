#!/bin/bash
# Modules Menu - Tmux module integrations
# Location: ~/.tmux/modules/menus/tmux/modules-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/modules-menu.sh"
PARENT=$(get_parent "tmux/management-menu.sh")

TOOL_NAME="tmux-modules"
CFG_DIR="$HOME/.core/.sys/cfg/tmux/modules"

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Modules' $MENU_TITLE_MODULE)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Module Settings')" "" "" \
  " Yazibar" y "$(om modules/yazibar-module-menu.sh)" \
  " FZF Browsers" f "$(om modules/fzf-module-menu.sh)" \
  " Status Bar" s "$(om modules/status-module-menu.sh)" \
  " Menus" m "$(om modules/menus-module-menu.sh)" \
  "" \
  "$(menu_sep 'Edit')" "" "" \
  " Edit All Modules" e "run-shell 'source $TMUX_CONF/lib/config-session.sh && edit_config $TOOL_NAME \"$CFG_DIR\"'" \
  " Claude Code" c "run-shell 'source $TMUX_CONF/lib/ai-session.sh && ai_session $TOOL_NAME \"$CFG_DIR\"'"
