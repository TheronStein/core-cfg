# Debug utilities - only loaded when needed

# Debug function for startup profiling
function debug-zsh-startup() {
    local logfile="${ZDOTDIR}/logs/startup-$(date +%Y%m%d-%H%M%S).log"
    mkdir -p "${ZDOTDIR}/logs"
    
    echo "Starting trace... Output: $logfile"
    TRACE_ZSH=1 zsh -xvic exit 2>&1 | tee "$logfile"
    echo "Trace complete. View with: less $logfile"
}

# Watch startup in real-time
function watch-zsh-startup() {
    TRACE_ZSH=1 zsh -xvic exit 2>&1 | less -R
}

# Profile startup time
function profile-zsh-startup() {
    hyperfine --warmup 3 'zsh -i -c exit' 2>/dev/null || \
    for i in {1..10}; do time zsh -i -c exit; done
}

# Clean up old debug logs
function clean-zsh-logs() {
    find "${ZDOTDIR}/logs" -name "*.log" -mtime +7 -delete 2>/dev/null
    echo "Cleaned logs older than 7 days"
}
