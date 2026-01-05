#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="session/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "tmux/session-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#89dceb,bold]󰆓 Save & Restore " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "󰆓 Save State" s "run-shell '$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh' ; display-message 'Session saved'" \
  "󰦛 Restore Session" r "run-shell '$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh'" \
  "" \
  " Last Save Info" i "display-message 'Last: #(ls -la ~/.tmux/resurrect/last | awk \"{print \\$NF}\")'"
