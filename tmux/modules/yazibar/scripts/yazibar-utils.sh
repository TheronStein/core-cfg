#!/usr/bin/env bash
# Yazibar - Shared Utilities
# Common functions used across yazibar scripts

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

get_tmux_option() {
    local option="$1"
    local default="$2"
    local value=$(tmux show-option -gqv "$option")
    echo "${value:-$default}"
}

set_tmux_option() {
    local option="$1"
    local value="$2"
    tmux set-option -gq "$option" "$value"
}

clear_tmux_option() {
    local option="$1"
    tmux set-option -guq "$option"
}

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

get_left_pane() {
    local key=$(get_window_option_key "@yazibar-left-pane-id")
    get_tmux_option "$key" ""
}

set_left_pane() {
    local key=$(get_window_option_key "@yazibar-left-pane-id")
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

get_right_pane() {
    local key=$(get_window_option_key "@yazibar-right-pane-id")
    get_tmux_option "$key" ""
}

set_right_pane() {
    local key=$(get_window_option_key "@yazibar-right-pane-id")
    set_tmux_option "$key" "$1"
}

clear_right_pane() {
    local key=$(get_window_option_key "@yazibar-right-pane-id")
    clear_tmux_option "$key"
}

# ============================================================================
# PANE HELPERS
# ============================================================================

pane_exists() {
    local pane_id="$1"
    local window_id="${2:-$(get_current_window)}"
    [ -n "$pane_id" ] && tmux list-panes -t "$window_id" -F "#{pane_id}" 2>/dev/null | grep -q "^${pane_id}$"
}

pane_exists_globally() {
    local pane_id="$1"
    [ -n "$pane_id" ] && tmux list-panes -a -F "#{pane_id}" 2>/dev/null | grep -q "^${pane_id}$"
}

get_current_pane() {
    tmux display-message -p '#{pane_id}'
}

get_current_dir() {
    tmux display-message -p '#{pane_current_path}'
}

get_pane_width() {
    local pane_id="${1:-$(get_current_pane)}"
    tmux display-message -p -t "$pane_id" '#{pane_width}'
}

get_pane_height() {
    local pane_id="${1:-$(get_current_pane)}"
    tmux display-message -p -t "$pane_id" '#{pane_height}'
}

# ============================================================================
# SESSION/SERVER HELPERS
# ============================================================================

server_running() {
    local server="$1"
    tmux -L "$server" list-sessions &>/dev/null
}

session_exists() {
    local server="$1"
    local session="$2"
    tmux -L "$server" has-session -t "$session" 2>/dev/null
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

display_error() {
    display_message "ERROR: $1" 5000
}

display_info() {
    display_message "$1" 2000
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
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$log_file"
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

# Export functions for sourcing
export -f get_tmux_option set_tmux_option clear_tmux_option
export -f yazibar_server yazibar_left_session yazibar_right_session
export -f yazibar_left_width yazibar_right_width yazibar_width_file
export -f is_left_enabled set_left_enabled get_left_pane set_left_pane clear_left_pane
export -f is_right_enabled set_right_enabled get_right_pane set_right_pane clear_right_pane
export -f pane_exists get_current_pane get_current_dir get_pane_width get_pane_height
export -f server_running session_exists
export -f display_message display_error display_info
export -f debug_enabled debug_log
export -f validate_tmux_version
