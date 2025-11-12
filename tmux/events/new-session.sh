#!/bin/bash
BINDIR=$COREBIN/tmux
SESSION_NAME="${1:-main}"

determine_server_name() {
  if [ -n "$TMUX" ]; then
    tmux show-environment -g TMUX_SERVER_NAME 2>/dev/null | cut -d '=' -f2-
  else
    tmux -S /tmp/tmux_$SERVER_NAME show-environment -g TMUX_SERVER_NAME 2>/dev/null | cut -d '=' -f2-
  fi
}

SERVER_NAME=$(determine_server_name)

TMUX_SESSION_CWD="$(tmux -S /tmp/tmux_$SERVER_NAME show-environment -g TMUX_SESSION_CWD 2>/dev/null | cut -d '=' -f2-)"

# if [ -z "$TMUX_SESSION_CWD" ]; then
#   TMUX_SESSION_CWD=$(tmux show-environment -g TMUX_SESSION_CWD 2>/dev/null | cut -d '=' -f2-)
# fi

if [ -z "$TMUX_SESSION_CWD" ]; then
  TMUX_SESSION_CWD="$HOME"
fi

new-session -d -s $SESSION_NAME -c $TMUX_SESSION_CWD
