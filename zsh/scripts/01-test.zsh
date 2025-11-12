#!/bin/bash

echo "Extended Configuration Test"
echo "==========================="

# Test functions
echo "Testing functions:"
zsh -ic 'mkcd /tmp/test_$$; pwd; cd ..; rm -rf /tmp/test_$$' 2>/dev/null && echo "  mkcd: ✓" || echo "  mkcd: ✗"
zsh -ic 'h2d ff 2>/dev/null' | grep -q "255" && echo "  h2d: ✓" || echo "  h2d: ✗"

# Test aliases
echo -e "\nTesting aliases:"
zsh -ic 'alias ls 2>/dev/null' | grep -q "eza\|color" && echo "  ls: ✓" || echo "  ls: ✗"

# Test FZF (check if function exists, don't run it)
echo -e "\nTesting FZF:"
zsh -ic 'typeset -f fcd >/dev/null 2>&1' && echo "  fcd: ✓" || echo "  fcd: ✗"
zsh -ic 'typeset -f fe >/dev/null 2>&1' && echo "  fe: ✓" || echo "  fe: ✗"

# Performance
echo -e "\nPerformance:"
zsh -ic 'zsh-stats 2>/dev/null' | head -4

# Load time
echo -e "\nLoad time test:"
time zsh -i -c exit
