#!/usr/bin/env bash
# Pane Picker - FZF-based tmux pane selection
# Location: ~/.tmux/modules/fzf/pickers/pane-picker.sh
# Usage: pane-picker.sh [--action=swap|join-h|join-v|send-h|send-v|target] [--all]
#
# Actions:
#   swap     - Swap current pane with selected (default)
#   join-h   - Join selected pane here (horizontal split)
#   join-v   - Join selected pane here (vertical split)
#   send-h   - Send current pane to selected window (horizontal)
#   send-v   - Send current pane to selected window (vertical)
#   move     - Move pane to selected window
#   target   - Output pane target (for use in other commands)
#
# Options:
#   --all    - Show panes from all sessions (default: current session only)

set -euo pipefail

# Source libraries
source ~/.core/.cortex/lib/fzf-config.sh
source ~/.core/.cortex/lib/tmux.sh

# Parse arguments
ACTION="swap"
SHOW_ALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --action=*) ACTION="${1#*=}"; shift ;;
        -a) ACTION="$2"; shift 2 ;;
        --all) SHOW_ALL=true; shift ;;
        *) shift ;;
    esac
done

# Get current pane info
CURRENT_SESSION=$(tmux::session::name)
CURRENT_WINDOW=$(tmux::window::index)
CURRENT_PANE=$(tmux::pane::index)
CURRENT_PANE_ID=$(tmux::pane::id)

# Colors
C_RESET='\033[0m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_DIM='\033[2m'
C_BOLD='\033[1m'
C_BLUE='\033[34m'
C_MAGENTA='\033[35m'

# Build pane list
# Format: session:window.pane | command | path | size
get_panes() {
    local format_str="#{session_name}:#{window_index}.#{pane_index}|#{pane_current_command}|#{pane_current_path}|#{pane_width}x#{pane_height}|#{pane_id}"

    if [[ "$SHOW_ALL" == "true" ]]; then
        tmux list-panes -a -F "$format_str" 2>/dev/null
    else
        tmux list-panes -s -F "$format_str" 2>/dev/null
    fi | while IFS='|' read -r target cmd path size pane_id; do
        local marker=" "
        local target_color="$C_CYAN"
        [[ "$pane_id" == "$CURRENT_PANE_ID" ]] && { marker="*"; target_color="$C_GREEN$C_BOLD"; }

        # Shorten path
        local short_path="${path/#$HOME/~}"
        [[ ${#short_path} -gt 25 ]] && short_path="...${short_path: -22}"

        # Shorten command
        local short_cmd="$cmd"
        [[ ${#short_cmd} -gt 15 ]] && short_cmd="${short_cmd:0:12}..."

        printf "${C_YELLOW}%s${C_RESET} ${target_color}%-18s${C_RESET}  ${C_MAGENTA}%-15s${C_RESET}  ${C_DIM}%-10s${C_RESET}  ${C_BLUE}%s${C_RESET}\n" \
            "$marker" "$target" "$short_cmd" "$size" "$short_path"
    done
}

# Preview script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Header based on action
case "$ACTION" in
    swap)    HEADER="Select pane to swap with current" ;;
    join-h)  HEADER="Select pane to bring here (horizontal)" ;;
    join-v)  HEADER="Select pane to bring here (vertical)" ;;
    send-h)  HEADER="Select window to send pane (horizontal)" ;;
    send-v)  HEADER="Select window to send pane (vertical)" ;;
    move)    HEADER="Select window to move pane to" ;;
    target)  HEADER="Select target pane" ;;
    *)       HEADER="Select pane" ;;
esac

# Keybind hints
KEYBINDS="^/ preview  Esc cancel"

# Run FZF
SELECTED=$(get_panes | fzf-tmux -p 80%,80% \
    --ansi \
    --layout=reverse \
    --border=rounded \
    --color="$(fzf::colors)" \
    --preview="$SCRIPT_DIR/preview-pane.sh {}" \
    --preview-window=right:60%:wrap \
    --header="$HEADER
$KEYBINDS" \
    --prompt="Pane> " \
    --bind="ctrl-/:toggle-preview" \
    --bind="esc:cancel" \
) || exit 0

# Extract pane target
TARGET=$(echo "$SELECTED" | sed 's/^[* ] //' | awk '{print $1}')

[[ -z "$TARGET" ]] && exit 0

# For some actions, we need the window part only
TARGET_WINDOW="${TARGET%.*}"

# Execute action
case "$ACTION" in
    swap)
        tmux swap-pane -t "$TARGET"
        ;;
    join-h)
        # Bring selected pane here, horizontal split
        tmux join-pane -h -s "$TARGET"
        ;;
    join-v)
        # Bring selected pane here, vertical split
        tmux join-pane -v -s "$TARGET"
        ;;
    send-h)
        # Send current pane to selected location, horizontal
        tmux join-pane -h -t "$TARGET"
        ;;
    send-v)
        # Send current pane to selected location, vertical
        tmux join-pane -v -t "$TARGET"
        ;;
    move)
        # Move pane to end of target window
        tmux move-pane -t "$TARGET_WINDOW"
        ;;
    target)
        echo "$TARGET"
        ;;
esac
