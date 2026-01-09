tmux display-menu -x C -y P -T "#[fg=#7aa2f7,bold][TMUX] 󰙀  [Prefix Mode] 󰌌 " \
  "#[fg=#bb9af7,bold]━━━ [Quick Actions] ━━━" "" "" \
  " Zoom Toggle" z "resize-pane -Z" \
  " Resize Mode" r "run-shell '$TMUX_MENUS/modes/resize.sh'" \
  " Copy Mode" / "copy-mode" \
  "󰑓 Reload Config" R "source-file $TMUX_CONF/tmux.conf ; display 'Config reloaded'"
