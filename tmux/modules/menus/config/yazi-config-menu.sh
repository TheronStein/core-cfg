#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

YAZI_CFG="$HOME/.config/yazi"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]Yazi Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZI_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZI_CFG\" claude'" \
  "" \
  "Main Config" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZI_CFG\" \"\\$EDITOR yazi.toml\"'" \
  "Keymap" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZI_CFG\" \"\\$EDITOR keymap.toml\"'" \
  "Theme" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZI_CFG\" \"\\$EDITOR theme.toml\"'" \
  "Plugins" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZI_CFG\" \"\\$EDITOR init.lua\"'"
