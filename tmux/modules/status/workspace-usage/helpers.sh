#!/usr/bin/env bash

# Source shared library for core tmux operations
if [ -f "$TMUX_CONF/modules/lib/tmux-core.sh" ]; then
    source "$TMUX_CONF/modules/lib/tmux-core.sh"
fi

# Note: get_tmux_option and set_tmux_option are now provided by modules/lib/tmux-core.sh
