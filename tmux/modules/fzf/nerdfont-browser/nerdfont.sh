#!/bin/bash
# File: nerd-font-browser.sh
# Function: Main Nerd Font icon browser with category selection and tmux popup integration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Category definitions with their corresponding files
declare -A CATEGORIES=(
    ["Angles & Arrows"]="nerd-angle.sh"
    ["Blocks & Shapes"]="nerd-blocks.sh"
    ["Brackets & Braces"]="nerd-bracks.sh"
    ["Circular Icons"]="nerd-cirtcular.sh"
    ["Diamond Shapes"]="nerd-diamond.sh"
    ["GitHub & Git"]="nerd-github.sh"
    ["General Icons"]="nerd-icons.sh"
    ["Lines & Borders"]="nerd-lines.sh"
    ["Powerline Symbols"]="nerd-powerline.sh"
    ["Square Shapes"]="nerd-square.sh"
)

# Generate preview for bat
generate_preview() {
    local category_file="$1"
    local file_path="$SCRIPT_DIR/$category_file"

    if [[ -f "$file_path" ]]; then
        # Create a temporary file with syntax highlighting
        local temp_file="/tmp/nerd-preview-$$.txt"

        # Add header and format for better viewing
        {
            echo "# Icons in this category:"
            echo ""
            grep -v '^#' "$file_path" | head -20 | while IFS= read -r line; do
                if [[ -n "$line" ]]; then
                    # Extract icon and description
                    icon=$(echo "$line" | awk '{print $1}')
                    desc=$(echo "$line" | cut -d' ' -f2-)
                    echo "   $icon  $desc"
                fi
            done

            # Show total count
            local total=$(grep -v '^#' "$file_path" | grep -v '^$' | wc -l)
            echo ""
            echo "Total icons: $total"
        } >"$temp_file"

        # Use bat for syntax highlighting, fallback to cat
        if command -v bat >/dev/null 2>&1; then
            bat --style=numbers,header --language=bash --theme=ansi "$temp_file" 2>/dev/null || cat "$temp_file"
        else
            cat "$temp_file"
        fi

        rm -f "$temp_file"
    else
        echo "Category file not found: $category_file"
    fi
}

# Function to show icons from selected category
show_category_icons() {
    local category="$1"
    local category_file="${CATEGORIES[$category]}"
    local file_path="$SCRIPT_DIR/$category_file"

    if [[ ! -f "$file_path" ]]; then
        echo "Error: Category file not found: $file_path"
        return 1
    fi

    # Create a temporary file for the icon selection
    local temp_icons="/tmp/nerd-category-icons-$$.txt"
    grep -v '^#' "$file_path" | grep -v '^$' >"$temp_icons"

    local selected_icon
    selected_icon=$(cat "$temp_icons" | fzf \
        --preview 'echo -e "\n\n   Symbol: {1}\n\n   Unicode: {2}\n   Description: {3..}"' \
        --preview-window=up:8:wrap \
        --header="[$category] Select icon (ENTER to copy, ESC to go back)" \
        --layout=reverse \
        --height=100% \
        --ansi \
        --bind 'enter:accept' \
        --bind 'esc:abort')

    if [[ -n "$selected_icon" ]]; then
        local icon=$(echo "$selected_icon" | awk '{print $1}')
        local unicode=$(echo "$selected_icon" | awk '{print $2}')
        local desc=$(echo "$selected_icon" | cut -d' ' -f3-)

        # Copy to clipboard
        if command -v xclip >/dev/null 2>&1; then
            echo -n "$icon" | xclip -selection clipboard
            echo "Copied to clipboard: $icon ($desc)"
        elif command -v pbcopy >/dev/null 2>&1; then
            echo -n "$icon" | pbcopy
            echo "Copied to clipboard: $icon ($desc)"
        else
            echo "Icon: $icon"
            echo "Unicode: $unicode"
            echo "Description: $desc"
            echo "Note: No clipboard utility found (xclip/pbcopy)"
        fi

        # Also output to stdout for potential piping
        echo -n "$icon"
    fi

    rm -f "$temp_icons"
}

# Export the preview function for fzf
export -f generate_preview
export SCRIPT_DIR
export -A CATEGORIES

# Main category selection
main() {
    # If argument provided, go directly to that category
    if [[ -n "$1" ]] && [[ -n "${CATEGORIES[$1]}" ]]; then
        show_category_icons "$1"
        return
    fi

    # Create category list
    printf "%s\n" "${!CATEGORIES[@]}" | sort |
        fzf --preview 'generate_preview "${CATEGORIES[{}]}"' \
            --preview-window=right:60%:wrap \
            --header='Select Nerd Font category (ENTER to browse icons, ESC to exit)' \
            --layout=reverse \
            --height=100% \
            --ansi \
            --bind 'enter:accept' |
        while read -r selected_category; do
            if [[ -n "$selected_category" ]]; then
                show_category_icons "$selected_category"
            fi
        done
}

# Check if running in tmux and offer popup mode
if [[ -n "$TMUX" ]] && [[ "$1" != "--no-popup" ]]; then
    # Run in tmux popup
    exec tmux popup -E -w 120 -h 40 "$0 --no-popup $*"
else
    main "$@"
fi
