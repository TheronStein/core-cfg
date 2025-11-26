#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

MPV_CFG="$HOME/.config/mpv"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]MPV Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MPV_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MPV_CFG\" claude'" \
  "" \
  "mpv.conf" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MPV_CFG\" \"\\$EDITOR mpv.conf\"'" \
  "input.conf" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MPV_CFG\" \"\\$EDITOR input.conf\"'" \
  "Scripts" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MPV_CFG/scripts\" yazi'" \
  "Shaders" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MPV_CFG/shaders\" yazi'"
