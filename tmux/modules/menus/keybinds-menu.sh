#!/bin/bash
# Keybinds Reference Menu

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
PARENT_MENU=$("$MENU_NAV" get "$(basename "$0")" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#bb9af7,bold] Keybind References " \
  "󰌌 Core Keybinds" c "display-message 'Prefix: C-Space | Split: v/d | Navigate: Alt+hjkl'" \
  "󰘳 Window Keys" w "display-message 'New: Prefix+c | Next: Prefix+n | Prev: Prefix+p | List: Prefix+w'" \
  "󰂮 Pane Keys" p "display-message 'Split V: Prefix+v | Split H: Prefix+d | Navigate: Alt+Arrows'" \
  "󰒺 Copy Mode" C "display-message 'Enter: Prefix+[ | Copy: Space->Enter | Paste: Prefix+]'" \
  "" \
  "󱂬 Popup Keys" P "display-message 'Lazygit: Prefix+g | Float term: Prefix+t | Task: Prefix+T'" \
  "󰕷 Search Keys" s "display-message 'FZF: Prefix+f | URLs: Prefix+u | Sessions: M-w'" \
  "" \
  "󰒓 Resize Mode" r "display-message 'Enter: Prefix+R | Resize: hjkl/Arrows | Exit: q/Esc'" \
  "" \
  "󰁮 Back" b "run-shell '$TMUX_MENUS/$PARENT_MENU'"
