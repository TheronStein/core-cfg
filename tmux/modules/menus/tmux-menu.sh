#!/bin/bash
# TMUX Management Menu

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
PARENT_MENU=$("$MENU_NAV" get "$(basename "$0")" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#73daca,bold]󰙀 TMUX Management " \
  "󰑓 Reload Configuration" r "source-file '$TMUX_CONF/tmux.conf' ; display 'Tmux config reloaded'" \
  "" \
  "Save State" s "run-shell '$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh && tmux display-message \"Session saved at \$(date +%H:%M:%S)\"'" \
  "Restore Session" r "run-shell '$TMUX_CONF/utils/workspace/restore-session.sh'" \
  "󰒲 Sessions" S "run-shell '$TMUX_MENUS/tmux/session-menu.sh'" \
  "󰒫 Kill Server" K "confirm-before -p 'Kill tmux server? (y/n)' 'kill-server'" \
  "" \
  " Plugins" p "run-shell '$TMUX_MENUS/tmux/plugin-menu.sh'" \
  "󰚰 Install Plugins" I "run-shell '$TMUX_CONF/plugins/tpm/bindings/install_plugins'" \
  "󰚰 Update Plugins" U "run-shell '$TMUX_CONF/plugins/tpm/bindings/update_plugins'" \
  "󰚰 Clean Plugins" C "run-shell '$TMUX_CONF/plugins/tpm/bindings/clean_plugins'" \
  "" \
  "󰁮 Back" b "run-shell '$TMUX_MENUS/$PARENT_MENU'"
