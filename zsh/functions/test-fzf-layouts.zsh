#!/usr/bin/env zsh
# Simple test version of fzf layout switcher

test-fzf-layouts() {
    echo "Starting test-fzf-layouts..."

    # Simple array of options
    local -a layouts=(
        "1. Classic reverse"
        "2. With margin and padding"
        "3. Sharp borders"
        "4. Reverse-list"
        "5. Minimal floating"
        "6. Fancy themed"
        "7. Default reset"
    )

    echo "Array contains ${#layouts[@]} items"
    echo "Items:"
    printf '  %s\n' "${layouts[@]}"
    echo ""
    echo "Calling fzf now..."

    local selection
    selection=$(printf '%s\n' "${layouts[@]}" | fzf \
        --prompt='Test Layout> ' \
        --header='Simple test - do you see these options?' \
        --height=50% \
        --border=rounded)

    if [[ -n "$selection" ]]; then
        echo "You selected: $selection"
    else
        echo "No selection made"
    fi
}

# Also create a minimal test without any variables
fzf-minimal-test() {
    echo "one" "two" "three" | tr ' ' '\n' | fzf --prompt="Minimal> " --height=40%
}
