#!/usr/bin/env bash
# ==============================================================================
# Tmux Menu Utilities
# ==============================================================================
# Location: ~/.core/.sys/cfg/tmux/lib/menu-utils.sh
# Purpose: Shared functions for tmux display-menu scripts
#
# Usage:
#   source "$TMUX_CONF/lib/menu-utils.sh"
#
# Functions:
#   fzf_popup <picker-script> [args]  - Generate display-popup command for FZF picker
#   om <menu-path>                     - Generate run-shell command with nav tracking
# ==============================================================================

# Prevent double-sourcing
[[ -n "${_MENU_UTILS_SH_LOADED:-}" ]] && return 0
_MENU_UTILS_SH_LOADED=1

# ==============================================================================
# Configuration
# ==============================================================================

# These are expected to be set by the calling environment
: "${TMUX_CONF:=$HOME/.tmux}"
: "${TMUX_MENUS:=$TMUX_CONF/modules/menus}"

# FZF pickers directory
PICKERS="${TMUX_CONF}/modules/fzf/pickers"

# Default popup dimensions
POPUP_WIDTH="${POPUP_WIDTH:-80}"
POPUP_HEIGHT="${POPUP_HEIGHT:-70}"

# ==============================================================================
# FZF Popup Integration
# ==============================================================================

# Generate display-popup command for running an FZF picker
# Usage: fzf_popup 'session-picker.sh --action=switch'
# Returns: display-popup -E -w 80% -h 70% '/path/to/pickers/session-picker.sh --action=switch'
#
# Override defaults per-script by setting POPUP_WIDTH/POPUP_HEIGHT before sourcing
fzf_popup() {
    local script="$1"
    echo "display-popup -E -w ${POPUP_WIDTH}% -h ${POPUP_HEIGHT}% '${PICKERS}/${script}'"
}

# Generate centered popup with custom dimensions (one-off override)
# Usage: fzf_popup_sized 90 90 'session-picker.sh'
fzf_popup_sized() {
    local width="$1"
    local height="$2"
    local script="$3"
    echo "display-popup -E -w ${width}% -h ${height}% '${PICKERS}/${script}'"
}

# ==============================================================================
# Menu Navigation
# ==============================================================================

# Navigation script path
MENU_NAV="${TMUX_MENUS}/menu-nav.sh"

# Open submenu with navigation tracking
# Usage: om "tmux/panes-menu.sh"
# Returns: run-shell command string that tracks navigation
om() {
    local target_menu="$1"
    local current_menu="${2:-}"

    if [[ -n "$current_menu" ]]; then
        "$MENU_NAV" set "$(basename "$target_menu")" "$current_menu" 2>/dev/null
    fi
    echo "run-shell '${TMUX_MENUS}/${target_menu}'"
}

# Get parent menu for back navigation
# Usage: get_parent "current-menu.sh" "default-parent.sh"
get_parent() {
    local current="$1"
    local default="${2:-main-menu.sh}"
    "$MENU_NAV" get "$current" "$default" 2>/dev/null
}

# ==============================================================================
# Common Menu Helpers
# ==============================================================================

# Generate reload config command with confirmation
reload_config_cmd() {
    echo "source-file ${TMUX_CONF}/tmux.conf ; display 'Config reloaded'"
}

# Generate confirm-before wrapper
# Usage: confirm "Kill server?" "kill-server"
confirm() {
    local prompt="$1"
    local command="$2"
    echo "confirm-before -p '${prompt} (y/n)' '${command}'"
}

# ==============================================================================
# Export for subshells if needed
# ==============================================================================

if [[ -n "$BASH_VERSION" ]]; then
    export -f fzf_popup fzf_popup_sized om get_parent reload_config_cmd confirm 2>/dev/null
fi
