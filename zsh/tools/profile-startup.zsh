#!/usr/bin/env zsh
# Tmux-aware ZSH startup profiler
# Measures shell initialization time and identifies bottlenecks

echo "=== ZSH Startup Profiler ==="
echo "Context: $([ -n "$TMUX" ] && echo "Inside tmux" || echo "Outside tmux")"
echo "Terminal: ${TERM_PROGRAM:-$TERM}"
echo ""

# Test 1: Bare minimum startup
echo "Test 1: Minimal zsh (no config)"
time zsh -d -f -c 'exit'

# Test 2: With .zshenv only
echo ""
echo "Test 2: With environment setup"
time zsh -c 'exit' 2>&1 | tail -1

# Test 3: Full startup with profiling
echo ""
echo "Test 3: Full startup with zprof"
cat > /tmp/zsh-prof-test.zsh <<'EOF'
zmodload zsh/zprof
source ~/.zshrc
zprof | head -40
EOF

time zsh /tmp/zsh-prof-test.zsh

rm -f /tmp/zsh-prof-test.zsh

echo ""
echo "=== Startup Time Breakdown ==="

# Test instant prompt status
if [[ -n "$TMUX" ]]; then
  echo ""
  echo "Instant Prompt Cache Status (in tmux):"
  ls -lah ~/.cache/p10k-instant-prompt-* 2>/dev/null || echo "  No instant prompt cache found"
fi
