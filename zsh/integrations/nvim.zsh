# ~/.core/zsh/modules/nvim.zsh
# Neovim Integration - shell helpers, session management, and remote control

#=============================================================================
# CHECK FOR NEOVIM
#=============================================================================
(( $+commands[nvim] )) || return 0

#=============================================================================
# ENVIRONMENT CONFIGURATION
#=============================================================================
export EDITOR="nvim"
export VISUAL="nvim"
export NVIM_APPNAME="${NVIM_APPNAME:-nvim}"
export MANPAGER="nvim +Man!"

#=============================================================================
# BASIC ALIASES
#=============================================================================
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'

# Quick edits for common files
alias e.='nvim .'
alias e-='nvim -'  # Read from stdin

#=============================================================================
# NVIM CONFIG VARIATIONS
# Use different configs with NVIM_APPNAME
#=============================================================================

# Switch nvim config temporarily
function nvim-with() {
    NVIM_APPNAME="$1" nvim "${@:2}"
}

# Available configs (customize for your setup)
alias nvim-lazy='NVIM_APPNAME=lazyvim nvim'
alias nvim-chad='NVIM_APPNAME=nvchad nvim'
alias nvim-astro='NVIM_APPNAME=astronvim nvim'
alias nvim-minimal='nvim -u NONE'
alias nvim-clean='nvim --clean'

# List available nvim configs
function nvim-configs() {
    echo "╭─ Available Neovim Configurations ─╮"
    for dir in ~/.config/*/init.lua ~/.config/*/init.vim; do
        [[ -f "$dir" ]] && echo "  $(dirname $dir | xargs basename)"
    done
    echo "╰───────────────────────────────────╯"
    echo "Current: ${NVIM_APPNAME:-nvim}"
}

#=============================================================================
# NVIM SERVER/CLIENT MODE
# For terminal multiplexer integration
#=============================================================================

# Start nvim as a server
function nvim-server() {
    local socket="${1:-/tmp/nvim-server-$USER}"
    nvim --listen "$socket"
}

# Connect to nvim server
function nvim-client() {
    local socket="${1:-/tmp/nvim-server-$USER}"
    if [[ -S "$socket" ]]; then
        nvim --server "$socket" --remote "${@:2}"
    else
        echo "No nvim server at $socket"
        echo "Start with: nvim-server $socket"
        return 1
    fi
}

# Send command to nvim server
function nvim-cmd() {
    local socket="${1:-/tmp/nvim-server-$USER}"
    if [[ -S "$socket" ]]; then
        nvim --server "$socket" --remote-send "${@:2}"
    else
        echo "No nvim server at $socket"
        return 1
    fi
}

# Open file in existing nvim server or start new
function nvo() {
    local socket="/tmp/nvim-server-$USER"
    if [[ -S "$socket" ]]; then
        nvim --server "$socket" --remote "$@"
    else
        nvim "$@"
    fi
}

#=============================================================================
# NVIM + FZF INTEGRATION
#=============================================================================

