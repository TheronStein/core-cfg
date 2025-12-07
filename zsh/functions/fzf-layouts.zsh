#!/usr/bin/env zsh
# fzf-layouts.zsh - Legacy compatibility wrapper
# This file provides backwards compatibility with the old fzf-layout-switcher
# The actual implementation is now in fzf-theme
#
# Location: $CORE_CFG/zsh/functions/fzf-layouts.zsh

# Source the main theme system if not already loaded
if ! (( $+functions[fzf-layout-select] )); then
    source "${CORE_CFG:-$HOME/.core/.sys/cfg}/zsh/functions/fzf-theme"
fi

# Legacy function name - redirects to new system
fzf-layout-switcher() {
    echo "Note: fzf-layout-switcher is now fzf-appearance"
    echo "Use 'fzf-themes' for color themes, 'fzf-layouts' for layouts"
    echo ""

    # Show the combined appearance selector
    fzf-appearance
}

# Quick access functions for common operations
fzf-quick-theme() {
    local theme="${1:-}"
    if [[ -z "$theme" ]]; then
        fzf-theme-select
    else
        fzf-theme-apply "$theme"
    fi
}

fzf-quick-layout() {
    local layout="${1:-}"
    if [[ -z "$layout" ]]; then
        fzf-layout-select
    else
        fzf-layout-apply "$layout"
    fi
}

# Interactive live preview mode - cycle through themes
fzf-theme-preview() {
    echo "FZF Theme Live Preview"
    echo "======================"
    echo ""
    echo "Press Enter to apply current theme, 'n' for next, 'p' for previous, 'q' to quit"
    echo ""

    local -a themes=()
    local theme_file
    for theme_file in "${CORE_CFG:-$HOME/.core/.sys/cfg}/zsh/integrations/themes/fzf"/*.zsh(N); do
        [[ -f "$theme_file" ]] || continue
        themes+=("$theme_file")
    done

    if [[ ${#themes[@]} -eq 0 ]]; then
        echo "No themes found!"
        return 1
    fi

    local idx=1
    local total=${#themes[@]}
    local key

    while true; do
        local current="${themes[$idx]}"
        local name=$(_fzf_get_theme_name "$current")

        echo -ne "\r\033[K[$idx/$total] Theme: $name "

        # Apply theme temporarily
        local colors=$(_fzf_build_color_string "$current")
        export _FZF_THEME_COLORS="$colors"
        _fzf_rebuild_opts

        # Wait for keypress
        read -k key

        case "$key" in
            n|N|$'\e[C')  # Next or right arrow
                ((idx++))
                [[ $idx -gt $total ]] && idx=1
                ;;
            p|P|$'\e[D')  # Previous or left arrow
                ((idx--))
                [[ $idx -lt 1 ]] && idx=$total
                ;;
            q|Q|$'\e')  # Quit
                echo ""
                echo "Cancelled - reverting to saved theme"
                fzf-theme-init
                return 0
                ;;
            ''|$'\n')  # Enter - apply
                echo ""
                echo "$(basename "$current" .zsh)" > "$FZF_THEME_STATE_DIR/current-theme"
                echo "Applied: $name"
                return 0
                ;;
        esac
    done
}

# Show current theme and layout info
fzf-show-current() {
    echo "Current FZF Configuration"
    echo "========================="
    echo ""

    if [[ -f "$FZF_THEME_STATE_DIR/current-theme" ]]; then
        local theme=$(cat "$FZF_THEME_STATE_DIR/current-theme")
        echo "Color Theme: $theme"
    else
        echo "Color Theme: (default)"
    fi

    if [[ -f "$FZF_THEME_STATE_DIR/current-layout" ]]; then
        local layout=$(cat "$FZF_THEME_STATE_DIR/current-layout")
        echo "Layout: $layout"
    else
        echo "Layout: (default)"
    fi

    echo ""
    echo "FZF_DEFAULT_OPTS preview (first 5 options):"
    echo "$FZF_DEFAULT_OPTS" | tr ' ' '\n' | grep -E '^--' | head -5 | sed 's/^/  /'
}

# Aliases for backwards compatibility
alias fzf-layouts='fzf-layout-select'
alias fzf-appearance='fzf-appearance'
alias fzf-current='fzf-show-current'
alias fzf-preview-themes='fzf-theme-preview'
