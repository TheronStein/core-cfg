#!/usr/bin/env bash

# Source canonical tmux library
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"
source "$TMUX_CONF/lib/state-utils.sh"

PATH="/usr/local/bin:$PATH:/usr/sbin"
