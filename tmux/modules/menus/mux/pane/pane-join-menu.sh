#!/bin/bash
# Pane join submenu - join panes horizontally or vertically

tmux display-menu -x W -y S -T "Join Panes" \
  "Send: Current → Selected (horiz)" '@' "choose-tree { joinp -fh -t '%%' }" \
  "Send: Current → Selected (vert)" '#' "choose-tree { joinp -fv -t '%%' }" \
  "" \
  "Join: Selected → Current (horiz)" h "choose-tree { joinp -fv -s '%%' }" \
  "Join: Selected → Current (vert)" v "choose-tree { joinp -fh -s '%%' }" \
  "" \
  "Back" Tab "run-shell '$TMUX_MENUS/pane-menu.sh'"
