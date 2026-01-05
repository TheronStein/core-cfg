#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="mux/$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "mux/pane-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#89b4fa,bold] Join Panes " \
  "󰌑 Back" Tab "run-shell '$TMUX_MENUS/$PARENT'" \
  "" \
  "#[fg=#cba6f7]Send current pane to:" "" "" \
  " Selected (horizontal)" h "choose-tree { joinp -fh -t '%%' }" \
  " Selected (vertical)" v "choose-tree { joinp -fv -t '%%' }" \
  "" \
  "#[fg=#cba6f7]Bring selected pane here:" "" "" \
  " Horizontal" H "choose-tree { joinp -fh -s '%%' }" \
  " Vertical" V "choose-tree { joinp -fv -s '%%' }"
