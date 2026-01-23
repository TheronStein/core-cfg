#!/bin/bash
# Application Management Menu
# Location: ~/.tmux/modules/menus/app-management.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="app-management.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'App Management' $MENU_TITLE_APP)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'SECURITY')" "" "" \
  "󰞀 Bitwarden Config" B "$(om apps/bitwarden-config-menu.sh)" \
  "󰞀 1Password Config" O "$(om apps/1password-config-menu.sh)" \
  "" \
  "$(menu_sep 'COMMUNICATION')" "" "" \
  "󰾱 NeoMutt Config" M "$(om apps/neomutt-config-menu.sh)" \
  " Qutebrowser Config" Q "$(om apps/qutebrowser-config-menu.sh)" \
  "" \
  "$(menu_sep 'MEDIA')" "" "" \
  "󰐹 MPV Config" V "$(om media/mpv-config-menu.sh)" \
  "󰓇 Spotify Config" S "$(om media/spotify-config-menu.sh)"
