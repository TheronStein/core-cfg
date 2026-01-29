#!/usr/bin/env bash
# Session Initialization Picker - Prompts for working directory on new sessions
# Location: ~/.tmux/modules/fzf/pickers/session-init-picker.sh
#
# This script is called by the after-new-session hook to let users pick
# a working directory for new sessions. It's smart about when to run:
# - Skips special sessions (view, ai, apps)
# - Skips if session was created via session-dir-picker (already initialized)
# - Skips if there are multiple windows (not a fresh session)

set -euo pipefail

# Source FZF configuration
source ~/.core/.cortex/lib/fzf-config.sh

# Get session info
session_name=$(tmux display-message -p '#{session_name}')
window_count=$(tmux display-message -p '#{session_windows}')
current_path=$(tmux display-message -p '#{pane_current_path}')

# Check if already initialized via session-dir-picker
initialized=$(tmux show-option -qv @session-dir-initialized 2>/dev/null || echo "")
[[ "$initialized" == "1" ]] && exit 0

# Skip special session patterns
case "$session_name" in
    *-view-*|ai|apps|floating) exit 0 ;;
esac

# Skip if not a fresh session (more than 1 window)
[[ "$window_count" != "1" ]] && exit 0

# Skip if already in a meaningful directory (not $HOME)
[[ "$current_path" != "$HOME" ]] && exit 0

# Configuration
readonly DEFAULT_FIND_PATH="$HOME/.core"
readonly MAX_DEPTH=3

# Preview script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Home path replacement for display
home_replacer=""
[[ "$HOME" =~ ^[a-zA-Z0-9_/.@-]+$ ]] && home_replacer="s|^$HOME/|~/|"

# FZF bindings for switching modes
zoxide_bind="ctrl-j:change-prompt(  )+reload(zoxide query -l | sed -e \"$home_replacer\")"
find_bind="ctrl-f:change-prompt(  )+reload(fd -H -d $MAX_DEPTH -t d . $DEFAULT_FIND_PATH | sed 's|/$||' | sed -e \"$home_replacer\")"

get_directories() {
    # Start with zoxide results (most relevant)
    zoxide query -l 2>/dev/null | sed -e "$home_replacer"
}

main() {
    local result

    result=$(get_directories | fzf-tmux -p 90%,90% \
        --prompt "  " \
        --header "   New Session: $session_name - Choose working directory
^f fd  ^j zoxide  ^/ preview  Enter select  Esc skip" \
        --preview "$SCRIPT_DIR/preview-dir.sh {}" \
        --preview-window "right:70%:wrap" \
        --color="$(fzf::colors)" \
        --bind "$zoxide_bind" \
        --bind "$find_bind" \
        --bind "ctrl-/:toggle-preview" \
        --bind "tab:down,btab:up" \
        --no-sort \
        --cycle \
        --delimiter='/' \
        --with-nth="-2,-1" \
        --keep-right \
        --border-label "   Session Setup") || {
        local exit_code=$?
        # User cancelled - mark as initialized anyway so we don't prompt again
        tmux set-option @session-dir-initialized 1
        exit 0
    }

    [[ -z "$result" ]] && {
        tmux set-option @session-dir-initialized 1
        exit 0
    }

    # Expand ~ back to $HOME
    local dir="$result"
    [[ -n "$home_replacer" ]] && dir=$(echo "$dir" | sed -e "s|^~/|$HOME/|")

    # Add to zoxide
    zoxide add "$dir" &>/dev/null || true

    # Change current pane directory
    tmux send-keys "cd '$dir' && clear" Enter

    # Rename window to directory basename
    local window_name
    window_name=$(basename "$dir" | tr ' .:' '_')
    tmux rename-window "$window_name"

    # Mark as initialized
    tmux set-option @session-dir-initialized 1

    tmux display-message "Session directory: $dir"
}

main "$@"
