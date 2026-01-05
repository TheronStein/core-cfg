#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#f38ba8,bold] Plugin Management " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " Install Plugins" i "run-shell '~/.tmux/plugins/tpm/scripts/install_plugins.sh'" \
  "󰚰 Update Plugins" u "run-shell '~/.tmux/plugins/tpm/scripts/update_plugin.sh'" \
  "󰑓 Source Plugins" s "run-shell '~/.tmux/plugins/tpm/scripts/source_plugins.sh'" \
  "󰃢 Clean Plugins" c "run-shell '~/.tmux/plugins/tpm/scripts/clean_plugins.sh'" \
  " List Plugins" l "run-shell '~/.tmux/plugins/tpm/scripts/list_plugins.sh'"
