# ~/.core/zsh/modules/prompt.zsh
# Prompt Configuration - custom prompt with git, virtualenv, and status indicators
# Note: This serves as a fallback when Powerlevel10k is not available

#=============================================================================
# CHECK FOR POWERLEVEL10K
# If p10k is loaded (via zinit), skip this custom prompt
#=============================================================================
if (( ${+functions[prompt_powerlevel10k_setup]} )) || [[ -n "$POWERLEVEL9K_VERSION" ]]; then
    return 0
fi

#=============================================================================
# COLORS
#=============================================================================
# Define colors for easy reference
typeset -A prompt_colors
prompt_colors=(
    reset       "%f%k"
    red         "%F{red}"
    green       "%F{green}"
    yellow      "%F{yellow}"
    blue        "%F{blue}"
    magenta     "%F{magenta}"
    cyan        "%F{cyan}"
    white       "%F{white}"
    gray        "%F{240}"
    orange      "%F{208}"
    pink        "%F{213}"
    
    # Background colors
    bg_red      "%K{red}"
    bg_green    "%K{green}"
    bg_blue     "%K{blue}"
    bg_gray     "%K{236}"
)

#=============================================================================
# PROMPT SEGMENTS
#=============================================================================

# User and host segment
function prompt_segment_user() {
    local user_color="${prompt_colors[green]}"
    local host_color="${prompt_colors[blue]}"
    
    # Root user gets red
    [[ $UID -eq 0 ]] && user_color="${prompt_colors[red]}"
    
    # SSH connection indicator
    if [[ -n "$SSH_CONNECTION" ]]; then
        echo -n "${user_color}%n${prompt_colors[gray]}@${host_color}%m${prompt_colors[reset]} "
    else
        echo -n "${user_color}%n${prompt_colors[reset]} "
    fi
}

