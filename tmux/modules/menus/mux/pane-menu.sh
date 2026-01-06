#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="mux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '$TMUX_MENUS/$1'"
}

tmux display-menu -x C -y C -T "#[fg=#89b4fa,bold]󰂮 Pane Management " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  " Kill Pane" x "kill-pane" \
  " Vertical Split" v "run-shell '$TMUX_CONF/events/split.sh v'" \
  " Horizontal Split" d "run-shell '$TMUX_CONF/events/split.sh h'" \
  "" \
  "󰓡 Swap with selected" q "display-panes { swapp -t '%%' }" \
  " Rotate Clockwise" r "rotate-window" \
  " Rotate Counter-Clockwise" R "rotate-window -D" \
  "" \
  " Break Pane (follow)" b "break-pane" \
  " Break Pane (stay)" B "break-pane -d" \
  " Move to Previous Window" p "move-pane -t :-1" \
  " Move to Next Window" n "move-pane -t :+1" \
  "" \
  "󰓦 Toggle Pane Sync" y "if -F '#{pane_synchronized}' 'set -w synchronize-panes off; display \"Sync off\"' 'set -w synchronize-panes on; display \"Sync on\"'" \
  " Swap Menu" s "$(om mux/pane-swap-menu.sh)" \
  " Join Menu" j "$(om mux/pane-join-menu.sh)"
