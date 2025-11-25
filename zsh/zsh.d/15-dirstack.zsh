# ~/.core/.sys/configs/zsh/zsh.d/35-dirstack.zsh
# Directory stack setup with improved startup protection

# Prevent multiple loading
[[ -n "$_DIRSTACK_LOADED" ]] && return
export _DIRSTACK_LOADED=1

# Only run if truly interactive and startup is complete
if [[ -o interactive && -z "$ZSH_STARTING_UP" ]]; then
    # Setup directories
    typeset -gx CHPWD_RECENT_DIRS="${ZDOTDIR}/.cache/chpwd-recent-dirs"
    [[ -d "${ZDOTDIR}/.cache" ]] || mkdir -p "${ZDOTDIR}/.cache"
    
    # Load modules with error handling
    zmodload -F zsh/parameter +p:dirstack 2>/dev/null
    autoload -Uz chpwd_recent_dirs add-zsh-hook cdr 2>/dev/null
    
    # Configure styles
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 20
    zstyle ':chpwd:*' recent-dirs-file "${CHPWD_RECENT_DIRS}"
    zstyle ':chpwd:*' recent-dirs-prune 'pattern:/tmp(|/*)'
    zstyle ':completion:*' recent-dirs-insert both
    
    # Protected chpwd function with multiple safeguards
    chpwd_recent_dirs_protected() {
        # Prevent loops and execution during startup
        [[ -n "$ZSH_STARTING_UP" ]] && return 0
        [[ -n "$ZINIT[BLOCK_CHPWD]" ]] && return 0
        [[ $ZSH_SUBSHELL -ne 0 ]] && return 0
        [[ $ZSH_EVAL_CONTEXT == *:file:* ]] && return 0
        [[ -n "$_DIRSTACK_IN_CHPWD" ]] && return 0
        
        # Set guard to prevent recursion
        local _DIRSTACK_IN_CHPWD=1
        
        # Call the actual function with error handling
        if (( $+functions[chpwd_recent_dirs] )); then
            chpwd_recent_dirs 2>/dev/null || true
        fi
    }
    
    # Add hook with protection (only if not already added)
    if ! (( $+functions[chpwd_recent_dirs_protected] )) || \
       [[ ${chpwd_functions[(i)chpwd_recent_dirs_protected]} -gt ${#chpwd_functions} ]]; then
        add-zsh-hook chpwd chpwd_recent_dirs_protected 2>/dev/null || true
    fi
    
    # Initialize dirstack safely
    if [[ -r "${CHPWD_RECENT_DIRS}" ]]; then
        typeset -gaU dirstack 2>/dev/null
        # Fixed: properly read and parse the file
        if [[ -s "${CHPWD_RECENT_DIRS}" ]]; then
            local -a temp_dirs
            temp_dirs=("${(@f)$(<${CHPWD_RECENT_DIRS})}")
            dirstack=("${temp_dirs[@]}")
            dirstack=("${dirstack[@]:#$PWD}")
        fi
    fi
fi

# Aliases (always available)
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index
