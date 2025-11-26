#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

NVIM_CFG="$HOME/.config/nvim"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]Neovim Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$NVIM_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$NVIM_CFG\" claude'" \
  "" \
  "Init.lua" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$NVIM_CFG\" \"\\$EDITOR init.lua\"'" \
  "Keymaps" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$NVIM_CFG\" \"\\$EDITOR lua/keymaps.lua\"'" \
  "Options" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$NVIM_CFG\" \"\\$EDITOR lua/options.lua\"'" \
  "Plugins" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$NVIM_CFG\" \"\\$EDITOR lua/plugins/init.lua\"'" \
  "LSP Config" 5 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$NVIM_CFG\" \"\\$EDITOR lua/lsp.lua\"'" \
  "Autocmds" 6 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$NVIM_CFG\" \"\\$EDITOR lua/autocmds.lua\"'"
