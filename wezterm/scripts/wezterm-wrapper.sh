#!/usr/bin/env bash
# WezTerm Connect Wrapper - Handles workspace selection and connection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGER="$SCRIPT_DIR/workspace-manager.sh"
LOG_FILE="$HOME/.core/cfg/wezterm/.logs/wezterm-mux.log"
MUX_DOMAIN="${WEZTERM_LOCAL_MUX:-asusfx}"
WINDOW_CLASS="${WEZTERM_WINDOW_CLASS:-wezterm}"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Log function
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [wrapper] $*" >>"$LOG_FILE"
}

# Find or create available workspace
workspace_name=$("$MANAGER" find-available)

log "Attempting connection to workspace: $workspace_name (class: $WINDOW_CLASS, domain: $MUX_DOMAIN)"

# Check if workspace is occupied (shouldn't happen with find-available, but safety check)
if "$MANAGER" is-occupied "$workspace_name" &>/dev/null; then
  log "ERROR: Workspace $workspace_name is already occupied"
  notify-send -u critical "WezTerm Connection Failed" \
    "Workspace '$workspace_name' is already occupied by another client"
  exit 1
fi

# Mark workspace as occupied
"$MANAGER" occupy "$workspace_name"
log "Marked workspace $workspace_name as occupied"

# Connect to mux server with workspace
log "Executing: wezterm connect $MUX_DOMAIN --workspace $workspace_name --class $WINDOW_CLASS"
exec wezterm connect "$MUX_DOMAIN" --workspace "$workspace_name" --class "$WINDOW_CLASS"
