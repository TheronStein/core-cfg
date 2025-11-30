# ~/.core/zsh/modules/wezterm.zsh
# WezTerm Integration - OSC sequences, shell integration, and helper functions

#=============================================================================
# CHECK FOR WEZTERM
#=============================================================================
[[ "$TERM_PROGRAM" == "WezTerm" ]] || return 0

#=============================================================================
# ENVIRONMENT
#=============================================================================
export WEZTERM_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm/wezterm.lua"

#=============================================================================
# OSC (Operating System Command) SEQUENCES
# WezTerm supports various OSC sequences for rich terminal features
#=============================================================================

# Set terminal title
function wezterm-title() {
    printf '\033]0;%s\007' "$*"
}

# Set tab title
function wezterm-tab-title() {
    printf '\033]1;%s\007' "$*"
}

# Set window title
function wezterm-window-title() {
    printf '\033]2;%s\007' "$*"
}

# OSC 7: Notify shell of current working directory
# This enables WezTerm to open new tabs/panes in the same directory
function wezterm-set-cwd() {
    printf '\033]7;file://%s%s\033\\' "$HOST" "$PWD"
}

# Hook into cd to update cwd (using add-zsh-hook to avoid conflicts)
autoload -Uz add-zsh-hook
add-zsh-hook chpwd wezterm-set-cwd

# Set initial cwd
wezterm-set-cwd

#=============================================================================
# OSC 133: SEMANTIC ZONES (Shell Integration)
# Marks command prompts and outputs for better navigation
#=============================================================================

# Mark prompt start
function wezterm-prompt-start() {
    printf '\033]133;A\007'
}

# Mark command start (after prompt)
function wezterm-cmd-start() {
    printf '\033]133;B\007'
}

# Mark command executed
function wezterm-cmd-executed() {
    printf '\033]133;C\007'
}

# Mark command finished with exit status
function wezterm-cmd-finished() {
    printf '\033]133;D;%s\007' "$1"
}

# Integration hooks (using add-zsh-hook to avoid conflicts with p10k)
autoload -Uz add-zsh-hook

function _wezterm_precmd() {
    wezterm-cmd-finished "$?"
    wezterm-prompt-start
}

function _wezterm_preexec() {
    wezterm-cmd-start
}

# Only add hooks if ZLE is available (interactive shell)
if [[ -o zle ]]; then
    add-zsh-hook precmd _wezterm_precmd
    add-zsh-hook preexec _wezterm_preexec
fi

#=============================================================================
# OSC 1337: EXTENDED FEATURES
#=============================================================================

# Set user variable (accessible in WezTerm config)
function wezterm-set-var() {
    local name="$1"
    local value="$2"
    printf '\033]1337;SetUserVar=%s=%s\007' "$name" "$(echo -n "$value" | base64)"
}

# File hyperlink (clickable file paths)
function wezterm-hyperlink() {
    local url="$1"
    local text="${2:-$url}"
    printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$url" "$text"
}

# Notify (shows notification)
function wezterm-notify() {
    local title="${1:-Notification}"
    local body="${2:-}"
    printf '\033]777;notify;%s;%s\007' "$title" "$body"
}

# Toast notification
function wezterm-toast() {
    printf '\033]9;%s\007' "$*"
}

#=============================================================================
# OSC 52: CLIPBOARD
#=============================================================================

# Copy to clipboard via OSC 52
function wezterm-copy() {
    local data
    if [[ -n "$1" ]]; then
        data="$1"
    else
        data=$(cat)
    fi
    printf '\033]52;c;%s\007' "$(echo -n "$data" | base64)"
}

# Copy current command line to clipboard
function wezterm-copy-cmd() {
    wezterm-copy "$BUFFER"
    zle -M "Copied to clipboard via OSC 52"
}
zle -N wezterm-copy-cmd
bindkey '^[Y' wezterm-copy-cmd  # Alt+Shift+Y

#=============================================================================
# IMAGE DISPLAY (iTerm2 protocol, supported by WezTerm)
#=============================================================================

# Display image inline in terminal
function wezterm-imgcat() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "File not found: $file"
        return 1
    fi
    
    local width="${2:-auto}"
    local height="${3:-auto}"
    local data=$(base64 < "$file")
    
    printf '\033]1337;File=inline=1;width=%s;height=%s:%s\007' \
        "$width" "$height" "$data"
}

