#!/bin/bash
# Workspaces Menu - Tmux server sockets management
# Location: ~/.tmux/modules/menus/tmux/workspaces-menu.sh

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "tmux/management-menu.sh")

# Get socket directory
SOCKET_DIR="${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)"

tmux display-menu -x C -y C -T "#[fg=#89dceb,bold]󰖟 Workspaces (Sockets) " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " List Sockets" l "display-popup -E -w 60% -h 50% 'echo \"=== Active Sockets ===\"; ls -la $SOCKET_DIR 2>/dev/null || echo \"No sockets found\"; echo \"\"; read -p \"Press Enter to close...\"'" \
  " Current Socket" c "display-message 'Socket: #{socket_path}'" \
  "" \
  " New Socket Session" n "command-prompt -p 'Socket name:,Session name:' 'run-shell \"tmux -L %1 new-session -d -s %2 && tmux -L %1 attach\"'" \
  "󰿅 Attach to Socket" a "command-prompt -p 'Socket name:' 'run-shell \"tmux -L %1 attach || tmux display-message \\\"Socket not found\\\"\"'" \
  "" \
  "󰒫 Kill Socket" k "command-prompt -p 'Socket to kill:' 'run-shell \"tmux -L %1 kill-server 2>/dev/null && tmux display-message \\\"Killed socket: %1\\\" || tmux display-message \\\"Socket not found\\\"\"'"
