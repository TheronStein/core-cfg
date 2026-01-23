#!/bin/bash
# Inspect Menu - Introspection and debugging
# Location: ~/.tmux/modules/menus/tmux/inspect-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/inspect-menu.sh"
PARENT=$(get_parent "tmux-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '' 'Inspect' $MENU_TITLE_MODULE)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Browsers')" "" "" \
  " Browse Options" o "$(fzf_popup 'options-browser.sh')" \
  "󰌌 Browse Keybinds" k "$(fzf_popup 'keybinds-browser.sh')" \
  "" \
  "$(menu_sep 'Show')" "" "" \
  " Server Info" i "display-popup -E -w 80% -h 70% 'tmux server-info | less'" \
  "󰌌 List All Keys" K "display-popup -E -w 80% -h 90% 'tmux list-keys | less'" \
  " Messages" m "display-popup -E -w 80% -h 70% 'tmux show-messages | less'" \
  "󰓾 Hooks" h "display-popup -E -w 80% -h 70% 'tmux show-hooks -g | less'" \
  " Environment" e "display-popup -E -w 80% -h 70% 'tmux show-environment | sort | less'" \
  "󰆍 Commands" c "display-popup -E -w 80% -h 90% 'tmux list-commands | less'" \
  "" \
  "$(menu_sep 'Options by Scope')" "" "" \
  " Server" S "$(fzf_popup 'options-browser.sh --scope=server')" \
  " Session" s "$(fzf_popup 'options-browser.sh --scope=session')" \
  " Window" w "$(fzf_popup 'options-browser.sh --scope=window')" \
  " Pane" p "$(fzf_popup 'options-browser.sh --scope=pane')" \
  "" \
  " Customization Mode" C "customize-mode" \
  "" \
  "󰘬 Show Clock" t "clock-mode"
