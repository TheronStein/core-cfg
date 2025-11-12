#!/bin/bash

echo "Full Configuration Test Suite"
echo "============================="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }

echo -e "\n=== Core Functions ==="
zsh -ic 'type lsfuncs &>/dev/null' && pass "Zsh functions" || fail "Zsh functions"
zsh -ic 'type whichcomp &>/dev/null' && pass "Completion info" || fail "Completion info"

echo -e "\n=== Language Support ==="
zsh -ic 'type cargo-home &>/dev/null' && pass "Rust utilities" || fail "Rust utilities"
zsh -ic 'type py &>/dev/null' && pass "Python utilities" || fail "Python utilities"

echo -e "\n=== System Functions ==="
zsh -ic 'type sysinfo &>/dev/null' && pass "System info" || fail "System info"
zsh -ic 'type ports &>/dev/null' && pass "Port management" || fail "Port management"

echo -e "\n=== File Management ==="
zsh -ic 'type ff &>/dev/null' && pass "File finder" || fail "File finder"
zsh -ic 'type backup-ts &>/dev/null' && pass "Timestamped backup" || fail "Timestamped backup"

echo -e "\n=== Performance ==="
echo -n "Load time: "
{ time zsh -i -c exit; } 2>&1 | grep real

echo -e "\n=== Statistics ==="
zsh -ic '
    echo "Functions: $(print -l ${(ok)functions} | wc -l)"
    echo "Aliases: $(print -l ${(ok)aliases} | wc -l)"
    echo "Widgets: $(zle -la 2>/dev/null | wc -l)"
'
