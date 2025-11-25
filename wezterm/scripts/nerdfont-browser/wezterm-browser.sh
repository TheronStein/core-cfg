#!/usr/bin/env bash
# WezTerm Nerd Font Browser with FZF and WezTerm nerdfonts integration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
CATEGORIES_FILE="$DATA_DIR/categories.json"
WEZTERM_NERDFONT_DATA="$HOME/.core/.sys/configs/wezterm/.data/wezterm_nerdfont_names.txt"

# Ensure dependencies
for cmd in fzf jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

# Check if data exists
if [[ ! -f "$CATEGORIES_FILE" ]]; then
    echo "Error: Categories file not found: $CATEGORIES_FILE"
    echo "Run: python3 $SCRIPT_DIR/generate-wezterm-data.py"
    exit 1
fi

# Get WezTerm nerdfonts icon by name
get_icon() {
    local name="$1"
    # Use WezTerm to render the icon
    wezterm -n --config "$(cat <<EOF
local wezterm = require('wezterm')
local nf = wezterm.nerdfonts
local icon = nf.$name or "?"
wezterm.log_info(icon)
print(icon)
return {}
EOF
)" 2>&1 | grep -v '^[0-9]' | tail -1 || echo "?"
}

# Browse categories
browse_categories() {
    jq -r '.categories[] | "\(.name)|\(.icon_name)|\(.description)|\(.count)"' "$CATEGORIES_FILE" |
        while IFS='|' read -r name icon_name desc count; do
            # Use | as delimiter so we can extract exact name
            printf "%s | %s (%d)\n" "$name" "$desc" "$count"
        done |
        fzf \
            --ansi \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ WezTerm Nerd Fonts Categories ╠" \
            --prompt="Category ❯ " \
            --pointer="▶" \
            --marker="✓" \
            --delimiter=' | ' \
            --with-nth=1,2 \
            --header=$'Navigate: ↑↓ PageUp/PageDown | Select: Enter | Quit: Esc\n─────────────────────────────────────────' \
            --preview="$SCRIPT_DIR/wezterm-preview.sh category {}" \
            --preview-window=right:60%:wrap:rounded \
            --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
            --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
            --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
            --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
            --bind="ctrl-/:toggle-preview"
}

# Browse icons within a category
browse_icons() {
    local category_name="$1"
    local file_name="$2"
    local file_path="$DATA_DIR/$file_name"
    local mapping_file="$DATA_DIR/icon-name-to-glyph.txt"

    if [[ ! -f "$file_path" ]]; then
        echo "Error: File not found: $file_path" >&2
        return 1
    fi

    # Read icon names and show glyph + name
    grep -v '^#' "$file_path" | grep -v '^$' |
        while read -r icon_name; do
            # Look up the glyph from mapping file
            local glyph="?"
            if [[ -f "$mapping_file" ]]; then
                glyph=$(grep "^${icon_name}[[:space:]]" "$mapping_file" | cut -f2)
                [[ -z "$glyph" ]] && glyph="?"
            fi
            # Show: glyph  icon_name
            printf "%s  %s\n" "$glyph" "$icon_name"
        done |
        fzf \
            --ansi \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ $category_name ╠" \
            --prompt="Icon ❯ " \
            --pointer="▶" \
            --marker="✓" \
            --header=$'Select: Enter (copy) | Back: Esc/Alt+← | Preview: Ctrl-/ | PageUp/PageDown\n─────────────────────────────────────────' \
            --preview="$SCRIPT_DIR/wezterm-preview.sh icon {}" \
            --preview-window=right:60%:wrap:rounded \
            --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
            --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
            --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
            --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
            --bind="ctrl-/:toggle-preview" \
            --bind="alt-left:abort" \
            --bind="enter:execute-silent($SCRIPT_DIR/copy-icon.sh {})+accept"
}

# Main loop
main() {
    while true; do
        # Browse categories
        selected=$(browse_categories)

        if [[ -z "$selected" ]]; then
            break
        fi

        # Extract category name (field 1 with delimiter ' | ')
        category_name=$(echo "$selected" | cut -d'|' -f1 | xargs)

        # Get file name from JSON
        file_name=$(jq -r --arg name "$category_name" \
            '.categories[] | select(.name == $name) | .file' "$CATEGORIES_FILE")

        if [[ -z "$file_name" ]]; then
            echo "Error: Could not find file for category: '$category_name'" >&2
            sleep 2
            continue
        fi

        # Browse icons in selected category (allow abort without exiting script)
        icon_result=$(browse_icons "$category_name" "$file_name" || true)

        if [[ -n "$icon_result" ]]; then
            # Icon was selected and copied, exit the browser
            break
        fi
    done
}

main
