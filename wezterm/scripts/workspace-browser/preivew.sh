#!/usr/bin/env bash
# Preview generator for WezTerm workspace browser

set -euo pipefail

ITEM="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
WORKSPACES_FILE="$DATA_DIR/workspaces.json"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BRIGHT_CYAN='\033[0;96m'
BRIGHT_WHITE='\033[0;97m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
RESET='\033[0m'

# Extract workspace name (remove icon if present)
workspace_name="${ITEM#* }"
workspace_name="${workspace_name%% |*}"

# Get workspace info
workspace_info=$(jq -r --arg name "$workspace_name" \
  '.workspaces[] | select(.name == $name)' "$WORKSPACES_FILE" 2>/dev/null)

if [[ -z "$workspace_info" ]]; then
  echo -e "${RED}Workspace not found: $workspace_name${RESET}"
  exit 1
fi

# Extract fields
occupied=$(echo "$workspace_info" | jq -r '.occupied')
created=$(echo "$workspace_info" | jq -r '.created')
last_used=$(echo "$workspace_info" | jq -r '.last_used // .created')

# Determine status
if [[ "$occupied" == "true" ]]; then
  status_icon="🔒"
  status_text="${RED}Occupied${RESET}"
  status_desc="${DIM}Another client is currently attached${RESET}"
else
  status_icon="✓"
  status_text="${GREEN}Available${RESET}"
  status_desc="${DIM}Ready to connect${RESET}"
fi

# Header
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║${RESET} ${BOLD}${BRIGHT_WHITE}$status_icon  $workspace_name${RESET}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
echo

# Status
echo -e "${BOLD}${CYAN}📊 Status:${RESET} $status_text"
echo -e "  $status_desc"
echo

# Timestamps
echo -e "${BOLD}${CYAN}📅 Created:${RESET}    ${YELLOW}$created${RESET}"
echo -e "${BOLD}${CYAN}🕐 Last Used:${RESET}  ${YELLOW}$last_used${RESET}"
echo

# Additional info
if [[ "$occupied" == "true" ]]; then
  echo -e "${BOLD}${RED}━━━ Warning ━━━${RESET}"
  echo -e "${DIM}This workspace is currently in use by another client."
  echo -e "Selecting it may fail or disconnect the other client.${RESET}"
else
  echo -e "${BOLD}${GREEN}━━━ Ready ━━━${RESET}"
  echo -e "${DIM}This workspace is available for connection."
  echo -e "Press ENTER to connect to this workspace.${RESET}"
fi

echo
echo -e "${DIM}${ITALIC}Navigate with ↑↓ • ESC to go back • Ctrl-/ to toggle preview${RESET}"
