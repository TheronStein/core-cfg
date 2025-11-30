# ~/.core/zsh/modules/functions.zsh
# Utility functions - commonly used helper functions for shell operations

#=============================================================================
# DIRECTORY OPERATIONS
#=============================================================================

# Create directory and cd into it
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Go up n directories
function up() {
    local count="${1:-1}"
    local target=""
    for ((i=0; i<count; i++)); do
        target+="../"
    done
    cd "$target"
}

# Back to previous directory and list
function back() {
    cd - && ls
}

# Create a temporary directory and cd into it
function tmpdir() {
    local dir=$(mktemp -d)
    cd "$dir"
    echo "Created and moved to: $dir"
}

# Find and cd to a directory
function cdf() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf)
    [[ -n "$dir" ]] && cd "$dir"
}

#=============================================================================
# FILE OPERATIONS
#=============================================================================

# Extract any archive
function extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)  tar xjf "$1"     ;;
            *.tar.gz)   tar xzf "$1"     ;;
            *.tar.xz)   tar xJf "$1"     ;;
            *.tar.zst)  tar --zstd -xf "$1" ;;
            *.bz2)      bunzip2 "$1"     ;;
            *.gz)       gunzip "$1"      ;;
            *.tar)      tar xf "$1"      ;;
            *.tbz2)     tar xjf "$1"     ;;
            *.tgz)      tar xzf "$1"     ;;
            *.zip)      unzip "$1"       ;;
            *.Z)        uncompress "$1"  ;;
            *.7z)       7z x "$1"        ;;
            *.rar)      unrar x "$1"     ;;
            *.xz)       xz -d "$1"       ;;
            *.zst)      zstd -d "$1"     ;;
            *)          echo "Cannot extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create archive from files/directories
function archive() {
    local name="$1"
    shift
    case "$name" in
        *.tar.gz|*.tgz)  tar czvf "$name" "$@" ;;
        *.tar.bz2|*.tbz) tar cjvf "$name" "$@" ;;
        *.tar.xz)        tar cJvf "$name" "$@" ;;
        *.tar.zst)       tar --zstd -cvf "$name" "$@" ;;
        *.tar)           tar cvf "$name" "$@" ;;
        *.zip)           zip -r "$name" "$@" ;;
        *.7z)            7z a "$name" "$@" ;;
        *)               echo "Unknown archive format: $name" ;;
    esac
}

# Backup file with timestamp
function backup() {
    local file="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    cp -v "$file" "${file}.${timestamp}.bak"
}

# Safe delete to trash
function trash() {
    local trash_dir="${XDG_DATA_HOME:-$HOME/.local/share}/Trash/files"
    mkdir -p "$trash_dir"
    for file in "$@"; do
        mv -v "$file" "$trash_dir/"
    done
}

# Find files by name
function ff() {
    fd --type f --hidden --follow "$@"
}

# Find directories by name
function ffd() {
    fd --type d --hidden --follow "$@"
}

#=============================================================================
# TEXT/FILE CONTENT OPERATIONS
#=============================================================================

# Count lines in files
function lines() {
    wc -l "$@" | sort -n
}

# Show file with line numbers (uses bat if available)
function show() {
    if command -v bat &>/dev/null; then
        bat --style=numbers "$@"
    else
        cat -n "$@"
    fi
}

# Quick grep in files (uses ripgrep if available)
function qg() {
    if command -v rg &>/dev/null; then
        rg --color=always "$@"
    else
        grep -rn --color=auto "$@"
    fi
}

# Preview file (first n lines)
function head() {
    command head -n "${2:-20}" "$1" 2>/dev/null | bat --style=plain --color=always 2>/dev/null || command head -n "${2:-20}" "$1"
}

