#!/usr/bin/env bash
# ==============================================================================
# Tmux Pane Utilities - WRAPPER
# ==============================================================================
# DEPRECATED: This file now sources the global library.
# All pane functions are available via ~/.core/.cortex/lib/tmux.sh
#
# For new code, source the global library directly:
#   source ~/.core/.cortex/lib/tmux.sh
#
# This file provides backwards-compatible function names that map to the
# namespaced functions in the global library.
# ==============================================================================

# Prevent double-sourcing
[[ -n "${_PANE_UTILS_SH_LOADED:-}" ]] && return 0
_PANE_UTILS_SH_LOADED=1

# Source the global tmux library
source "${HOME}/.core/.cortex/lib/tmux.sh"

# ==============================================================================
# Legacy Function Aliases (for backwards compatibility)
# ==============================================================================

# Pane existence checks
pane_exists() { tmux::pane::exists "$@"; }
pane_exists_in_window() { tmux::pane::exists_in_window "$@"; }

# Pane creation
create_pane_right() { tmux::pane::create_right "$@"; }
create_pane_below() { tmux::pane::create_below "$@"; }
create_pane_in_dir() { tmux::pane::create_in_dir "$@"; }

# Pane termination
kill_pane_safe() { tmux::pane::kill "$@"; }
kill_other_panes() { tmux::pane::kill_others "$@"; }

# Pane navigation
select_pane() { tmux::pane::select "$@"; }
select_pane_direction() { tmux::pane::select_direction "$@"; }
get_pane_in_direction() { tmux::pane::id_in_direction "$@"; }

# Pane information
list_panes() { tmux::pane::list; }
list_all_panes() { tmux::pane::list_all; }
get_pane_by_command() { tmux::pane::find_by_command "$@"; }

# Pane actions
send_keys() { tmux::pane::send_keys "$@"; }
toggle_zoom() { tmux::pane::toggle_zoom; }
swap_panes() { tmux::pane::swap "$@"; }

# Layout manager integration
get_locked_pane_ids() { tmux::layout::get_locked_panes; }
is_pane_locked() { tmux::layout::is_pane_locked "$@"; }
get_all_panes_detailed() { tmux::pane::list_detailed; }

# Core functions from tmux-utils.sh
get_pane_id() { tmux::pane::id; }
get_pane_index() { tmux::pane::index; }
get_pane_cwd() { tmux::pane::cwd; }
get_pane_command() { tmux::pane::command; }

# Export legacy functions for subshells
export -f pane_exists pane_exists_in_window
export -f create_pane_right create_pane_below create_pane_in_dir
export -f kill_pane_safe kill_other_panes
export -f select_pane select_pane_direction get_pane_in_direction
export -f list_panes list_all_panes get_pane_by_command
export -f send_keys toggle_zoom swap_panes
export -f get_locked_pane_ids is_pane_locked get_all_panes_detailed
export -f get_pane_id get_pane_index get_pane_cwd get_pane_command
