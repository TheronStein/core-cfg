#!/bin/bash
SPOTIFY_CFG="$HOME/.config/spotify-player"

tmux display-menu -x W -y S -T "Spotify Player Configuration" \
  "󰌑 Back to Menu" b "run-shell '$TMUX_MENUS/main-menu.sh'" \
  "󰈔 Explore Config" e "display-popup -E -w 90% -h 90% -d '$SPOTIFY_CFG' 'yazi'" \
  " Claude Code" c "display-popup -E -w 90% -h 90% -d '$SPOTIFY_CFG' 'claude'" \
  "" \
  "app.toml" 1 "display-popup -E -w 90% -h 90% -d '$SPOTIFY_CFG' '$EDITOR app.toml'" \
  "theme.toml" 2 "display-popup -E -w 90% -h 90% -d '$SPOTIFY_CFG' '$EDITOR theme.toml'" \
  "keymap.toml" 3 "display-popup -E -w 90% -h 90% -d '$SPOTIFY_CFG' '$EDITOR keymap.toml'"
