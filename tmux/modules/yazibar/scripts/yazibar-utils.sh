#!/usr/bin/env bash
# Yazibar - Shared Utilities
# Common functions used across yazibar scripts

# ============================================================================
# SOURCE DEPENDENCIES
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"

# Source canonical tmux libraries
source "$TMUX_CONF/lib/state-utils.sh"
source "$TMUX_CONF/lib/pane-utils.sh"

# Source local layout functions (pane ID management)
source "$SCRIPT_DIR/layout.sh"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Default values (can be overridden by tmux options)
YAZIBAR_SERVER="core-ide"
YAZIBAR_LEFT_SESSION="left-sidebar"
YAZIBAR_RIGHT_SESSION="right-sidebar"
YAZIBAR_LEFT_WIDTH="30%"
YAZIBAR_RIGHT_WIDTH="25%"
YAZIBAR_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/yazibar"
YAZIBAR_WIDTH_FILE="$YAZIBAR_DATA_DIR/widths.txt"
LAYOUT_MANAGER="$TMUX_CONF/scripts/layout-manager.sh"

# Ensure data directory exists
mkdir -p "$YAZIBAR_DATA_DIR"

# ============================================================================
# TMUX OPTION HELPERS
# ============================================================================

# ============================================================================
# CONFIGURATION GETTERS
# ============================================================================

yazibar_server() {
  get_tmux_option "@yazibar-server" "$YAZIBAR_SERVER"
}

yazibar_left_session() {
  get_tmux_option "@yazibar-left-session" "$YAZIBAR_LEFT_SESSION"
}

yazibar_right_session() {
  get_tmux_option "@yazibar-right-session" "$YAZIBAR_RIGHT_SESSION"
}

yazibar_left_width() {
  get_tmux_option "@yazibar-left-width" "$YAZIBAR_LEFT_WIDTH"
}

yazibar_right_width() {
  get_tmux_option "@yazibar-right-width" "$YAZIBAR_RIGHT_WIDTH"
}

yazibar_width_file() {
  get_tmux_option "@yazibar-width-file" "$YAZIBAR_WIDTH_FILE"
}

# ============================================================================
# STATE MANAGEMENT
# ============================================================================

# ============================================================================
# WINDOW-SCOPED STATE MANAGEMENT
# ============================================================================

# Get current window ID
get_current_window() {
  tmux display-message -p '#{window_id}'
}

# Get window-specific option key
get_window_option_key() {
  local base_key="$1"
  local window_id="${2:-$(get_current_window)}"
  echo "${base_key}-${window_id}"
}

# Left sidebar state (window-scoped)
is_left_enabled() {
  local key=$(get_window_option_key "@yazibar-left-enabled")
  [ "$(get_tmux_option "$key" "0")" = "1" ]
}

set_left_enabled() {
  local key=$(get_window_option_key "@yazibar-left-enabled")
  set_tmux_option "$key" "$1"
}

clear_left_pane() {
  local key=$(get_window_option_key "@yazibar-left-pane-id")
  clear_tmux_option "$key"
}

# Right sidebar state (window-scoped)
is_right_enabled() {
  local key=$(get_window_option_key "@yazibar-right-enabled")
  [ "$(get_tmux_option "$key" "0")" = "1" ]
}

set_right_enabled() {
  local key=$(get_window_option_key "@yazibar-right-enabled")
  set_tmux_option "$key" "$1"
}

# ============================================================================
# DISPLAY HELPERS
# ============================================================================

display_message() {
  local message="$1"
  local duration="${2:-3000}"

  local saved_duration=$(get_tmux_option "display-time" "750")
  tmux set-option -gq display-time "$duration"
  tmux display-message "$message"
  tmux set-option -gq display-time "$saved_duration"
}

# ============================================================================
# DEBUGGING
# ============================================================================

debug_enabled() {
  [ "$(get_tmux_option "@yazibar-debug" "0")" = "1" ]
}

debug_log() {
  if debug_enabled; then
    local log_file="$YAZIBAR_DATA_DIR/debug.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$log_file"
  fi
}

# ============================================================================
# VALIDATION
# ============================================================================

validate_tmux_version() {
  local required="$1"
  local current=$(tmux -V | grep -oE '[0-9]+\.[0-9]+')

  # Simple version comparison (works for major.minor)
  if awk -v curr="$current" -v req="$required" 'BEGIN {exit !(curr >= req)}'; then
    return 0
  else
    display_error "tmux $required or higher required (current: $current)"
    return 1
  fi
}

# Export yazibar-specific functions (library functions already exported by their sources)
export -f yazibar_server yazibar_left_session yazibar_right_session
export -f yazibar_left_width yazibar_right_width yazibar_width_file
export -f is_left_enabled set_left_enabled get_left_pane set_left_pane clear_left_pane
export -f is_right_enabled set_right_enabled get_right_pane set_right_pane clear_right_pane
export -f get_current_window get_window_option_key
export -f display_message debug_enabled debug_log
export -f validate_tmux_version
