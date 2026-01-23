#!/bin/bash
# Save & Restore Menu
# Location: ~/.tmux/modules/menus/session/save-restore-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="session/save-restore-menu.sh"
PARENT=$(get_parent "tmux/sessions-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰆓' 'Save & Restore' $MENU_TITLE_SESSION)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Actions')" "" "" \
  "󰆓 Save State" s "run-shell '$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh' ; display-message 'Session saved'" \
  "󰦛 Restore Session" r "run-shell '$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh'" \
  "" \
  " Last Save Info" i "display-message 'Last: #(ls -la ~/.tmux/resurrect/last | awk \"{print \\$NF}\")'"
