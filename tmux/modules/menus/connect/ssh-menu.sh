#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="connect/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

# Read SSH hosts from config
SSH_CONFIG="$HOME/.ssh/config"

tmux display-menu -x C -y C -T "#[fg=#74c7ec,bold] SSH Connections " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " New SSH Connection" n "command-prompt -p 'SSH to:' 'new-window -n \"ssh-%1\" \"ssh %%\"'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ SAVED HOSTS ━━━" "" "" \
  " Browse SSH Config" c "display-popup -E -w 80% -h 70% -T ' SSH Config ' '\$EDITOR ~/.ssh/config'" \
  " FZF SSH Select" f "display-popup -E -w 60% -h 50% 'grep -E \"^Host \" ~/.ssh/config | cut -d\" \" -f2 | fzf --prompt=\"SSH to: \" | xargs -I{} tmux new-window -n \"ssh-{}\" \"ssh {}\"'"
