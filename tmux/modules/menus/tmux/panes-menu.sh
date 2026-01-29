#!/bin/bash
# Panes Menu
# Location: ~/.tmux/modules/menus/tmux/panes-menu.sh

source "$TMUX_MENUS/menu-settings.sh"

CURRENT_MENU="tmux/panes-menu.sh"
PARENT=$(get_parent "tmux-menu.sh")

tmux display-menu -x $MENU_POS_X -y $MENU_POS_Y \
  -T "$(menu_title '󰂮' 'Panes' $MENU_TITLE_PANE)" \
  -s "$MENU_STYLE" -H "$MENU_SELECT_STYLE" -S "$MENU_BORDER_STYLE" -b "$MENU_BORDER_LINES" \
  "$MENU_ICON_BACK Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "$(menu_sep 'Create')" "" "" \
  " Vertical Split" v "$(fzf_popup 'split-dir-picker.sh --direction=h')" \
  " Horizontal Split" d "$(fzf_popup 'split-dir-picker.sh --direction=v')" \
  "" \
  "$(menu_sep 'Quick (CWD)')" "" "" \
  " Quick Vertical" V "run-shell '$TMUX_CONF/events/split.sh v'" \
  " Quick Horizontal" D "run-shell '$TMUX_CONF/events/split.sh h'" \
  "" \
  "$(menu_sep 'Actions')" "" "" \
  " Kill Pane" x "run-shell 'source ~/.core/.cortex/lib/tmux.sh && tmux::pane::kill'" \
  " Break to Window" b "break-pane" \
  " Break (stay)" B "break-pane -d" \
  "󰓦 Toggle Sync" y "if -F '#{pane_synchronized}' 'set -w synchronize-panes off; display \"Sync off\"' 'set -w synchronize-panes on; display \"Sync on\"'" \
  "" \
  "$(menu_sep 'Move & Swap')" "" "" \
  "󰓡 Swap Pane" s "$(fzf_popup 'pane-picker.sh --action=swap --all')" \
  " Join Here (H)" j "$(fzf_popup 'pane-picker.sh --action=join-h --all')" \
  " Join Here (V)" J "$(fzf_popup 'pane-picker.sh --action=join-v --all')" \
  " Send to Window" m "$(fzf_popup 'pane-picker.sh --action=send-h --all')" \
  "" \
  "$(menu_sep 'Rotate')" "" "" \
  " Rotate CW" r "rotate-window" \
  " Rotate CCW" R "rotate-window -D"
