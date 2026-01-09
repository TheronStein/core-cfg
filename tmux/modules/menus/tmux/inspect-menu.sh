#!/bin/bash
# Inspect Menu - Introspection and debugging
# Location: ~/.tmux/modules/menus/tmux/inspect-menu.sh

# Use larger popups for inspection tools
POPUP_WIDTH=85 POPUP_HEIGHT=80
source "$TMUX_CONF/lib/menu-utils.sh"

CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$(get_parent "$CURRENT_MENU" "tmux-menu.sh")

tmux display-menu -x C -y P -T "#[fg=#cba6f7,bold]   Inspect   " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Browsers ━━━" "" "" \
  " Browse Options" o "$(fzf_popup 'options-browser.sh')" \
  "󰌌 Browse Keybinds" k "$(fzf_popup 'keybinds-browser.sh')" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Show ━━━" "" "" \
  " Server Info" i "display-popup -E -w 80% -h 70% 'tmux server-info | less'" \
  "󰌌 List All Keys" K "display-popup -E -w 80% -h 90% 'tmux list-keys | less'" \
  " Messages" m "display-popup -E -w 80% -h 70% 'tmux show-messages | less'" \
  "󰓾 Hooks" h "display-popup -E -w 80% -h 70% 'tmux show-hooks -g | less'" \
  " Environment" e "display-popup -E -w 80% -h 70% 'tmux show-environment | sort | less'" \
  "󰆍 Commands" c "display-popup -E -w 80% -h 90% 'tmux list-commands | less'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Options by Scope ━━━" "" "" \
  " Server" S "$(fzf_popup 'options-browser.sh --scope=server')" \
  " Session" s "$(fzf_popup 'options-browser.sh --scope=session')" \
  " Window" w "$(fzf_popup 'options-browser.sh --scope=window')" \
  " Pane" p "$(fzf_popup 'options-browser.sh --scope=pane')" \
  "" \
  " Customization Mode" C "customize-mode"
