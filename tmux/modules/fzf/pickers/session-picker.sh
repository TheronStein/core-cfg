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

# Build session list with details
# Format: session_name | windows | created | attached
get_sessions() {
    tmux list-sessions -F "#{session_name}|#{session_windows}|#{session_created}|#{?session_attached,attached,}" 2>/dev/null | \
    while IFS='|' read -r name windows created attached; do
        local marker=" "
        [[ "$name" == "$CURRENT_SESSION" ]] && marker="*"
        local attached_icon=""
        [[ -n "$attached" ]] && attached_icon=" 󰀘"
        local created_fmt
        created_fmt=$(date -d "@$created" "+%m/%d %H:%M" 2>/dev/null || echo "")
        printf "%s %s  %s wins  %s%s\n" "$marker" "$name" "$windows" "$created_fmt" "$attached_icon"
    done
}

# Preview: show windows and panes in session
preview_session() {
    local session="$1"
    # Remove marker and extra spaces
    session=$(echo "$session" | sed 's/^[* ] //' | awk '{print $1}')

    echo -e "\033[1;34m═══ Session: $session ═══\033[0m"
    echo ""

    # List windows
    echo -e "\033[1;33m Windows:\033[0m"
    tmux list-windows -t "$session" -F "  #{window_index}: #{window_name} (#{window_panes} panes)" 2>/dev/null
    echo ""

    # Show pane content from first window
    echo -e "\033[1;33m Active Pane Preview:\033[0m"
    tmux capture-pane -t "$session" -p -S -15 2>/dev/null | head -15 || echo "  (no preview available)"
}
export -f preview_session

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
SELECTED=$(get_sessions | fzf \
    --ansi \
    --height=80% \
    --layout=reverse \
    --border=rounded \
    --color="$(fzf::colors)" \
    --preview='bash -c "preview_session {}"' \
    --preview-window=top:70%:wrap \
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
