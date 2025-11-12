#!/usr/bin/env bash
# Yazibar - Yazi Runner
# Runs yazi with CWD synchronization and proper configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

SIDE="${1:-left}"  # left or right
START_DIR="${2:-$HOME}"

# ============================================================================
# CWD SYNCHRONIZATION
# ============================================================================

# Function to update shell CWD via OSC 7 (called by yazi plugin)
update_cwd() {
    local new_dir="$1"

    # Send OSC 7 escape sequence to update terminal's CWD
    # Format: OSC 7 ; file://hostname/path ST
    printf '\033]7;file://%s%s\033\\' "$(hostname)" "$new_dir"

    # Also update tmux's pane_current_path
    # Note: This might not work directly, tmux tracks CWD separately
}

export -f update_cwd

# ============================================================================
# YAZI HOOKS
# ============================================================================

# Yazi DDS event handler
# This script is called by yazi when events occur (cd, hover, etc.)
handle_yazi_event() {
    local event_type="$1"
    local event_data="$2"

    case "$event_type" in
        cd)
            # Directory changed
            update_cwd "$event_data"
            debug_log "CWD changed to: $event_data"

            # If this is left sidebar, sync to right
            if [ "$SIDE" = "left" ]; then
                set_tmux_option "@yazibar-current-dir" "$event_data"
            fi
            ;;
        hover)
            # File/dir hovered
            if [ "$SIDE" = "left" ]; then
                set_tmux_option "@yazibar-hovered-file" "$event_data"
                debug_log "Hovered: $event_data"
            fi
            ;;
    esac
}

export -f handle_yazi_event

# ============================================================================
# YAZI EXECUTION
# ============================================================================

# Change to start directory
cd "$START_DIR" || exit 1

# Set yazi config directory
export YAZI_CONFIG_HOME="${YAZI_CONFIG_HOME:-$HOME/.core/cfg/yazi-sidebar}"

# Set yazibar side (used by yazi plugins)
export YAZIBAR_SIDE="$SIDE"

# Set pane ID for yazi to reference
export YAZIBAR_PANE_ID="$TMUX_PANE"

# Run yazi
# Note: Yazi plugins will call handle_yazi_event via DDS or hooks
exec yazi "$START_DIR"
