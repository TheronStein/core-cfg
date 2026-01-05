#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="mux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#cba6f7,bold] Sidebar " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "󰋊 Remote Mounts" r "display-popup -E -w 90% -h 90% -T ' Rclone Mount Manager ' '~/.core/.sys/cfg/tmux/modules/browsers/rclone-browser/browser.sh'" \
  " Yazibar Toggle" y "run-shell '$TMUX_MODULES/yazibar/toggle.sh'"
