#!/bin/bash

echo "Advanced Configuration Test"
echo "==========================="

# Test new functions
echo -e "\n1. Testing functions:"
zsh -ic 'type bak >/dev/null 2>&1' && echo "  bak: ✓" || echo "  bak: ✗"
zsh -ic 'type fco >/dev/null 2>&1' && echo "  fco: ✓" || echo "  fco: ✗"
zsh -ic 'type path_append >/dev/null 2>&1' && echo "  path_append: ✓" || echo "  path_append: ✗"

# Test dirstack
echo -e "\n2. Testing dirstack:"
zsh -ic 'dirs >/dev/null 2>&1' && echo "  dirs: ✓" || echo "  dirs: ✗"

# Test global aliases
echo -e "\n3. Testing aliases:"
zsh -ic 'alias -g G >/dev/null 2>&1' && echo "  global aliases: ✓" || echo "  global aliases: ✗"

# Performance check
echo -e "\n4. Performance:"
time zsh -i -c exit
