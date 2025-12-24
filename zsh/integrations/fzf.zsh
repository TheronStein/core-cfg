# ~/.core/zsh/integrations/fzf.zsh
# Consolidated FZF configuration with theme system integration
# Includes core config, functions, widgets, and fzf-tab integration

# =============================================================================
# EARLY EXIT IF FZF NOT AVAILABLE
# =============================================================================
(( $+commands[fzf] )) || return 0

# =============================================================================
# PATHS AND VARIABLES
# =============================================================================
export FZF_PREVIEW="${CORE_CFG:-$HOME/.core/.sys/cfg}/zsh/tools/fzf-preview"

# Ensure preview script is executable
[[ -x "$FZF_PREVIEW" ]] || chmod +x "$FZF_PREVIEW" 2>/dev/null

# =============================================================================
# THEME SYSTEM - Load the theme management functions
# =============================================================================
source "${CORE_CFG:-$HOME/.core/.sys/cfg}/zsh/functions/fzf-theme"

# Initialize saved theme preferences
fzf-theme-init

# =============================================================================
# FZF COMMANDS (fd integration)
# =============================================================================
if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
    export FZF_ALT_C_COMMAND='find . -type d -not -path "*/\.git/*"'
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# =============================================================================
# CONTEXT-SPECIFIC FZF OPTIONS
# =============================================================================
export FZF_CTRL_T_OPTS="
    --preview 'bash \"$FZF_PREVIEW\" {} 2>/dev/null'
    --preview-window='right:60%:wrap'
    --bind='ctrl-/:toggle-preview'
    --header='Files | C-/: toggle preview | C-y: copy'
"

export FZF_ALT_C_OPTS="
    --preview 'bash \"$FZF_PREVIEW\" {} 2>/dev/null'
    --preview-window='right:40%:wrap'
    --header='Directories | C-/: toggle preview'
"

export FZF_CTRL_R_OPTS="
    --preview 'echo {} | sed \"s/^ *[0-9]* *//\" | bat --style=plain --color=always -l bash 2>/dev/null || echo {}'
    --preview-window='down:3:wrap'
    --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
    --header='History | C-y: copy command'
    --exact
"

# =============================================================================
# FZF COMPLETION FUNCTIONS
# =============================================================================
_fzf_compgen_path() {
    fd --hidden --follow --exclude .git . "$1" 2>/dev/null || \
    find "$1" -type f -not -path '*/\.git/*' 2>/dev/null
}

_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude .git . "$1" 2>/dev/null || \
    find "$1" -type d -not -path '*/\.git/*' 2>/dev/null
}

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd)           fzf --preview "bash \"$FZF_PREVIEW\" {} 2>/dev/null" "$@" ;;
        export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
        ssh)          fzf --preview 'dig +short {} 2>/dev/null || echo "Host: {}"' "$@" ;;
        git)          fzf --preview 'git log --oneline --graph --color=always {} 2>/dev/null | head -20' "$@" ;;
        kill)         fzf --preview 'ps -p {} -o comm,pid,user,time,stat 2>/dev/null || echo "PID: {}"' "$@" ;;
        *)            fzf --preview "bash \"$FZF_PREVIEW\" {} 2>/dev/null" "$@" ;;
    esac
}

# =============================================================================
# CORE HELPER FUNCTIONS (Used by widgets in 03-widgets.zsh)
# =============================================================================

# Get current theme colors for fzf
_fzf_colors() {
    # Return the current FZF color scheme
    # Falls back to a sensible default if not set
    if [[ -n "${FZF_DEFAULT_OPTS_COLORS:-}" ]]; then
        echo "$FZF_DEFAULT_OPTS_COLORS"
    elif [[ -n "${_FZF_THEME_COLORS:-}" ]]; then
        echo "$_FZF_THEME_COLORS"
    else
        # Default dark theme colors
        echo "bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    fi
}

# Get base fzf options for widgets
_fzf_base_opts() {
    local colors="$(_fzf_colors)"
    echo "--height=80% --layout=reverse --border=rounded --info=inline --color='$colors'"
}

# =============================================================================
# GIT HELPER FUNCTIONS
# =============================================================================

# Git: fuzzy add files
function fzf-git-add() {
    local files
    files=$(git status --short 2>/dev/null | \
        fzf --multi --ansi \
            --preview 'git diff --color=always -- {-1} 2>/dev/null | delta 2>/dev/null || git diff --color=always -- {-1}' \
            --header 'Select files to stage (Tab to multi-select)' \
            --bind 'ctrl-a:select-all,ctrl-d:deselect-all' | \
        awk '{print $2}')

    if [[ -n "$files" ]]; then
        echo "$files" | xargs git add
        git status --short
    fi
}

