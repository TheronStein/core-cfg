#!/usr/bin/env bash
# Yazibar - Nvim Address Registry
# Detects and registers nvim socket addresses for file opening

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# NVIM SOCKET DETECTION
# ============================================================================

# Find nvim socket in current pane
find_nvim_in_pane() {
    local pane_id="${1:-$(get_current_pane)}"

    # Get pane's process ID
    local pane_pid=$(tmux display-message -p -t "$pane_id" '#{pane_pid}')

    if [ -z "$pane_pid" ]; then
        return 1
    fi

    # Find nvim processes under this pane
    local nvim_pids=$(pgrep -P "$pane_pid" nvim)

    if [ -z "$nvim_pids" ]; then
        # Try looking for nvim in child processes recursively
        nvim_pids=$(pstree -p "$pane_pid" | grep -o 'nvim([0-9]*)' | grep -o '[0-9]*')
    fi

    if [ -z "$nvim_pids" ]; then
        return 1
    fi

    # Get the first nvim PID
    local nvim_pid=$(echo "$nvim_pids" | head -1)

    # Find nvim socket by checking environment or socket directory
    # Method 1: Check /tmp for nvim sockets owned by current user
    local nvim_socket=$(find /tmp -user "$(whoami)" -name "nvim*" -type s 2>/dev/null | head -1)

    if [ -n "$nvim_socket" ]; then
        echo "$nvim_socket"
        return 0
    fi

    # Method 2: Check XDG_RUNTIME_DIR
    if [ -n "$XDG_RUNTIME_DIR" ]; then
        nvim_socket=$(find "$XDG_RUNTIME_DIR" -name "nvim*" -type s 2>/dev/null | head -1)
        if [ -n "$nvim_socket" ]; then
            echo "$nvim_socket"
            return 0
        fi
    fi

    return 1
}

# Find nvim socket in current window (any pane)
find_nvim_in_window() {
    local window_id=$(tmux display-message -p '#{window_id}')

    # Get all panes in current window
    local pane_ids=$(tmux list-panes -t "$window_id" -F "#{pane_id}")

    for pane_id in $pane_ids; do
        local nvim_addr=$(find_nvim_in_pane "$pane_id")
        if [ -n "$nvim_addr" ]; then
            echo "$nvim_addr"
            return 0
        fi
    done

    return 1
}

# ============================================================================
# NVIM ADDRESS REGISTRATION
# ============================================================================

# Register current window's nvim address
register_current_nvim() {
    local nvim_addr=$(find_nvim_in_window)

    if [ -n "$nvim_addr" ]; then
        set_tmux_option "@yazibar-current-nvim-addr" "$nvim_addr"
        debug_log "Registered nvim address: $nvim_addr"
        echo "$nvim_addr"
        return 0
    else
        debug_log "No nvim instance found in current window"
        clear_tmux_option "@yazibar-current-nvim-addr"
        return 1
    fi
}

# Get registered nvim address
get_current_nvim() {
    get_tmux_option "@yazibar-current-nvim-addr" ""
}

# Clear registered nvim address
clear_current_nvim() {
    clear_tmux_option "@yazibar-current-nvim-addr"
}

# ============================================================================
# NVIM FILE OPENING
# ============================================================================

# Open file in registered nvim instance
open_in_nvim() {
    local file="$1"
    local nvim_addr=$(get_current_nvim)

    if [ -z "$nvim_addr" ]; then
        # Try to find nvim address
        nvim_addr=$(find_nvim_in_window)
        if [ -z "$nvim_addr" ]; then
            display_error "No nvim instance found"
            return 1
        fi
    fi

    debug_log "Opening $file in nvim: $nvim_addr"

    # Use nvim remote to open file
    if command -v nvim &> /dev/null; then
        nvim --server "$nvim_addr" --remote "$file"
        return $?
    else
        display_error "nvim command not found"
        return 1
    fi
}

# ============================================================================
# AUTO-DETECTION
# ============================================================================

# Automatically register nvim when pane focus changes
auto_register() {
    register_current_nvim >/dev/null 2>&1
}

# ============================================================================
# STATUS
# ============================================================================

status_nvim() {
    echo "=== Nvim Address Status ==="

    local nvim_addr=$(get_current_nvim)
    if [ -n "$nvim_addr" ]; then
        echo "Registered address: $nvim_addr"

        # Check if socket still exists
        if [ -S "$nvim_addr" ]; then
            echo "Socket exists: YES"
        else
            echo "Socket exists: NO (stale)"
        fi
    else
        echo "No registered nvim address"
    fi

    echo ""
    echo "Nvim instances in current window:"
    find_nvim_in_window || echo "  None found"
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-help}" in
    find-pane)
        find_nvim_in_pane "$2"
        ;;
    find-window)
        find_nvim_in_window
        ;;
    register)
        register_current_nvim
        ;;
    get-current)
        get_current_nvim
        ;;
    clear)
        clear_current_nvim
        ;;
    open)
        open_in_nvim "$2"
        ;;
    auto-register)
        auto_register
        ;;
    status)
        status_nvim
        ;;
    help|*)
        cat <<EOF
Yazibar Nvim Address Registry

COMMANDS:
  find-pane [pane-id]   Find nvim socket in pane
  find-window           Find nvim socket in current window
  register              Register current window's nvim
  get-current           Get registered nvim address
  clear                 Clear registered address
  open <file>           Open file in registered nvim
  auto-register         Auto-register on focus (for hooks)
  status                Show nvim status

USAGE:
  $0 register
  $0 open /path/to/file
  $0 status
EOF
        ;;
esac
