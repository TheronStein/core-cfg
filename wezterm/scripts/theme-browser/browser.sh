#!/usr/bin/env bash
# WezTerm Keymap Browser with FZF

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
KEYMAPS_FILE="$DATA_DIR/keymaps.json"

# Ensure dependencies
for cmd in fzf jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

# Check if data exists, generate if missing
if [[ ! -f "$KEYMAPS_FILE" ]]; then
    echo "Keymap data not found. Generating..."
    "$SCRIPT_DIR/generate-data.sh" || {
        echo "Failed to generate keymap data" >&2
        exit 1
    }
fi

# Browse categories (modifier groups or key tables/modes)
browse_categories() {
    # Use TAB as delimiter since category IDs may contain | characters
    jq -r '.categories[] | "\(.id)\t\(.name)\t\(.description)\t\(.count)\t\(.is_key_table)"' "$KEYMAPS_FILE" |
        while IFS=$'\t' read -r id name desc count is_key_table; do
            local icon="⌨"
            [[ "$is_key_table" == "true" ]] && icon="⚡"

            # Format: ID<TAB>icon name | description (count)
            # We include ID at the start so we can extract it reliably
            printf "%s\t%s %s | %s (%d)\n" "$id" "$icon" "$name" "$desc" "$count"
        done |
        fzf \
            --ansi \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ WezTerm Keymaps ╠" \
            --prompt="Category ❯ " \
            --pointer="▶" \
            --marker="✓" \
            --delimiter=$'\t' \
            --with-nth=2 \
            --header=$'Navigate: ↑↓ PageUp/PageDown | Select: Enter | Quit: Esc\nLeader Key: Super+Space (1000ms timeout)\n─────────────────────────────────────────' \
            --preview="$SCRIPT_DIR/keymap-preview.sh category {2}" \
            --preview-window=right:60%:wrap:rounded \
            --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
            --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
            --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
            --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
            --bind="ctrl-/:toggle-preview"
}

# Browse keybindings within a category
browse_keybinds() {
    local category_name="$1"
    local category_id="$2"

    jq -r --arg id "$category_id" \
        '.categories[] | select(.id == $id) | .keybinds[] | "\(.display)|\(.description)"' \
        "$KEYMAPS_FILE" |
        while IFS='|' read -r display description; do
            printf "%-25s  %s\n" "$display" "$description"
        done |
        fzf \
            --ansi \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ $category_name ╠" \
            --prompt="Keybind ❯ " \
            --pointer="▶" \
            --marker="✓" \
            --header=$'Back: Esc/Alt+← | Preview: Ctrl-/ | PageUp/PageDown\n─────────────────────────────────────────' \
            --preview="$SCRIPT_DIR/keymap-preview.sh keybind {}" \
            --preview-window=right:60%:wrap:rounded \
            --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
            --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
            --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
            --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
            --bind="ctrl-/:toggle-preview" \
            --bind="alt-left:abort"
}

# Main loop
main() {
    while true; do
        # Browse categories
        selected=$(browse_categories)

        if [[ -z "$selected" ]]; then
            break
        fi

        # Extract category ID (first field before TAB)
        category_id=$(echo "$selected" | cut -f1)

        # Extract display name for the header (second field, remove icon)
        category_display=$(echo "$selected" | cut -f2 | cut -d'|' -f1 | xargs)
        category_name="${category_display#* }"

        if [[ -z "$category_id" ]]; then
            echo "Error: Could not extract category ID from selection" >&2
            sleep 2
            continue
        fi

        # Browse keybinds in selected category (allow abort without exiting script)
        keybind_result=$(browse_keybinds "$category_name" "$category_id" || true)

        # If a keybind was selected, we could copy it or show more info
        # For now, just return to category list
    done
}

main
