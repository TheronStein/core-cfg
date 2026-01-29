# ============================================================================
# AI Server Configuration
# ============================================================================
# This is a server-specific tmux configuration for the 'ai' server.
# Provides complete isolation for Claude Code and AI-related sessions.
#
# Usage:
#   tmux -f $TMUX_CONF/workspaces/ai.tmux -L ai new-session -s claude
#   tmux -f $TMUX_CONF/workspaces/ai.tmux -L ai new-session -A -s claude  # attach if exists
#
# This will:
#   - Load all base tmux.conf settings
#   - Use a separate resurrect directory: ~/.tmux/resurrect/ai/
#   - Set TMUX_SESSION_CWD to $HOME/.core/.cortex
#   - Provide visual distinction via status bar
# ============================================================================

# Source the base tmux configuration
source-file "$TMUX_CONF/tmux.conf"

# ============================================================================
# Server-Specific Settings
# ============================================================================

# Set custom environment variable for this server's default CWD
# Using .cortex as the AI/knowledge hub
set-environment -g TMUX_SESSION_CWD "$HOME/.core/.cortex"

# Server identification
set-environment -g TMUX_SERVER_NAME "ai"
set-environment -g TMUX_WORKSPACE_DISPLAY "AI"

# ============================================================================
# Resurrect Configuration (Server-Specific)
# ============================================================================

# Set custom resurrect directory for this server
# This keeps AI server sessions completely separate from other servers
set -g @resurrect-dir "~/.tmux/resurrect/ai"

# Capture pane contents for better restoration
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

# ============================================================================
# AI Server Status Bar Customization
# ============================================================================

# Status bar workspace display is handled by TMUX_WORKSPACE_DISPLAY above
# The base config's status-workspace.sh reads this variable

# ============================================================================
# AI Server Keybindings (Optional Overrides)
# ============================================================================

# Quick save/restore for AI environment
# bind-key C-s run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh"
# bind-key C-r run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh"

# ============================================================================
# Auto-create session on server start (Optional)
# ============================================================================

# Uncomment to auto-create a default session when server starts
# new-session -d -s claude -c "$HOME/.core/.cortex"
