# ~/.core/zsh/modules/zoxide.zsh
# Zoxide Integration - smarter cd command that learns your habits

#=============================================================================
# CHECK FOR ZOXIDE
#=============================================================================
(( $+commands[zoxide] )) || return 0

#=============================================================================
# ENVIRONMENT
#=============================================================================
export _ZO_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zoxide"
export _ZO_ECHO=0           # Don't echo directory after cd
export _ZO_RESOLVE_SYMLINKS=1

#=============================================================================
# INITIALIZE ZOXIDE
#=============================================================================
eval "$(zoxide init zsh)"

#=============================================================================
# ALIASES
#=============================================================================
# z is already defined by zoxide init
# zi is interactive mode

alias zz='z -'              # Previous directory
alias zh='z ~'              # Home
alias zr='z /'              # Root

#=============================================================================
# FUNCTIONS
#=============================================================================

# Interactive directory jump with fzf
function zf() {
    local result
    result=$(zoxide query -l | \
        fzf --height 50% --reverse \
            --header '╭─ Zoxide Directories ─╮' \
            --preview 'eza -la --color=always --icons {} 2>/dev/null | head -20' \
            --preview-window 'right:50%' \
            --tiebreak=index)
    
    [[ -n "$result" ]] && cd "$result"
}

# Jump to directory matching pattern (non-interactive)
function zq() {
    local query="$*"
    local result=$(zoxide query "$query")
    
    if [[ -n "$result" ]]; then
        echo "$result"
        cd "$result"
    else
        echo "No match found for: $query"
        return 1
    fi
}

# List all stored directories with scores
function zl() {
    zoxide query -ls | \
        awk '{printf "%8.1f  %s\n", $1, $2}' | \
        sort -rn | \
        head -${1:-20}
}

# List directories matching query
function zls() {
    zoxide query -l "$@"
}

# Add directory to zoxide database
function za() {
    local dir="${1:-$PWD}"
    zoxide add "$dir"
    echo "Added: $dir"
}

# Remove directory from zoxide database
function zrm() {
    if [[ -n "$1" ]]; then
        zoxide remove "$1"
        echo "Removed: $1"
    else
        # Interactive removal
        local selected
        selected=$(zoxide query -l | \
            fzf --multi \
                --header '╭─ Select directories to remove ─╮' \
                --preview 'eza -la --color=always --icons {} 2>/dev/null | head -10')
        
        if [[ -n "$selected" ]]; then
            echo "$selected" | while read -r dir; do
                zoxide remove "$dir"
                echo "Removed: $dir"
            done
        fi
    fi
}

# Clean non-existent directories
function zclean() {
    local count=0
    zoxide query -l | while read -r dir; do
        if [[ ! -d "$dir" ]]; then
            zoxide remove "$dir"
            echo "Removed (non-existent): $dir"
            ((count++))
        fi
    done
    echo "Cleaned $count entries"
}

# Jump to project directory
function zp() {
    local project_dirs=(
        ~/projects
        ~/work
        ~/src
        ~/code
    )
    
    local all_projects=()
    for base in "${project_dirs[@]}"; do
        [[ -d "$base" ]] && all_projects+=("$base"/*)
    done
    
    local selected
    selected=$(printf '%s\n' "${all_projects[@]}" | \
        fzf --header '╭─ Projects ─╮' \
            --preview 'eza -la --color=always --icons {} 2>/dev/null | head -15')
    
    if [[ -n "$selected" ]]; then
        zoxide add "$selected"
        cd "$selected"
    fi
}

# Jump to git root
function zg() {
    local root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$root" ]]; then
        cd "$root"
    else
        echo "Not in a git repository"
        return 1
    fi
}

# Jump to config directory
function zc() {
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
    
    if [[ -n "$1" ]]; then
        local target="$config_dir/$1"
        if [[ -d "$target" ]]; then
            cd "$target"
        else
            echo "Config directory not found: $target"
            return 1
        fi
    else
        local selected
        selected=$(fd --type d --max-depth 1 . "$config_dir" | \
            fzf --header '╭─ Config Directories ─╮' \
                --preview 'eza -la --color=always --icons {} 2>/dev/null | head -15')
        [[ -n "$selected" ]] && cd "$selected"
    fi
}

# Jump and open in editor
function ze() {
    local result
    result=$(zoxide query -l | \
        fzf --header '╭─ Jump and Edit ─╮' \
            --preview 'eza -la --color=always --icons {} 2>/dev/null | head -20')
    
    if [[ -n "$result" ]]; then
        cd "$result"
        ${EDITOR:-nvim} .
    fi
}

# Jump and open in yazi
function zy() {
    local result
    result=$(zoxide query -l | \
        fzf --header '╭─ Jump to Yazi ─╮' \
            --preview 'eza -la --color=always --icons {} 2>/dev/null | head -20')
    
    if [[ -n "$result" ]]; then
        yazi "$result"
    fi
}

# Import directories from shell history
function zimport() {
    echo "Importing directories from shell history..."
    local count=0
    
    # Extract directories from history
    fc -l 1 | grep -oE 'cd [^;|&]+' | sed 's/cd //' | \
        while read -r dir; do
            dir=$(eval echo "$dir" 2>/dev/null)
            if [[ -d "$dir" ]]; then
                zoxide add "$dir"
                ((count++))
            fi
        done
    
    echo "Imported $count directories"
}

# Statistics
function zstats() {
    local total=$(zoxide query -l | wc -l)
    local top_score=$(zoxide query -ls | head -1 | awk '{print $1}')
    
    echo "╭─ Zoxide Statistics ─╮"
    echo "  Total directories: $total"
    echo "  Highest score: $top_score"
    echo "  Database: $_ZO_DATA_DIR"
    echo "╰──────────────────────╯"
    echo ""
    echo "Top 10 directories:"
    zl 10
}

#=============================================================================
# WIDGET FOR KEYBINDING
#=============================================================================

# Widget for Alt+Z keybinding
function widget::zoxide-jump() {
    local result
    result=$(zoxide query -l | \
        fzf --height 50% --reverse \
            --header '╭─ Jump ─╮' \
            --preview 'eza -la --color=always --icons {} 2>/dev/null | head -15' \
            --preview-window 'right:50%')
    
    if [[ -n "$result" ]]; then
        cd "$result"
        zle accept-line
    fi
    zle reset-prompt
}
zle -N widget::zoxide-jump
bindkey '^[z' widget::zoxide-jump  # Alt+Z
