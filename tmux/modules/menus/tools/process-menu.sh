#!/bin/bash
# Process Management Menu
# Location: ~/.tmux/modules/menus/tools/process-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tools/process-menu.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Process Management' $MENU_TITLE_APP)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Monitors')" "" "" \
  " System Monitor" h "display-popup -E -w 95% -h 95% -T ' htop ' htop" \
  " Btop" b "display-popup -E -w 95% -h 95% -T ' btop ' btop" \
  "" \
  "$(menu_sep 'Kill')" "" "" \
  " Kill by Name" k "command-prompt -p 'Kill process:' 'run-shell \"pkill %1 && tmux display-message \\\"Killed %1\\\"\"'" \
  "󰓛 Kill by PID" K "command-prompt -p 'Kill PID:' 'run-shell \"kill %1 && tmux display-message \\\"Killed PID %1\\\"\"'" \
  "" \
  "$(menu_sep 'Browse')" "" "" \
  " Process List" p "display-popup -E -w 90% -h 80% -T ' Processes ' 'ps aux | less'" \
  " FZF Kill" f "display-popup -E -w 80% -h 60% 'ps aux | fzf --header=\"Select process to kill\" | awk \"{print \\$2}\" | xargs -r kill && tmux display-message \"Process killed\"'"
