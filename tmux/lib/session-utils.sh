#!/usr/bin/env bash
# ==============================================================================
# Tmux Session Utilities - WRAPPER
# ==============================================================================
# DEPRECATED: This file now sources the global library.
# All session functions are available via ~/.core/.cortex/lib/session.sh
#
# For new code, source the global library directly:
#   source ~/.core/.cortex/lib/session.sh
#
# This file provides backwards-compatible function names that map to the
# namespaced functions in the global library.
# ==============================================================================

# Source the global session library
source "${HOME}/.core/.cortex/lib/session.sh"

# ==============================================================================
# Legacy Function Aliases (for backwards compatibility)
# ==============================================================================

# These map old function names to new namespaced functions
session_exists() { session::exists "$@"; }
get_current_session() { session::current; }
get_current_session_id() { session::current_id; }
list_sessions() { session::list_raw; }
get_session_path() { session::path "$@"; }
create_detached_session() { session::create "$@"; }
kill_session() { session::kill "$@"; }

# Export legacy functions for subshells
export -f session_exists get_current_session get_current_session_id
export -f list_sessions get_session_path
export -f create_detached_session kill_session
