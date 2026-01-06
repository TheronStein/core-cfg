#!/bin/bash
# Modules Management Menu
# Quick access to tmux module configurations

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="modules-management.sh"

# Helper to open submenu with parent tracking
om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '$TMUX_MENUS/$1'"
}

# Get dynamic back button
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] Modules Management " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ TMUX MODULES ━━━" "" "" \
  "󰈔 Yazibar Module" y "$(om modules/yazibar-module-menu.sh)" \
  " FZF Module" f "$(om modules/fzf-module-menu.sh)" \
  " Menus Module" m "$(om modules/menus-module-menu.sh)" \
  " Status Module" s "$(om modules/status-module-menu.sh)" \
  "" \
  "#[fg=#01F9C6,bold]━━━ ACTIONS ━━━" "" "" \
  " Explore Modules" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME/.core/.sys/cfg/tmux/modules\" yazi'" \
  "󰘧 Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME/.core/.sys/cfg/tmux/modules\" claude'"
