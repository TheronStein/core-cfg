#!/usr/bin/env zsh
# Debug functions for fzf issues

# Test if fzf can display a simple list
fzf-test-simple() {
    echo "Testing basic fzf functionality..."
    local result
    result=$(echo -e "Apple\nBanana\nCherry\nDate\nEggplant" | \
        fzf --prompt="Pick a fruit> " \
            --header="Use arrow keys or type to search" \
            --height=40% \
            --border=rounded)

    if [[ -n "$result" ]]; then
        echo "✓ Success! You selected: $result"
    else
        echo "✗ Cancelled or no selection"
    fi
}

# Test with FZF_DEFAULT_OPTS
fzf-test-with-defaults() {
    echo "Current FZF_DEFAULT_OPTS:"
    echo "$FZF_DEFAULT_OPTS" | head -5
    echo "..."
    echo ""
    echo "Testing with defaults..."

    local items=("First" "Second" "Third" "Fourth" "Fifth")
    local result
    result=$(printf '%s\n' "${items[@]}" | fzf --prompt="Test> ")

    if [[ -n "$result" ]]; then
        echo "✓ Selected: $result"
    else
        echo "✗ No selection"
    fi
}

# Test array population
fzf-test-array() {
    echo "Testing array population and display..."

    typeset -a test_array
    test_array=(
        "1. First option"
        "2. Second option"
        "3. Third option"
        "4. Fourth option"
    )

    echo "Array has ${#test_array[@]} elements:"
    printf '  %s\n' "${test_array[@]}"
    echo ""
    echo "Sending to fzf..."

    local result
    result=$(printf '%s\n' "${test_array[@]}" | fzf --prompt="Array Test> " --height=40%)

    if [[ -n "$result" ]]; then
        echo "✓ You picked: $result"
    else
        echo "✗ Cancelled"
    fi
}

# Check FZF environment
fzf-check-env() {
    echo "=== FZF Environment Check ==="
    echo ""
    echo "FZF binary:"
    which fzf
    fzf --version
    echo ""
    echo "FZF_DEFAULT_COMMAND:"
    echo "${FZF_DEFAULT_COMMAND:-<not set>}"
    echo ""
    echo "FZF_DEFAULT_OPTS (first 10 lines):"
    echo "$FZF_DEFAULT_OPTS" | head -10
    echo ""
    echo "In TMUX: ${TMUX:+yes}"
    echo "Terminal: $TERM"
    echo "Shell: $SHELL"
}

# Run all tests
fzf-test-all() {
    echo "═══════════════════════════════════════"
    echo "  FZF Diagnostic Test Suite"
    echo "═══════════════════════════════════════"
    echo ""

    fzf-check-env
    echo ""
    echo "─────────────────────────────────────"
    read -k "?Press any key for Test 1: Simple list..."
    echo ""
    fzf-test-simple

    echo ""
    echo "─────────────────────────────────────"
    read -k "?Press any key for Test 2: With defaults..."
    echo ""
    fzf-test-with-defaults

    echo ""
    echo "─────────────────────────────────────"
    read -k "?Press any key for Test 3: Array test..."
    echo ""
    fzf-test-array

    echo ""
    echo "═══════════════════════════════════════"
    echo "  Tests Complete"
    echo "═══════════════════════════════════════"
}
