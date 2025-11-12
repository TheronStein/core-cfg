# Performance optimizations

# Compile important files
function compile-zsh-files() {
    local file
    for file in "${ZDOTDIR}"/**/*.zsh(N); do
        if [[ ! -f "${file}.zwc" ]] || [[ "${file}" -nt "${file}.zwc" ]]; then
            zcompile "${file}"
            echo "Compiled: ${file}"
        fi
    done
}

# Optimize completion dump
function refresh-completions() {
    rm -f "${ZDOTDIR}/.zcompdump"*
    autoload -Uz compinit && compinit
    zcompile "${ZDOTDIR}/.zcompdump"
    echo "Completions refreshed"
}

# Profile specific parts
function profile-part() {
    local part="${1:?Part to profile}"
    time zsh -ic "source ${ZDOTDIR}/zsh.d/${part}"
}

# Lazy load functions
function lazy-load() {
    local cmd="$1"
    local func="$2"
    eval "$cmd() { unfunction $cmd; $func; $cmd \$@ }"
}

# Check for slow startup parts
function debug-startup() {
    zsh -xvic exit 2>&1 | ts -i "%.s" | ${PAGER:-less}
}
