# Performance monitoring

# Profile startup
function zsh-profile() {
    ZPROF=1 zsh -i -c exit
}

# Benchmark
function zsh-bench() {
    hyperfine --warmup 3 'zsh -i -c exit'
}

# Stats function
function zsh-stats-full() {
    echo "=== Zsh Statistics ==="
    echo "Functions: ${#${(k)functions}}"
    echo "Aliases: ${#${(k)aliases}}"
    echo "Commands: ${#${(k)commands}}"
    echo "Parameters: ${#${(k)parameters}}"
    echo "Modules: ${#${(k)modules}}"
    echo ""
    echo "=== Top 10 Functions by Size ==="
    for func in ${(k)functions}; do
        echo "${#functions[$func]} $func"
    done | sort -rn | head -10
}

# Clean zwc files
function zwc-clean() {
    find "${ZDOTDIR}" -name "*.zwc" -delete
    find "${ZDOTDIR}" -name "*.zwc.old" -delete
    echo "Cleaned .zwc files"
}
