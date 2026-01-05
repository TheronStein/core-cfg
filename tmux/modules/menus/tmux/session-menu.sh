#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '$TMUX_MENUS/$1'"
}

tmux display-menu -x C -y C -T "#[fg=#fab387,bold]󰹬 Session Management " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " Switch Session" s "choose-tree -s" \
  "󰑕 Rename Session" r "command-prompt -I '#S' 'rename-session %%'" \
  " New Session" n "command-prompt -p 'New session name:' 'new-session -d -s %%'" \
  " Kill Session" x "confirm-before -p 'Kill session #S? (y/n)' kill-session" \
  "" \
  " Task Management" t "$(om modules/task-menu.sh)" \
  "󰆓 Save/Restore" S "$(om session/save-restore-menu.sh)"
