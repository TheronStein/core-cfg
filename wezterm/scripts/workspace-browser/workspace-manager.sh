#!/usr/bin/env bash
# Workspace Manager - Handles workspace state tracking

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
WORKSPACES_FILE="$DATA_DIR/workspaces.json"
LOG_FILE="$HOME/.core/cfg/wezterm/.logs/wezterm-mux.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Log function
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$LOG_FILE"
}

# Initialize workspaces.json if it doesn't exist
init_workspaces() {
  if [[ ! -f "$WORKSPACES_FILE" ]]; then
    mkdir -p "$DATA_DIR"
    cat >"$WORKSPACES_FILE" <<'EOF'
{
  "workspaces": []
}
EOF
    log "Initialized workspaces.json"
  fi
}

# Get workspace info by name
get_workspace() {
  local name="$1"
  jq -r --arg name "$name" '.workspaces[] | select(.name == $name)' "$WORKSPACES_FILE"
}

# Check if workspace exists
workspace_exists() {
  local name="$1"
  local exists=$(jq -r --arg name "$name" '.workspaces[] | select(.name == $name) | .name' "$WORKSPACES_FILE")
  [[ -n "$exists" ]]
}

# Check if workspace is occupied
is_occupied() {
  local name="$1"
  if ! workspace_exists "$name"; then
    return 1
  fi
  local occupied=$(jq -r --arg name "$name" '.workspaces[] | select(.name == $name) | .occupied' "$WORKSPACES_FILE")
  [[ "$occupied" == "true" ]]
}

# Mark workspace as occupied
occupy_workspace() {
  local name="$1"
  init_workspaces

  if ! workspace_exists "$name"; then
    # Create new workspace entry
    jq --arg name "$name" --arg timestamp "$(date -Iseconds)" \
      '.workspaces += [{
                "name": $name,
                "occupied": true,
                "created": $timestamp,
                "last_used": $timestamp
            }]' "$WORKSPACES_FILE" >"${WORKSPACES_FILE}.tmp"
    mv "${WORKSPACES_FILE}.tmp" "$WORKSPACES_FILE"
    log "Created and occupied workspace: $name"
  else
    # Update existing workspace
    jq --arg name "$name" --arg timestamp "$(date -Iseconds)" \
      '(.workspaces[] | select(.name == $name) | .occupied) = true |
             (.workspaces[] | select(.name == $name) | .last_used) = $timestamp' \
      "$WORKSPACES_FILE" >"${WORKSPACES_FILE}.tmp"
    mv "${WORKSPACES_FILE}.tmp" "$WORKSPACES_FILE"
    log "Occupied workspace: $name"
  fi
}

# Mark workspace as free
release_workspace() {
  local name="$1"
  init_workspaces

  if workspace_exists "$name"; then
    jq --arg name "$name" --arg timestamp "$(date -Iseconds)" \
      '(.workspaces[] | select(.name == $name) | .occupied) = false |
             (.workspaces[] | select(.name == $name) | .last_used) = $timestamp' \
      "$WORKSPACES_FILE" >"${WORKSPACES_FILE}.tmp"
    mv "${WORKSPACES_FILE}.tmp" "$WORKSPACES_FILE"
    log "Released workspace: $name"
  fi
}

# Find first available workspace or return next numbered workspace name
find_available_workspace() {
  init_workspaces

  # Get all workspace names
  local workspaces=$(jq -r '.workspaces[] | select(.occupied == false) | .name' "$WORKSPACES_FILE")

  # Find first available workspace matching pattern workspace{N}
  for ws in $workspaces; do
    if [[ "$ws" =~ ^workspace[0-9]+$ ]]; then
      echo "$ws"
      return 0
    fi
  done

  # No available workspace found, find next number
  local max_num=0
  while IFS= read -r ws; do
    if [[ "$ws" =~ ^workspace([0-9]+)$ ]]; then
      local num="${BASH_REMATCH[1]}"
      if ((num > max_num)); then
        max_num=$num
      fi
    fi
  done < <(jq -r '.workspaces[].name' "$WORKSPACES_FILE")

  # Return next available number
  echo "workspace$((max_num + 1))"
}

# List all workspaces with their status
list_workspaces() {
  init_workspaces
  jq -r '.workspaces[] | "\(.name)|\(.occupied)|\(.last_used // .created)"' "$WORKSPACES_FILE"
}

# Main command dispatcher
case "${1:-}" in
  occupy)
    [[ -z "${2:-}" ]] && {
      echo "Usage: $0 occupy <workspace_name>" >&2
      exit 1
    }
    occupy_workspace "$2"
    ;;
  release)
    [[ -z "${2:-}" ]] && {
      echo "Usage: $0 release <workspace_name>" >&2
      exit 1
    }
    release_workspace "$2"
    ;;
  find-available)
    find_available_workspace
    ;;
  is-occupied)
    [[ -z "${2:-}" ]] && {
      echo "Usage: $0 is-occupied <workspace_name>" >&2
      exit 1
    }
    if is_occupied "$2"; then
      echo "true"
      exit 0
    else
      echo "false"
      exit 1
    fi
    ;;
  list)
    list_workspaces
    ;;
  init)
    init_workspaces
    ;;
  *)
    echo "Usage: $0 {occupy|release|find-available|is-occupied|list|init} [workspace_name]" >&2
    exit 1
    ;;
esac
