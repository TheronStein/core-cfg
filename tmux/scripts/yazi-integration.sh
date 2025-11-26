#!/bin/bash
# Yazi-Tmux Integration Script
# Provides seamless integration between yazi and tmux

# ============================================================================
# CONFIGURATION
# ============================================================================

TMUX_CONF="${HOME}/.core/.sys/cfg/tmux"
YAZI_CONF="${HOME}/.core/.sys/cfg/yazi"
NVIM_CONF="${HOME}/.core/.sys/cfg/nvim"
STATE_DIR="${HOME}/.local/state/core-ide"

# ============================================================================
# YAZI SIDEBAR MANAGEMENT
# ============================================================================

# Toggle left yazi sidebar
toggle_left_sidebar() {
    local session_name="${1:-$(tmux display-message -p '#S')}"
    local left_pane=$(tmux list-panes -F "#{pane_id}:#{pane_cmd}" | grep "yazi" | head -1 | cut -d: -f1)

    if [ -n "$left_pane" ]; then
        # Sidebar exists, toggle visibility
        tmux break-pane -d -P -s "$left_pane" || tmux join-pane -h -t :.0 -s "$left_pane"
    else
        # Create new sidebar
        create_left_sidebar "$session_name"
    fi
}

# Create left yazi sidebar
create_left_sidebar() {
    local session_name="${1:-$(tmux display-message -p '#S')}"
    local width="${2:-25%}"

    # Save current pane
    local current_pane=$(tmux display-message -p '#{pane_id}')

    # Create sidebar pane
    tmux split-window -h -b -l "$width" -c "#{pane_current_path}" \
        "YAZI_CONFIG_HOME='$YAZI_CONF' yazi"

    # Mark as sidebar
    tmux set-option -p @is_sidebar "1"
    tmux set-option -p @sidebar_type "left"

    # Return to original pane
    tmux select-pane -t "$current_pane"
}

