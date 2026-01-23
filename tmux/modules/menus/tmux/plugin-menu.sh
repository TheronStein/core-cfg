#!/bin/bash
# Plugin Management Menu
# Location: ~/.tmux/modules/menus/tmux/plugin-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/plugin-menu.sh"
PARENT=$(get_parent "tmux/management-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Plugin Management' $MENU_TITLE_APP)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'TPM Actions')" "" "" \
  " Install Plugins" i "run-shell '~/.tmux/plugins/tpm/scripts/install_plugins.sh'" \
  "󰚰 Update Plugins" u "run-shell '~/.tmux/plugins/tpm/scripts/update_plugin.sh'" \
  "󰑓 Source Plugins" s "run-shell '~/.tmux/plugins/tpm/scripts/source_plugins.sh'" \
  "󰃢 Clean Plugins" c "run-shell '~/.tmux/plugins/tpm/scripts/clean_plugins.sh'" \
  " List Plugins" l "run-shell '~/.tmux/plugins/tpm/scripts/list_plugins.sh'"