# Replace text in files
function replace() {
    if [[ $# -lt 3 ]]; then
        echo "Usage: replace <old> <new> <files...>"
        return 1
    fi
    local old="$1"
    local new="$2"
    shift 2
    sed -i "s/$old/$new/g" "$@"
}

#=============================================================================
# PROCESS MANAGEMENT
#=============================================================================

# Find process by name
function pf() {
    procs 2>/dev/null "$@" || ps aux | grep -v grep | grep "$@"
}

# Kill process by name
function pk() {
    pkill -9 -f "$@"
}

# Port info - what's using a port
function port() {
    ss -tulpn | grep ":$1 "
}

# Kill process on port
function killport() {
    local pid=$(ss -tulpn | grep ":$1 " | awk '{print $7}' | cut -d'=' -f2 | cut -d',' -f1)
    if [[ -n "$pid" ]]; then
        kill -9 "$pid"
        echo "Killed process $pid on port $1"
    else
        echo "No process found on port $1"
    fi
}

#=============================================================================
# NETWORK UTILITIES
#=============================================================================

# Quick HTTP server
function serve() {
    local port="${1:-8000}"
    echo "Serving on http://localhost:$port"
    python -m http.server "$port"
}

# Get public IP
function myip() {
    curl -s ifconfig.me
    echo
}

# Get local IP
function localip() {
    ip addr show | grep -E "inet .* brd" | awk '{print $2}' | head -1
}

# DNS lookup
function dns() {
    dig +short "$@"
}

# Check if host is reachable
function isup() {
    ping -c 3 -W 2 "$1" &>/dev/null && echo "$1 is UP" || echo "$1 is DOWN"
}

# Download with progress
function dl() {
    curl -L -o "${2:-$(basename $1)}" --progress-bar "$1"
}

#=============================================================================
# GIT HELPERS
#=============================================================================

# Git root directory
function gitroot() {
    local root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$root" ]]; then
        cd "$root"
    else
        echo "Not in a git repository"
        return 1
    fi
}

# Git quick commit
function gcq() {
    git add -A && git commit -m "${1:-Quick commit}"
}

# Git amend with same message
function gamend() {
    git add -A && git commit --amend --no-edit
}

# Git undo last commit (keep changes)
function gundo() {
    git reset --soft HEAD~1
}

# Git discard all changes
function gdiscard() {
    read -q "?Discard all changes? [y/N] " && git checkout -- . && git clean -fd
    echo
}

# Git log with graph
function glog() {
    git log --oneline --graph --all --decorate -${1:-20}
}

# Git blame with colors
function gblame() {
    git blame --color-by-age --color-lines "$@"
}

# Git open in browser (GitHub/GitLab)
function gopen() {
    local url=$(git remote get-url origin 2>/dev/null | sed 's/git@/https:\/\//' | sed 's/\.git$//' | sed 's/\.com:/.com\//')
    [[ -n "$url" ]] && xdg-open "$url" 2>/dev/null || echo "No remote found"
}

#=============================================================================
# DOCKER HELPERS
#=============================================================================

# Docker exec into container
function dsh() {
    docker exec -it "$1" "${2:-/bin/sh}"
}

# Docker logs with follow
function dlog() {
    docker logs -f --tail "${2:-100}" "$1"
}

# Docker remove all stopped containers
function drma() {
    docker rm $(docker ps -qa --filter status=exited)
}

# Docker stop all running containers
function dsa() {
    docker stop $(docker ps -q)
}

# Docker clean everything
function dclean() {
    docker system prune -af --volumes
}

# Docker image size summary
function dimages() {
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | sort -k3 -h
}

#=============================================================================
# SYSTEM INFORMATION
#=============================================================================

# System info summary
function sysinfo() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                     SYSTEM INFORMATION                       ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║ Hostname:   $(hostname)"
    echo "║ Kernel:     $(uname -r)"
    echo "║ Uptime:     $(uptime -p)"
    echo "║ Memory:     $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
    echo "║ Disk /:     $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    echo "║ CPU:        $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    echo "║ Load:       $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
    echo "╚══════════════════════════════════════════════════════════════╝"
}

# Quick disk usage
function usage() {
    du -sh "${1:-.}"/* 2>/dev/null | sort -h
}

# Largest files in directory
function largest() {
    fd --type f --exec du -h {} \; 2>/dev/null | sort -rh | head -${1:-20}
}

# Show PATH entries
function path() {
    echo "$PATH" | tr ':' '\n' | nl
}

#=============================================================================
# DEVELOPMENT HELPERS
#=============================================================================

# Quick Python virtual environment
function pyenv() {
    if [[ ! -d ".venv" ]]; then
        python -m venv .venv
        echo "Created virtual environment"
    fi
    source .venv/bin/activate
}

# JSON pretty print
function json() {
    if [[ -f "$1" ]]; then
        jq . "$1"
    else
        echo "$1" | jq .
    fi
}

# Base64 encode/decode
function b64e() {
    echo -n "$1" | base64
}

function b64d() {
    echo "$1" | base64 -d
}

# URL encode/decode
function urle() {
    python -c "import urllib.parse; print(urllib.parse.quote('$1'))"
}

function urld() {
    python -c "import urllib.parse; print(urllib.parse.unquote('$1'))"
}

# Generate random string
function randstr() {
    local length="${1:-32}"
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
    echo
}

# Generate random password
function randpass() {
    local length="${1:-20}"
    tr -dc 'A-Za-z0-9!@#$%^&*()' < /dev/urandom | head -c "$length"
    echo
}

#=============================================================================
# CLIPBOARD HELPERS
#=============================================================================

# Copy to clipboard
function clip() {
    if [[ -f "$1" ]]; then
        cat "$1" | wl-copy 2>/dev/null || cat "$1" | xclip -selection clipboard
    else
        echo -n "$1" | wl-copy 2>/dev/null || echo -n "$1" | xclip -selection clipboard
    fi
}

# Paste from clipboard
function paste() {
    wl-paste 2>/dev/null || xclip -selection clipboard -o
}

#=============================================================================
# MISC UTILITIES
#=============================================================================

# Quick timer
function timer() {
    local seconds="${1:-60}"
    echo "Timer set for $seconds seconds..."
    sleep "$seconds" && notify-send "Timer" "Time's up!" 2>/dev/null || echo "Time's up!"
}

# Stopwatch
function stopwatch() {
    local start=$(date +%s)
    echo "Stopwatch started. Press Ctrl+C to stop."
    while true; do
        local now=$(date +%s)
        local elapsed=$((now - start))
        printf "\r%02d:%02d:%02d" $((elapsed/3600)) $((elapsed%3600/60)) $((elapsed%60))
        sleep 1
    done
}

# Weather
function weather() {
    curl -s "wttr.in/${1:-}?format=3"
}

# Cheat sheet
function cheat() {
    curl -s "cheat.sh/$1"
}

# Calculator
function calc() {
    echo "scale=4; $*" | bc -l
}

# Diff two commands output
function diffcmd() {
    diff <(eval "$1") <(eval "$2")
}

# Watch command with colors
function watch() {
    command watch --color -n "${2:-2}" "$1"
}
