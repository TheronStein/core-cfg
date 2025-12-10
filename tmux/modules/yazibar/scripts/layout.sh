get_left_pane() {
  local key=$(get_window_option_key "@yazibar-left-pane-id")
  get_tmux_option "$key" ""
}

set_left_pane() {
  local key=$(get_window_option_key "@yazibar-left-pane-id")
  set_tmux_option "$key" "$1"
}

get_right_pane() {
  local key=$(get_window_option_key "@yazibar-right-pane-id")
  get_tmux_option "$key" ""
}

set_right_pane() {
  local key=$(get_window_option_key "@yazibar-right-pane-id")
  set_tmux_option "$key" "$1"
}

clear_right_pane() {
  local key=$(get_window_option_key "@yazibar-right-pane-id")
  clear_tmux_option "$key"
}
