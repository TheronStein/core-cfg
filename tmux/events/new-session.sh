#!/bin/bash
UTILS=$TMUX_CONF/utils
source $UTILSserver.sh
SESSION_NAME="new_session_$(date +%s)"

SERVER_NAME=$(determine_server_name)
TMUX_SESSION_CWD="$(tmux -S /tmp/tmux_$SERVER_NAME show-environment -g TMUX_SESSION_CWD 2>/dev/null | cut -d '=' -f2-)"

if [ -z "$TMUX_SESSION_CWD" ]; then
  TMUX_SESSION_CWD=$(tmux show-environment -g TMUX_SESSION_CWD 2>/dev/null | cut -d '=' -f2-)
fi

new-session -d -s $SESSION_NAME -c $TMUX_SESSION_CWD