# Git: fuzzy checkout/restore files
function fzf-git-checkout-file() {
    local files
    files=$(git diff --name-only 2>/dev/null | \
        fzf --multi --ansi \
            --preview 'git diff --color=always -- {} 2>/dev/null | delta 2>/dev/null || git diff --color=always -- {}' \
            --header 'Select files to restore' | \
        tr '\n' ' ')

    if [[ -n "$files" ]]; then
        git checkout -- $files
    fi
}

# Docker: view logs with fuzzy container selection
function fzf-docker-logs() {
    local container
    container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null | \
        fzf --header-lines=1 \
            --preview 'docker logs --tail 50 $(echo {} | awk "{print \$1}") 2>&1' | \
        awk '{print $1}')

    if [[ -n "$container" ]]; then
        docker logs -f "$container"
    fi
}

# Docker: exec into container
function fzf-docker-exec() {
    local container
    container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null | \
        fzf --header-lines=1 \
            --preview 'docker inspect $(echo {} | awk "{print \$1}") 2>/dev/null | head -30' | \
        awk '{print $1}')

    if [[ -n "$container" ]]; then
        local cmd="${1:-/bin/bash}"
        docker exec -it "$container" "$cmd"
    fi
}

# Man pages: fuzzy search
function fzf-man() {
    local page
    page=$(apropos . 2>/dev/null | \
        fzf --preview 'man $(echo {} | awk "{print \$1}") 2>/dev/null | head -50' | \
        awk '{print $1}')

    if [[ -n "$page" ]]; then
        man "$page"
    fi
}

