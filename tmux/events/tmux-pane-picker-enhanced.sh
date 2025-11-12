#!/bin/bash
# File: tmux-pane-picker-enhanced.sh
# Enhanced tmux pane picker with rich preview supporting both moving panes and joining windows

# Configuration
PREVIEW_WIDTH="70%"
PREVIEW_LINES=30

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to get detailed pane info
get_pane_info() {
    tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}|#{session_name}|#{window_name}|#{pane_current_command}|#{pane_current_path}|#{pane_title}|#{pane_width}x#{pane_height}|#{pane_active}"
}

# Create preview script
create_preview_script() {
    local script_path="/tmp/tmux_preview_enhanced_$$"

    cat >"$script_path" <<'PREVIEW_SCRIPT'
#!/bin/bash

# Configuration
PREVIEW_LINES=30

# Get pane info from argument
pane_info="$1"
pane_id=$(echo "$pane_info" | cut -d'|' -f1)
session=$(echo "$pane_info" | cut -d'|' -f2)
window=$(echo "$pane_info" | cut -d'|' -f3)
command=$(echo "$pane_info" | cut -d'|' -f4)
path=$(echo "$pane_info" | cut -d'|' -f5)
title=$(echo "$pane_info" | cut -d'|' -f6)
size=$(echo "$pane_info" | cut -d'|' -f7)
active=$(echo "$pane_info" | cut -d'|' -f8)

# Header with pane metadata
printf "\033[0;34m╭─ Pane Info ─────────────────────────────────────╮\033[0m\n"
printf "\033[0;34m│\033[0m ID: \033[1;33m%s\033[0m\n" "$pane_id"
printf "\033[0;34m│\033[0m Session: \033[0;32m%s\033[0m\n" "$session"
printf "\033[0;34m│\033[0m Window: \033[0;32m%s\033[0m\n" "$window"
printf "\033[0;34m│\033[0m Command: \033[1;33m%s\033[0m\n" "$command"
printf "\033[0;34m│\033[0m Path: %s\n" "$path"
printf "\033[0;34m│\033[0m Title: %s\n" "$title"
printf "\033[0;34m│\033[0m Size: %s\n" "$size"
printf "\033[0;34m│\033[0m Active: %s\n" "$([ "$active" = "1" ] && echo "Yes" || echo "No")"
printf "\033[0;34m╰─────────────────────────────────────────────────╯\033[0m\n"
echo ""

# Pane content
printf "\033[0;34m╭─ Pane Content ──────────────────────────────────╮\033[0m\n"
tmux capture-pane -t "$pane_id" -p 2>/dev/null | head -n $PREVIEW_LINES
printf "\033[0;34m╰─────────────────────────────────────────────────╯\033[0m\n"
PREVIEW_SCRIPT

    chmod +x "$script_path"
    echo "$script_path"
}

# Format pane list for display
format_pane_list() {
    get_pane_info | while IFS='|' read -r pane_id session window command path title size active; do
        local active_indicator=""
        [ "$active" = "1" ] && active_indicator="●" || active_indicator="○"

        printf "%-25s %s %-15s %-20s %-15s %s\n" \
            "$pane_id" \
            "$active_indicator" \
            "$session" \
            "$window" \
            "$command" \
            "$title"
    done
}

# Main function
main() {
    local action="${1:-move}" # move or join

    echo "Loading tmux panes..."

    # Check if we're in a tmux session
    if [ -z "$TMUX" ]; then
        echo "Error: This script must be run from within a tmux session."
        exit 1
    fi

    local current_session=$(tmux display-message -p '#{session_name}')
    local current_window=$(tmux display-message -p '#{window_index}')

    echo "Current session: $current_session:$current_window"
    echo ""

    # Create preview script
    local preview_script=$(create_preview_script)

    # Cleanup function
    cleanup() {
        rm -f "$preview_script"
    }
    trap cleanup EXIT

    # Get selection with fzf
    local selected=$(get_pane_info |
        fzf --ansi \
            --header="Select pane to $action to current session ($current_session:$current_window)" \
            --header-lines=0 \
            --delimiter="|" \
            --with-nth=1,3,4,5,6 \
            --preview="${preview_script} {}" \
            --preview-window="right:$PREVIEW_WIDTH:wrap" \
            --bind="ctrl-r:reload(tmux list-panes -a -F '#{session_name}:#{window_name}')" \
            --bind="ctrl-p:toggle-preview" \
            --bind="alt-m:change-header(Move pane mode)+reload(tmux list-panes -a -F '#{session_name}:#{window_name}')" \
            --bind="alt-j:change-header(Join window mode)+reload(tmux list-panes -a -F '#{session_name}:#{window_name}')" \
            --prompt="Pane> " \
            --border \
            --height=90%)

    if [[ -n "$selected" ]]; then
        local selected_pane=$(echo "$selected" | cut -d'|' -f1)
        local selected_session=$(echo "$selected" | cut -d'|' -f2)

        # Prevent moving pane from current session to itself
        if [[ "$selected_session" == "$current_session" ]]; then
            echo "Cannot move pane within the same session. Use tmux commands for local pane management."
            exit 1
        fi

        echo "Selected: $selected_pane"
        echo "Action: $action"

        case "$action" in
        "move")
            echo "Moving pane $selected_pane to current session..."
            if tmux move-pane -s "$selected_pane" -t "$current_session:$current_window"; then
                echo "✓ Pane moved successfully!"
            else
                echo "✗ Failed to move pane"
                exit 1
            fi
            ;;
        "join")
            echo "Joining window to current session..."
            local window_target="${selected_pane%.*}" # Remove pane number
            if tmux move-window -s "$window_target" -t "$current_session:"; then
                echo "✓ Window joined successfully!"
            else
                echo "✗ Failed to join window"
                exit 1
            fi
            ;;
        esac
    else
        echo "No pane selected."
    fi
}

# Show help
show_help() {
    cat <<EOF
Tmux Pane Picker with fzf and bat preview

Usage: $0 [action]

Actions:
  move    Move selected pane to current session (default)
  join    Move entire window to current session
  help    Show this help

Keybindings in fzf:
  Ctrl-R    Reload pane list
  Ctrl-P    Toggle preview
  Alt-M     Switch to move mode
  Alt-J     Switch to join mode
  Enter     Select and execute action
  Esc       Cancel

Requirements:
  - tmux
  - fzf
  - bat (optional, will fallback to cat)
EOF
}

# Parse arguments
case "${1:-}" in
"help" | "-h" | "--help")
    show_help
    exit 0
    ;;
"move" | "join" | "")
    main "$1"
    ;;
*)
    echo "Unknown action: $1"
    show_help
    exit 1
    ;;
esac
