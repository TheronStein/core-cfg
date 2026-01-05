#!/bin/bash
# Application Management Menu

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="app-management.sh"

om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '$TMUX_MENUS/$1'"
}

PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] App Management " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ SECURITY ━━━" "" "" \
  "󰞀 Bitwarden Config" B "$(om apps/bitwarden-config-menu.sh)" \
  "󰞀 1Password Config" O "$(om apps/1password-config-menu.sh)" \
  "" \
  "#[fg=#01F9C6,bold]━━━ COMMUNICATION ━━━" "" "" \
  "󰾱 NeoMutt Config" M "$(om apps/neomutt-config-menu.sh)" \
  " Qutebrowser Config" Q "$(om apps/qutebrowser-config-menu.sh)" \
  "" \
  "#[fg=#01F9C6,bold]━━━ MEDIA ━━━" "" "" \
  "󰐹 MPV Config" V "$(om media/mpv-config-menu.sh)" \
  "󰓇 Spotify Config" S "$(om media/spotify-config-menu.sh)"
