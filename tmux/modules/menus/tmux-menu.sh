#!/bin/bash
# TMUX Main Menu - Primary tmux menu entry point
# Location: ~/.tmux/modules/menus/tmux-menu.sh
# Binding: C-Space (root table)

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
PICKERS="$TMUX_CONF/modules/fzf/pickers"

om() {
  "$MENU_NAV" set "$(basename "$1")" "tmux-menu.sh"
  echo "run-shell '$TMUX_MENUS/$1'"
}

tmux display-menu -x C -y P -T "#[fg=#7aa2f7,bold] 󰙀  TMUX  󰙀 " \
  " Zoom" z "resize-pane -Z" \
  " Copy Mode" / "copy-mode" \
  " Resize Mode" r "run-shell '$TMUX_MENUS/modes/pane-resize-select.sh'" \
  "󰌌 Prefix Mode" Space "switch-client -T prefix" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Interface ━━━" "" "" \
  "󰂮 Panes" a "$(om tmux/panes-menu.sh)" \
  "󰖯 Windows" w "$(om tmux/windows-menu.sh)" \
  " Layouts" l "$(om tmux/layouts-menu.sh)" \
  "󰹬 Sessions" s "$(om tmux/sessions-menu.sh)" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Environment ━━━" "" "" \
  " Inspect" i "$(om tmux/inspect-menu.sh)" \
  " Configure" c "$(om tmux/configure-menu.sh)" \
  "󰕥 Manage" m "$(om tmux/management-menu.sh)" \
  "" \
  "󰘬 Clock" t "clock-mode" \
  "󰆍 Commands" "?" "display-popup -E -w 80% -h 90% 'tmux list-commands | less'" \
  "" \
  "󰑓 Reload Config" R "source-file $TMUX_CONF/tmux.conf ; display 'Config reloaded'" \
  "󰒫 Kill Server" K "confirm-before -p 'Kill tmux server? (y/n)' 'kill-server'"
