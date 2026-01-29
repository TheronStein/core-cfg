# ============================================================================
# Development Server Configuration
# ============================================================================
# This is a server-specific tmux configuration for the 'development' server.
#
# Usage:
#   tmux -f $TMUX_CONF/workspaces/development.tmux -L development new-session
#
# This will:
#   - Load all base tmux.conf settings
#   - Use a separate resurrect directory: ~/.tmux/resurrect/development/
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
set-environment -g TMUX_SERVER_NAME "development"
set-environment -g TMUX_WORKSPACE_DISPLAY "Dev"

# ============================================================================
# Resurrect Configuration (Server-Specific)
# ============================================================================

# Set custom resurrect directory for this server
set -g @resurrect-dir "~/.tmux/resurrect/development"

# Capture additional state
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

# Optional: Custom save/restore hooks
set -g @resurrect-hook-post-save-all 'echo "Development server saved: $(date)" >> ~/.tmux/resurrect/development/save.log'
set -g @resurrect-hook-post-restore-all 'echo "Development server restored: $(date)" >> ~/.tmux/resurrect/development/restore.log'

# ============================================================================
# Development Server Keybindings (Optional Overrides)
# ============================================================================

# Quick save/restore for development environment
# bind-key C-s run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh"
# bind-key C-r run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh"

# ============================================================================
# Status Bar Customization (Optional)
# ============================================================================

# Uncomment to show server name in status bar
# set -g status-left "#[fg=blue,bold][ DEV ]#[default] "

# ============================================================================
# Auto-create session on server start (Optional)
# ============================================================================

# Uncomment to auto-create a default session when server starts
# new-session -d -s dev-main -c "$HOME/.core/dev"
