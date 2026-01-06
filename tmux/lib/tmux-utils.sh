#!/usr/bin/env bash
# ==============================================================================
# Tmux Core Utilities - WRAPPER
# ==============================================================================
# DEPRECATED: This file now sources the global library.
# All tmux functions are available via ~/.core/.cortex/lib/tmux.sh
#
# For new code, source the global library directly:
#   source ~/.core/.cortex/lib/tmux.sh
#
# This file provides backwards-compatible function names that map to the
# namespaced functions in the global library.
# ==============================================================================

# Prevent double-sourcing
[[ -n "${_TMUX_UTILS_SH_LOADED:-}" ]] && return 0
_TMUX_UTILS_SH_LOADED=1

# Source the global tmux library
source "${HOME}/.core/.cortex/lib/tmux.sh"

# ==============================================================================
# Legacy Function Aliases (for backwards compatibility)
# ==============================================================================

# Environment detection
is_tmux() { tmux::in_tmux; }
is_wezterm() { tmux::in_wezterm; }
is_ssh() { tmux::in_ssh; }
command_exists() { command -v "$1" &>/dev/null; }

# ID retrieval
get_session_id() { tmux::session::id; }
get_session_name() { tmux::session::name; }
get_window_id() { tmux::window::id; }
get_window_index() { tmux::window::index; }
get_window_name() { tmux::window::name "$@"; }
get_pane_id() { tmux::pane::id; }
get_pane_index() { tmux::pane::index; }
get_pane_cwd() { tmux::pane::cwd; }
get_pane_command() { tmux::pane::command; }

# Window/pane info
get_pane_count() { tmux::window::pane_count; }
get_window_count() { tmux::session::window_count; }
is_pane_zoomed() { tmux::pane::is_zoomed; }

# Utility functions
tmux_safe() { tmux::safe "$@"; }
tmux_format() { tmux::format "$@"; }
tmux_log() { tmux::log "$@"; }

# Export legacy functions
export -f is_tmux is_wezterm is_ssh command_exists
export -f get_session_id get_session_name
export -f get_window_id get_window_index get_window_name
export -f get_pane_id get_pane_index get_pane_cwd get_pane_command
export -f get_pane_count get_window_count is_pane_zoomed
export -f tmux_safe tmux_format tmux_log
