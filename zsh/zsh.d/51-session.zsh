# Session management

# Save command to a project-specific history
function save-cmd() {
    local cmd="${1:-$history[$HISTCMD]}"
    local project="${2:-$(basename $PWD)}"
    local file="${ZDOTDIR}/.cache/project-history/${project}.hist"
    
    mkdir -p "${ZDOTDIR}/.cache/project-history"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $cmd" >> "$file"
    echo "Saved to $project history"
}

# Load project-specific history
function load-project-history() {
    local project="${1:-$(basename $PWD)}"
    local file="${ZDOTDIR}/.cache/project-history/${project}.hist"
    
    if [[ -f "$file" ]]; then
        cat "$file"
    else
        echo "No history for project: $project"
    fi
}

# Save current environment
function save-env() {
    local name="${1:-default}"
    local file="${ZDOTDIR}/.cache/environments/${name}.env"
    
    mkdir -p "${ZDOTDIR}/.cache/environments"
    export -p > "$file"
    echo "Environment saved as: $name"
}

# Load saved environment
function load-env() {
    local name="${1:-default}"
    local file="${ZDOTDIR}/.cache/environments/${name}.env"
    
    if [[ -f "$file" ]]; then
        source "$file"
        echo "Environment loaded: $name"
    else
        echo "Environment not found: $name"
    fi
}

# Directory bookmarks
typeset -gA BOOKMARKS

function bookmark() {
    local name="${1:?Bookmark name required}"
    local dir="${2:-$PWD}"
    BOOKMARKS[$name]="$dir"
    echo "Bookmarked: $name -> $dir"
}

function go() {
    local name="${1:?Bookmark name required}"
    if [[ -n "${BOOKMARKS[$name]}" ]]; then
        cd "${BOOKMARKS[$name]}"
    else
        echo "Bookmark not found: $name"
        echo "Available bookmarks:"
        for k v in ${(kv)BOOKMARKS}; do
            echo "  $k -> $v"
        done
    fi
}

# Persist bookmarks
function save-bookmarks() {
    typeset -p BOOKMARKS > "${ZDOTDIR}/.cache/bookmarks.zsh"
}

function load-bookmarks() {
    [[ -f "${ZDOTDIR}/.cache/bookmarks.zsh" ]] && source "${ZDOTDIR}/.cache/bookmarks.zsh"
}

# Auto-load bookmarks on startup
load-bookmarks 2>/dev/null
