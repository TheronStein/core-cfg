#!/usr/bin/env bash
# ==============================================================================
# Tmux Window Utilities - WRAPPER
# ==============================================================================
# DEPRECATED: This file now sources the global library.
# All window functions are available via ~/.core/.cortex/lib/tmux.sh
#
# For new code, source the global library directly:
#   source ~/.core/.cortex/lib/tmux.sh
#
# This file provides backwards-compatible function names that map to the
# namespaced functions in the global library.
# ==============================================================================

# Source the global tmux library
source "${HOME}/.core/.cortex/lib/tmux.sh"

# ==============================================================================
# Legacy Function Aliases (for backwards compatibility)
# ==============================================================================

window_exists() { tmux::window::exists "$@"; }
get_window_name() { tmux::window::name "$@"; }
get_window_index() { tmux::window::index "$@"; }
get_window_id_by_index() { tmux::window::id_by_index "$@"; }
list_windows() { tmux::window::list "$@"; }
get_window_layout() { tmux::window::layout "$@"; }

# Core functions from tmux-utils.sh
get_window_id() { tmux::window::id; }

# Export functions for subshells
export -f window_exists get_window_name get_window_index get_window_id_by_index
export -f list_windows get_window_layout get_window_id
