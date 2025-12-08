#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

ZSH_CFG="$HOME/.core/.sys/cfg/zsh"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold]ZSH Configuration " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$ZSH_CFG\" yazi'" \
  " Claude Code" c "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$ZSH_CFG\" claude'" \
  "" \
  ".zshrc" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME\" \"\\$EDITOR .zshrc\"'" \
  ".zshenv" 2 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$HOME\" \"\\$EDITOR .zshenv\"'" \
  "Aliases" 3 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$ZSH_CFG\" \"\\$EDITOR aliases.zsh\"'" \
  "Functions" 4 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$ZSH_CFG\" \"\\$EDITOR functions.zsh\"'" \
  "Plugins" 5 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$ZSH_CFG\" \"\\$EDITOR plugins.zsh\"'" \
  "Theme" 6 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$ZSH_CFG\" \"\\$EDITOR theme.zsh\"'"
