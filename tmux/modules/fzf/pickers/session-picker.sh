#!/usr/bin/env bash
# Session Picker - FZF-based tmux session selection
# Location: ~/.tmux/modules/fzf/pickers/session-picker.sh
# Usage: session-picker.sh [--action=switch|kill|target]
#
# Actions:
#   switch  - Switch to selected session (default)
#   kill    - Kill selected session
#   target  - Output session name (for use in other commands)

set -euo pipefail

# Source libraries
source ~/.core/.cortex/lib/fzf-config.sh
source ~/.core/.cortex/lib/tmux.sh

# Parse arguments
ACTION="switch"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --action=*) ACTION="${1#*=}"; shift ;;
        -a) ACTION="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Get current session to mark it
CURRENT_SESSION=$(tmux::session::name)

# Colors
C_RESET='\033[0m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_DIM='\033[2m'
C_BOLD='\033[1m'
C_MAGENTA='\033[35m'

# Build session list with details
# Format: session_name | windows | created | attached
get_sessions() {
    tmux list-sessions -F "#{session_name}|#{session_windows}|#{session_created}|#{?session_attached,attached,}" 2>/dev/null | \
    while IFS='|' read -r name windows created attached; do
        local marker=" "
        local name_color="$C_CYAN"
        [[ "$name" == "$CURRENT_SESSION" ]] && { marker="*"; name_color="$C_GREEN$C_BOLD"; }
        local attached_icon=""
        [[ -n "$attached" ]] && attached_icon=" ${C_MAGENTA}󰀘${C_RESET}"
        local created_fmt
        created_fmt=$(date -d "@$created" "+%m/%d %H:%M" 2>/dev/null || echo "")
        printf "${C_YELLOW}%s${C_RESET} ${name_color}%s${C_RESET}  ${C_DIM}%s wins${C_RESET}  ${C_DIM}%s${C_RESET}%b\n" \
            "$marker" "$name" "$windows" "$created_fmt" "$attached_icon"
    done
}

# Preview script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Header based on action
case "$ACTION" in
    switch) HEADER="Select session to switch to" ;;
    kill)   HEADER="Select session to kill" ;;
    target) HEADER="Select target session" ;;
    *)      HEADER="Select session" ;;
esac

# Keybind hints
KEYBINDS="^r reload  ^/ preview  Esc cancel"

# Run FZF
SELECTED=$(get_sessions | fzf-tmux -p 80%,80% \
    --ansi \
    --layout=reverse \
    --border=rounded \
    --color="$(fzf::colors)" \
    --preview="$SCRIPT_DIR/preview-session.sh {}" \
    --preview-window=right:60%:wrap \
    --header="$HEADER
$KEYBINDS" \
    --prompt="Session> " \
    --bind="ctrl-r:reload(bash -c 'source $0; get_sessions')" \
    --bind="ctrl-/:toggle-preview" \
    --bind="esc:cancel" \
) || exit 0

# Extract session name (remove marker and get first word)
SESSION_NAME=$(echo "$SELECTED" | sed 's/^[* ] //' | awk '{print $1}')

[[ -z "$SESSION_NAME" ]] && exit 0

# Execute action
case "$ACTION" in
    switch)
        tmux switch-client -t "$SESSION_NAME"
        ;;
    kill)
        if [[ "$SESSION_NAME" == "$CURRENT_SESSION" ]]; then
            tmux display-message "Cannot kill current session"
            exit 1
        fi
        tmux kill-session -t "$SESSION_NAME"
        tmux display-message "Killed session: $SESSION_NAME"
        ;;
    target)
        echo "$SESSION_NAME"
        ;;
esac