# Display image from URL
function wezterm-imgurl() {
    local url="$1"
    local tmp=$(mktemp)
    curl -sL "$url" > "$tmp"
    wezterm-imgcat "$tmp"
    rm -f "$tmp"
}

# Quick image preview (for file managers/scripts)
function imgpreview() {
    if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
        wezterm-imgcat "$1"
    else
        # Fallback to other tools
        command -v chafa &>/dev/null && chafa "$1"
    fi
}

#=============================================================================
# MULTIPLEXING HELPERS
# WezTerm has built-in multiplexing (tabs, panes, workspaces)
#=============================================================================

# Open new tab in current directory
function wezterm-new-tab() {
    wezterm cli spawn --cwd "$PWD" "$@"
}

# Open new pane (split)
function wezterm-split-h() {
    wezterm cli split-pane --horizontal --cwd "$PWD" "$@"
}

function wezterm-split-v() {
    wezterm cli split-pane --bottom --cwd "$PWD" "$@"
}

# Move between panes
function wezterm-pane-left() { wezterm cli activate-pane-direction Left; }
function wezterm-pane-right() { wezterm cli activate-pane-direction Right; }
function wezterm-pane-up() { wezterm cli activate-pane-direction Up; }
function wezterm-pane-down() { wezterm cli activate-pane-direction Down; }

# List panes
function wezterm-panes() {
    wezterm cli list --format json | jq -r '.[] | "\(.pane_id): \(.title) (\(.cwd))"'
}

# Focus pane by ID
function wezterm-focus() {
    wezterm cli activate-pane --pane-id "$1"
}

# Create new workspace
function wezterm-workspace() {
    local name="${1:-$(basename $PWD)}"
    wezterm cli spawn --new-window --workspace "$name" --cwd "$PWD"
}

# List workspaces
function wezterm-workspaces() {
    wezterm cli list --format json | jq -r '.[].workspace' | sort -u
}

#=============================================================================
# THEME/APPEARANCE
#=============================================================================

# Set color scheme (requires config support)
function wezterm-theme() {
    local scheme="$1"
    wezterm-set-var "color_scheme" "$scheme"
    echo "Set theme to: $scheme (requires config reload)"
}

# Toggle background opacity
function wezterm-opacity() {
    local opacity="${1:-0.9}"
    wezterm-set-var "background_opacity" "$opacity"
}

#=============================================================================
# QUICK ACTIONS
#=============================================================================

# Open configuration
function wezterm-config() {
    ${EDITOR:-nvim} "$WEZTERM_CONFIG_FILE"
}

# Reload configuration
function wezterm-reload() {
    wezterm cli spawn -- wezterm cli activate-tab-relative 0
    echo "Configuration reloaded"
}

# Show WezTerm info
function wezterm-info() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      WEZTERM INFO                            ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║ Version:    $(wezterm --version 2>/dev/null || echo 'Unknown')"
    echo "║ Config:     $WEZTERM_CONFIG_FILE"
    echo "║ TERM:       $TERM"
    echo "║ Pane ID:    ${WEZTERM_PANE:-Unknown}"
    echo "╚══════════════════════════════════════════════════════════════╝"
}

#=============================================================================
# FZF INTEGRATION
#=============================================================================

# Select and focus pane
function wezterm-fzf-pane() {
    local pane
    pane=$(wezterm cli list --format json | \
        jq -r '.[] | "\(.pane_id): \(.title)"' | \
        fzf --header '╭─ WezTerm Panes ─╮')
    
    if [[ -n "$pane" ]]; then
        local pane_id=$(echo "$pane" | cut -d: -f1)
        wezterm cli activate-pane --pane-id "$pane_id"
    fi
}

# Select workspace
function wezterm-fzf-workspace() {
    local ws
    ws=$(wezterm cli list --format json | \
        jq -r '.[].workspace' | sort -u | \
        fzf --header '╭─ WezTerm Workspaces ─╮')
    
    [[ -n "$ws" ]] && echo "Selected workspace: $ws"
}

#=============================================================================
# ALIASES
#=============================================================================
alias wez='wezterm'
alias wezc='wezterm-config'
alias wezr='wezterm-reload'
alias wezi='wezterm-info'
alias wezt='wezterm-new-tab'
alias wezh='wezterm-split-h'
alias wezv='wezterm-split-v'
alias wezp='wezterm-panes'
