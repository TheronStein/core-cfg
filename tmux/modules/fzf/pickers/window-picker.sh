#!/usr/bin/env bash
# Window Picker - FZF-based tmux window selection
# Location: ~/.tmux/modules/fzf/pickers/window-picker.sh
# Usage: window-picker.sh [--action=switch|swap|move-before|move-after|link|target] [--follow]
#
# Actions:
#   switch      - Switch to selected window (default)
#   swap        - Swap current window with selected
#   move-before - Move current window before selected
#   move-after  - Move current window after selected
#   link        - Link selected window to current session
#   target      - Output window target (for use in other commands)
#
# Options:
#   --follow    - Stay on moved/swapped window (default: stay on current)
#   --all       - Show windows from all sessions (default for some actions)

set -euo pipefail

# Source libraries
source ~/.core/.cortex/lib/fzf-config.sh
source ~/.core/.cortex/lib/tmux.sh

# Parse arguments
ACTION="switch"
FOLLOW=false
SHOW_ALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --action=*) ACTION="${1#*=}"; shift ;;
        -a) ACTION="$2"; shift 2 ;;
        --follow) FOLLOW=true; shift ;;
        --all) SHOW_ALL=true; shift ;;
        *) shift ;;
    esac
done

# For certain actions, default to showing all sessions
case "$ACTION" in
    switch|link) SHOW_ALL=true ;;
esac

# Get current window info
CURRENT_SESSION=$(tmux::session::name)
CURRENT_WINDOW=$(tmux::window::index)
CURRENT_WINDOW_ID=$(tmux::window::id)

# Colors
C_RESET='\033[0m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_DIM='\033[2m'
C_BOLD='\033[1m'
C_BLUE='\033[34m'

# Build window list
# Format: session:index | name | panes | path
get_windows() {
    local format_str
    if [[ "$SHOW_ALL" == "true" ]]; then
        format_str="#{session_name}:#{window_index}|#{window_name}|#{window_panes}|#{pane_current_path}"
        tmux list-windows -a -F "$format_str" 2>/dev/null
    else
        format_str="#{session_name}:#{window_index}|#{window_name}|#{window_panes}|#{pane_current_path}"
        tmux list-windows -F "$format_str" 2>/dev/null
    fi | while IFS='|' read -r target name panes path; do
        local marker=" "
        local target_color="$C_CYAN"
        local session="${target%%:*}"
        local index="${target##*:}"
        [[ "$session" == "$CURRENT_SESSION" && "$index" == "$CURRENT_WINDOW" ]] && { marker="*"; target_color="$C_GREEN$C_BOLD"; }

        # Shorten path
        local short_path="${path/#$HOME/~}"
        [[ ${#short_path} -gt 30 ]] && short_path="...${short_path: -27}"

        printf "${C_YELLOW}%s${C_RESET} ${target_color}%-20s${C_RESET}  ${C_DIM}%s panes${C_RESET}  ${C_BLUE}%s${C_RESET}  ${C_DIM}%s${C_RESET}\n" \
            "$marker" "$target" "$panes" "$name" "$short_path"
    done
}

# Preview script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Header based on action
case "$ACTION" in
    switch)      HEADER="Select window to switch to" ;;
    swap)        HEADER="Select window to swap with current" ;;
    move-before) HEADER="Select position to move window before" ;;
    move-after)  HEADER="Select position to move window after" ;;
    link)        HEADER="Select window to link to this session" ;;
    target)      HEADER="Select target window" ;;
    *)           HEADER="Select window" ;;
esac

# Keybind hints
KEYBINDS="^/ preview  Esc cancel"

# Run FZF
SELECTED=$(get_windows | fzf-tmux -p 80%,80% \
    --ansi \
    --layout=reverse \
    --border=rounded \
    --color="$(fzf::colors)" \
    --preview="$SCRIPT_DIR/preview-window.sh {}" \
    --preview-window=right:60%:wrap \
    --header="$HEADER
$KEYBINDS" \
    --prompt="Window> " \
    --bind="ctrl-/:toggle-preview" \
    --bind="esc:cancel" \
) || exit 0

# Extract window target
TARGET=$(echo "$SELECTED" | sed 's/^[* ] //' | awk '{print $1}')

[[ -z "$TARGET" ]] && exit 0

# Build follow flag
FOLLOW_FLAG=""
[[ "$FOLLOW" == "false" ]] && FOLLOW_FLAG="-d"

# Execute action
case "$ACTION" in
    switch)
        tmux switch-client -t "$TARGET"
        ;;
    swap)
        tmux swap-window $FOLLOW_FLAG -t "$TARGET"
        ;;
    move-before)
        tmux move-window $FOLLOW_FLAG -b -t "$TARGET"
        ;;
    move-after)
        tmux move-window $FOLLOW_FLAG -a -t "$TARGET"
        ;;
    link)
        # Link window from another session to current
        tmux link-window -s "$TARGET" -t "$CURRENT_SESSION"
        tmux display-message "Linked window from $TARGET"
        ;;
    target)
        echo "$TARGET"
        ;;
esac
