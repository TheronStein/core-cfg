# ============================================================================
# Testing Server Configuration
# ============================================================================
# This is a server-specific tmux configuration for the 'testing' server.
# For testing and experimentation.
#
# Usage:
#   tmux -f $TMUX_CONF/workspaces/testing.tmux -L testing new-session
#
# This will:
#   - Load all base tmux.conf settings
#   - Use a separate resurrect directory: ~/.tmux/resurrect/testing/
#   - Set TMUX_SESSION_CWD to $HOME/.core/dev
# ============================================================================

# Source the base tmux configuration
source-file "$TMUX_CONF/tmux.conf"

# ============================================================================
# Server-Specific Settings
# ============================================================================

# Set custom environment variable for this server's default CWD
set-environment -g TMUX_SESSION_CWD "$HOME/.core/dev"

# Server identification
set-environment -g TMUX_SERVER_NAME "testing"
set-environment -g TMUX_WORKSPACE_DISPLAY "Testing"

# ============================================================================
# Resurrect Configuration (Server-Specific)
# ============================================================================

# Set custom resurrect directory for this server
set -g @resurrect-dir "~/.tmux/resurrect/testing"

# Capture additional state
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

# ============================================================================
# Testing Server Keybindings (Optional Overrides)
# ============================================================================

# Quick save/restore
# bind-key C-s run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh"
# bind-key C-r run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh"

# ============================================================================
# Status Bar Customization
# ============================================================================

# Status bar workspace display is handled by TMUX_WORKSPACE_DISPLAY above
# The base config's status-workspace.sh reads this variable

# ============================================================================
# Auto-create session on server start (Optional)
# ============================================================================

# Uncomment to auto-create a default session when server starts
# new-session -d -s test-main -c "$HOME/.core/dev"
