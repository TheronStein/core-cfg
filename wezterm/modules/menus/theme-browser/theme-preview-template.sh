#!/usr/bin/env bash
# Theme preview template - generates a visual preview similar to Ghostty
# Shows colors, syntax highlighting, and text to demonstrate theme

set -euo pipefail

THEME_NAME="${1:-Unknown Theme}"

# Generate color palette display with actual ANSI colors
show_colors() {
    echo
    # Standard colors (0-7)
    printf " "
    for i in {0..7}; do
        printf "\033[48;5;${i}m    \033[0m "
    done
    echo

    # Bright colors (8-15)
    printf " "
    for i in {8..15}; do
        printf "\033[48;5;${i}m    \033[0m "
    done
    echo
    echo

    # Show color numbers
    printf " "
    for i in {0..7}; do
        printf "\033[38;5;${i}m%-5s\033[0m" "$i"
    done
    echo

    printf " "
    for i in {8..15}; do
        printf "\033[38;5;${i}m%-5s\033[0m" "$i"
    done
    echo
    echo
}

# Generate sample code with syntax highlighting
show_sample_code() {
    # Use actual colors for syntax highlighting
    printf "\033[38;5;12m# Sample Shell Script\033[0m\n"
    printf "\033[38;5;13mfunction\033[0m \033[38;5;11mgreet\033[0m() {\n"
    printf "    \033[38;5;13mlocal\033[0m name=\033[38;5;10m\"\${1:-World}\"\033[0m\n"
    printf "    \033[38;5;11mecho\033[0m \033[38;5;10m\"Hello, \$name!\"\033[0m\n"
    printf "\n"
    printf "    \033[38;5;12m# Colors and formatting\033[0m\n"
    printf "    \033[1;32m✓\033[0m Success!\n"
    printf "    \033[1;31m✗\033[0m Error!\n"
    printf "    \033[1;33m⚠\033[0m Warning!\n"
    printf "}\n"
    printf "\n"
    printf "\033[38;5;12m# Test with different inputs\033[0m\n"
    printf "\033[38;5;13mfor\033[0m name \033[38;5;13min\033[0m \033[38;5;10m\"Alice\"\033[0m \033[38;5;10m\"Bob\"\033[0m \033[38;5;10m\"Charlie\"\033[0m; \033[38;5;13mdo\033[0m\n"
    printf "    greet \033[38;5;10m\"\$name\"\033[0m\n"
    printf "\033[38;5;13mdone\033[0m\n"
    printf "\n"
    printf "\033[38;5;11mexit\033[0m \033[38;5;9m0\033[0m\n"
}

# Generate sample text with formatting
show_sample_text() {
    echo
    printf "Lorem ipsum dolor sit amet, \033[1mconsectetur\033[0m adipiscing elit.\n"
    printf "Cras hendrerit \033[3maliquet\033[0m turpis non dictum. Mauris pulvinar\n"
    printf "nisl sit amet \033[4mdui cursus\033[0m tempus.\n"
    echo
    printf "• \033[38;5;7mRegular text\033[0m\n"
    printf "• \033[1;38;5;15mBold text\033[0m\n"
    printf "• \033[3;38;5;14mItalic text\033[0m\n"
    printf "• \033[4;38;5;13mUnderlined text\033[0m\n"
    echo
    printf "\033[2m─────────────────────────────────────────────────────────\033[0m\n"
    echo
    printf "TABLE EXAMPLE:\n"
    printf "\033[38;5;8m┌──────────┬──────────┬──────────┐\033[0m\n"
    printf "\033[38;5;8m│\033[0m \033[1mCol 1\033[0m    \033[38;5;8m│\033[0m \033[1mCol 2\033[0m    \033[38;5;8m│\033[0m \033[1mCol 3\033[0m    \033[38;5;8m│\033[0m\n"
    printf "\033[38;5;8m├──────────┼──────────┼──────────┤\033[0m\n"
    printf "\033[38;5;8m│\033[0m   Data   \033[38;5;8m│\033[0m   More   \033[38;5;8m│\033[0m   Info   \033[38;5;8m│\033[0m\n"
    printf "\033[38;5;8m└──────────┴──────────┴──────────┘\033[0m\n"
    echo
    printf "\033[2m─────────────────────────────────────────────────────────\033[0m\n"
}

# Main preview function
main() {
    # Header with colors
    printf "\033[1;36m═══════════════════════════════════════════════════════════════\033[0m\n"
    printf "\033[1;36m  Theme Preview: \033[1;33m%s\033[0m\n" "$THEME_NAME"
    printf "\033[1;36m═══════════════════════════════════════════════════════════════\033[0m\n"
    echo
    printf "\033[1;33m⚠ Note: Colors shown here are ANSI preview only.\033[0m\n"
    printf "\033[1;33m   The ACTUAL theme is being applied to your current window!\033[0m\n"
    printf "\033[1;33m   Look at your main WezTerm window to see the real colors.\033[0m\n"
    echo

    # Color palette
    show_colors

    # Sample code
    printf "\033[1;35m─── Sample Code ───\033[0m\n"
    show_sample_code

    # Sample text
    echo
    printf "\033[1;35m─── Sample Text ───\033[0m\n"
    show_sample_text

    echo
    printf "\033[1;36m═══════════════════════════════════════════════════════════════\033[0m\n"
    printf "\033[1;32m✓ Theme '%s' is being previewed in your window\033[0m\n" "$THEME_NAME"
    printf "\033[1;32m  Press Enter to apply permanently to this workspace\033[0m\n"
    printf "\033[1;36m═══════════════════════════════════════════════════════════════\033[0m\n"
}

main "$@"
