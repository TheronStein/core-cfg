#!/bin/bash
# Configuration Management Menu

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="config-management.sh"

# Helper to open submenu with parent tracking
om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '\$TMUX_MENUS/$1'"
}

# Get dynamic back button
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]󰒓 Config Management " \
  "󰌑 Back" Tab "run-shell '\$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ CONFIGURATIONS ━━━" "" "" \
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
  "#[fg=#01F9C6,bold]━━━ ENVIRONMENT ━━━" "" "" \
  " Hyprland Config" h "$(om env/hyprland-config-menu.sh)" \
  " Rofi Config" r "$(om env/rofi-config-menu.sh)" \
  "󰕮 Waybar Config" y "$(om env/waybar-config-menu.sh)" \
  " Dunst Config" u "$(om env/dunst-config-menu.sh)"
