#!/bin/bash
# Workspaces Menu - Tmux server sockets management
# Location: ~/.tmux/modules/menus/tmux/workspaces-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/workspaces-menu.sh"
PARENT=$(get_parent "tmux/management-menu.sh")

# Get socket directory
SOCKET_DIR="${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)"

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰖟' 'Workspaces (Sockets)' $MENU_TITLE_MODULE)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'View')" "" "" \
  " List Sockets" l "display-popup -E -w 60% -h 50% 'echo \"=== Active Sockets ===\"; ls -la $SOCKET_DIR 2>/dev/null || echo \"No sockets found\"; echo \"\"; read -p \"Press Enter to close...\"'" \
  " Current Socket" c "display-message 'Socket: #{socket_path}'" \
  "" \
  "$(menu_sep 'Manage')" "" "" \
  " New Socket Session" n "command-prompt -p 'Socket name:,Session name:' 'run-shell \"tmux -L %1 new-session -d -s %2 && tmux -L %1 attach\"'" \
  "󰿅 Attach to Socket" a "command-prompt -p 'Socket name:' 'run-shell \"tmux -L %1 attach || tmux display-message \\\"Socket not found\\\"\"'" \
  "" \
  "󰒫 Kill Socket" k "command-prompt -p 'Socket to kill:' 'run-shell \"tmux -L %1 kill-server 2>/dev/null && tmux display-message \\\"Killed socket: %1\\\" || tmux display-message \\\"Socket not found\\\"\"'"
