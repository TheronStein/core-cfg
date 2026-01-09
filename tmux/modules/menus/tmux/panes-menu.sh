#!/bin/bash
# Panes Menu
# Location: ~/.tmux/modules/menus/tmux/panes-menu.sh

source "$TMUX_CONF/lib/menu-utils.sh"

CURRENT_MENU="tmux/$(basename "$0")"
PARENT=$(get_parent "$CURRENT_MENU" "tmux-menu.sh")

tmux display-menu -x C -y P -T "#[fg=#89b4fa,bold] 󰂮  Panes  󰂮 " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Create ━━━" "" "" \
  " Vertical Split" v "run-shell '$TMUX_CONF/events/split.sh v'" \
  " Horizontal Split" d "run-shell '$TMUX_CONF/events/split.sh h'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Actions ━━━" "" "" \
  " Kill Pane" x "kill-pane" \
  " Break to Window" b "break-pane" \
  " Break (stay)" B "break-pane -d" \
  "󰓦 Toggle Sync" y "if -F '#{pane_synchronized}' 'set -w synchronize-panes off; display \"Sync off\"' 'set -w synchronize-panes on; display \"Sync on\"'" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Move & Swap ━━━" "" "" \
  "󰓡 Swap Pane" s "$(fzf_popup 'pane-picker.sh --action=swap --all')" \
  " Join Here (H)" j "$(fzf_popup 'pane-picker.sh --action=join-h --all')" \
  " Join Here (V)" J "$(fzf_popup 'pane-picker.sh --action=join-v --all')" \
  " Send to Window" m "$(fzf_popup 'pane-picker.sh --action=send-h --all')" \
  "" \
  "#[fg=#01F9C6,bold]━━━ Navigate ━━━" "" "" \
  " To Prev Window" p "move-pane -t :-1" \
  " To Next Window" n "move-pane -t :+1" \
  " Rotate CW" r "rotate-window" \
  " Rotate CCW" R "rotate-window -D"
