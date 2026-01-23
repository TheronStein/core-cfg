#!/bin/bash
# Management Menu - Extensions and Resources
# Location: ~/.tmux/modules/menus/tmux/management-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/management-menu.sh"
PARENT=$(get_parent "tmux-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰕥' 'Manage' $MENU_TITLE_TMUX)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Quick Settings')" "" "" \
  "󰍽 Toggle Mouse" M "if -F '#{mouse}' 'set mouse off; display \"Mouse off\"' 'set mouse on; display \"Mouse on\"'" \
  " Toggle Status" S "if -F '#{status}' 'set status off' 'set status on'" \
  "󰔡 Toggle Pane Border" B "if -F '#{pane-border-status}' 'set pane-border-status off' 'set pane-border-status bottom'" \
  " Toggle Monitor" A "if -F '#{monitor-activity}' 'setw monitor-activity off; display \"Monitor off\"' 'setw monitor-activity on; display \"Monitor on\"'" \
  "" \
  "$(menu_sep 'Extensions')" "" "" \
  " Modules" m "$(om tmux/modules-menu.sh)" \
  " Plugins" p "$(om tmux/plugin-menu.sh)" \
  "󰖟 Workspaces" w "$(om tmux/workspaces-menu.sh)" \
  "󰀘 Clients" c "$(om tmux/clients-menu.sh)" \
  " Buffers" b "$(om tmux/buffers-menu.sh)" \
  "" \
  "$(menu_sep 'Session Persistence')" "" "" \
  "󰆓 Save State" s "run-shell '$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh' ; display 'Session saved'" \
  "󰦛 Restore" r "run-shell '$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh'" \
  " Last Save" i "display-message 'Last: #(ls -la ~/.tmux/resurrect/last 2>/dev/null | awk \"{print \\$NF}\" || echo \"none\")'" \
  "" \
  "󰒫 Kill Server" K "confirm-before -p 'Kill tmux server? (y/n)' 'kill-server'"
