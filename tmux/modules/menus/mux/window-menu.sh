#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="mux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '$TMUX_MENUS/$1'"
}

tmux display-menu -x C -y C -T "#[fg=#a6e3a1,bold]󰖯 Window Management " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " New Window" c "command-prompt -p 'Window name:' 'new-window -n \"%%\" -c \"#{pane_current_path}\" -a -t \"{next}\"'" \
  "󰑕 Rename Window" r "command-prompt -p 'New name:' 'rename-window \"%%\"'" \
  " Kill Window" x "confirm-before -p 'Kill window #W? (y/n)' kill-window" \
  " List All Windows" l "choose-tree -w" \
  "" \
  "󰌑 Share to Session" s "command-prompt -p 'Target session:' 'link-window -s . -t \"%%\"'" \
  " Get from Session" g "display-popup -E -w 80% -h 80% '~/.core/.sys/cfg/tmux/scripts/pick-window.sh'" \
  " Move to Session" m "display-popup -E -w 80% -h 60% '~/.core/.sys/cfg/tmux/scripts/move-window.sh'" \
  "" \
  "󰓡 Swap Windows" S "$(om mux/window-swap-menu.sh)" \
  " Move Window" M "$(om mux/window-move-menu.sh)" \
  "" \
  " Move Left" q "run-shell '$TMUX_MENUS/mux/window-move-left.sh'" \
  " Move Right" e "run-shell '$TMUX_MENUS/mux/window-move-right.sh'" \
  "" \
  " Swap Next (follow)" N "swapw -d -t +1 \\; display '#{e|-:#{window_index},1} => #{window_index}'" \
  " Swap Prev (follow)" P "swapw -d -t -1 \\; display '#{window_index} <= #{e|+:#{window_index},1}'"
