resurrect_server_name() {
  if [ -n "$TMUX" ]; then
    tmux show-environment -g TMUX_RESURRECT_SERVER_NAME 2>/dev/null | cut -d '=' -f2-
  else
    tmux -S /tmp/tmux_$SERVER_NAME show-environment -g TMUX_RESURRECT_SERVER_NAME 2>/dev/null | cut -d '=' -f2-
  fi
}
