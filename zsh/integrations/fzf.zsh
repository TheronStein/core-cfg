# ~/.core/zsh/integrations/fzf.zsh
# FZF Integration - Advanced fuzzy finding configuration with rich previews
# Dependencies: fzf, fd, ripgrep, bat, delta, eza, jq

#=============================================================================
# CHECK FOR FZF
#=============================================================================
(( $+commands[fzf] )) || return 0

#=============================================================================
# FZF ENVIRONMENT CONFIGURATION
#=============================================================================
# Use fd for file listing (respects .gitignore)
if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
    export FZF_ALT_C_COMMAND='find . -type d -not -path "*/\.git/*"'
fi

# Ctrl+T file selector command
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

#=============================================================================
# FZF APPEARANCE & BEHAVIOR
#=============================================================================
export FZF_DEFAULT_OPTS="
    --height=80%
    --layout=reverse
    --border=rounded
    --info=inline
    --margin=1
    --padding=1
    --prompt='❯ '
    --pointer='▶'
    --marker='✓'
    --header-first
    --ansi
    --cycle
    --multi
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-a:select-all'
    --bind='ctrl-d:deselect-all'
    --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
    --bind='ctrl-u:preview-page-up'
    --bind='ctrl-n:preview-page-down'
    --bind='alt-j:preview-down'
    --bind='alt-k:preview-up'
    --bind='ctrl-f:page-down'
    --bind='ctrl-b:page-up'
    --bind='tab:toggle+down'
    --bind='shift-tab:toggle+up'
    --preview-window='right:60%:wrap:hidden'
    --color='bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8'
    --color='fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc'
    --color='marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
    --color='selected-bg:#45475a'
"

# Ctrl+T specific options (file preview)
export FZF_CTRL_T_OPTS="
    --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}'
    --preview-window='right:60%:wrap'
    --bind='ctrl-/:toggle-preview'
    --header='Files | C-/: toggle preview | C-y: copy'
"

# Alt+C specific options (directory preview)
export FZF_ALT_C_OPTS="
    --preview 'eza -la --color=always --icons --group-directories-first {} 2>/dev/null'
    --preview-window='right:60%:wrap'
    --header='Directories | C-/: toggle preview'
"

# Ctrl+R specific options (history)
export FZF_CTRL_R_OPTS="
    --preview 'echo {} | sed \"s/^ *[0-9]* *//\" | bat --style=plain --color=always -l bash'
    --preview-window='down:3:wrap'
    --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
    --header='History | C-y: copy command'
    --exact
"

#=============================================================================
# FZF COMPLETION CONFIGURATION
#=============================================================================
# Use fd for path completion
_fzf_compgen_path() {
    fd --hidden --follow --exclude .git . "$1"
}

# Use fd for directory completion
_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude .git . "$1"
}

# Advanced completion preview
_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd)           fzf --preview 'eza -la --color=always --icons {}' "$@" ;;
        export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
        ssh)          fzf --preview 'dig +short {}' "$@" ;;
        git)          fzf --preview 'git log --oneline --graph --color=always {}' "$@" ;;
        kill)         fzf --preview 'ps -p {} -o comm,pid,user,time,stat' "$@" ;;
        *)            fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}' "$@" ;;
    esac
}

#=============================================================================
# HELPER FUNCTIONS
#=============================================================================

# Function: fzf-git-add
# Description: Interactive git add with diff preview
function fzf-git-add() {
    local files
    files=$(git status --short | \
        fzf --multi --ansi \
            --preview 'git diff --color=always -- {-1} | delta' \
            --preview-window 'right:60%:wrap' \
            --header 'Select files to stage' \
            --bind 'ctrl-a:select-all,ctrl-d:deselect-all' | \
        awk '{print $2}')

    if [[ -n "$files" ]]; then
        echo "$files" | xargs git add
        git status --short
    fi
}

# Function: fzf-git-checkout-file
# Description: Restore files from git with preview
function fzf-git-checkout-file() {
    local files
    files=$(git diff --name-only | \
        fzf --multi --ansi \
            --preview 'git diff --color=always -- {} | delta' \
            --preview-window 'right:60%:wrap' \
            --header 'Select files to restore' | \
        tr '\n' ' ')

    if [[ -n "$files" ]]; then
        git checkout -- $files
    fi
}

# Function: fzf-docker-logs
# Description: View docker container logs interactively
function fzf-docker-logs() {
    local container
    container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | \
        fzf --header-lines=1 \
            --preview 'docker logs --tail 50 $(echo {} | awk "{print \$1}")' \
            --preview-window 'right:60%:wrap' | \
        awk '{print $1}')

    if [[ -n "$container" ]]; then
        docker logs -f "$container"
    fi
}

# Function: fzf-docker-exec
# Description: Execute command in docker container
function fzf-docker-exec() {
    local container
    container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | \
        fzf --header-lines=1 \
            --preview 'docker inspect $(echo {} | awk "{print \$1}")' \
            --preview-window 'right:60%:wrap' | \
        awk '{print $1}')

    if [[ -n "$container" ]]; then
        local cmd="${1:-/bin/bash}"
        docker exec -it "$container" "$cmd"
    fi
}

