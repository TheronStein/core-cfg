#!/usr/bin/env bash

readonly DEFAULT_FIND_PATH="$HOME/.core"
readonly DEFAULT_SHOW_NTH="-2,-1"
readonly DEFAULT_MAX_DEPTH="2"
readonly DEFAULT_PREVIEW_POSITION="top"
readonly DEFAULT_LAYOUT="reverse"
readonly DEFAULT_SESSION_NAME_STYLE="basename"
readonly DEFAULT_FZF_TMUX_OPTIONS="-p 90%"

readonly PROMPT='  '
readonly MARKER=''
readonly BORDER_LABEL='   [COREMUX]'
readonly HEADER='^f   ^j   ^s   ^w   ^x '

readonly SESSION_HEADER=''
readonly SESSION_HEADER='  ^x '
readonly SESSION_HEADER='  ^x '
readonly WINDOW_HEADER='  ^x '
readonly PANE_HEADER='󰀿  ^x '

# home path fix for sed
home_replacer=""
fzf_tmux_options=${FZF_TMUX_OPTS:-"$DEFAULT_FZF_TMUX_OPTIONS"}
[[ "$HOME" =~ ^[a-zA-Z0-9_/.@-]+$ ]] && home_replacer="s|^$HOME/|~/|"

# Cache tmux options for performance
TMUX_OPTIONS=$(tmux show-options -g | grep "^@coremux-")

get_tmux_option() {
  local option="$1"
  local default="$2"
  local value

  if [[ -n "$TMUX_OPTIONS" ]]; then
    value=$(echo "$TMUX_OPTIONS" | grep "^$option " | cut -d' ' -f2- | tr -d '"')
  fi

  echo "${value:-$default}"
}

find_path=$(get_tmux_option "@tea-find-path" "$DEFAULT_FIND_PATH")

if [[ ! -d "$find_path" ]]; then
  find_path="~"
fi
