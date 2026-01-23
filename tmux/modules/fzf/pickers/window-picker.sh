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
        local session="${target%%:*}"
        local index="${target##*:}"
        [[ "$session" == "$CURRENT_SESSION" && "$index" == "$CURRENT_WINDOW" ]] && marker="*"

        # Shorten path
        local short_path="${path/#$HOME/~}"
        [[ ${#short_path} -gt 30 ]] && short_path="...${short_path: -27}"

        printf "%s %-20s  %s panes  %s  %s\n" "$marker" "$target" "$panes" "$name" "$short_path"
    done
}

# Preview: show panes in window
preview_window() {
    local line="$1"
    # Extract target (session:index)
    local target
    target=$(echo "$line" | sed 's/^[* ] //' | awk '{print $1}')

    local session="${target%%:*}"
    local index="${target##*:}"

    echo -e "\033[1;34m═══ Window: $target ═══\033[0m"
    echo ""

    # Window info
    local name layout
    name=$(tmux display-message -t "$target" -p '#{window_name}' 2>/dev/null || echo "unknown")
    layout=$(tmux display-message -t "$target" -p '#{window_layout}' 2>/dev/null | cut -c1-40)
    echo -e "\033[1;33m Name:\033[0m $name"
    echo -e "\033[1;33m Layout:\033[0m ${layout}..."
    echo ""

    # List panes
    echo -e "\033[1;33m Panes:\033[0m"
    tmux list-panes -t "$target" -F "  #{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height})" 2>/dev/null
    echo ""

    # Preview pane content
    echo -e "\033[1;33m Active Pane:\033[0m"
    tmux capture-pane -t "$target" -p -S -12 2>/dev/null | head -12 || echo "  (no preview)"
}
export -f preview_window

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
SELECTED=$(get_windows | fzf \
    --ansi \
    --height=80% \
    --layout=reverse \
    --border=rounded \
    --color="$(fzf::colors)" \
    --preview='bash -c "preview_window {}"' \
    --preview-window=top:70%:wrap \
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
