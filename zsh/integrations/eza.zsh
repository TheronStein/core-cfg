# ~/.core/zsh/modules/eza.zsh
# Eza Integration - modern ls replacement with icons and git integration

#=============================================================================
# CHECK FOR EZA
#=============================================================================
(( $+commands[eza] )) || return 0

#=============================================================================
# ENVIRONMENT
#=============================================================================
export EZA_COLORS="da=1;34:di=1;34:ex=1;32:ln=1;36"
export EZA_ICONS_AUTO=1

#=============================================================================
# BASE ALIASES
#=============================================================================
alias ls='eza --icons --group-directories-first'
alias l='eza -l --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias la='eza -a --icons --group-directories-first'
alias l.='eza -d .* --icons'

#=============================================================================
# TREE VIEWS
#=============================================================================
alias lt='eza -T --icons --level=2'
alias lt1='eza -T --icons --level=1'
alias lt2='eza -T --icons --level=2'
alias lt3='eza -T --icons --level=3'
alias lt4='eza -T --icons --level=4'
alias lta='eza -Ta --icons --level=2'
alias ltd='eza -TD --icons --level=3'
alias ltg='eza -T --icons --level=2 --git-ignore'

#=============================================================================
# SORTING OPTIONS
#=============================================================================
alias lm='eza -la --icons --sort=modified'           # Modified time
alias lmr='eza -la --icons --sort=modified --reverse' # Modified (oldest first)
alias lsize='eza -la --icons --sort=size'            # Size (largest first)
alias lsizer='eza -la --icons --sort=size --reverse' # Size (smallest first)
alias lext='eza -la --icons --sort=extension'        # Extension
alias lname='eza -la --icons --sort=name'            # Name (default)
alias ltype='eza -la --icons --sort=type'            # Type

#=============================================================================
# FILTERED VIEWS
#=============================================================================
alias ldir='eza -lD --icons'                         # Directories only
alias lfile='eza -lf --icons'                        # Files only
alias llink='eza -la --icons | grep "^l"'            # Links only
alias lexec='eza -la --icons | grep "^-..x"'         # Executables

#=============================================================================
# GIT INTEGRATION
#=============================================================================
alias lg='eza -la --icons --git'                     # With git status
alias lgi='eza -la --icons --git --git-ignore'       # Respect .gitignore
alias lgm='eza -la --icons --git | grep "M "'        # Modified files
alias lga='eza -la --icons --git | grep "N "'        # New/added files

#=============================================================================
# SPECIAL VIEWS
#=============================================================================
alias lh='eza -la --icons --sort=modified | head -20' # Latest 20
alias lrecent='eza -la --icons --sort=modified | head -10'
alias lbig='eza -la --icons --sort=size | head -20'   # Biggest 20
alias lold='eza -la --icons --sort=modified --reverse | head -20'

#=============================================================================
# RECURSIVE VIEWS
#=============================================================================
alias lr='eza -laR --icons --level=2'                # Recursive 2 levels
alias lr3='eza -laR --icons --level=3'               # Recursive 3 levels

#=============================================================================
# HEADER AND FORMATTING
#=============================================================================
alias lH='eza -la --icons --header'                  # With column headers
alias lno='eza -la --no-icons'                       # Without icons
alias lw='eza -la --icons --no-permissions --no-user --no-time' # Wide (minimal)

#=============================================================================
# FUNCTIONS
#=============================================================================

# List with custom depth tree
function ltn() {
    local depth="${1:-2}"
    shift
    eza -T --icons --level="$depth" "$@"
}

# Find and list files matching pattern
function lf() {
    local pattern="$1"
    shift
    eza -la --icons "$@" | grep -i "$pattern"
}

# List files modified within N days
function ldays() {
    local days="${1:-7}"
    find . -maxdepth 1 -mtime -"$days" -exec eza -ld --icons {} +
}

# List files larger than size
function llarger() {
    local size="${1:-1M}"
    find . -maxdepth 1 -size +"$size" -exec eza -ld --icons {} +
}

# Interactive directory browser with preview
function lf() {
    local dir="${1:-.}"
    local selected
    selected=$(eza -la --icons "$dir" | fzf --ansi \
        --preview 'f=$(echo {} | awk "{print \$NF}"); [[ -d "$f" ]] && eza -la --icons "$f" || bat --style=numbers --color=always "$f" 2>/dev/null' \
        --preview-window 'right:60%')
    
    if [[ -n "$selected" ]]; then
        local file=$(echo "$selected" | awk '{print $NF}')
        if [[ -d "$file" ]]; then
            cd "$file"
        else
            ${EDITOR:-nvim} "$file"
        fi
    fi
}

# List directory sizes
function ldsize() {
    local dir="${1:-.}"
    for d in "$dir"/*/; do
        [[ -d "$d" ]] && echo "$(du -sh "$d" 2>/dev/null | cut -f1) $(eza -d --icons "$d")"
    done | sort -h
}

# Quick directory stats
function lstats() {
    local dir="${1:-.}"
    echo "╭─ Directory Statistics ─╮"
    echo "  Files:       $(find "$dir" -maxdepth 1 -type f | wc -l)"
    echo "  Directories: $(find "$dir" -maxdepth 1 -type d | wc -l)"
    echo "  Hidden:      $(find "$dir" -maxdepth 1 -name '.*' | wc -l)"
    echo "  Total size:  $(du -sh "$dir" 2>/dev/null | cut -f1)"
    echo "╰─────────────────────────╯"
}

# Preview function for fzf (used by other modules)
function eza-preview() {
    if [[ -d "$1" ]]; then
        eza -la --color=always --icons "$1" | head -30
    elif [[ -f "$1" ]]; then
        bat --style=numbers --color=always "$1" 2>/dev/null | head -30
    fi
}

#=============================================================================
# AUTO-LS AFTER CD
#=============================================================================

# Uncomment to enable auto-ls after cd
# function chpwd() {
#     eza --icons --group-directories-first
# }

# Or shorter list
function chpwd_eza() {
    eza -a --icons --group-directories-first | head -20
    local total=$(eza -a | wc -l)
    [[ $total -gt 20 ]] && echo "... and $((total - 20)) more"
}

# Enable with: add-zsh-hook chpwd chpwd_eza
