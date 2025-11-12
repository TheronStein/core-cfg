#!/usr/bin/env bash
# Yazibar - Main Plugin Loader
# Tmux plugin for dual yazi sidebars with synchronization

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$CURRENT_DIR/scripts"
CONF_DIR="$CURRENT_DIR/conf"

# ============================================================================
# PLUGIN INITIALIZATION
# ============================================================================

# Source utility functions
source "$SCRIPTS_DIR/yazibar-utils.sh"

# Check tmux version
if ! validate_tmux_version "3.0"; then
    exit 1
fi

# Ensure sessions exist on startup (lazy initialization)
# We don't create them here to avoid slowing down tmux startup
# They'll be created when first used

# ============================================================================
# LOAD CONFIGURATIONS
# ============================================================================

# Load keybindings
if [ -f "$CONF_DIR/keybindings.conf" ]; then
    tmux source-file "$CONF_DIR/keybindings.conf"
    debug_log "Loaded keybindings"
fi

# Load hooks
if [ -f "$CONF_DIR/hooks.conf" ]; then
    tmux source-file "$CONF_DIR/hooks.conf"
    debug_log "Loaded hooks"
fi

# ============================================================================
# PLUGIN OPTIONS
# ============================================================================

# Set default options if not already set
tmux set-option -gq @yazibar-server "core-ide" 2>/dev/null || true
tmux set-option -gq @yazibar-left-session "left-sidebar" 2>/dev/null || true
tmux set-option -gq @yazibar-right-session "right-sidebar" 2>/dev/null || true
tmux set-option -gq @yazibar-left-width "30%" 2>/dev/null || true
tmux set-option -gq @yazibar-right-width "25%" 2>/dev/null || true
tmux set-option -gq @yazibar-right-needs-left "1" 2>/dev/null || true
tmux set-option -gq @yazibar-debug "0" 2>/dev/null || true

# Initialize state
tmux set-option -gq @yazibar-left-enabled "0"
tmux set-option -gq @yazibar-right-enabled "0"
tmux set-option -gq @yazibar-sync-active "0"

debug_log "Yazibar plugin loaded"
