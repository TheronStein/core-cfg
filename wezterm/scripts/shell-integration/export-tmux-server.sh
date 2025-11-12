#!/usr/bin/env bash
# ============================================================================
# WezTerm Shell Integration - Export Tmux Server Name
# ============================================================================
# This script exports the current tmux server name to WezTerm via OSC 1337
# sequences so it can be displayed in the tabline.
#
# Usage:
#   Source this in your shell rc file (.bashrc, .zshrc, etc.):
#   source ~/.core/cfg/wezterm/scripts/shell-integration/export-tmux-server.sh
#
# Or add to your PROMPT_COMMAND (bash) or precmd (zsh)
# ============================================================================

# Function to export tmux server name to WezTerm
__wezterm_export_tmux_server() {
    # Only run if we're in WezTerm
    if [[ "$TERM_PROGRAM" != "WezTerm" ]]; then
        return
    fi

    # Check if we're in a tmux session
    if [[ -n "$TMUX" ]]; then
        # Extract socket path from TMUX variable
        # Format: /tmp/tmux-{uid}/server_name,session_id,window_id
        local socket_path="${TMUX%%,*}"
        local server_name="${socket_path##*/}"

        # Export via OSC 1337 sequence
        # Format: OSC 1337 ; SetUserVar=key=base64_value ST
        local encoded_value=$(printf "%s" "$server_name" | base64)
        printf "\033]1337;SetUserVar=tmux_server=%s\007" "$encoded_value"
    else
        # Clear the variable if not in tmux
        printf "\033]1337;SetUserVar=tmux_server=%s\007" ""
    fi
}

# Auto-setup for different shells
if [[ -n "$BASH_VERSION" ]]; then
    # Bash setup
    if [[ "$PROMPT_COMMAND" != *"__wezterm_export_tmux_server"* ]]; then
        PROMPT_COMMAND="__wezterm_export_tmux_server${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    fi
elif [[ -n "$ZSH_VERSION" ]]; then
    # Zsh setup
    if [[ ! " ${precmd_functions[*]} " =~ " __wezterm_export_tmux_server " ]]; then
        precmd_functions+=(__wezterm_export_tmux_server)
    fi
fi

# Also export immediately on source
__wezterm_export_tmux_server
