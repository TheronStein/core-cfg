# ============================================================================
# Objective Server Configuration
# ============================================================================
# This is a server-specific tmux configuration for the 'objective' server.
# For goal tracking and task management.
#
# Usage:
#   tmux -f $TMUX_CONF/workspaces/objective.tmux -L objective new-session
#
# This will:
#   - Load all base tmux.conf settings
#   - Use a separate resurrect directory: ~/.tmux/resurrect/objective/
#   - Set TMUX_SESSION_CWD to $HOME/.core/.life/planning
# ============================================================================

# Source the base tmux configuration
source-file "$TMUX_CONF/tmux.conf"

# ============================================================================
# Server-Specific Settings
# ============================================================================

# Set custom environment variable for this server's default CWD
set-environment -g TMUX_SESSION_CWD "$HOME/.core/.life/planning"

# Server identification
set-environment -g TMUX_SERVER_NAME "objective"
set-environment -g TMUX_WORKSPACE_DISPLAY "Goals"

# ============================================================================
# Resurrect Configuration (Server-Specific)
# ============================================================================

# Set custom resurrect directory for this server
set -g @resurrect-dir "~/.tmux/resurrect/objective"

# Capture additional state
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

# ============================================================================
# Objective Server Keybindings (Optional Overrides)
# ============================================================================

# Quick save/restore
# bind-key C-s run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh"
# bind-key C-r run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh"

# ============================================================================
# Status Bar Customization (Optional)
# ============================================================================

# Uncomment to show server name in status bar
# set -g status-left "#[fg=magenta,bold][ OBJ ]#[default] "

# ============================================================================
# Auto-create session on server start (Optional)
# ============================================================================

# Uncomment to auto-create a default session when server starts
# new-session -d -s obj-main -c "$HOME/.core/.life/planning"
