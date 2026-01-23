#!/usr/bin/env bash
# ==============================================================================
# AI Session Handler - Persistent Claude Code sessions per tool
# ==============================================================================
# Location: ~/.tmux/lib/ai-session.sh
# Purpose: Manage persistent Claude Code sessions in a dedicated "ai" tmux session
#
# Usage:
#   source "$TMUX_CONF/lib/ai-session.sh"
#   ai_session "tmux" "/path/to/config"
# ==============================================================================

# Prevent double-sourcing
[[ -n "${_AI_SESSION_SH_LOADED:-}" ]] && return 0
_AI_SESSION_SH_LOADED=1

# ==============================================================================
# Configuration
# ==============================================================================

: "${AI_SESSION_NAME:=ai}"
: "${POPUP_WIDTH:=95}"
: "${POPUP_HEIGHT:=95}"

# ==============================================================================
# Main Function
# ==============================================================================

# Open Claude Code for tool in persistent AI session
#
# Behavior:
#   - Creates "ai" session if it doesn't exist
#   - Creates window named after tool if it doesn't exist
#   - Attaches to existing window if it does exist
#   - Launches Claude Code if not already running
#   - Shows status bar for navigation between conversations
#   - Detach-only behavior (d key detaches, never closes window)
#
# Arguments:
#   $1 - Tool name (used for window naming)
#   $2 - Config directory path (working directory for Claude)
#
# Example:
#   ai_session "tmux" "$HOME/.config/tmux"
#
ai_session() {
    local tool="$1"
    local config_dir="$2"

    # Validate arguments
    if [[ -z "$tool" || -z "$config_dir" ]]; then
        tmux display-message "Error: ai_session requires tool name and config directory"
        return 1
    fi

    # Expand path if needed
    config_dir="${config_dir/#\~/$HOME}"

    # Verify directory exists
    if [[ ! -d "$config_dir" ]]; then
        tmux display-message "Error: Config directory not found: $config_dir"
        return 1
    fi

    # Ensure ai session exists
    if ! tmux has-session -t "$AI_SESSION_NAME" 2>/dev/null; then
        # Create new session with first window for this tool
        tmux new-session -d -s "$AI_SESSION_NAME" -n "$tool" -c "$config_dir"
        # Start claude in the new window
        tmux send-keys -t "${AI_SESSION_NAME}:${tool}" "claude" Enter
    fi

    # Create window for tool if it doesn't exist
    if ! tmux list-windows -t "$AI_SESSION_NAME" -F '#{window_name}' | grep -q "^${tool}$"; then
        tmux new-window -t "$AI_SESSION_NAME" -n "$tool" -c "$config_dir"
        # Start claude in the new window
        tmux send-keys -t "${AI_SESSION_NAME}:${tool}" "claude" Enter
    fi

    # Attach to window in popup
    # Note: -E is intentionally NOT used so detach works (d key detaches back to original session)
    # Status bar remains visible for navigation between AI conversations
    tmux display-popup -w "${POPUP_WIDTH}%" -h "${POPUP_HEIGHT}%" \
        "tmux attach-session -t '${AI_SESSION_NAME}:${tool}'"
}

# ==============================================================================
# Export for subshells
# ==============================================================================

if [[ -n "$BASH_VERSION" ]]; then
    export -f ai_session 2>/dev/null
fi
