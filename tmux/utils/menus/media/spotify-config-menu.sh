#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

SPOTIFY_CFG="$HOME/.config/spotify-player"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]Spotify Player Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$SPOTIFY_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$SPOTIFY_CFG\" claude'" \
  "" \
  "app.toml" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$SPOTIFY_CFG\" \"\\$EDITOR app.toml\"'" \
  "theme.toml" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$SPOTIFY_CFG\" \"\\$EDITOR theme.toml\"'" \
  "keymap.toml" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$SPOTIFY_CFG\" \"\\$EDITOR keymap.toml\"'"
