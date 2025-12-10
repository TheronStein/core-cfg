#!/bin/bash

ARG1="${1:-cmd}"

list_servers() {
  tmux ls | awk -F: '{print $1}'
}

list_sessions_in_server() {
  local server_name="$1"
  tmux -S /tmp/tmux_$server_name ls | awk -F: '{print $1}'
}

get_server_info() {
  local server_name="$1"
  local sessions
  sessions=$(list_sessions_in_server "$server_name")
  echo "Server: $server_name"
  echo "Sessions:"
  for session in $sessions; do
    echo "  - $session"
  done
}

determine_server_name() {
  if [ -n "$TMUX" ]; then
    tmux show-environment -g TMUX_SERVER_NAME 2>/dev/null | cut -d '=' -f2-
  else
    tmux -S /tmp/tmux_$SERVER_NAME show-environment -g TMUX_SERVER_NAME 2>/dev/null | cut -d '=' -f2-
  fi
  SERVER_NAME=$(determine_server_name)
  return $SERVER_NAME
}

server_running() {
  local server="$1"
  tmux -L "$server" list-sessions &>/dev/null
}

main() {
  case "$ARG1" in
    get-server-name)
      SERVER_NAME=$(determine_server_name)
      if [ -n "$SERVER_NAME" ]; then
        echo "$SERVER_NAME"
      else
        echo "No TMUX_SERVER_NAME found."
        exit 1
      fi
      ;;
    list-servers)
      list_servers
      ;;
    server-info)
      SERVER_NAME=$(determine_server_name)
      if [ -n "$SERVER_NAME" ]; then
        get_server_info "$SERVER_NAME"
      else
        echo "No TMUX_SERVER_NAME found."
        exit 1
      fi
      ;;
    *)
      echo "Usage: $0 {list-servers|server-info}"
      exit 1
      ;;
  esac
}
