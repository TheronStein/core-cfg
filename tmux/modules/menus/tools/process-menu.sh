#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="tools/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#eba0ac,bold] Process Management " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " System Monitor" h "display-popup -E -w 95% -h 95% -T ' htop ' htop" \
  " Btop" b "display-popup -E -w 95% -h 95% -T ' btop ' btop" \
  "" \
  " Kill by Name" k "command-prompt -p 'Kill process:' 'run-shell \"pkill %1 && tmux display-message \\\"Killed %1\\\"\"'" \
  "󰓛 Kill by PID" K "command-prompt -p 'Kill PID:' 'run-shell \"kill %1 && tmux display-message \\\"Killed PID %1\\\"\"'" \
  "" \
  " Process List" p "display-popup -E -w 90% -h 80% -T ' Processes ' 'ps aux | less'" \
  " FZF Kill" f "display-popup -E -w 80% -h 60% 'ps aux | fzf --header=\"Select process to kill\" | awk \"{print \\$2}\" | xargs -r kill && tmux display-message \"Process killed\"'"
