# ~/.core/zsh/modules/bat.zsh
# Bat Integration - syntax-highlighted cat replacement with git integration

#=============================================================================
# CHECK FOR BAT
#=============================================================================
(( $+commands[bat] )) || return 0

#=============================================================================
# ENVIRONMENT
#=============================================================================
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/bat/config"
export BAT_THEME="${BAT_THEME:-Catppuccin Mocha}"
export BAT_STYLE="${BAT_STYLE:-numbers,changes,header}"

# Use bat for man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

#=============================================================================
# BASE ALIASES
#=============================================================================
alias cat='bat --paging=never'
alias catp='bat --plain'                    # Plain (no line numbers)
alias catl='bat --style=full'               # Full (all decorations)
alias catn='bat --style=numbers'            # Numbers only
alias catg='bat --style=numbers,changes'    # Numbers + git changes

#=============================================================================
# PAGING OPTIONS
#=============================================================================
alias less='bat --paging=always'
alias more='bat --paging=always'
alias batpage='bat --paging=always'
alias batnever='bat --paging=never'

#=============================================================================
# LANGUAGE-SPECIFIC ALIASES
#=============================================================================
alias batjson='bat -l json'
alias batyaml='bat -l yaml'
alias batsh='bat -l bash'
alias batpy='bat -l python'
alias batrs='bat -l rust'
alias batgo='bat -l go'
alias batjs='bat -l javascript'
alias batts='bat -l typescript'
alias batlua='bat -l lua'
alias batmd='bat -l markdown'
alias batsql='bat -l sql'
alias bathtml='bat -l html'
alias batcss='bat -l css'
alias batdiff='bat -l diff'
alias batlog='bat -l log'

#=============================================================================
# FUNCTIONS
#=============================================================================

# View file with specific language
function batl() {
    local lang="$1"
    shift
    bat -l "$lang" "$@"
}

# Preview first/last N lines
function bathead() {
    local lines="${1:-20}"
    shift
    bat --line-range "1:$lines" "$@"
}

function battail() {
    local lines="${1:-20}"
    shift
    local total=$(wc -l < "$1")
    local start=$((total - lines + 1))
    [[ $start -lt 1 ]] && start=1
    bat --line-range "$start:" "$@"
}

# View specific line range
function batrange() {
    local start="$1"
    local end="$2"
    shift 2
    bat --line-range "$start:$end" "$@"
}

# Highlight specific lines
function bathighlight() {
    local lines="$1"
    shift
    bat --highlight-line "$lines" "$@"
}

# Diff two files with bat
function batdiff() {
    if [[ $# -ne 2 ]]; then
        # echo "Usage: batdiff <file1> <file2>"
        return 1
    fi
    diff -u "$1" "$2" | bat -l diff
}

# Show git diff with bat
function batgit() {
    git diff "$@" | bat -l diff
}

# Show staged changes
function batgits() {
    git diff --staged "$@" | bat -l diff
}

# Show file at specific git commit
function batcommit() {
    local commit="$1"
    local file="$2"
    git show "$commit:$file" | bat -l "${file##*.}"
}

# Interactive file browser with bat preview
function batfzf() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always --line-range :300 {}' \
        --preview-window 'right:60%:wrap')
    [[ -n "$file" ]] && bat "$file"
}

# View all matching files
function batgrep() {
    local pattern="$1"
    shift
    rg -l "$pattern" "$@" | xargs bat
}

# View log files with follow
function batwatch() {
    tail -f "$1" | bat --paging=never -l log
}

# Pretty print JSON from stdin or file
function batjsonp() {
    if [[ -n "$1" && -f "$1" ]]; then
        jq . "$1" | bat -l json
    else
        jq . | bat -l json
    fi
}

# Pretty print YAML from stdin or file
function batyamlp() {
    if [[ -n "$1" && -f "$1" ]]; then
        bat -l yaml "$1"
    else
        bat -l yaml
    fi
}

# Show help for command with syntax highlighting
function bathelp() {
    "$@" --help 2>&1 | bat --plain -l help
}

# View environment variable as formatted content
function batenv() {
    local var="$1"
    local lang="${2:-}"
    
    if [[ -n "$lang" ]]; then
        echo "${(P)var}" | bat -l "$lang"
    else
        echo "${(P)var}" | bat
    fi
}

# Compare command outputs
function batcmp() {
    diff <(eval "$1") <(eval "$2") | bat -l diff
}

#=============================================================================
# CACHE MANAGEMENT
#=============================================================================

# Build bat cache (for custom themes/syntaxes)
function bat-cache-build() {
    bat cache --build
    echo "Bat cache rebuilt"
}

# Clear bat cache
function bat-cache-clear() {
    bat cache --clear
    echo "Bat cache cleared"
}

# List available themes
function bat-themes() {
    bat --list-themes | bat -l ini
}

# List available languages
function bat-languages() {
    bat --list-languages | bat
}

# Preview theme
function bat-theme-preview() {
    local theme="${1:-$BAT_THEME}"
    bat --theme="$theme" --list-themes
}

#=============================================================================
# CONFIG FILE HELPERS
#=============================================================================

# View common config files with appropriate syntax
function batconfig() {
    case "$1" in
        zsh|zshrc)      bat -l zsh ~/.zshrc ;;
        bash|bashrc)    bat -l bash ~/.bashrc ;;
        tmux)           bat -l conf ~/.config/tmux/tmux.conf ;;
        nvim|vim)       bat -l lua ~/.config/nvim/init.lua ;;
        hypr*)          bat -l conf ~/.config/hypr/hyprland.conf ;;
        wezterm)        bat -l lua ~/.config/wezterm/wezterm.lua ;;
        ssh)            bat -l sshconfig ~/.ssh/config ;;
        git)            bat -l gitconfig ~/.gitconfig ;;
        *)              echo "Unknown config: $1" ;;
    esac
}

#=============================================================================
# INTEGRATION WITH OTHER TOOLS
#=============================================================================

# Man pages with bat
function bman() {
    man "$@" | bat -l man -p
}

# Help pages
function bhelp() {
    "$@" --help 2>&1 | bat -l help -p
}

# View process output
function bps() {
    ps aux | bat -l log --style=plain
}

# View /etc files
function betc() {
    local file="/etc/$1"
    [[ -f "$file" ]] && sudo bat "$file" || echo "File not found: $file"
}
