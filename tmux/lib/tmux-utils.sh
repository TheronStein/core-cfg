#!/usr/bin/env bash
# ==============================================================================
# Tmux Core Utilities
# ==============================================================================
# Core tmux utility functions for environment detection and ID retrieval.
#
# Usage:
#   source "$TMUX_CONF/lib/tmux-utils.sh"
#   if is_tmux; then
#     echo "Session: $(get_session_id)"
#   fi
#
# ==============================================================================

# Prevent double-sourcing
[[ -n "${_TMUX_UTILS_SH_LOADED:-}" ]] && return 0
_TMUX_UTILS_SH_LOADED=1

# Ensure TMUX_CONF is set
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"

# Source shared library if available
if [[ -f "$HOME/.core/.cortex/lib/detect.sh" ]]; then
    source "$HOME/.core/.cortex/lib/detect.sh"
fi

# ==============================================================================
# Environment Detection
# ==============================================================================

# Check if running inside tmux
is_tmux() {
    [[ -n "${TMUX:-}" ]]
}

# Check if running inside WezTerm
is_wezterm() {
    [[ -n "${WEZTERM_PANE:-}" ]] || [[ -n "${WEZTERM_UNIX_SOCKET:-}" ]]
}

# Check if running over SSH
is_ssh() {
    [[ -n "${SSH_TTY:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# ==============================================================================
# ID Retrieval Functions
# ==============================================================================

# Get current session ID
get_session_id() {
    tmux display-message -p '#{session_id}' 2>/dev/null
}

# Get current session name
get_session_name() {
    tmux display-message -p '#{session_name}' 2>/dev/null
}

# Get current window ID
get_window_id() {
    tmux display-message -p '#{window_id}' 2>/dev/null
}

# Get current window index
get_window_index() {
    tmux display-message -p '#{window_index}' 2>/dev/null
}

# Get current window name
get_window_name() {
    tmux display-message -p '#{window_name}' 2>/dev/null
}

# Get current pane ID
get_pane_id() {
    tmux display-message -p '#{pane_id}' 2>/dev/null
}

# Get pane index
get_pane_index() {
    tmux display-message -p '#{pane_index}' 2>/dev/null
}

# Get pane current working directory
get_pane_cwd() {
    tmux display-message -p '#{pane_current_path}' 2>/dev/null
}

# Get pane current command
get_pane_command() {
    tmux display-message -p '#{pane_current_command}' 2>/dev/null
}

# ==============================================================================
# Window/Pane Info
# ==============================================================================

# Get number of panes in current window
get_pane_count() {
    tmux display-message -p '#{window_panes}' 2>/dev/null
}

# Get number of windows in current session
get_window_count() {
    tmux display-message -p '#{session_windows}' 2>/dev/null
}

# Check if pane is zoomed
is_pane_zoomed() {
    local zoomed
    zoomed=$(tmux display-message -p '#{window_zoomed_flag}' 2>/dev/null)
    [[ "$zoomed" == "1" ]]
}

# ==============================================================================
# Utility Functions
# ==============================================================================

# Safely run tmux command (handles not in tmux)
tmux_safe() {
    is_tmux && tmux "$@"
}

# Get tmux format value
tmux_format() {
    local format="$1"
    tmux display-message -p "$format" 2>/dev/null
}

# Log message (for debugging)
tmux_log() {
    local msg="$1"
    local logfile="${TMUX_CONF}/.logs/tmux-scripts.log"
    mkdir -p "$(dirname "$logfile")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$logfile"
}
