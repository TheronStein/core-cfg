#!/usr/bin/env bash
# Yazibar - Yazi Runner with DDS Event Streaming
# Runs yazi with --local-events for automatic sidebar synchronization
#
# ARCHITECTURE:
# - Left sidebar: Streams hover/cd events via --local-events
# - Events are processed by a background handler via named pipe (fifo)
# - Handler sends reveal commands to right sidebar in real-time
# - Right sidebar: Plain yazi that receives reveal commands via send-keys
#
# This design solves the limitation that Yazi plugins cannot auto-subscribe
# to native events - we use --local-events instead.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

SIDE="${1:-left}"  # left or right
START_DIR="${2:-$HOME}"

# Debug log function
_debug_log() {
    echo "[$(date '+%H:%M:%S')] $*" >> /tmp/yazibar-run-debug.log
}

_debug_log "=== yazibar-run-yazi.sh started ==="
_debug_log "SIDE=$SIDE START_DIR=$START_DIR"

# ============================================================================
# YAZI CONFIGURATION
# ============================================================================

# Set yazi config directory based on sidebar side
# Use absolute path since CORE_CFG may not be set in all contexts
CORE_CFG="${CORE_CFG:-$HOME/.core/.sys/cfg}"

# Force set YAZI_CONFIG_HOME (don't use default if already set - we want our profile)
if [ "$SIDE" = "left" ]; then
    export YAZI_CONFIG_HOME="${CORE_CFG}/yazi/profiles/sidebar-left"
else
    export YAZI_CONFIG_HOME="${CORE_CFG}/yazi/profiles/sidebar-right"
fi

_debug_log "YAZI_CONFIG_HOME=$YAZI_CONFIG_HOME"

# Export environment variables for yazibar-sync.yazi plugin
export YAZIBAR_SIDE="$SIDE"
export YAZIBAR_PANE_ID="$TMUX_PANE"
export YAZIBAR_WINDOW_ID="$(tmux display-message -p '#{window_id}')"

_debug_log "YAZIBAR_SIDE=$YAZIBAR_SIDE YAZIBAR_WINDOW_ID=$YAZIBAR_WINDOW_ID"

# Change to start directory
cd "$START_DIR" || exit 1

# ============================================================================
# CRITICAL: Bypass graphical/terminal detection to avoid DECRQSS timeout
# tmux cannot handle DECRQSS escape sequences, causing 10-20 second delays
# Setting these empty forces Chafa fallback and skips problematic queries
# ============================================================================
export WAYLAND_DISPLAY=''
export DISPLAY=''
export XDG_SESSION_TYPE=''
export SWAYSOCK=''

_debug_log "Set empty display vars to bypass DECRQSS detection"

# ============================================================================
# LEFT SIDEBAR: Run with DDS event streaming for sync
# ============================================================================
if [ "$SIDE" = "left" ]; then
    # Get the right pane ID from tmux options (window-scoped)
    WINDOW_ID=$(tmux display-message -p '#{window_id}')
    RIGHT_PANE=$(tmux show-option -gqv "@yazibar-right-pane-id-${WINDOW_ID}")

    if [ -n "$RIGHT_PANE" ] && pane_exists_globally "$RIGHT_PANE"; then
        debug_log "Left sidebar: Starting with DDS event sync to $RIGHT_PANE"

        # Create a named pipe for event processing
        # This allows yazi to remain interactive while streaming events
        FIFO="/tmp/yazibar_events_${TMUX_PANE//\%/}"
        rm -f "$FIFO"
        mkfifo "$FIFO"

        # Start the DDS handler in background, reading from the fifo
        "$SCRIPT_DIR/yazibar-dds-handler.sh" "$RIGHT_PANE" < "$FIFO" &
        DDS_HANDLER_PID=$!

        # Store handler PID for cleanup
        set_tmux_option "@yazibar-dds-handler-pid-${WINDOW_ID}" "$DDS_HANDLER_PID"

        debug_log "Started DDS handler PID: $DDS_HANDLER_PID"

        # Run yazi with --local-events streaming hover and cd to the fifo
        # The fifo allows yazi to run interactively while events stream to handler
        yazi "$START_DIR" \
            --local-events=hover,cd > "$FIFO" 2>/dev/null

        # Cleanup when yazi exits
        debug_log "Left sidebar exited, cleaning up DDS handler"
        kill "$DDS_HANDLER_PID" 2>/dev/null
        rm -f "$FIFO"
        clear_tmux_option "@yazibar-dds-handler-pid-${WINDOW_ID}"
    else
        debug_log "Left sidebar: No right pane found ($RIGHT_PANE), running without sync"
        # Run without event streaming if no right pane exists
        exec yazi "$START_DIR"
    fi
else
    # ============================================================================
    # RIGHT SIDEBAR: Plain yazi that receives reveal commands via send-keys
    # ============================================================================
    debug_log "Right sidebar: Starting in preview mode"
    exec yazi "$START_DIR"
fi
