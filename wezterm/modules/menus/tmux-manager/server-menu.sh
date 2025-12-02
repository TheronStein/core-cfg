#!/usr/bin/env bash
# WezTerm TMUX Manager - Server Management Menu

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Arguments from WezTerm
CALLBACK_FILE="${1:-}"
SERVER_SOCKET="${2:-}"
SERVER_NAME="${3:-TMUX Server}"

if [[ -z "$CALLBACK_FILE" ]]; then
    echo "Error: CALLBACK_FILE not provided" >&2
    exit 1
fi

if [[ -z "$SERVER_SOCKET" ]]; then
    echo "Error: SERVER_SOCKET not provided" >&2
    exit 1
fi

# Menu items
declare -a MENU_ITEMS=(
    "back|← Back to Servers List"
    "separator0|─────────────────────────────"
    "header|─── 📋 MANAGE $SERVER_NAME ───"
    "create_session|➕ Create New Session"
    "choose_icon|🎨 Choose Server Icon"
    "choose_color|🌈 Choose Server Color"
    "jump_config|⚙️  Jump to Config"
    "separator1|─────────────────────────────"
    "list_sessions|📺 List Sessions"
)

# Show menu
show_menu() {
    printf "%s\n" "${MENU_ITEMS[@]}" \
        | fzf \
            --ansi \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ TMUX Manager > $SERVER_NAME ╠" \
            --prompt="Select ❯ " \
            --pointer="▶" \
            --marker="✓" \
            --delimiter='|' \
            --with-nth=2 \
            --header=$'Navigate: ↑↓ | Select: Enter | Quit: Esc\n─────────────────────────────────────────' \
            --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
            --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
            --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
            --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4"
}

# Main
selected=$(show_menu)

if [[ -n "$selected" ]]; then
    action_id=$(echo "$selected" | cut -d'|' -f1)

    # Skip if separator or header was selected
    if [[ "$action_id" =~ ^(separator|header) ]]; then
        exit 1
    fi

    echo "$action_id" > "$CALLBACK_FILE"
else
    exit 1
fi
