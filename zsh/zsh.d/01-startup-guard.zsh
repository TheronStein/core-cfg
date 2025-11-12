# ~/.core/cfg/zsh/zsh.d/01-startup-guard.zsh
# Startup protection and loop prevention

# Prevent multiple loading of this guard
[[ -n "$_STARTUP_GUARD_LOADED" ]] && return
export _STARTUP_GUARD_LOADED=1

# Set startup protection variables
export ZSH_LOADING_CONFIGS=1

# Function to safely source files
safe_source() {
    local file="$1"
    [[ -r "$file" ]] && source "$file" 2>/dev/null || true
}

# Trap errors during startup
trap_startup_error() {
    print "Warning: Error occurred during zsh startup" >&2
    unset ZSH_STARTING_UP ZSH_LOADING_CONFIGS
    return 1
}

# Set error trap
trap 'trap_startup_error' ERR

# Clean up any existing problematic processes
pkill -f "zinit.*scheduler" 2>/dev/null || true

# NOTE: ulimit disabled - was causing startup hangs
# ulimit -t 30 2>/dev/null || true  # 30 seconds CPU time limit
