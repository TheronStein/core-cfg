#!/usr/bin/env bash
# WezTerm Tab Color Browser with FZF and live preview

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEZTERM_CONFIG_DIR="${WEZTERM_CONFIG_DIR:-$HOME/.core/.sys/cfg/wezterm}"
COLORS_FILE="$WEZTERM_CONFIG_DIR/.data/tabs/colors.json"

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
    "Red Dark|#dc8a78|Darker red - Muted alerts"
    "Maroon|#eba0ac|Catppuccin Maroon - Deep red"
    "Maroon Dark|#e8a2af|Darker maroon - Wine"

    # Pinks & Roses
    "Rose|#f5c2e7|Catppuccin Rose - Soft pink"
    "Pink|#f5c2e7|Catppuccin Pink - Bright pink"
    "Flamingo|#f2cdcd|Catppuccin Flamingo - Light pink-gray"
    "Rosewater|#f5e0dc|Catppuccin Rosewater - Warm white"

    # Oranges
    "Peach|#fab387|Catppuccin Peach - Warm orange"
    "Peach Dark|#ef9f76|Darker peach - Burnt orange"
    "Orange|#fe640b|Pure orange - High energy"
    "Coral|#ff7f50|Coral - Tropical"

    # Yellows
    "Yellow|#f9e2af|Catppuccin Yellow - Bright yellow"
    "Yellow Dark|#e5c890|Darker yellow - Mustard"
    "Gold|#ffd700|Gold - Metallic"
    "Amber|#ffbf00|Amber - Rich yellow"

    # Greens
    "Green|#a6e3a1|Catppuccin Green - Success & terminal"
    "Green Dark|#a6d189|Darker green - Forest"
    "Teal|#94e2d5|Catppuccin Teal - Cyan-green"
    "Teal Dark|#81c8be|Darker teal - Ocean"
    "Mint|#98d8c8|Mint - Fresh green"
    "Lime|#a8d545|Lime - Bright green"

    # Cyans
    "Sky|#89dceb|Catppuccin Sky - Light blue"
    "Sky Dark|#99d1db|Darker sky - Muted cyan"
    "Cyan|#00ffff|Pure cyan - Electric"
    "Aqua|#00ced1|Aqua - Deep cyan"

    # Blues
    "Sapphire|#74c7ec|Catppuccin Sapphire - Bright blue"
    "Sapphire Dark|#85c1dc|Darker sapphire - Deep blue"
    "Blue|#89b4fa|Catppuccin Blue - Primary blue"
    "Blue Dark|#8caaee|Darker blue - Navy-ish"
    "Azure|#007fff|Azure - True blue"
    "Cobalt|#0047ab|Cobalt - Deep blue"

    # Purples & Lavenders
    "Lavender|#b4befe|Catppuccin Lavender - Purple-blue"
    "Lavender Dark|#babbf1|Darker lavender - Muted purple"
    "Mauve|#cba6f7|Catppuccin Mauve - Purple accent"
    "Mauve Dark|#ca9ee6|Darker mauve - Deep purple"
    "Purple|#9b59d0|Pure purple - Violet"
    "Magenta|#ff00ff|Magenta - Hot pink-purple"
    "Violet|#8b00ff|Violet - Rich purple"

    # Browns & Earthy
    "Brown|#8b4513|Brown - Earthy"
    "Chocolate|#d2691e|Chocolate - Rich brown"
    "Tan|#d2b48c|Tan - Light brown"
    "Sienna|#a0522d|Sienna - Reddish brown"

    # Grays & Neutrals
    "Surface2|#585b70|Catppuccin Surface 2 - Dark gray"
    "Overlay2|#9399b2|Catppuccin Overlay 2 - Medium gray"
    "Overlay1|#7f849c|Catppuccin Overlay 1 - Lighter gray"
    "Surface1|#45475a|Catppuccin Surface 1 - Darker gray"
    "Base|#1e1e2e|Catppuccin Base - Almost black"
    "Mantle|#181825|Catppuccin Mantle - Very dark"
    "Crust|#11111b|Catppuccin Crust - Darkest"
    "Silver|#c0c0c0|Silver - Light gray"
    "Slate|#708090|Slate - Cool gray"

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
