# ~/.core/zsh/modules/performance.zsh
# Performance optimizations for ZSH startup and runtime
# Includes profiling, lazy loading, caching, and optimization utilities

#=============================================================================
# PERFORMANCE MEASUREMENT
#=============================================================================

# Function: zsh-profile
# Description: Profile ZSH startup time
# Usage: zsh-profile [--detailed]
function zsh-profile() {
    local detailed="${1}"

    if [[ "$detailed" == "--detailed" ]]; then
        # Detailed profiling with zprof
        env ZSH_PROF=1 zsh -ic "zprof; exit" | less
    else
        # Quick profiling
        for i in {1..10}; do
            time zsh -ic exit
        done | awk '/real/ {sum += $2; count++} END {print "Average: " sum/count "s"}'
    fi
}

# Function: zsh-benchmark
# Description: Benchmark specific command or function
# Usage: zsh-benchmark <command> [iterations]
function zsh-benchmark() {
    local cmd="${1:?Usage: zsh-benchmark <command> [iterations]}"
    local iterations="${2:-100}"
    local total=0

    echo "Benchmarking: $cmd"
    echo "Iterations: $iterations"

    for ((i=1; i<=iterations; i++)); do
        local start=$(date +%s%N)
        eval "$cmd" &>/dev/null
        local end=$(date +%s%N)
        local elapsed=$((end - start))
        total=$((total + elapsed))
    done

    local avg=$((total / iterations))
    echo "Average time: $(echo "scale=3; $avg / 1000000" | bc) ms"
}

#=============================================================================
# LAZY LOADING FRAMEWORK
#=============================================================================

# Lazy load function generator
function make-lazy-load() {
    local func="${1}"
    local file="${2}"

    eval "
    function ${func}() {
        unfunction ${func}
        source '${file}'
        ${func} \"\$@\"
    }
    "
}

# Lazy load heavy completions
function lazy-load-completions() {
    local -A lazy_completions=(
        kubectl "${XDG_DATA_HOME}/zsh/completions/kubectl"
        helm "${XDG_DATA_HOME}/zsh/completions/helm"
        terraform "${XDG_DATA_HOME}/zsh/completions/terraform"
        aws "${XDG_DATA_HOME}/zsh/completions/aws"
    )

    for cmd file in ${(kv)lazy_completions}; do
        if (( $+commands[$cmd] )) && [[ ! -f "$file" ]]; then
            # Generate completion file if it doesn't exist
            case "$cmd" in
                kubectl)
                    kubectl completion zsh > "$file" 2>/dev/null
                    ;;
                helm)
                    helm completion zsh > "$file" 2>/dev/null
                    ;;
                terraform)
                    terraform -install-autocomplete 2>/dev/null
                    ;;
            esac
        fi

        # Create lazy loading wrapper
        if [[ -f "$file" ]]; then
            eval "
            function _${cmd}_completion_loader() {
                unfunction _${cmd}_completion_loader
                source '$file'
                return 124  # Request ZSH to retry completion
            }
            compdef _${cmd}_completion_loader ${cmd}
            "
        fi
    done
}

# Enable lazy loading
lazy-load-completions

#=============================================================================
# CACHING SYSTEM
#=============================================================================

# Function: cache-eval
# Description: Cache output of expensive commands
# Usage: cache-eval <cache-name> <ttl-seconds> <command>
function cache-eval() {
    local cache_name="${1}"
    local ttl="${2}"
    local cmd="${3}"
    local cache_dir="${XDG_CACHE_HOME}/zsh/cache-eval"
    local cache_file="$cache_dir/${cache_name}.cache"

    mkdir -p "$cache_dir"

    # Check if cache is valid
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)))
        if [[ $cache_age -lt $ttl ]]; then
            cat "$cache_file"
            return 0
        fi
    fi

    # Generate and cache output
    eval "$cmd" | tee "$cache_file"
}

