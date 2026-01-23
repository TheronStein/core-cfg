#!/bin/bash
# Keybind Reference Menu
# Location: ~/.tmux/modules/menus/reference/keybinds-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="reference/keybinds-menu.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰌌' 'Keybind Reference' $MENU_TITLE_WINDOW)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Navigation')" "" "" \
  "󰌌 Core Keybinds" c "display-message 'Prefix: C-Space | Split: v/d | Navigate: Alt+hjkl'" \
  "󰘳 Window Keys" w "display-message 'New: Prefix+c | Next: Prefix+n | Prev: Prefix+p | List: Prefix+w'" \
  "󰂮 Pane Keys" p "display-message 'Split V: Prefix+v | Split H: Prefix+d | Navigate: Alt+Arrows'" \
  "" \
  "$(menu_sep 'Features')" "" "" \
  "󰒺 Copy Mode" C "display-message 'Enter: Prefix+[ | Copy: Space->Enter | Paste: Prefix+]'" \
  "󱂬 Popup Keys" P "display-message 'Lazygit: Prefix+g | Float term: Prefix+t | Task: Prefix+T'" \
  "󰕷 Search Keys" s "display-message 'FZF: Prefix+f | URLs: Prefix+u | Sessions: M-w'" \
  "" \
  "󰒓 Resize Mode" r "display-message 'Enter: Prefix+R | Resize: hjkl/Arrows | Exit: q/Esc'"
