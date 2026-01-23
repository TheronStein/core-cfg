#!/bin/bash
# Windows Menu
# Location: ~/.tmux/modules/menus/tmux/windows-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/windows-menu.sh"
PARENT=$(get_parent "tmux-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰖯' 'Windows' $MENU_TITLE_WINDOW)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Create & Rename')" "" "" \
  " New Window" c "command-prompt -p 'Window name:' 'new-window -n \"%%\" -c \"#{pane_current_path}\" -a -t \"{next}\"'" \
  "󰑕 Rename" r "command-prompt -p 'New name:' 'rename-window \"%%\"'" \
  " Kill Window" x "confirm-before -p 'Kill window #W? (y/n)' kill-window" \
  "" \
  "$(menu_sep 'Navigate')" "" "" \
  "󰖯 Switch" s "$(fzf_popup 'window-picker.sh --action=switch')" \
  "" \
  "$(menu_sep 'Move & Swap')" "" "" \
  "󰓡 Swap" S "$(fzf_popup 'window-picker.sh --action=swap')" \
  " Move Before" "<" "$(fzf_popup 'window-picker.sh --action=move-before')" \
  " Move After" ">" "$(fzf_popup 'window-picker.sh --action=move-after')" \
  " Move Left" q "swap-window -d -t -1" \
  " Move Right" e "swap-window -d -t +1" \
  "" \
  "$(menu_sep 'Cross-Session')" "" "" \
  "󰌑 Link from Session" L "$(fzf_popup 'window-picker.sh --action=link')" \
  " Move to Session" m "command-prompt -p 'Target session:' 'move-window -t \"%%\"'"
