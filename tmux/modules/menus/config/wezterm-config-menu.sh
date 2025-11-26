#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

WEZTERM_CFG="$HOME/.core/.sys/cfg/wezterm"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]WezTerm Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$WEZTERM_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$WEZTERM_CFG\" claude'" \
  "" \
  "Main Config" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$WEZTERM_CFG\" \"\\$EDITOR wezterm.lua\"'" \
  "Keybindings" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$WEZTERM_CFG\" \"\\$EDITOR keybindings.lua\"'" \
  "Appearance" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$WEZTERM_CFG\" \"\\$EDITOR appearance.lua\"'" \
  "Colors" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$WEZTERM_CFG\" \"\\$EDITOR colors.lua\"'"
