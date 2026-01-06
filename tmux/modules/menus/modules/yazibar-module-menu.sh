#!/bin/bash
# Yazibar Module Configuration Menu
# Quick access to yazibar module settings and scripts

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "modules-management.sh")

YAZIBAR_DIR="$HOME/.core/.sys/cfg/tmux/modules/yazibar"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]󰈔 Yazibar Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ SETTINGS ━━━" "" "" \
  "⚙ Core Settings (widths, paths)" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR scripts/yazibar-utils.sh\"'" \
  " Keybindings" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR conf/keybindings.conf\"'" \
  " Hooks Configuration" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR conf/hooks.conf\"'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ MAIN SCRIPTS ━━━" "" "" \
  " Left Sidebar" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR scripts/yazibar-left.sh\"'" \
  " Right Sidebar" 5 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR scripts/yazibar-right.sh\"'" \
  "󰑓 Run Yazi Script" 6 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR scripts/yazibar-run-yazi.sh\"'" \
  "󰐱 Width Management" 7 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR scripts/yazibar-width.sh\"'" \
  "󰒓 Init Script" 8 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR yazibar.tmux\"'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ UTILITIES ━━━" "" "" \
  " Pane Utils" u "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR scripts/pane-utils.sh\"'" \
  " DDS Handler" d "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR scripts/yazibar-dds-handler.sh\"'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ ACTIONS ━━━" "" "" \
  "󰈔 Explore Yazibar" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" yazi'" \
  "󰘧 Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" claude'" \
  "󰦗 View README" r "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$YAZIBAR_DIR\" \"\\$EDITOR README.md\"'"