# Systemd: fuzzy service management
function fzf-systemctl() {
    local unit
    unit=$(systemctl list-units --all --no-legend 2>/dev/null | \
        fzf --preview 'SYSTEMD_COLORS=1 systemctl status $(echo {} | awk "{print \$1}") 2>/dev/null | head -30' \
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

# Package management: fuzzy install (Arch)
function fzf-pacman-install() {
    local packages
    local installer="${1:-paru}"

    if command -v "$installer" &>/dev/null; then
        packages=$($installer -Slq 2>/dev/null | \
            fzf --multi --preview "$installer -Si {} 2>/dev/null" \
                --header 'Select packages to install (Tab to multi-select)')

        if [[ -n "$packages" ]]; then
            echo "$packages" | xargs $installer -S
        fi
    else
        echo "Package manager $installer not found"
    fi
}

# Kill process on port
function fzf-kill-port() {
    local process
    process=$(ss -tulpn 2>/dev/null | grep LISTEN | \
        fzf --header 'Select port to kill process' \
            --preview 'echo {} | grep -oP "pid=\K[0-9]+" | xargs ps -p 2>/dev/null' | \
        grep -oP 'pid=\K[0-9]+')

    if [[ -n "$process" ]]; then
        kill -9 "$process"
        echo "Killed process $process"
    fi
}

# NPM scripts: fuzzy run
function fzf-npm-scripts() {
    [[ ! -f package.json ]] && { echo "No package.json found"; return 1; }

    local script
    script=$(jq -r '.scripts | keys[]' package.json 2>/dev/null | \
        fzf --preview 'jq -r ".scripts.\"{}\"" package.json' \
            --preview-window 'down:3:wrap' \
            --header 'Select npm script to run')

    if [[ -n "$script" ]]; then
        npm run "$script"
    fi
}

# Environment variables: fuzzy view/edit
function fzf-environment() {
    local var
    var=$(env | sort | \
        fzf --preview 'echo {} | cut -d= -f2-' \
            --preview-window 'down:3:wrap' \
            --header 'Environment Variables' | \
        cut -d= -f1)

    if [[ -n "$var" ]]; then
        echo "Current value: ${(P)var}"
        echo -n "New value (empty to cancel): "
        read new_value
        if [[ -n "$new_value" ]]; then
            export "$var=$new_value"
            echo "Updated $var"
        fi
    fi
}

# WiFi: fuzzy network selection
function fzf-wifi() {
    (( $+commands[nmcli] )) || { echo "nmcli not found"; return 1; }

    local network
    network=$(nmcli device wifi list 2>/dev/null | sed 1d | \
        fzf --preview 'echo "Signal: $(echo {} | awk \"{print \$7}\")"' \
            --header 'Select WiFi network' | \
        sed 's/^[* ] //' | awk '{print $2}')

    if [[ -n "$network" ]]; then
        nmcli device wifi connect "$network"
    fi
}

# Clipboard history (cliphist)
function fzf-cliphist() {
    (( $+commands[cliphist] )) || { echo "cliphist not found"; return 1; }
    (( $+commands[wl-copy] )) || { echo "wl-copy not found"; return 1; }

    local selection
    selection=$(cliphist list 2>/dev/null | \
        fzf --preview 'echo {} | cliphist decode 2>/dev/null' \
            --preview-window 'down:3:wrap' \
            --header 'Clipboard History | Enter: copy to clipboard')

    if [[ -n "$selection" ]]; then
        echo "$selection" | cliphist decode | wl-copy
        echo "Copied to clipboard"
    fi
}

# Tmux layouts: fuzzy selection
function fzf-tmux-layouts() {
    [[ -z "$TMUX" ]] && { echo "Not in a tmux session"; return 1; }

    local layouts=(
        "even-horizontal|Split panes evenly horizontally"
        "even-vertical|Split panes evenly vertically"
        "main-horizontal|One large pane on top, others below"
        "main-vertical|One large pane on left, others on right"
        "tiled|Tile all panes evenly"
    )

    local selection
    selection=$(printf '%s\n' "${layouts[@]}" | \
        fzf --delimiter='|' \
            --with-nth=1,2 \
            --header='Select tmux layout' | \
        cut -d'|' -f1)

    if [[ -n "$selection" ]]; then
        tmux select-layout "$selection"
        echo "Applied layout: $selection"
    fi
}

# =============================================================================
# ALIASES
# =============================================================================
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
alias fclip='fzf-cliphist'
alias flayout='fzf-tmux-layouts'

# =============================================================================
# ZLE WIDGETS AND KEYBINDINGS
# =============================================================================
# Load system fzf keybindings
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

# Register git helpers as ZLE widgets
zle -N fzf-git-add
zle -N fzf-git-checkout-file

# Keybinding for git add
if ! bindkey | grep -q "fzf-git-add"; then
    bindkey '^G^A' fzf-git-add
fi

# =============================================================================
# FZF-TAB CONFIGURATION
# =============================================================================
# NOTE: Core fzf-tab settings are applied in 02-zinit.zsh during plugin load
# via the atload ice. This ensures settings are applied AFTER fzf-tab initializes.
#
# This section provides additional runtime configuration and helper functions
# that can be used after the shell is fully initialized.

# Function to update fzf-tab theme colors at runtime
# Called by fzf-theme-apply when user changes themes
_fzf_update_tab_theme() {
    local colors="${1:-${_FZF_THEME_COLORS:-}}"
    if [[ -n "$colors" ]]; then
        zstyle ':fzf-tab:*' fzf-flags \
            --height=60% \
            --color="$colors" \
            --bind='ctrl-/:toggle-preview' \
            --bind='ctrl-a:select-all' \
            --bind='ctrl-d:deselect-all'
    fi
}

# =============================================================================
# TMUX INTEGRATION
# =============================================================================
if [[ -n "$TMUX" ]]; then
    export FZF_TMUX_OPTS="-p 80%,80%"
fi

# =============================================================================
# ADDITIONAL FZF FUNCTIONS (legacy support)
# =============================================================================

# Directory change with preview
function fcd-zle() {
    local dir
    dir=$(fd ${1:-.} --prune -td 2>/dev/null | fzf +m)
    if [[ -d "$dir" ]]; then
        builtin cd "$dir"
        (($+WIDGET)) && zle zredraw-prompt
    else
        (($+WIDGET)) && zle redisplay
    fi
}
zle -N fcd-zle

# Foreground job selector
function f1fg() {
    local job
    job="$(builtin jobs 2>/dev/null | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')"
    [[ -n "$job" ]] && print '' && fg %$job
}

# SSH host selector
function f1ssh() {
    local -a hosts
    local choice

    hosts=( ${=${${${${(@M)${(f)"$(<$HOME/.ssh/config)"}}:#Host *}#Host }:#*\**}:#*\?*} )
    choice=$(builtin print -rl "$hosts[@]" | fzf +m)

    [[ -n $choice ]] && command ssh $choice
}

# Load fzf-fig functions
[[ -f "${CORE_CFG:-$HOME/.core/.sys/cfg}/zsh/functions/fzf-fig" ]] && \
    source "${CORE_CFG:-$HOME/.core/.sys/cfg}/zsh/functions/fzf-fig"

# Load layout switcher (backwards compatibility)
[[ -f "${CORE_CFG:-$HOME/.core/.sys/cfg}/zsh/functions/fzf-layouts.zsh" ]] && \
    source "${CORE_CFG:-$HOME/.core/.sys/cfg}/zsh/functions/fzf-layouts.zsh"
