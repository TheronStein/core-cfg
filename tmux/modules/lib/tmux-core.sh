#!/usr/bin/env bash
# modules/lib/tmux-core.sh
# DEPRECATED: Use ~/.core/.sys/cfg/tmux/lib/state-utils.sh instead
#
# This file now sources the canonical library to maintain backward compatibility.

# Source canonical library
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"
source "$TMUX_CONF/lib/state-utils.sh"

# Legacy function wrapper for get_current_window (use get_window_id instead)
get_current_window() {
    get_window_id
}

# Export functions for subshells (for backward compatibility)
export -f get_tmux_option set_tmux_option clear_tmux_option
export -f get_window_option set_window_option clear_window_option
export -f get_current_window
