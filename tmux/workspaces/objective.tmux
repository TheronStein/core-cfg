# ============================================================================
# Development Server Configuration
# ============================================================================
# This is a server-specific tmux configuration for the 'development' server.
#
# Usage:
#   tmux -f ~/.core/cfg/tmux/development.tmux -L development new-session
#
# This will:
#   - Load all base tmux.conf settings
#   - Use a separate resurrect directory: ~/.tmux/resurrect/development/
#   - Set TMUX_SESSION_CWD to $HOME/.core/dev
# ============================================================================

# Source the base tmux configuration
source-file "~/.core/cfg/tmux/tmux.conf"

# ============================================================================
# Server-Specific Settings
# ============================================================================

# Set custom environment variable for this server's default CWD
set-environment -g TMUX_SESSION_CWD "$HOME/.core/dev"

# Server identification (optional, useful for status bar)
set-environment -g TMUX_SERVER_NAME "development"

# ============================================================================
# Resurrect Configuration (Server-Specific)
# ============================================================================

# Set custom resurrect directory for this server
# This keeps development server sessions separate from other servers
set -g @resurrect-dir "~/.tmux/resurrect/development"

# Optional: Capture additional state
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'

# Optional: Custom save/restore hooks for development server
# set -g @resurrect-hook-post-save-all 'echo "Development server saved: $(date)" >> ~/.tmux/resurrect/development/save.log'
# set -g @resurrect-hook-post-restore-all 'echo "Development server restored: $(date)" >> ~/.tmux/resurrect/development/restore.log'

# ============================================================================
# Development Server Keybindings (Optional Overrides)
# ============================================================================

# Quick save/restore for development environment
# Uncomment if you want different keybindings for this server
# bind-key C-s run-shell "~/.core/cfg/tmux/plugins/tmux-resurrect/scripts/save.sh"
# bind-key C-r run-shell "~/.core/cfg/tmux/plugins/tmux-resurrect/scripts/restore.sh"

# ============================================================================
# Status Bar Customization (Optional)
# ============================================================================

# Uncomment to show server name in status bar
# set -g status-left "#[fg=blue,bold][ DEV ]#[default] "

# ============================================================================
# Auto-create session on server start
# ============================================================================

# This runs when the server starts - uncomment to auto-create a session
# new-session -d -s dev-main -c "$HOME/.core/dev"
