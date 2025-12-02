#!/usr/bin/env bash
# WezTerm Actions - Keymaps Submenu

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEZTERM_CONFIG_DIR="${WEZTERM_CONFIG_DIR:-$HOME/.config/wezterm}"
WEZTERM_SCRIPTS="${WEZTERM_SCRIPTS:-$WEZTERM_CONFIG_DIR/scripts}"

# Arguments from WezTerm
CALLBACK_FILE="${1:-}"

if [[ -z "$CALLBACK_FILE" ]]; then
    echo "Error: CALLBACK_FILE not provided" >&2
    exit 1
fi

# Menu items
declare -a MENU_ITEMS=(
    "edit_keymaps|✏️  Edit Keymaps in Neovim"
    "list_keymaps|📋 List Keymaps (Browser)"
    "back|← Back to Actions Menu"
)

# Show keymaps menu
show_keymaps_menu() {
    printf "%s\n" "${MENU_ITEMS[@]}" \
        | fzf \
            --ansi \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ Session Manager > Actions > Keymaps ╠" \
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
selected=$(show_keymaps_menu)

if [[ -n "$selected" ]]; then
    action_id=$(echo "$selected" | cut -d'|' -f1)
    echo "$action_id" > "$CALLBACK_FILE"
else
    exit 1
fi
