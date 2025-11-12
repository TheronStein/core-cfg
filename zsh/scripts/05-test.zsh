#!/bin/bash

echo "Final Configuration Test"
echo "========================"

# Test categories
categories=(
    "ZLE:zle-keymap-select:ZLE widgets"
    "Tools:aws-profile:Cloud tools"
    "Session:bookmark:Session management"
    "Utils:urlencode:Utilities"
    "Optimize:compile-zsh-files:Optimizations"
)

for category in "${categories[@]}"; do
    IFS=':' read -r name func desc <<< "$category"
    echo -e "\n=== $desc ==="
    if zsh -ic "type $func &>/dev/null"; then
        echo "  ✓ $name functions loaded"
    else
        echo "  ✗ $name functions missing"
    fi
done

echo -e "\n=== Final Statistics ==="
zsh -ic '
    echo "Total functions: $(print -l ${(ok)functions} | wc -l)"
    echo "Total aliases: $(print -l ${(ok)aliases} | wc -l)"
    echo "Total keybindings: $(bindkey | wc -l)"
    echo "Completion functions: $(print -l $_comps | wc -l)"
'

echo -e "\n=== Startup Performance ==="
hyperfine --warmup 3 --min-runs 10 'zsh -ic exit' 2>/dev/null || time zsh -ic exit
