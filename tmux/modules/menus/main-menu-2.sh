#!/bin/bash
tmux display-menu -x W -y S \
  "Zoom Toggle" z "resize-pane -Z" \
  " Vertical Split" v "run-shell '~/.core/cfg/tmux/events/vsplit.sh'" \
  " Horizontal Split" d "run-shell '~/.core/cfg/tmux/events/hsplit.sh'" \
  "" \
  "󰂮 Pane Management" a "run-shell '$TMUX_MENUS/mux/pane-menu.sh'" \
  "󰖯 Window Management" w "run-shell '$TMUX_MENUS/mux/window-menu.sh'" \
  " Layout Management" l "run-shell '$TMUX_MENUS/mux/layout-menu.sh'" \
  "" \
  "Keybind References Menu" k "run-shell '$TMUX_MENUS/keybinds-menu.sh'" \
  "Key Modes Menu" m "run-shell '$TMUX_MENUS/keymodes-menu.sh'" \
  "󱂬 Popup Windows Menu" f "run-shell '$TMUX_MENUS/popup-windows.sh'" \
  "Sidebar Menu" b "run-shell '$TMUX_MENUS/sidebar-menu.sh'" \
  "" \
  "󰙀 TMUX Management" t "run-shell '$TMUX_MENUS/tmux-menu.sh'" \
  "󰹬 Session Management" s "run-shell '$TMUX_MENUS/tmux/session-menu.sh'" \
  " Plugin Management" p "run-shell '$TMUX_MENUS/plugin-menu.sh'"

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
