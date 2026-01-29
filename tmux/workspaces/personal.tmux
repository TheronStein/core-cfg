# ============================================================================
# Personal Server Configuration
# ============================================================================
# This is a server-specific tmux configuration for the 'personal' server.
# For personal projects and non-work activities.
#
# Usage:
#   tmux -f $TMUX_CONF/workspaces/personal.tmux -L personal new-session
#
# This will:
#   - Load all base tmux.conf settings
#   - Use a separate resurrect directory: ~/.tmux/resurrect/personal/
#   - Set TMUX_SESSION_CWD to $HOME/.core/.personal
# ============================================================================

# Source the base tmux configuration
source-file "$TMUX_CONF/tmux.conf"

# ============================================================================
# Server-Specific Settings
# ============================================================================

# Set custom environment variable for this server's default CWD
set-environment -g TMUX_SESSION_CWD "$HOME/.core/.personal"

# Server identification
set-environment -g TMUX_SERVER_NAME "personal"
set-environment -g TMUX_WORKSPACE_DISPLAY "Personal"

# ============================================================================
# Resurrect Configuration (Server-Specific)
# ============================================================================

# Set custom resurrect directory for this server
set -g @resurrect-dir "~/.tmux/resurrect/personal"

# Capture additional state
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

# Optional: Custom save/restore hooks
set -g @resurrect-hook-post-save-all 'echo "Personal server saved: $(date)" >> ~/.tmux/resurrect/personal/save.log'
set -g @resurrect-hook-post-restore-all 'echo "Personal server restored: $(date)" >> ~/.tmux/resurrect/personal/restore.log'

# ============================================================================
# Personal Server Keybindings (Optional Overrides)
# ============================================================================

# Quick save/restore
# bind-key C-s run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/save.sh"
# bind-key C-r run-shell "$TMUX_CONF/plugins/tmux-resurrect/scripts/restore.sh"

# ============================================================================
# Status Bar Customization (Optional)
# ============================================================================

# Uncomment to show server name in status bar
# set -g status-left "#[fg=yellow,bold][ PERS ]#[default] "

# ============================================================================
# Auto-create session on server start (Optional)
# ============================================================================

# Uncomment to auto-create a default session when server starts
# new-session -d -s pers-main -c "$HOME/.core/.personal"