# Function: clear-zsh-cache
# Description: Clear all ZSH caches
function clear-zsh-cache() {
    local cache_dir="${XDG_CACHE_HOME}/zsh"

    echo "Clearing ZSH caches..."

    # Completion dump
    rm -f "$cache_dir/.zcompdump"*

    # Cache-eval caches
    rm -rf "$cache_dir/cache-eval"

    # FZF history
    rm -f "$cache_dir/fzf-history"

    # Command caches
    rm -rf "$cache_dir/commands"

    echo "✅ ZSH caches cleared"

    # Rebuild completion dump
    echo "Rebuilding completion dump..."
    compinit -d "$cache_dir/.zcompdump"
    zcompile "$cache_dir/.zcompdump"
}

#=============================================================================
# COMPILATION OPTIMIZATIONS
#=============================================================================

# Function: compile-zsh-files
# Description: Compile all ZSH configuration files
function compile-zsh-files() {
    local zsh_dir="${ZSH_CORE:-$HOME/.core/zsh}"

    echo "Compiling ZSH files..."

    # Find all .zsh files
    find "$zsh_dir" -name "*.zsh" -type f | while read -r file; do
        # Skip already compiled files
        if [[ ! -f "${file}.zwc" ]] || [[ "$file" -nt "${file}.zwc" ]]; then
            echo "Compiling: $file"
            zcompile "$file"
        fi
    done

    # Compile .zshrc and .zshenv
    for file in "$HOME/.zshrc" "$HOME/.zshenv" "$zsh_dir/.zshrc" "$zsh_dir/.zshenv"; do
        if [[ -f "$file" ]] && { [[ ! -f "${file}.zwc" ]] || [[ "$file" -nt "${file}.zwc" ]]; }; then
            echo "Compiling: $file"
            zcompile "$file"
        fi
    done

    echo "✅ Compilation complete"
}

# Function: cleanup-zwc-files
# Description: Remove orphaned .zwc files
function cleanup-zwc-files() {
    local zsh_dir="${ZSH_CORE:-$HOME/.core/zsh}"

    echo "Cleaning up .zwc files..."

    find "$zsh_dir" -name "*.zwc" -type f | while read -r zwc_file; do
        local source_file="${zwc_file%.zwc}"
        if [[ ! -f "$source_file" ]]; then
            echo "Removing orphaned: $zwc_file"
            rm -f "$zwc_file"
        fi
    done

    echo "✅ Cleanup complete"
}

#=============================================================================
# MEMORY OPTIMIZATION
#=============================================================================

# Function: zsh-memory-usage
# Description: Show ZSH memory usage
function zsh-memory-usage() {
    local pid="${1:-$$}"

    if [[ -f "/proc/$pid/status" ]]; then
        echo "ZSH Memory Usage (PID: $pid):"
        grep -E "^(VmSize|VmRSS|VmData|VmStk)" "/proc/$pid/status"
    else
        ps aux | grep -E "^USER|zsh" | grep -v grep
    fi
}

# Function: optimize-history
# Description: Optimize history file by removing duplicates
function optimize-history() {
    local histfile="${HISTFILE:-$HOME/.zsh_history}"
    local tmpfile=$(mktemp)

    if [[ ! -f "$histfile" ]]; then
        echo "History file not found: $histfile"
        return 1
    fi

    echo "Optimizing history file..."

    # Remove duplicates while preserving order
    awk '!seen[$0]++' "$histfile" > "$tmpfile"

    # Backup original
    cp "$histfile" "${histfile}.backup"

    # Replace with optimized version
    mv "$tmpfile" "$histfile"

    local original_lines=$(wc -l < "${histfile}.backup")
    local new_lines=$(wc -l < "$histfile")
    local removed=$((original_lines - new_lines))

    echo "✅ Removed $removed duplicate entries"
    echo "   Original: $original_lines lines"
    echo "   Optimized: $new_lines lines"
}

#=============================================================================
# PATH OPTIMIZATION
#=============================================================================

