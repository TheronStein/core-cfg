#!/bin/bash
# Configuration Management Menu
# Location: ~/.tmux/modules/menus/config-management.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="config-management.sh"
PARENT=$(get_parent "main-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰒓' 'Config Management' $MENU_TITLE_CONFIG)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'CONFIGURATIONS')" "" "" \
  " TMUX Config" t "$(om config/tmux-config-menu.sh)" \
  " WezTerm Config" w "$(om config/wezterm-config-menu.sh)" \
  " ZSH Config" z "$(om config/zsh-config-menu.sh)" \
  "󰈔 Yazi Config" y "$(om config/yazi-config-menu.sh)" \
  " Neovim Config" n "$(om config/nvim-config-menu.sh)" \
  "󰏗 Bin Scripts" b "$(om config/bin-config-menu.sh)" \
  "󰏗 TBin Scripts" T "$(om config/tbin-config-menu.sh)" \
  " Git Config" g "$(om config/git-config-menu.sh)" \
  " GitHub CLI Config" G "$(om config/gh-config-menu.sh)" \
  "" \
  "$(menu_sep 'ENVIRONMENT')" "" "" \
  " Hyprland Config" h "$(om env/hyprland-config-menu.sh)" \
  " Rofi Config" r "$(om env/rofi-config-menu.sh)" \
  "󰕮 Waybar Config" W "$(om env/waybar-config-menu.sh)" \
  " Dunst Config" u "$(om env/dunst-config-menu.sh)"
