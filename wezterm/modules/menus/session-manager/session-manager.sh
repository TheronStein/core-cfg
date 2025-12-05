#!/usr/bin/env bash
# WezTerm Session Manager with FZF

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEZTERM_CONFIG_DIR="${WEZTERM_CONFIG_DIR:-$HOME/.config/wezterm}"

# Arguments from WezTerm
CALLBACK_FILE="${1:-}"

if [[ -z "$CALLBACK_FILE" ]]; then
    echo "Error: CALLBACK_FILE not provided" >&2
    exit 1
fi

# Ensure dependencies
for cmd in fzf; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

# Menu items
# Format: ID|LABEL
declare -a MENU_ITEMS=(
    "header_management|─── 📋 MANAGEMENT ───"
    "workspace_management|🌐 Workspace Management"
    "tab_management|📑 Tab Management"
    "tab_metadata|📊 Tab Metadata Browser"
    "pane_management|🪟 Pane Management"
    "tmux_management|🖥️  TMUX Management"
    "header_customization|─── 🎨 CUSTOMIZATION ───"
    "tab_color|🎨 Set Tab Color"
    "keymaps|⌨️  Keymaps"
    "themes|🎨 Themes"
    "nerdfont_picker|🔤 Nerdfont Picker"
)

# Show main menu
show_main_menu() {
    printf "%s\n" "${MENU_ITEMS[@]}" \
        | fzf \
            --ansi \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ Session Manager ╠" \
            --prompt="Select ❯ " \
            --pointer="▶" \
            --marker="✓" \
            --delimiter='|' \
            --with-nth=2 \
            --header=$'Navigate: ↑↓ | Select: Enter | Toggle Preview: Ctrl+/ | Quit: Esc\n─────────────────────────────────────────' \
            --preview="$SCRIPT_DIR/preview.sh {1}" \
            --preview-window=right:60%:wrap:rounded \
            --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
            --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
            --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
            --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
            --bind="ctrl-/:toggle-preview"
}

# Main
selected=$(show_main_menu)

if [[ -n "$selected" ]]; then
    # Extract action ID (first field before |)
    action_id=$(echo "$selected" | cut -d'|' -f1)

    # Skip if header was selected
    if [[ "$action_id" =~ ^header_ ]]; then
        exit 1
    fi

    # Write selection to callback file
    echo "$action_id" > "$CALLBACK_FILE"
else
    # User cancelled
    exit 1
fi