# Edit files selected with fzf
function nvf() {
    local files
    files=$(fzf --multi \
        --preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null' \
        --preview-window 'right:60%:wrap' \
        --header '╭─ Select files to edit ─╮')
    [[ -n "$files" ]] && nvim ${(f)files}
}

# Edit file at line (from grep/ripgrep output)
function nvl() {
    local selection
    selection=$(rg --line-number --color=always "${@:-.}" | \
        fzf --ansi --delimiter ':' \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
            --preview-window 'right:60%:+{2}-5')
    
    if [[ -n "$selection" ]]; then
        local file=$(echo "$selection" | cut -d: -f1)
        local line=$(echo "$selection" | cut -d: -f2)
        nvim "+$line" "$file"
    fi
}

# Edit from git status
function nvgs() {
    local files
    files=$(git status --short | \
        fzf --multi --ansi \
            --preview 'git diff --color=always -- {-1}' \
            --preview-window 'right:60%:wrap' \
            --header '╭─ Git modified files ─╮' | \
        awk '{print $2}')
    [[ -n "$files" ]] && nvim ${(f)files}
}

# Edit recent files (from nvim oldfiles)
function nvr() {
    local file
    file=$(nvim --headless -c 'echo join(v:oldfiles, "\n")' -c 'q' 2>&1 | \
        grep -v '^$' | \
        fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null | head -40' \
            --preview-window 'right:60%' \
            --header '╭─ Recent files ─╮')
    [[ -n "$file" && -f "$file" ]] && nvim "$file"
}

# Edit files containing pattern
function nvp() {
    local pattern="$1"
    if [[ -z "$pattern" ]]; then
        # echo "Usage: nvp <pattern>"
        return 1
    fi
    
    local files
    files=$(rg -l "$pattern" | \
        fzf --multi \
            --preview "rg --color=always '$pattern' {}" \
            --preview-window 'right:60%:wrap' \
            --header "╭─ Files containing: $pattern ─╮")
    [[ -n "$files" ]] && nvim ${(f)files}
}

#=============================================================================
# NVIM + TMUX INTEGRATION
#=============================================================================

# Open file in nvim pane (if exists) or new pane
function nvt() {
    if [[ -z "$TMUX" ]]; then
        nvim "$@"
        return
    fi
    
    # Check for existing nvim pane
    local nvim_pane
    nvim_pane=$(tmux list-panes -F "#{pane_id}:#{pane_current_command}" | \
        grep -E "nvim|vim" | head -1 | cut -d: -f1)
    
    if [[ -n "$nvim_pane" ]]; then
        # Send file to existing nvim
        if [[ -n "$1" ]]; then
            tmux send-keys -t "$nvim_pane" ":e $(realpath $1)" Enter
        fi
        tmux select-pane -t "$nvim_pane"
    else
        # Open new nvim
        nvim "$@"
    fi
}

# Open nvim in tmux popup
function nvpop() {
    if [[ -n "$TMUX" ]]; then
        tmux display-popup -E -w 90% -h 90% "nvim $*"
    else
        nvim "$@"
    fi
}

#=============================================================================
# NVIM + YAZI INTEGRATION
#=============================================================================

# Open yazi, then edit selected files
function nvy() {
    local tmp=$(mktemp -t "yazi-nvim.XXXXXX")
    yazi --chooser-file="$tmp" "$@" 2>/dev/null
    
    if [[ -s "$tmp" ]]; then
        nvim $(cat "$tmp")
    fi
    rm -f "$tmp"
}

#=============================================================================
# PROJECT-AWARE EDITING
#=============================================================================

# Open project root in nvim
function nvroot() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$root" ]]; then
        cd "$root"
        nvim .
    else
        nvim .
    fi
}

# Open nvim with session auto-load
function nvs() {
    local session_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/sessions"
    local session_name="${1:-$(basename $PWD)}"
    local session_file="$session_dir/${session_name}.vim"
    
    mkdir -p "$session_dir"
    
    if [[ -f "$session_file" ]]; then
        nvim -S "$session_file"
    else
        nvim -c "mks! $session_file" .
    fi
}

# List nvim sessions
function nvs-list() {
    local session_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/sessions"
    
    if [[ -d "$session_dir" ]]; then
        echo "╭─ Neovim Sessions ─╮"
        ls -1 "$session_dir"/*.vim 2>/dev/null | xargs -I {} basename {} .vim
        echo "╰───────────────────╯"
    else
        echo "No sessions found"
    fi
}

# Open session with fzf
function nvs-pick() {
    local session_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/sessions"
    local session
    
    session=$(ls -1 "$session_dir"/*.vim 2>/dev/null | \
        xargs -I {} basename {} .vim | \
        fzf --header '╭─ Select session ─╮')
    
    [[ -n "$session" ]] && nvim -S "$session_dir/$session.vim"
}

#=============================================================================
# DIFF AND MERGE
#=============================================================================

# Nvim diff mode
function nvdiff() {
    nvim -d "$@"
}

# Three-way merge with nvim
function nvmerge() {
    if [[ $# -ne 4 ]]; then
        # echo "Usage: nvmerge <local> <base> <remote> <merged>"
        return 1
    fi
    nvim -d "$1" "$2" "$3" -c "wincmd J | wincmd ="
}

# Git mergetool with nvim
function nvmergetool() {
    git mergetool --tool=nvimdiff
}

#=============================================================================
# FILE TYPE SPECIFIC OPENING
#=============================================================================

# Open with specific filetype
function nvft() {
    local ft="$1"
    shift
    nvim -c "set ft=$ft" "$@"
}

# Open as JSON (pretty formatted)
function nvjson() {
    if [[ -f "$1" ]]; then
        jq . "$1" | nvim -c "set ft=json" -
    else
        echo "$1" | jq . | nvim -c "set ft=json" -
    fi
}

# Open as YAML
function nvyaml() {
    nvim -c "set ft=yaml" "$@"
}

# Open as markdown
function nvmd() {
    nvim -c "set ft=markdown" "$@"
}

#=============================================================================
# STDIN/STDOUT HELPERS
#=============================================================================

# Edit stdin in nvim, output to stdout
function nvedit() {
    local tmp=$(mktemp)
    cat > "$tmp"
    nvim "$tmp" </dev/tty >/dev/tty
    cat "$tmp"
    rm -f "$tmp"
}

# Pipe to nvim
function nvpipe() {
    nvim -c "set bt=nofile" -
}

# Command output to nvim
function nvcmd() {
    eval "$@" | nvim -c "set bt=nofile" -
}

#=============================================================================
# QUICK CONFIG EDITING
#=============================================================================

# Edit nvim config
function nvconfig() {
    nvim "${XDG_CONFIG_HOME:-$HOME/.config}/${NVIM_APPNAME:-nvim}/init.lua"
}

# Edit common configs
function nvedit-zsh() { nvim ~/.zshrc; }
function nvedit-tmux() { nvim ~/.config/tmux/tmux.conf; }
function nvedit-hypr() { nvim ~/.config/hypr/hyprland.conf; }
function nvedit-wez() { nvim ~/.config/wezterm/wezterm.lua; }
function nvedit-yazi() { nvim ~/.config/yazi; }

#=============================================================================
# SCRATCH BUFFERS
#=============================================================================

# Open scratch buffer
function nvscratch() {
    local ft="${1:-markdown}"
    nvim -c "set bt=nofile ft=$ft"
}

# Open scratch with timestamp (for notes)
function nvnote() {
    local notes_dir="${XDG_DATA_HOME:-$HOME/.local/share}/notes"
    mkdir -p "$notes_dir"
    local note_file="$notes_dir/$(date +%Y-%m-%d).md"
    
    # Add timestamp if file exists
    if [[ -f "$note_file" ]]; then
        echo -e "\n## $(date +%H:%M)\n" >> "$note_file"
    else
        echo "# Notes for $(date +%Y-%m-%d)" > "$note_file"
        echo -e "\n## $(date +%H:%M)\n" >> "$note_file"
    fi
    
    nvim "+normal Go" "$note_file"
}

#=============================================================================
# NEOVIM HEALTH CHECK
#=============================================================================

function nvhealth() {
    nvim -c "checkhealth" -c "only"
}

#=============================================================================
# COMPLETIONS
#=============================================================================

# Complete recent files for nvr
function _nvr_files() {
    local files
    files=$(nvim --headless -c 'echo join(v:oldfiles, "\n")' -c 'q' 2>&1 | grep -v '^$')
    _describe 'recent files' files
}
(( $+functions[compdef] )) && compdef _nvr_files nvr
