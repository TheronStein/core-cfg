#!/bin/bash
# Windows Menu
# Location: ~/.tmux/modules/menus/tmux/windows-menu.sh

source "$TMUX_CONF/lib/menu-utils.sh"

CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$(get_parent "$CURRENT_MENU" "tmux-menu.sh")

tmux display-menu -x C -y P -T "#[fg=#a6e3a1,bold] 󰖯  Windows  󰖯 " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Create & Rename ━━━" "" "" \
  " New Window" c "command-prompt -p 'Window name:' 'new-window -n \"%%\" -c \"#{pane_current_path}\" -a -t \"{next}\"'" \
  "󰑕 Rename" r "command-prompt -p 'New name:' 'rename-window \"%%\"'" \
  " Kill Window" x "confirm-before -p 'Kill window #W? (y/n)' kill-window" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Navigate ━━━" "" "" \
  "󰖯 Switch" s "$(fzf_popup 'window-picker.sh --action=switch')" \
  " Previous" p "previous-window" \
  " Next" n "next-window" \
  " Last" l "last-window" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Move & Swap ━━━" "" "" \
  "󰓡 Swap" S "$(fzf_popup 'window-picker.sh --action=swap')" \
  " Move Before" "<" "$(fzf_popup 'window-picker.sh --action=move-before')" \
  " Move After" ">" "$(fzf_popup 'window-picker.sh --action=move-after')" \
  " Move Left" q "swap-window -d -t -1" \
  " Move Right" e "swap-window -d -t +1" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Cross-Session ━━━" "" "" \
  "󰌑 Link from Session" L "$(fzf_popup 'window-picker.sh --action=link')" \
  " Move to Session" m "command-prompt -p 'Target session:' 'move-window -t \"%%\"'" \
