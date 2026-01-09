#!/usr/bin/env bash
# Keybinds Browser - FZF-based tmux keybinding explorer
# Location: ~/.tmux/modules/fzf/pickers/keybinds-browser.sh
# Usage: keybinds-browser.sh [--table=prefix|root|copy-mode|copy-mode-vi|all]
#
# Tables:
#   prefix       - Prefix key table (default)
#   root         - Root key table (no prefix)
#   copy-mode    - Emacs copy mode bindings
#   copy-mode-vi - Vi copy mode bindings
#   all          - All key tables

set -euo pipefail

# Source libraries
source ~/.core/.cortex/lib/fzf-config.sh

# Parse arguments
TABLE="all"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --table=*) TABLE="${1#*=}"; shift ;;
        -t) TABLE="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Get keybindings
get_keybindings() {
    local table="$1"

    if [[ "$table" == "all" ]]; then
        # Get all key tables
        tmux list-keys 2>/dev/null
    else
        # Get specific table
        tmux list-keys -T "$table" 2>/dev/null
    fi | while read -r line; do
        # Parse: bind-key [-T table] key command
        # Format for display
        local key_table key command

        if [[ "$line" =~ ^bind-key\ -T\ ([^ ]+)\ ([^ ]+)\ (.+)$ ]]; then
            key_table="${BASH_REMATCH[1]}"
            key="${BASH_REMATCH[2]}"
            command="${BASH_REMATCH[3]}"
        elif [[ "$line" =~ ^bind-key\ ([^ ]+)\ (.+)$ ]]; then
            key_table="prefix"
            key="${BASH_REMATCH[1]}"
            command="${BASH_REMATCH[2]}"
        else
            continue
        fi

        # Truncate long commands
        local short_cmd="$command"
        [[ ${#short_cmd} -gt 50 ]] && short_cmd="${short_cmd:0:47}..."

        # Color code by table
        local table_display
        case "$key_table" in
            prefix)       table_display="[prefix]     " ;;
            root)         table_display="[root]       " ;;
            copy-mode)    table_display="[copy]       " ;;
            copy-mode-vi) table_display="[copy-vi]    " ;;
            *)            table_display="[$key_table]" ;;
        esac

        printf "%-14s %-12s %s\n" "$table_display" "$key" "$short_cmd"
    done
}

# Preview: show binding details and related bindings
preview_keybind() {
    local line="$1"

    # Parse the line
    local key_table key
    key_table=$(echo "$line" | awk '{print $1}' | tr -d '[]')
    key=$(echo "$line" | awk '{print $2}')

    echo -e "\033[1;34m═══ Keybinding Details ═══\033[0m"
    echo ""

    echo -e "\033[1;33m Table:\033[0m $key_table"
    echo -e "\033[1;33m Key:\033[0m $key"
    echo ""

    # Get full command
    echo -e "\033[1;33m Full Command:\033[0m"
    echo "─────────────────────────────────────"

    local table_arg=""
    [[ "$key_table" != "prefix" ]] && table_arg="-T $key_table"

    tmux list-keys $table_arg "$key" 2>/dev/null | while read -r cmd; do
        # Remove bind-key prefix
        echo "$cmd" | sed 's/^bind-key //'
    done

    echo "─────────────────────────────────────"
    echo ""

    # Show related bindings (same key, different tables)
    echo -e "\033[1;36m Related Bindings:\033[0m"
    local found_related=false

    for t in prefix root copy-mode copy-mode-vi; do
        [[ "$t" == "$key_table" ]] && continue
        local related
        related=$(tmux list-keys -T "$t" 2>/dev/null | grep -E "bind-key -T $t $key " || true)
        if [[ -n "$related" ]]; then
            echo "  [$t] $key → $(echo "$related" | sed "s/bind-key -T $t $key //")"
            found_related=true
        fi
    done

    [[ "$found_related" == "false" ]] && echo "  (none)"

    echo ""
    echo -e "\033[1;90m───────────────────────────────\033[0m"
    echo -e "\033[1;90m Press Enter to copy key name\033[0m"

    # Decode special keys
    echo ""
    echo -e "\033[1;33m Key Notation:\033[0m"
    case "$key" in
        C-*) echo "  Ctrl + ${key#C-}" ;;
        M-*) echo "  Alt/Meta + ${key#M-}" ;;
        S-*) echo "  Shift + ${key#S-}" ;;
        *) echo "  $key" ;;
    esac
}
export -f preview_keybind

# Header
case "$TABLE" in
    prefix)       HEADER="Prefix Key Bindings (C-Space + key)" ;;
    root)         HEADER="Root Key Bindings (no prefix)" ;;
    copy-mode)    HEADER="Copy Mode Bindings (emacs)" ;;
    copy-mode-vi) HEADER="Copy Mode Bindings (vi)" ;;
    all)          HEADER="All Key Bindings (filter by table name)" ;;
esac

# Run FZF
SELECTED=$(get_keybindings "$TABLE" | fzf \
    --ansi \
    --height=90% \
    --layout=reverse \
    --border=rounded \
    --color="$(fzf::colors)" \
    --preview='bash -c "preview_keybind {}"' \
    --preview-window=right:50%:wrap \
    --header="$HEADER (ESC to cancel)" \
    --prompt="Key> " \
    --bind="esc:cancel" \
    --bind="ctrl-p:reload(bash -c 'source ~/.core/.cortex/lib/fzf-config.sh; $(declare -f get_keybindings); get_keybindings prefix')+change-prompt(Prefix> )" \
    --bind="ctrl-r:reload(bash -c 'source ~/.core/.cortex/lib/fzf-config.sh; $(declare -f get_keybindings); get_keybindings root')+change-prompt(Root> )" \
    --bind="ctrl-v:reload(bash -c 'source ~/.core/.cortex/lib/fzf-config.sh; $(declare -f get_keybindings); get_keybindings copy-mode-vi')+change-prompt(CopyVi> )" \
    --bind="ctrl-a:reload(bash -c 'source ~/.core/.cortex/lib/fzf-config.sh; $(declare -f get_keybindings); get_keybindings all')+change-prompt(All> )" \
) || exit 0

# Extract key for clipboard
KEY_NAME=$(echo "$SELECTED" | awk '{print $2}')

[[ -z "$KEY_NAME" ]] && exit 0

# Copy key name to tmux buffer
echo -n "$KEY_NAME" | tmux load-buffer -
tmux display-message "Copied to buffer: $KEY_NAME"
