#!/usr/bin/env bash
# Yazibar - Open file in Nvim
# Opens files in an existing nvim instance in the current window, or creates a new pane

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# FILE OPENING LOGIC
# ============================================================================

open_file_in_nvim() {
    local file="$1"

    if [ -z "$file" ]; then
        display_error "No file specified"
        return 1
    fi

    # Make sure file path is absolute
    if [[ "$file" != /* ]]; then
        file="$(pwd)/$file"
    fi

    debug_log "Opening file: $file"

    # Get current window
    local window_id=$(tmux display-message -p '#{window_id}')
    local left_pane=$(get_left_pane)
    local right_pane=$(get_right_pane)

    # Look for nvim in current window panes
    local nvim_pane=""
    local pane_ids=$(tmux list-panes -t "$window_id" -F "#{pane_id}")

    for pane_id in $pane_ids; do
        # Skip sidebars
        if [ "$pane_id" = "$left_pane" ] || [ "$pane_id" = "$right_pane" ]; then
            continue
        fi

        # Check if this pane is running nvim
        local pane_command=$(tmux display-message -p -t "$pane_id" '#{pane_current_command}')
        if [ "$pane_command" = "nvim" ]; then
            nvim_pane="$pane_id"
            debug_log "Found nvim in pane: $nvim_pane"
            break
        fi
    done

    if [ -n "$nvim_pane" ]; then
        # Open file in existing nvim using tmux send-keys
        debug_log "Opening $file in existing nvim pane $nvim_pane"

        # Focus the nvim pane first
        tmux select-pane -t "$nvim_pane"

        # Escape the file path for vim command
        local escaped_file="${file//\'/\'\'}"

        # Send the edit command to nvim
        # <C-\><C-n> ensures we're in normal mode first
        tmux send-keys -t "$nvim_pane" C-\\ C-n ":edit $escaped_file" Enter

        display_info "Opened in nvim"
        return 0
    fi

    # No nvim found - create new pane with nvim
    debug_log "No active nvim found, opening in new pane"

    # Find a non-sidebar pane to split from
    local target_pane=""
    for pane_id in $pane_ids; do
        if [ "$pane_id" != "$left_pane" ] && [ "$pane_id" != "$right_pane" ]; then
            target_pane="$pane_id"
            break
        fi
    done

    # If no suitable pane found, just split from current window
    if [ -z "$target_pane" ]; then
        target_pane="$window_id"
    fi

    # Split horizontally and open nvim
    # Calculate a reasonable split size (50% of the remaining space after sidebars)
    local file_dir=$(dirname "$file")
    local escaped_file="${file//\'/\'\\\'}"

    # Split at 50% to create a balanced layout
    tmux split-window -t "$target_pane" -h -p 50 -c "$file_dir" "nvim '$escaped_file'"

    debug_log "Opened $file in new pane"
    display_info "Opened in new pane"
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-help}" in
    open)
        open_file_in_nvim "$2"
        ;;
    help|*)
        cat <<EOF
Yazibar Open in Nvim

COMMANDS:
  open <file>           Open file in nvim (existing or new pane)

USAGE:
  $0 open /path/to/file
EOF
        ;;
esac