# Function: optimize-path
# Description: Remove duplicates and non-existent directories from PATH
function optimize-path() {
    local new_path=""
    local -A seen

    echo "Current PATH entries: $(echo $PATH | tr ':' '\n' | wc -l)"

    # Process each PATH entry
    for dir in ${(s.:.)PATH}; do
        # Skip if already seen or doesn't exist
        if [[ -z "${seen[$dir]}" ]] && [[ -d "$dir" ]]; then
            seen[$dir]=1
            if [[ -n "$new_path" ]]; then
                new_path="${new_path}:${dir}"
            else
                new_path="${dir}"
            fi
        fi
    done

    export PATH="$new_path"
    echo "Optimized PATH entries: $(echo $PATH | tr ':' '\n' | wc -l)"

    # Show removed entries
    echo "Removed entries:"
    for dir in ${(s.:.)OLDPATH}; do
        if [[ ! -d "$dir" ]]; then
            echo "  - $dir (non-existent)"
        elif [[ -n "${seen[$dir]}" ]]; then
            echo "  - $dir (duplicate)"
        fi
    done
}

#=============================================================================
# STARTUP OPTIMIZATION
#=============================================================================

# Function: defer-init
# Description: Defer initialization of heavy features
# Usage: defer-init <seconds> <command>
function defer-init() {
    local delay="${1}"
    local cmd="${2}"

    (
        sleep "$delay"
        eval "$cmd"
    ) &!
}

# Function: conditional-source
# Description: Source file only if conditions are met
# Usage: conditional-source <file> <condition>
function conditional-source() {
    local file="${1}"
    local condition="${2:-true}"

    if [[ -f "$file" ]] && eval "$condition"; then
        source "$file"
        return 0
    fi
    return 1
}

#=============================================================================
# COMPLETION OPTIMIZATION
#=============================================================================

# Function: refresh-completions
# Description: Refresh completion system
function refresh-completions() {
    echo "Refreshing completions..."

    # Remove old completion dump
    rm -f "${XDG_CACHE_HOME}/zsh/.zcompdump"*

    # Reinitialize
    autoload -Uz compinit
    compinit -d "${XDG_CACHE_HOME}/zsh/.zcompdump"

    # Compile the dump
    zcompile "${XDG_CACHE_HOME}/zsh/.zcompdump"

    echo "✅ Completions refreshed"
}

# Function: completion-stats
# Description: Show completion statistics
function completion-stats() {
    echo "Completion Statistics:"
    echo "====================="

    echo "\nRegistered completions: $(print -l ${(k)_comps} | wc -l)"
    echo "Completion dump size: $(ls -lh ${XDG_CACHE_HOME}/zsh/.zcompdump 2>/dev/null | awk '{print $5}')"

    echo "\nTop 10 largest completion functions:"
    for func in ${(k)_comps}; do
        (( $+functions[_${func}] )) && echo "${#functions[_${func}]} _${func}"
    done | sort -rn | head -10

    echo "\nAutoloaded functions: $(print -l $fpath | xargs -I {} find {} -type f 2>/dev/null | wc -l)"
}

#=============================================================================
# AUTOMATIC OPTIMIZATION
#=============================================================================

# Run optimizations periodically
if [[ ! -f "${XDG_STATE_HOME}/zsh/last-optimization" ]] || \
   [[ $(find "${XDG_STATE_HOME}/zsh/last-optimization" -mtime +7 2>/dev/null) ]]; then

    # Run in background after startup
    (
        sleep 5
        mkdir -p "${XDG_STATE_HOME}/zsh"

        # Compile files if needed
        compile-zsh-files &>/dev/null

        # Optimize history
        optimize-history &>/dev/null

        # Touch marker file
        touch "${XDG_STATE_HOME}/zsh/last-optimization"
    ) &!
fi

#=============================================================================
# PERFORMANCE ALIASES
#=============================================================================
alias zprof='zsh-profile'
alias zbench='zsh-benchmark'
alias zcache-clear='clear-zsh-cache'
alias zcompile-all='compile-zsh-files'
alias zclean-zwc='cleanup-zwc-files'
alias zmem='zsh-memory-usage'
alias zhist-optimize='optimize-history'
alias zpath-optimize='optimize-path'
alias zcomp-refresh='refresh-completions'
alias zcomp-stats='completion-stats'

#=============================================================================
# STARTUP TIMER (Optional - uncomment to enable)
#=============================================================================
# if [[ -n "$ZSH_STARTUP_TIMER" ]]; then
#     zmodload zsh/datetime
#     typeset -F SECONDS
#     echo "ZSH startup time: ${SECONDS}s"
# fi