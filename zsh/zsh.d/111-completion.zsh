# Extended completion from user's config

# Add system completion paths
fpath=(
    /usr/share/zsh/site-functions
    /usr/share/zsh/vendor-completions
    "${ZDOTDIR}/zinit/completions"
    "${ZDOTDIR}/functions"
    "${ZDOTDIR}/completions"
    "${ZDOTDIR}/zinit/completions"
    $fpath
)

# General completion cache policy - cache for 14 days
function _my-cache-policy() {
    [[ ! -f "$1" && -n "$1"(Nm+14) ]]
}

# Enable global completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZDOTDIR}/cache/zsh-completion"
zstyle ':completion:*' cache-policy _my-cache-policy

# Don't use compctl (deprecated)
zstyle ':completion:*' use-compctl false

#The complete section for pacman in your completion file
#zsh# ... [existing content above] ...

# Fix pacman completion
# Note: compdef calls will be executed after compinit via guard
if (( $+commands[pacman] )); then
    # Check if system completion exists and works
    if [[ -f /usr/share/zsh/site-functions/_pacman ]] && (( $(stat -c%s /usr/share/zsh/site-functions/_pacman) > 100 )); then
        # System completion exists and looks valid, use it
        autoload -Uz _pacman
    elif [[ -f "${ZDOTDIR}/functions/_pacman" ]]; then
        # Use our custom completion
        autoload -Uz _pacman
    elif [[ -n "${_comps[paru]}" ]] && (( $+functions[compdef] )); then
        # Fallback to paru's completion if it exists
        compdef ${_comps[paru]} pacman
    fi

    # Register the completion (only if compdef is available)
    (( $+functions[compdef] )) && compdef _pacman pacman
fi

# Also register for AUR helpers (only if compdef is available)
if (( $+functions[compdef] )); then
    for helper in yay paru pikaur trizen; do
        if (( $+commands[$helper] )); then
            if [[ -z "${_comps[$helper]}" ]]; then
                compdef _pacman $helper 2>/dev/null
            fi
        fi
    done
fi
# === END PACMAN COMPLETION FIX ===

# More matcher-list patterns
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'

zstyle ':completion:*:default' list-colors \
'di=1;38;5;33:ln=38;5;69:ex=1;38;5;124:so=1;38;5;21:pi=1;38;5;192:bd=1;38;5;67;48;5;137:cd=1;38;5;149;48;5;137:su=4;38;5;69;48;5;137:sg=4;38;5;33;48;5;137:tw=4;38;5;191;48;5;137:ow=4;38;5;73;48;5;137'

# Kill command completion improvement
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# CD completion improvements
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Man page sections
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Better formatting for warnings/errors
zstyle ':completion:*:warnings' format $'\e[31m-- No matches found --\e[0m'
zstyle ':completion:*:messages' format $'\e[36m-- %d --\e[0m'
zstyle ':completion:*:corrections' format $'\e[33m-- %d (errors: %e) --\e[0m'
zstyle ':completion:*:descriptions' format '[%d]'

# Group completions
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order path-directories functions commands builtins

# Process completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# SSH hosts (simplified from user's)
if [[ -r ~/.ssh/known_hosts ]]; then
    _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*})
    zstyle ':completion:*:hosts' hosts $_ssh_hosts
fi

# System-specific completions with package caching
# Systemctl completions with caching
if (( $+commands[systemctl] )); then
    # Load the completion
    autoload -Uz _systemctl

    # Set up nice formatting for systemctl
    zstyle ':completion:*:*:systemctl:*' format '%B%F{blue}%d%f%b'
    zstyle ':completion:*:*:systemctl:*' group-name ''
fi

# Pacman completions with package caching
if (( $+commands[pacman] )); then
    # Cache package names for faster completion
    zstyle ':completion:*:*:pacman:*' cache-path "${ZDOTDIR}/cache/pacman"
    zstyle ':completion:*:*:pacman:*' use-cache on

    # Group packages nicely
    zstyle ':completion:*:*:pacman:*' group-name ''
    zstyle ':completion:*:*:pacman:*' format '%B%F{green}%d%f%b'
fi

# Paru completions
if (( $+commands[paru] )); then
    # Generate completions if missing
    if [[ ! -f "${ZDOTDIR}/completions/_paru" ]]; then
        mkdir -p "${ZDOTDIR}/completions"
        command paru --gencompletions-zsh > "${ZDOTDIR}/completions/_paru" 2>/dev/null
    fi

    # Cache for faster AUR searches
    zstyle ':completion:*:*:paru:*' cache-path "${ZDOTDIR}/cache/paru"
    zstyle ':completion:*:*:paru:*' use-cache on

    # If paru completion fails, use pacman's (only if compdef is available)
    (( $+functions[compdef] )) && compdef _paru paru 2>/dev/null
fi

# Yay fallback to pacman (only if compdef is available)
if (( $+commands[yay] )) && (( $+functions[compdef] )); then
    compdef _pacman yay 2>/dev/null
fi

# Advanced FZF-tab settings (optimized for performance)
if (( $+functions[fzf-tab-complete] )); then
    # Default preview for files and directories (optimized)
    zstyle ':fzf-tab:complete:*:*' fzf-preview \
        '([[ -f $realpath ]] && (head -100 $realpath 2>/dev/null || echo "Binary file")) ||
         ([[ -d $realpath ]] && (ls -lh $realpath | head -50)) ||
         echo $realpath'

    # Preview window settings (smaller for performance)
    zstyle ':fzf-tab:complete:*:*' fzf-preview-window 'right:40%:wrap'

    # Command-specific previews (lightweight)
    zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview \
        'ps --pid=$word -o cmd --no-headers -w -w 2>/dev/null'

    zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
        'git log --oneline --graph --date=short --color=always $(sed s/^..// <<< "$word") 2>/dev/null | head -50'

    zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview \
        'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null | head -30'

    zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
        fzf-preview 'echo ${(P)word}'

    # Package manager previews (optimized - use cache)
    zstyle ':fzf-tab:complete:paru:*' fzf-preview \
        'paru -Si $word 2>/dev/null | head -30 || echo "Package: $word"'

    zstyle ':fzf-tab:complete:pacman:*' fzf-preview \
        'pacman -Si $word 2>/dev/null | head -20 || echo "Package: $word"'
fi

# Enable group support for all completions
zstyle ':completion:*' sort false
zstyle ':completion:*' list-grouped true

# Docker completions
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# Git completions
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-diff:*' sort false
zstyle ':completion:*:git-add:*' sort false

# SSH/SCP/RSYNC completions
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr

# Killall completion
zstyle ':completion:*:killall:*' command 'ps -u $USER -o comm='

# Process IDs completion
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm,cmd -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'

# File patterns for specific commands
zstyle ':completion:*:*:vim:*' file-patterns \
    '*.{txt,md,rst,org,tex,adoc}:text-files:text\ files' \
    '*.{c,h,cpp,hpp,cxx,cc}:source-files:source\ files' \
    '*:all-files'

zstyle ':completion:*:*:nvim:*' file-patterns \
    '*.{txt,md,rst,org,tex,adoc}:text-files:text\ files' \
    '*.{py,rb,js,ts,go,rs,lua,vim}:code-files:code\ files' \
    '*:all-files'

# Archive files
zstyle ':completion:*:unzip:*' file-patterns '*.zip:zip-files'
zstyle ':completion:*:tar:*' file-patterns '*.tar.gz:archives *.tar.bz2:archives *.tar.xz:archives *.tar:archives'

# REMOVED defer function that was causing the hang
# Heavy completions can be loaded normally or not at all
