#!/bin/bash
# Modules Menu - Tmux module integrations
# Location: ~/.tmux/modules/menus/tmux/modules-menu.sh

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "tmux/management-menu.sh")

om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '$TMUX_MENUS/$1'"
}

tmux display-menu -x C -y C -T "#[fg=#f9e2af,bold] Modules " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "󰈔 Yazibar" y "$(om modules/yazibar-module-menu.sh)" \
  " FZF Browsers" f "$(om modules/fzf-module-menu.sh)" \
  " Status Bar" s "$(om modules/status-module-menu.sh)" \
  "󰕰 Coremux" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME/.core/.sys/cfg/tmux/modules/coremux\" yazi'" \
  " Layout" l "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME/.core/.sys/cfg/tmux/modules/layout\" yazi'" \
  "󱂬 Popups" p "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME/.core/.sys/cfg/tmux/modules/popups\" yazi'" \
  "" \
  " Explore All Modules" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME/.core/.sys/cfg/tmux/modules\" yazi'" \
  "󰘧 Claude Code" C "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME/.core/.sys/cfg/tmux/modules\" claude'"
