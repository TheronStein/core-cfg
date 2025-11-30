# ~/.core/zsh/modules/options.zsh
# Shell options and settings - controls zsh behavior fundamentals

# ═══════════════════════════════════════════════════════════════════════════════
# DIRECTORY OPTIONS
# ═══════════════════════════════════════════════════════════════════════════════

setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # Push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # No duplicates in dir stack
setopt PUSHD_SILENT         # Don't print dir stack after pushd/popd
setopt PUSHD_TO_HOME        # pushd with no args goes to ~
setopt CDABLE_VARS          # cd to named directories
setopt CHASE_LINKS          # Resolve symlinks when changing directory

# Named directories (use ~name to access)
hash -d config="$XDG_CONFIG_HOME"
hash -d data="$XDG_DATA_HOME"
hash -d cache="$XDG_CACHE_HOME"
hash -d core="$HOME/.core"
hash -d dots="$HOME/.core"
hash -d nvim="$XDG_CONFIG_HOME/nvim"
hash -d proj="$HOME/projects"

# ═══════════════════════════════════════════════════════════════════════════════
# GLOBBING AND EXPANSION
# ═══════════════════════════════════════════════════════════════════════════════

setopt EXTENDED_GLOB        # Use extended globbing syntax
setopt GLOB_DOTS            # Include dotfiles in globbing
setopt NOMATCH              # Error if glob has no matches
setopt NUMERIC_GLOB_SORT    # Sort numerically when relevant
setopt RC_EXPAND_PARAM      # Array expansion with parameters
setopt REMATCH_PCRE         # Use PCRE for regex matching

# ═══════════════════════════════════════════════════════════════════════════════
# INPUT/OUTPUT
# ═══════════════════════════════════════════════════════════════════════════════

setopt CORRECT              # Spell check commands
setopt NO_CORRECT_ALL       # Don't correct all arguments
setopt INTERACTIVE_COMMENTS # Allow comments in interactive mode
setopt NO_CLOBBER           # Don't overwrite files with > (use >| to force)
setopt NO_FLOW_CONTROL      # Disable ^S/^Q flow control
setopt PATH_DIRS            # Search path for cd-able vars
setopt NO_RM_STAR_SILENT    # Query before rm with *

# ═══════════════════════════════════════════════════════════════════════════════
# JOB CONTROL
# ═══════════════════════════════════════════════════════════════════════════════

setopt AUTO_RESUME          # Resume jobs on simple command
setopt LONG_LIST_JOBS       # List jobs in long format
setopt NOTIFY               # Report background job status immediately
setopt NO_BG_NICE           # Don't nice background jobs
setopt NO_HUP               # Don't SIGHUP background jobs on exit
setopt NO_CHECK_JOBS        # Don't warn about running jobs on exit

# ═══════════════════════════════════════════════════════════════════════════════
# PROMPT
# ═══════════════════════════════════════════════════════════════════════════════

setopt PROMPT_SUBST         # Allow substitution in prompts
setopt TRANSIENT_RPROMPT    # Remove right prompt after command

# ═══════════════════════════════════════════════════════════════════════════════
# ENVIRONMENT VARIABLES
# ═══════════════════════════════════════════════════════════════════════════════

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"
export LESS="-R -F -X -i -M -S"
export LESSHISTFILE="${XDG_DATA_HOME}/less/history"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Colorful man pages via bat
export MANROFFOPT="-c"

# ═══════════════════════════════════════════════════════════════════════════════
# PATH CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

typeset -U path  # Unique entries only

path=(
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.npm-global/bin"
    "/usr/local/bin"
    $path
)