# Toggle right yazi sidebar (preview/secondary)
toggle_right_sidebar() {
    local session_name="${1:-$(tmux display-message -p '#S')}"
    local right_pane=$(tmux list-panes -F "#{pane_id}:#{pane_cmd}" | grep "yazi" | tail -1 | cut -d: -f1)

    if [ -n "$right_pane" ] && [ "$right_pane" != "$(tmux list-panes -F "#{pane_id}:#{pane_cmd}" | grep "yazi" | head -1 | cut -d: -f1)" ]; then
        # Right sidebar exists, toggle visibility
        tmux break-pane -d -P -s "$right_pane" || tmux join-pane -h -t :.$ -s "$right_pane"
    else
        # Create new sidebar
        create_right_sidebar "$session_name"
    fi
}

# Create right yazi sidebar
create_right_sidebar() {
    local session_name="${1:-$(tmux display-message -p '#S')}"
    local width="${2:-20%}"

    # Save current pane
    local current_pane=$(tmux display-message -p '#{pane_id}')

    # Create sidebar pane
    tmux split-window -h -l "$width" -c "#{pane_current_path}" \
        "YAZI_CONFIG_HOME='$YAZI_CONF' yazi --preview-only"

    # Mark as sidebar
    tmux set-option -p @is_sidebar "1"
    tmux set-option -p @sidebar_type "right"

    # Return to original pane
    tmux select-pane -t "$current_pane"
}

# ============================================================================
# YAZI-NEOVIM INTEGRATION
# ============================================================================

# Open file from yazi in neovim
yazi_open_in_nvim() {
    local file="$1"
    local nvim_pane=$(tmux list-panes -F "#{pane_id}:#{pane_cmd}" | grep "nvim" | head -1 | cut -d: -f1)

    if [ -n "$nvim_pane" ]; then
        # Neovim pane exists, send file to it
        tmux send-keys -t "$nvim_pane" Escape ":e $file" Enter
        tmux select-pane -t "$nvim_pane"
    else
        # Create new neovim pane
        tmux split-window -h "nvim '$file'"
    fi
}

# Sync yazi directory with current neovim file
sync_yazi_to_nvim() {
    local nvim_file=$(tmux display-message -p '#{pane_current_command}' | grep -q nvim && \
        tmux capture-pane -p -S -1 | grep -E "^[^│]*│.*│" | head -1 | sed 's/.*│\s*//')

    if [ -n "$nvim_file" ]; then
        local dir=$(dirname "$nvim_file")
        local yazi_pane=$(tmux list-panes -F "#{pane_id}:#{pane_cmd}" | grep "yazi" | head -1 | cut -d: -f1)

        if [ -n "$yazi_pane" ]; then
            tmux send-keys -t "$yazi_pane" "g" "$dir" Enter
        fi
    fi
}

# ============================================================================
# YAZI STATE PERSISTENCE
# ============================================================================

# Save yazi state for current session
save_yazi_state() {
    local session_name="${1:-$(tmux display-message -p '#S')}"
    local socket_context="${2:-main}"
    local state_file="${STATE_DIR}/sessions/${socket_context}/yazi/${session_name}.state"

    mkdir -p "$(dirname "$state_file")"

    # Get all yazi panes
    local yazi_panes=$(tmux list-panes -a -F "#{session_name}:#{window_index}:#{pane_index}:#{pane_cmd}:#{pane_current_path}" | grep yazi)

    echo "# Yazi state for session: $session_name" > "$state_file"
    echo "# Saved at: $(date -Iseconds)" >> "$state_file"
    echo "" >> "$state_file"

    while IFS= read -r pane_info; do
        if [ -n "$pane_info" ]; then
            echo "$pane_info" >> "$state_file"
        fi
    done <<< "$yazi_panes"
}

# Restore yazi state for session
restore_yazi_state() {
    local session_name="${1:-$(tmux display-message -p '#S')}"
    local socket_context="${2:-main}"
    local state_file="${STATE_DIR}/sessions/${socket_context}/yazi/${session_name}.state"

    if [ -f "$state_file" ]; then
        # Parse and restore state
        while IFS=: read -r session window pane cmd path; do
            if [[ "$cmd" == *"yazi"* ]] && [ -n "$path" ]; then
                # Check if window exists
                if tmux list-windows -t "$session" -F "#{window_index}" | grep -q "^$window$"; then
                    # Create yazi pane in the window
                    tmux select-window -t "$session:$window"
                    create_left_sidebar "$session"
                fi
            fi
        done < <(grep -v "^#" "$state_file" 2>/dev/null)
    fi
}

# ============================================================================
# FZF INTEGRATION
# ============================================================================

# Use fzf to select and open files in yazi
yazi_fzf_open() {
    local selected=$(fd --type f --hidden --follow --exclude .git | \
        fzf --preview 'bat --style=numbers --color=always {}' \
            --preview-window=right:60%)

    if [ -n "$selected" ]; then
        local yazi_pane=$(tmux list-panes -F "#{pane_id}:#{pane_cmd}" | grep "yazi" | head -1 | cut -d: -f1)
        if [ -n "$yazi_pane" ]; then
            local dir=$(dirname "$selected")
            tmux send-keys -t "$yazi_pane" "g" "$dir" Enter
            tmux send-keys -t "$yazi_pane" "/" "$(basename "$selected")" Enter
        fi
    fi
}

# ============================================================================
# MAIN COMMAND HANDLER
# ============================================================================

case "${1:-help}" in
    toggle-left)
        toggle_left_sidebar "$2"
        ;;
    toggle-right)
        toggle_right_sidebar "$2"
        ;;
    create-left)
        create_left_sidebar "$2" "$3"
        ;;
    create-right)
        create_right_sidebar "$2" "$3"
        ;;
    open-in-nvim)
        yazi_open_in_nvim "$2"
        ;;
    sync-to-nvim)
        sync_yazi_to_nvim
        ;;
    save-state)
        save_yazi_state "$2" "$3"
        ;;
    restore-state)
        restore_yazi_state "$2" "$3"
        ;;
    fzf-open)
        yazi_fzf_open
        ;;
    help|*)
        echo "Yazi-Tmux Integration"
        echo ""
        echo "Usage: $0 <command> [args...]"
        echo ""
        echo "Commands:"
        echo "  toggle-left [session]      - Toggle left yazi sidebar"
        echo "  toggle-right [session]     - Toggle right yazi sidebar"
        echo "  create-left [session] [width] - Create left sidebar"
        echo "  create-right [session] [width] - Create right sidebar"
        echo "  open-in-nvim <file>       - Open file in neovim pane"
        echo "  sync-to-nvim              - Sync yazi to current nvim file"
        echo "  save-state [session] [context] - Save yazi state"
        echo "  restore-state [session] [context] - Restore yazi state"
        echo "  fzf-open                  - Use fzf to select file in yazi"
        echo "  help                      - Show this help"
        ;;
esac