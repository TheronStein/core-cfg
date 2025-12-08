#!/bin/bash
# Application Management Menu

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="app-management.sh"

# Helper to open submenu with parent tracking
om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '\$TMUX_MENUS/$1'"
}

# Get dynamic back button
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] App Management " \
  "󰌑 Back" Tab "run-shell '\$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ OTHER TOOLS ━━━" "" "" \
  "󰞀 Bitwarden Config" B "$(om other/bitwarden-config-menu.sh)" \
  "󰞀 1Password Config" O "$(om other/1password-config-menu.sh)" \
  "󰾱 NeoMutt Config" M "$(om other/neomutt-config-menu.sh)" \
  " Qutebrowser Config" Q "$(om other/qutebrowser-config-menu.sh)" \
  "" \
  "#[fg=#01F9C6,bold]━━━ MEDIA ━━━" "" "" \
  "󰐹 MPV Config" V "$(om media/mpv-config-menu.sh)" \
  "󰓇 Spotify Player Config" S "$(om media/spotify-config-menu.sh)"