# Function: fzf-man
# Description: Browse man pages interactively
function fzf-man() {
    local page
    page=$(apropos . | \
        fzf --preview 'man $(echo {} | awk "{print \$1}")' \
            --preview-window 'right:70%:wrap' | \
        awk '{print $1}')

    if [[ -n "$page" ]]; then
        man "$page"
    fi
}

# Function: fzf-systemctl
# Description: Manage systemd services interactively
function fzf-systemctl() {
    local unit
    unit=$(systemctl list-units --all --no-legend | \
        fzf --preview 'SYSTEMD_COLORS=1 systemctl status $(echo {} | awk "{print \$1}")' \
            --preview-window 'right:60%:wrap' \
            --header 'Select systemd unit' | \
        awk '{print $1}')

    if [[ -n "$unit" ]]; then
        local action
        action=$(echo -e "status\nstart\nstop\nrestart\nenable\ndisable\nlogs" | \
            fzf --header "Select action for $unit")

        case "$action" in
            logs) journalctl -u "$unit" -f ;;
            status|start|stop|restart|enable|disable) sudo systemctl "$action" "$unit" ;;
        esac
    fi
}

# Function: fzf-pacman-install
# Description: Search and install packages with pacman/paru
function fzf-pacman-install() {
    local packages
    local installer="${1:-paru}"

    if command -v "$installer" &>/dev/null; then
        packages=$($installer -Slq | \
            fzf --multi --preview "$installer -Si {}" \
                --preview-window 'right:60%:wrap' \
                --header 'Select packages to install')

        if [[ -n "$packages" ]]; then
            echo "$packages" | xargs $installer -S
        fi
    else
        echo "Package manager $installer not found"
    fi
}

# Function: fzf-kill-port
# Description: Find and kill process using a specific port
function fzf-kill-port() {
    local process
    process=$(ss -tulpn 2>/dev/null | grep LISTEN | \
        fzf --header 'Select port to kill process' \
            --preview 'echo {} | grep -oP "pid=\K[0-9]+" | xargs ps -p' | \
        grep -oP 'pid=\K[0-9]+')

    if [[ -n "$process" ]]; then
        kill -9 "$process"
        echo "Killed process $process"
    fi
}

# Function: fzf-npm-scripts
# Description: Run npm scripts interactively
function fzf-npm-scripts() {
    [[ ! -f package.json ]] && echo "No package.json found" && return 1

    local script
    script=$(jq -r '.scripts | keys[]' package.json 2>/dev/null | \
        fzf --preview 'jq -r ".scripts.\"{}\"" package.json' \
            --preview-window 'down:3:wrap' \
            --header 'Select npm script to run')

    if [[ -n "$script" ]]; then
        npm run "$script"
    fi
}

# Function: fzf-environment
# Description: Browse and edit environment variables
function fzf-environment() {
    local var
    var=$(env | sort | \
        fzf --preview 'echo {} | cut -d= -f2-' \
            --preview-window 'down:3:wrap' \
            --header 'Environment Variables' | \
        cut -d= -f1)

    if [[ -n "$var" ]]; then
        echo "Current value: ${(P)var}"
        echo -n "New value: "
        read new_value
        if [[ -n "$new_value" ]]; then
            export "$var=$new_value"
            echo "Updated $var"
        fi
    fi
}

# Function: fzf-wifi
# Description: Connect to WiFi networks (requires nmcli)
function fzf-wifi() {
    (( $+commands[nmcli] )) || { echo "nmcli not found"; return 1; }

    local network
    network=$(nmcli device wifi list | sed 1d | \
        fzf --preview 'echo "Signal: $(echo {} | awk "{print \$7}")"' \
            --header 'Select WiFi network' | \
        sed 's/^[* ] //' | awk '{print $2}')

    if [[ -n "$network" ]]; then
        nmcli device wifi connect "$network"
    fi
}

#=============================================================================
# ALIASES
#=============================================================================
alias fga='fzf-git-add'
alias fgco='fzf-git-checkout-file'
alias fdl='fzf-docker-logs'
alias fde='fzf-docker-exec'
alias fman='fzf-man'
alias fsys='fzf-systemctl'
alias fpac='fzf-pacman-install'
alias fkill='fzf-kill-port'
alias fnpm='fzf-npm-scripts'
alias fenv='fzf-environment'
alias fwifi='fzf-wifi'

#=============================================================================
# KEY BINDINGS (if not already set)
#=============================================================================
# Load fzf key bindings and completion
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

# Register FZF git functions as widgets
zle -N fzf-git-add
zle -N fzf-git-checkout-file

# Custom bindings (only if not already bound)
if ! bindkey | grep -q "fzf-git-add"; then
    bindkey '^G^A' fzf-git-add
fi

#=============================================================================
# TMUX INTEGRATION
#=============================================================================
# Use tmux popup if available
if [[ -n "$TMUX" ]]; then
    export FZF_TMUX_OPTS="-p 80%,80%"

    # Function to use tmux popup for fzf
    ftb-tmux-popup() {
        fzf-tmux -p 80%,80% "$@"
    }
fi