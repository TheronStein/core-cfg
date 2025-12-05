#!/bin/bash
# Main Menu - Top level navigation

MENU_NAV="$TMUX_MENUS/menu-nav.sh"

# Helper to open submenu with parent tracking
om() {
  "$MENU_NAV" set "$(basename "$1")" "main-menu.sh"
  echo "run-shell '\$TMUX_MENUS/$1'"
}

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] Main Menu " \
  "󰒓 Config Management" c "$(om config-management.sh)" \
  "Zoom Toggle" z "resize-pane -Z" \
  " Vertical Split" v "run-shell '$TMUX_CONF/events/vsplit.sh'" \
  " Horizontal Split" d "run-shell '$TMUX_CONF/events/hsplit.sh'" \
  "" \
  "󰂮 Pane Management" a "$(om mux/pane-menu.sh)" \
  "󰖯 Window Management" w "$(om mux/window-menu.sh)" \
  " Layout Management" l "$(om mux/layout-menu.sh)" \
  "" \
  "Keybind References Menu" k "$(om keybinds-menu.sh)" \
  "Key Modes Menu" m "$(om modes/keymodes-menu.sh)" \
  "󱂬 Popup Windows Menu" e "$(om popup-windows.sh)" \
  "Sidebar Menu" b "$(om mux/sidebar-menu.sh)" \
  "" \
  "󰙀 TMUX Management" t "$(om tmux-menu.sh)" \
  "󰹬 Session Management" s "$(om tmux/session-menu.sh)" \
  " Plugin Management" p "$(om tmux/plugin-menu.sh)" \
  "󰏘 Theme Selector" T "run-shell '$TMUX_CONF/modules/themes/theme-switcher.sh'" \
  "" \
  " App Management" A "$(om app-management.sh)"

# 󰾱 Email
# 󰖟 Notes
# 󰈹 File Explorer
# 󰈔 Music Player
# 󰊳 System Monitor
# 󰍛 Calendar
# 󰓓 To-Do List
# 󰍥 Weather
# 󰖨 News Reader
# 󰒋 RSS Feed
# 󰓆 Chat Application
# 󰍜 Time Tracker
# 󰒡 Pomodoro Timer
# 󰒞 Password Manager
# 󰒥 Clipboard Manager
# 󰒨 Disk Usage Analyzer
# 󰒫 Network Monitor
#