# Directory segment
function prompt_segment_dir() {
    local dir_color="${prompt_colors[cyan]}"
    local max_length=40
    
    # Truncate long paths
    local dir="${PWD/#$HOME/~}"
    if [[ ${#dir} -gt $max_length ]]; then
        dir="...${dir: -$((max_length-3))}"
    fi
    
    echo -n "${dir_color}${dir}${prompt_colors[reset]}"
}

# Git segment
function prompt_segment_git() {
    # Check if in git repo
    local git_dir=$(git rev-parse --git-dir 2>/dev/null)
    [[ -z "$git_dir" ]] && return
    
    local branch=""
    local status_icons=""
    
    # Get branch name
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    
    # Check various states
    local git_status=$(git status --porcelain 2>/dev/null)
    
    # Staged changes
    [[ -n $(echo "$git_status" | grep "^[MADRC]") ]] && status_icons+="${prompt_colors[green]}+"
    
    # Unstaged changes
    [[ -n $(echo "$git_status" | grep "^.[MD]") ]] && status_icons+="${prompt_colors[yellow]}!"
    
    # Untracked files
    [[ -n $(echo "$git_status" | grep "^??") ]] && status_icons+="${prompt_colors[red]}?"
    
    # Stashed changes
    [[ -n $(git stash list 2>/dev/null) ]] && status_icons+="${prompt_colors[magenta]}$"
    
    # Ahead/behind
    local ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    if [[ -n "$ahead_behind" ]]; then
        local ahead=$(echo "$ahead_behind" | awk '{print $1}')
        local behind=$(echo "$ahead_behind" | awk '{print $2}')
        [[ $ahead -gt 0 ]] && status_icons+="${prompt_colors[green]}↑$ahead"
        [[ $behind -gt 0 ]] && status_icons+="${prompt_colors[red]}↓$behind"
    fi
    
    # Branch color based on state
    local branch_color="${prompt_colors[green]}"
    [[ -n "$status_icons" ]] && branch_color="${prompt_colors[yellow]}"
    
    echo -n " ${prompt_colors[gray]}on ${branch_color}${branch}${status_icons}${prompt_colors[reset]}"
}

# Python virtualenv segment
function prompt_segment_venv() {
    [[ -z "$VIRTUAL_ENV" ]] && return
    
    local venv_name=$(basename "$VIRTUAL_ENV")
    echo -n " ${prompt_colors[yellow]}(${venv_name})${prompt_colors[reset]}"
}

# Conda environment segment
function prompt_segment_conda() {
    [[ -z "$CONDA_DEFAULT_ENV" ]] && return
    [[ "$CONDA_DEFAULT_ENV" == "base" ]] && return
    
    echo -n " ${prompt_colors[green]}(conda:${CONDA_DEFAULT_ENV})${prompt_colors[reset]}"
}

# AWS profile segment
function prompt_segment_aws() {
    [[ -z "$AWS_PROFILE" ]] && return
    
    echo -n " ${prompt_colors[orange]}(aws:${AWS_PROFILE})${prompt_colors[reset]}"
}

# Kubernetes context segment
function prompt_segment_k8s() {
    [[ ! -f "$KUBECONFIG" && ! -f ~/.kube/config ]] && return
    
    local context=$(kubectl config current-context 2>/dev/null)
    [[ -z "$context" ]] && return
    
    echo -n " ${prompt_colors[blue]}(k8s:${context})${prompt_colors[reset]}"
}

# Background jobs segment
function prompt_segment_jobs() {
    local job_count=$(jobs -l | wc -l)
    [[ $job_count -eq 0 ]] && return
    
    echo -n " ${prompt_colors[magenta]}[${job_count}]${prompt_colors[reset]}"
}

# Last command duration segment
function prompt_segment_duration() {
    [[ -z "$_prompt_cmd_duration" ]] && return
    [[ $_prompt_cmd_duration -lt 5 ]] && return
    
    local duration=$_prompt_cmd_duration
    local output=""
    
    if [[ $duration -ge 3600 ]]; then
        output+="$((duration / 3600))h"
        duration=$((duration % 3600))
    fi
    if [[ $duration -ge 60 ]]; then
        output+="$((duration / 60))m"
        duration=$((duration % 60))
    fi
    if [[ $duration -gt 0 || -z "$output" ]]; then
        output+="${duration}s"
    fi
    
    echo -n " ${prompt_colors[gray]}took ${output}${prompt_colors[reset]}"
}

# Exit status segment
function prompt_segment_status() {
    local exit_code=$1
    
    if [[ $exit_code -eq 0 ]]; then
        echo -n "${prompt_colors[green]}❯${prompt_colors[reset]}"
    else
        echo -n "${prompt_colors[red]}❯${prompt_colors[reset]}"
    fi
}

#=============================================================================
# COMMAND TIMING
#=============================================================================
_prompt_cmd_start_time=""
_prompt_cmd_duration=""

function prompt_preexec() {
    _prompt_cmd_start_time=$SECONDS
}

function prompt_precmd() {
    local exit_code=$?
    
    # Calculate duration
    if [[ -n "$_prompt_cmd_start_time" ]]; then
        _prompt_cmd_duration=$((SECONDS - _prompt_cmd_start_time))
        _prompt_cmd_start_time=""
    else
        _prompt_cmd_duration=""
    fi
    
    # Store exit code for prompt
    _prompt_last_exit=$exit_code
}

#=============================================================================
# BUILD PROMPT
#=============================================================================

function build_prompt() {
    local exit_code=${_prompt_last_exit:-0}
    
    # Line 1: Info line
    echo -n "\n"
    prompt_segment_user
    prompt_segment_dir
    prompt_segment_git
    prompt_segment_venv
    prompt_segment_conda
    prompt_segment_aws
    prompt_segment_jobs
    prompt_segment_duration
    
    # Line 2: Input line
    echo -n "\n"
    prompt_segment_status $exit_code
    echo -n " "
}

function build_rprompt() {
    # Time on right side
    echo -n "${prompt_colors[gray]}%D{%H:%M}${prompt_colors[reset]}"
}

#=============================================================================
# SET PROMPT
#=============================================================================
setopt PROMPT_SUBST

# Add hooks
autoload -Uz add-zsh-hook
add-zsh-hook preexec prompt_preexec
add-zsh-hook precmd prompt_precmd

# Set prompts
PROMPT='$(build_prompt)'
RPROMPT='$(build_rprompt)'

# Continuation prompt
PROMPT2='${prompt_colors[gray]}… ${prompt_colors[reset]}'

# Selection prompt
PROMPT3='${prompt_colors[yellow]}?# ${prompt_colors[reset]}'

# Trace prompt (for debugging)
PROMPT4='${prompt_colors[gray]}+%N:%i> ${prompt_colors[reset]}'

#=============================================================================
# TRANSIENT PROMPT (optional)
# Simplifies prompt after command execution
#=============================================================================

function prompt_transient_enable() {
    function zle-line-finish() {
        PROMPT='${prompt_colors[gray]}❯${prompt_colors[reset]} '
        zle reset-prompt
    }
    zle -N zle-line-finish
    
    function zle-line-init() {
        PROMPT='$(build_prompt)'
        zle reset-prompt
    }
    zle -N zle-line-init
}

# Uncomment to enable transient prompt
# prompt_transient_enable

#=============================================================================
# VI MODE INDICATOR (optional)
#=============================================================================

function prompt_vi_mode_enable() {
    function zle-keymap-select() {
        case $KEYMAP in
            vicmd)
                PROMPT="${prompt_colors[yellow]}❮${prompt_colors[reset]} "
                ;;
            viins|main)
                PROMPT='$(build_prompt)'
                ;;
        esac
        zle reset-prompt
    }
    zle -N zle-keymap-select
}

# Uncomment to enable vi mode indicator
# prompt_vi_mode_enable

#=============================================================================
# WINDOW TITLE
#=============================================================================

function prompt_set_title() {
    local title="${1:-}"
    
    case "$TERM" in
        xterm*|rxvt*|alacritty|wezterm)
            print -Pn "\e]0;${title}\a"
            ;;
        screen*|tmux*)
            print -Pn "\ek${title}\e\\"
            ;;
    esac
}

function prompt_title_precmd() {
    prompt_set_title "%n@%m: %~"
}

function prompt_title_preexec() {
    local cmd="${1[(w)1]}"  # First word of command
    prompt_set_title "%n@%m: $cmd"
}

# Add hooks for window title
add-zsh-hook precmd prompt_title_precmd
add-zsh-hook preexec prompt_title_preexec
