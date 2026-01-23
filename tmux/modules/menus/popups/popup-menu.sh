#!/bin/bash
# Popup Applications Menu
# Location: ~/.tmux/modules/menus/popups/popup-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="popups/popup-menu.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󱂬' 'Popup Applications' $MENU_TITLE_MODULE)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'AI & Communication')" "" "" \
  "󰚩 AI Sessions (M-\`)" a "run-shell '$TMUX_CONF/modules/popups/ai-picker.sh'" \
  "󰓷 SMS Messaging" s "run-shell '$TMUX_CONF/modules/popups/smstui.sh'" \
  "󰾱 Neomutt Email" e "run-shell '$TMUX_CONF/modules/popups/neomutt.sh'" \
  " Documents" D "run-shell '$TMUX_CONF/modules/popups/notes.sh'" \
  "" \
  "$(menu_sep 'Utilities')" "" "" \
  " Spotify Player" S "run-shell '$TMUX_CONF/modules/popups/spotify_player.sh'" \
  " System Monitor" m "run-shell '$TMUX_CONF/modules/popups/btop.sh'" \
  "" \
  "$(menu_sep 'Reference')" "" "" \
  " Hyprland Keybinds" h "run-shell '$TMUX_CONF/modules/popups/hyprland-keymaps.sh'" \
  " Design Colors" d "run-shell '$TMUX_CONF/modules/popups/colors.sh'" \
  " Nerd Fonts" f "run-shell 'tmux display-popup -E -w 90% -h 90% -T \" Nerd Fonts \" ~/.core/.sys/cfg/wezterm/scripts/nerdfont-browser/wezterm-browser.sh'"
