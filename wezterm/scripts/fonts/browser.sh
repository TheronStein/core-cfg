#!/usr/bin/env bash

# Nerd Font Browser with FZF
set -euo pipefail

FONTS_DIR="${NERD_FONTS_DIR:-$HOME/.core/tbin/fonts}"
PREVIEW_SCRIPT="$FONTS_DIR/preview.sh"
CATEGORIES_FILE="$FONTS_DIR/categories.json"

# Ensure dependencies
for cmd in fzf jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

# Make preview script executable
chmod +x "$PREVIEW_SCRIPT"

# Function to browse categories
browse_categories() {
    jq -r '.categories[] | "\(.name)|\(.icon)|\(.description)"' "$CATEGORIES_FILE" |
        while IFS='|' read -r name icon desc; do
            printf "%-30s %s  %s\n" "$name" "$icon" "$desc"
        done |
        fzf \
            --ansi \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ Nerd Font Categories ╠" \
            --prompt="Category ❯ " \
            --pointer="▶" \
            --marker="✓" \
            --header=$'Navigate: ↑↓ | Select: Enter | Quit: Esc\n─────────────────────────────────────────' \
            --preview='cat_name=$(echo {} | sed -E "s/^([^[:space:]]+(\s+[^[:space:]]+)*)\s+.*/\1/" | sed "s/[[:space:]]*$//"); bash '"$PREVIEW_SCRIPT"' category "$cat_name"' \
            --preview-window=right:60%:wrap:rounded \
            --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
            --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
            --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
            --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
            --bind="ctrl-/:toggle-preview"
}

# Function to browse icons within a category
browse_icons() {
    local category_name="$1"
    local file_name="$2"
    local file_path="$FONTS_DIR/$file_name"

    if [[ ! -f "$file_path" ]]; then
        echo "Error: File not found: $file_path" >&2
        return 1
    fi

    # Get category color
    local color_name=$(jq -r --arg name "$category_name" \
        '.categories[] | select(.name == $name) | .color' "$CATEGORIES_FILE")

    grep -E '^[0-9]' "$file_path" |
        fzf \
            --ansi \
            --height=100% \
            --layout=reverse \
            --border=rounded \
            --border-label="╣ $category_name ╠" \
            --prompt="Icon ❯ " \
            --pointer="▶" \
            --marker="✓" \
            --header=$'Select: Enter (copy) | Back: Esc | Preview: Ctrl-/\n─────────────────────────────────────────' \
            --preview="$PREVIEW_SCRIPT icon {}" \
            --preview-window=right:60%:wrap:rounded \
            --with-nth=3 \
            --delimiter=' ' \
            --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
            --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
            --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
            --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
            --bind="ctrl-/:toggle-preview" \
            --bind="enter:execute-silent(echo -n {3} | xclip -selection clipboard 2>/dev/null || echo -n {3} | pbcopy 2>/dev/null)+accept" \
            --bind="ctrl-u:execute-silent(echo -n {2} | xclip -selection clipboard 2>/dev/null || echo -n {2} | pbcopy 2>/dev/null)" \
            --bind="ctrl-d:execute-silent(echo -n {1} | xclip -selection clipboard 2>/dev/null || echo -n {1} | pbcopy 2>/dev/null)"
}

# Main loop
main() {
    while true; do
        # Browse categories
        selected=$(browse_categories)

        if [[ -z "$selected" ]]; then
            # User pressed ESC or cancelled
            break
        fi

        # Extract the category name properly (handles multi-word names)
        # This regex captures everything up to the icon (before multiple spaces)
        category_name=$(echo "$selected" | sed -E 's/^([^[:space:]]+(\s+[^[:space:]]+)*)\s+.*/\1/' | sed 's/[[:space:]]*$//')

        # Debug output
        # echo "Selected: '$selected'" >&2
        # echo "Extracted category: '$category_name'" >&2

        # Get file name from JSON using the extracted category name
        file_name=$(jq -r --arg name "$category_name" \
            '.categories[] | select(.name == $name) | .file' "$CATEGORIES_FILE")

        if [[ -z "$file_name" ]]; then
            echo "Error: Could not find file for category: '$category_name'" >&2
            sleep 2
            continue
        fi

        # Browse icons in selected category
        icon_result=$(browse_icons "$category_name" "$file_name")

        if [[ -n "$icon_result" ]]; then
            # Icon was selected and copied
            glyph=$(echo "$icon_result" | awk '{print $3}')

            # If we're in tmux, send the glyph to the previous pane
            if [[ -n "${TMUX:-}" ]]; then
                tmux send-keys -t '{last}' "$glyph"
                echo "Sent '$glyph' to previous pane"
                sleep 0.5
                break
            else
                echo "Copied '$glyph' to clipboard"
                sleep 0.5
            fi
        fi
    done
}

# Run main function
main
