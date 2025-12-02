# ~/.core/zsh/00-options.zsh
# Core ZSH options and settings - configures shell behavior, history, and completions

#=============================================================================
# HISTORY CONFIGURATION
#=============================================================================
HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=100000                  # Maximum events in internal history
SAVEHIST=100000                  # Maximum events in history file

# Create history directory
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first when trimming
setopt HIST_FIND_NO_DUPS         # Don't display duplicates during search
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate entries
setopt HIST_IGNORE_DUPS          # Don't record consecutive duplicates
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to history file
setopt HIST_VERIFY               # Show command before executing from history
setopt INC_APPEND_HISTORY        # Add commands as they are typed
setopt SHARE_HISTORY             # Share history between sessions

#=============================================================================
# DIRECTORY NAVIGATION
#=============================================================================
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push directories onto stack
setopt CDABLE_VARS               # cd to named directories
setopt CHASE_LINKS               # Resolve symlinks in cd
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_MINUS               # Exchange + and - meanings
setopt PUSHD_SILENT              # Don't print directory stack
setopt PUSHD_TO_HOME             # pushd with no args goes home

# Named directories (bookmarks)
hash -d config="${XDG_CONFIG_HOME}"
hash -d data="${XDG_DATA_HOME}"
hash -d cache="${XDG_CACHE_HOME}"
hash -d core="${HOME}/.core"
hash -d dots="${HOME}/.dotfiles"
hash -d proj="${HOME}/projects"
hash -d dl="${HOME}/Downloads"

#=============================================================================
# GLOBBING AND EXPANSION
#=============================================================================
setopt EXTENDED_GLOB             # Use extended globbing syntax
setopt GLOB_DOTS                 # Include dotfiles in glob matches
setopt GLOB_STAR_SHORT           # ** for recursive globbing
setopt MARK_DIRS                 # Append / to directories
setopt NUMERIC_GLOB_SORT         # Sort numerically, not lexicographically
setopt RC_EXPAND_PARAM           # Array expansion with parameters
setopt REMATCH_PCRE              # Use PCRE for regex matching

# Disable some options for safety
unsetopt CASE_GLOB               # Case-insensitive globbing
unsetopt NOMATCH                 # Don't error on no glob matches

#=============================================================================
# INPUT/OUTPUT
#=============================================================================
setopt CORRECT                   # Command spelling correction
setopt CORRECT_ALL               # Argument spelling correction
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shell
setopt NO_CLOBBER                # Don't overwrite files with >
setopt NO_FLOW_CONTROL           # Disable ^S/^Q flow control
setopt PATH_DIRS                 # Find executables in path dirs
setopt RC_QUOTES                 # Allow '' to escape ' in single quotes

#=============================================================================
# JOB CONTROL
#=============================================================================
setopt AUTO_CONTINUE             # Send CONT to stopped jobs on disown
setopt AUTO_RESUME               # Single-word commands resume jobs
setopt CHECK_JOBS                # Warn about running jobs on exit
setopt CHECK_RUNNING_JOBS        # Warn about running jobs specifically
setopt HUP                       # Send HUP to jobs on exit
setopt LONG_LIST_JOBS            # List jobs in long format
setopt NOTIFY                    # Report job status immediately

#=============================================================================
# COMPLETION SYSTEM
#=============================================================================
setopt ALWAYS_TO_END             # Move cursor after completion
setopt AUTO_LIST                 # List choices on ambiguous completion
setopt AUTO_MENU                 # Show completion menu on tab
setopt AUTO_PARAM_KEYS           # Smart handling of completions
setopt AUTO_PARAM_SLASH          # Add trailing slash for directories
setopt AUTO_REMOVE_SLASH         # Remove slash if next char is word delimiter
setopt COMPLETE_ALIASES          # Complete aliases
setopt COMPLETE_IN_WORD          # Complete from both ends of word
setopt LIST_PACKED               # Make completion list more compact
setopt LIST_ROWS_FIRST           # Sort completions horizontally
setopt LIST_TYPES                # Show type indicators in listings

# Initialize completion
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME}/zsh/.zcompdump"
autoload -Uz bashcompinit && bashcompinit

# Completion styling
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/zcompcache"
# Use ANSI codes instead of %F{} for fzf compatibility
zstyle ':completion:*:descriptions' format $'\e[33m-- %d --\e[0m'
zstyle ':completion:*:messages' format $'\e[35m-- %d --\e[0m'
zstyle ':completion:*:warnings' format $'\e[31m-- no matches found --\e[0m'
zstyle ':completion:*:corrections' format $'\e[32m-- %d (errors: %e) --\e[0m'

# Process completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# SSH/SCP/rsync completion
zstyle ':completion:*:(ssh|scp|rsync):*' hosts $(
    cat ~/.ssh/known_hosts 2>/dev/null | cut -d' ' -f1 | tr ',' '\n' | uniq
)
zstyle ':completion:*:(ssh|scp|rsync):*' users root $USER

# Man page sections
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

#=============================================================================
# ZLE (ZSH LINE EDITOR) OPTIONS
#=============================================================================
setopt NO_BEEP                   # Disable beeping
setopt COMBINING_CHARS           # Combine zero-length characters
setopt EMACS                     # Use emacs keybindings as base

# Word characters (for navigation)
WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'

#=============================================================================
# MISC
#=============================================================================
setopt MULTIOS                   # Multiple redirections
setopt PROMPT_SUBST              # Allow prompt substitution
setopt TRANSIENT_RPROMPT         # Remove RPROMPT after command

# Watch for logins
watch=(notme)
LOGCHECK=60
WATCHFMT="%n from %M has %a tty%l at %T %W"
