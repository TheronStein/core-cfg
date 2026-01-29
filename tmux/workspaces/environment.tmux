# ============================================================================
# Environment Server Configuration
# ============================================================================
# This is a server-specific tmux configuration for the 'environment' server.
# For system environment and dotfile management.
#
# Usage:
#   tmux -f $TMUX_CONF/workspaces/environment.tmux -L environment new-session
#
# This will:
#   - Load all base tmux.conf settings
#   - Use a separate resurrect directory: ~/.tmux/resurrect/environment/
#   - Set TMUX_SESSION_CWD to $HOME/.core/.sys
# ============================================================================

# Source the base tmux configuration
source-file "$TMUX_CONF/tmux.conf"

# ============================================================================
# Server-Specific Settings
# ============================================================================

# Set custom environment variable for this server's default CWD
set-environment -g TMUX_SESSION_CWD "$HOME/.core/.sys"

# Server identification
set-environment -g TMUX_SERVER_NAME "environment"
set-environment -g TMUX_WORKSPACE_DISPLAY "Env"

# ============================================================================
# Resurrect Configuration (Server-Specific)
# ============================================================================

# Set custom resurrect directory for this server
set -g @resurrect-dir "~/.tmux/resurrect/environment"

# Capture additional state
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

# ============================================================================
# Environment Server Keybindings (Optional Overrides)
# ============================================================================

# Quick save/restore
# bind-key C-s run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh"
# bind-key C-r run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh"

# ============================================================================
# Status Bar Customization (Optional)
# ============================================================================

# Uncomment to show server name in status bar
# set -g status-left "#[fg=green,bold][ ENV ]#[default] "

# ============================================================================
# Auto-create session on server start (Optional)
# ============================================================================

# Uncomment to auto-create a default session when server starts
# new-session -d -s env-main -c "$HOME/.core/.sys"
