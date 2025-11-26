#!/usr/bin/env bash
# WezTerm Tab Color Browser with FZF and live preview

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_FILE="$HOME/.core/.sys/configs/wezterm/.data/tabs/colors.json"

# Arguments from WezTerm
TAB_ID="${1:-}"
TAB_TITLE="${2:-Tab}"
TAB_ICON="${3:-}"
TMUX_WORKSPACE="${4:-}"
CALLBACK_FILE="${5:-}"

if [[ -z "$TAB_ID" ]]; then
    echo "Error: TAB_ID not provided" >&2
    exit 1
fi

if [[ -z "$CALLBACK_FILE" ]]; then
    echo "Error: CALLBACK_FILE not provided" >&2
    exit 1
fi

# Ensure dependencies
for cmd in fzf jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

# Color palette (curated colors with names)
# Format: NAME|HEX|DESCRIPTION
declare -a COLORS=(
    # Reds
    "Red|#f38ba8|Catppuccin Red - Alerts & errors"
    "Rose|#f5c2e7|Catppuccin Rose - Soft pink"
    "Maroon|#eba0ac|Catppuccin Maroon - Deep red"

    # Oranges & Yellows
    "Peach|#fab387|Catppuccin Peach - Warm orange"
    "Yellow|#f9e2af|Catppuccin Yellow - Bright yellow"

    # Greens
    "Green|#a6e3a1|Catppuccin Green - Success & terminal"
    "Teal|#94e2d5|Catppuccin Teal - Cyan-green"

    # Blues
    "Sky|#89dceb|Catppuccin Sky - Light blue"
    "Sapphire|#74c7ec|Catppuccin Sapphire - Bright blue"
    "Blue|#89b4fa|Catppuccin Blue - Primary blue"
    "Lavender|#b4befe|Catppuccin Lavender - Purple-blue"

    # Purples
    "Mauve|#cba6f7|Catppuccin Mauve - Purple accent"
    "Pink|#f5c2e7|Catppuccin Pink - Bright pink"

    # Neutrals
    "Flamingo|#f2cdcd|Catppuccin Flamingo - Light pink-gray"
    "Rosewater|#f5e0dc|Catppuccin Rosewater - Warm white"

    # Darker options
    "Surface2|#585b70|Catppuccin Surface 2 - Dark gray"
    "Overlay2|#9399b2|Catppuccin Overlay 2 - Medium gray"

    # Special
    "Default|CLEAR|Use default mode color"
)

# Save color selection to JSON file
save_color() {
    local tab_id="$1"
    local color="$2"

    mkdir -p "$(dirname "$COLORS_FILE")"

    # Load existing colors or create empty object
    local colors="{}"
    if [[ -f "$COLORS_FILE" ]]; then
        colors=$(cat "$COLORS_FILE")
    fi

    # Update or remove the color
    if [[ "$color" == "CLEAR" ]]; then
        # Remove the tab color entry
        colors=$(echo "$colors" | jq --arg id "$tab_id" 'del(.[$id])')
    else
        # Set the tab color
        colors=$(echo "$colors" | jq --arg id "$tab_id" --arg color "$color" '.[$id] = $color')
    fi

    # Save back to file
    echo "$colors" > "$COLORS_FILE"
}

# Browse colors
browse_colors() {
    local current_selection=""

    # Build the choices list
    for entry in "${COLORS[@]}"; do
        IFS='|' read -r name hex desc <<< "$entry"
        printf "%s|%s|%s\n" "$name" "$hex" "$desc"
    done | fzf \
        --ansi \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --border-label="╣ Tab Color Picker ╠" \
        --prompt="Color ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --delimiter='|' \
        --with-nth=1,3 \
        --header=$'Tab: '"$TAB_TITLE"$'\nSelect: Enter | Clear Color: Alt-C | Quit: Esc\n─────────────────────────────────────────' \
        --preview="$SCRIPT_DIR/color-preview.sh {2} '$TAB_TITLE' '$TAB_ICON' '$TMUX_WORKSPACE'" \
        --preview-window=right:60%:wrap:rounded \
        --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
        --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
        --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
        --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
        --bind="ctrl-/:toggle-preview" \
        --bind="alt-c:execute-silent(echo 'CLEAR')+accept"
}

# Main
main() {
    # Show info about current tab
    echo "Selecting color for tab: $TAB_TITLE (ID: $TAB_ID)" >&2
    if [[ -n "$TMUX_WORKSPACE" ]]; then
        echo "Note: Tab is in tmux workspace '$TMUX_WORKSPACE' - workspace color will override custom color" >&2
    fi

    selected=$(browse_colors)

    if [[ -z "$selected" ]]; then
        echo "No color selected" >&2
        exit 0
    fi

    # Handle clear command
    if [[ "$selected" == "CLEAR" ]]; then
        save_color "$TAB_ID" "CLEAR"
        # Write to callback file for WezTerm to pick up
        echo "CLEAR" > "$CALLBACK_FILE"
        echo "Cleared custom color for tab $TAB_ID" >&2
        exit 0
    fi

    # Extract color hex from selection
    IFS='|' read -r name hex desc <<< "$selected"

    if [[ "$hex" == "CLEAR" ]]; then
        save_color "$TAB_ID" "CLEAR"
        # Write to callback file for WezTerm to pick up
        echo "CLEAR" > "$CALLBACK_FILE"
        echo "Reset to default color for tab $TAB_ID" >&2
    else
        save_color "$TAB_ID" "$hex"
        # Write to callback file for WezTerm to pick up
        echo "$hex" > "$CALLBACK_FILE"
        echo "Set tab $TAB_ID color to $name ($hex)" >&2
    fi
}

main
