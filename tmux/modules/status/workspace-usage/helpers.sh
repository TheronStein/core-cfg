#!/usr/bin/env bash

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  tmux show-option -gqv "$option" || echo "$default_value"
}

set_tmux_option() {
  tmux set-option -g "$1" "$2"
}
