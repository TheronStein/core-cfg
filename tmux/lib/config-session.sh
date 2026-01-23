#!/usr/bin/env bash
# ==============================================================================
# Config Session Handler - Ephemeral popup with neovim session persistence
# ==============================================================================
# Location: ~/.tmux/lib/config-session.sh
# Purpose: Open config directories in ephemeral popups with neovim auto-session
#
# Usage:
#   source "$TMUX_CONF/lib/config-session.sh"
#   edit_config "tmux" "/path/to/config"
# ==============================================================================

# Prevent double-sourcing
[[ -n "${_CONFIG_SESSION_SH_LOADED:-}" ]] && return 0
_CONFIG_SESSION_SH_LOADED=1

# ==============================================================================
# Configuration
# ==============================================================================

: "${POPUP_WIDTH:=95}"
: "${POPUP_HEIGHT:=95}"

# ==============================================================================
# Main Function
# ==============================================================================

# Edit configuration directory in ephemeral popup
# Neovim auto-session handles state persistence automatically
#
# Arguments:
#   $1 - Tool name (used for neovim session naming)
#   $2 - Config directory path
#
# Example:
#   edit_config "tmux" "$HOME/.config/tmux"
#
edit_config() {
    local tool="$1"
    local config_dir="$2"

    # Validate arguments
    if [[ -z "$tool" || -z "$config_dir" ]]; then
        tmux display-message "Error: edit_config requires tool name and config directory"
        return 1
    fi

    # Expand path if needed
    config_dir="${config_dir/#\~/$HOME}"

    # Verify directory exists
    if [[ ! -d "$config_dir" ]]; then
        tmux display-message "Error: Config directory not found: $config_dir"
        return 1
    fi

    # Launch ephemeral popup with neovim
    # -E flag makes popup close when command exits
    # Neovim auto-session will persist/restore state based on the session name
    tmux display-popup -E -w "${POPUP_WIDTH}%" -h "${POPUP_HEIGHT}%" -d "$config_dir" \
        "nvim -c \"let g:auto_session_name='configs-${tool}'\""
}

# ==============================================================================
# Export for subshells
# ==============================================================================

if [[ -n "$BASH_VERSION" ]]; then
    export -f edit_config 2>/dev/null
fi
