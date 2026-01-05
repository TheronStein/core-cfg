#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

MUTT_CFG="$HOME/.config/neomutt"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]NeoMutt Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MUTT_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MUTT_CFG\" claude'" \
  "" \
  "neomuttrc" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MUTT_CFG\" \"\\$EDITOR neomuttrc\"'" \
  "Accounts" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MUTT_CFG\" \"\\$EDITOR accounts.rc\"'" \
  "Keybindings" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MUTT_CFG\" \"\\$EDITOR keybindings.rc\"'" \
  "Colors" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MUTT_CFG\" \"\\$EDITOR colors.rc\"'" \
  "Mailcap" 5 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MUTT_CFG\" \"\\$EDITOR mailcap\"'"
