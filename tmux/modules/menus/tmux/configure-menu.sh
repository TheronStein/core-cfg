#!/bin/bash
# Configure Menu - Settings and configuration
# Location: ~/.tmux/modules/menus/tmux/configure-menu.sh

# Use larger popups for configuration options
POPUP_WIDTH=85 POPUP_HEIGHT=80
source "$TMUX_CONF/lib/menu-utils.sh"

CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$(get_parent "$CURRENT_MENU" "tmux-menu.sh")

tmux display-menu -x C -y P -T "#[fg=#89dceb,bold]   Configure   " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Quick Settings ━━━" "" "" \
  "󰍽 Toggle Mouse" m "if -F '#{mouse}' 'set mouse off; display \"Mouse off\"' 'set mouse on; display \"Mouse on\"'" \
  " Toggle Status" s "if -F '#{status}' 'set status off' 'set status on'" \
  "󰔡 Toggle Pane Border" b "if -F '#{pane-border-status}' 'set pane-border-status off' 'set pane-border-status bottom'" \
  " Toggle Monitor" a "if -F '#{monitor-activity}' 'setw monitor-activity off; display \"Monitor off\"' 'setw monitor-activity on; display \"Monitor on\"'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Edit Options ━━━" "" "" \
  " Server Options" S "$(fzf_popup 'options-browser.sh --scope=server')" \
  " Session Options" e "$(fzf_popup 'options-browser.sh --scope=session')" \
  " Window Options" w "$(fzf_popup 'options-browser.sh --scope=window')" \
  " Pane Options" p "$(fzf_popup 'options-browser.sh --scope=pane')" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Config Files ━━━" "" "" \
  "󰑓 Reload Config" R "source-file $TMUX_CONF/tmux.conf ; display 'Config reloaded'" \
  " Edit Config" E "display-popup -E -w 90% -h 90% '\${EDITOR:-nvim} $TMUX_CONF/tmux.conf'" \
  " Browse Config" B "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$TMUX_CONF\" yazi'"
