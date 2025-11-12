#!/usr/bin/env bash
# WezTerm Workspace Browser with FZF

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
WORKSPACES_FILE="$DATA_DIR/workspaces.json"
MANAGER="$SCRIPT_DIR/workspace-manager.sh"

# Ensure dependencies
for cmd in fzf jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done

# Initialize workspace data
"$MANAGER" init

# Browse available workspaces
browse_workspaces() {
  # Format: name<TAB>icon status | last_used
  "$MANAGER" list | while IFS='|' read -r name occupied last_used; do
    local icon="✓"
    local status="Available"

    if [[ "$occupied" == "true" ]]; then
      icon="🔒"
      status="Occupied"
    fi

    # Format for FZF: NAME<TAB>icon name | status (last_used)
    printf "%s\t%s %s | %s (%s)\n" "$name" "$icon" "$name" "$status" "$last_used"
  done \
    | fzf \
      --ansi \
      --height=100% \
      --layout=reverse \
      --border=rounded \
      --border-label="╣ WezTerm Workspaces ╠" \
      --prompt="Workspace ▸ " \
      --pointer="▶" \
      --marker="✓" \
      --delimiter=$'\t' \
      --with-nth=2 \
      --header=$'Navigate: ↑↓ PageUp/PageDown | Select: Enter | Quit: Esc\n─────────────────────────────────────────' \
      --preview="$SCRIPT_DIR/workspace-preview.sh {2}" \
      --preview-window=right:60%:wrap:rounded \
      --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
      --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
      --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
      --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
      --bind="ctrl-/:toggle-preview"
}

# Main
selected=$(browse_workspaces)

if [[ -n "$selected" ]]; then
  # Extract workspace name (first field before TAB)
  workspace_name=$(echo "$selected" | cut -f1)

  # Check if occupied
  if "$MANAGER" is-occupied "$workspace_name" &>/dev/null; then
    echo "ERROR: Workspace '$workspace_name' is already occupied" >&2
    exit 1
  fi

  # Output selected workspace name
  echo "$workspace_name"
else
  exit 1
fi
