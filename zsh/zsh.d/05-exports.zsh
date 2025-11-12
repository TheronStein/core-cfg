# Cache and data directories
typeset -gx ZSH_CACHE_DIR="${ZDOTDIR}/.cache"

# Completion directory (defined before mkdir)
declare -gx GENCOMP_DIR="${ZDOTDIR}/completions"
declare -gx GENCOMPL_FPATH="$GENCOMP_DIR"

# Create directories if needed
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"
[[ -n "$GENCOMP_DIR" && -d "$GENCOMP_DIR" ]] || mkdir -p "$GENCOMP_DIR"

# History file settings - CONSOLIDATED (removed duplicates)
typeset -g HISTFILE="${Zdirs[CACHE]}/history"
typeset -g HISTSIZE=$(( 12 * 10 ** 6 ))  # 12_000_000 (1.2 * SAVEHIST)
typeset -g SAVEHIST=$(( 10 ** 7 ))       # 10_000_000

declare -gx ABSD=${${(M)OSTYPE:#*(darwin|bsd)*}:+1}
declare -gx ZLOGF="${Zdirs[CACHE]}/my-zsh.log"
declare -gx LFLOGF="${Zdirs[CACHE]}/lf-zsh.log"

typeset -g HIST_STAMPS="yyyy-mm-dd"
typeset -g HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1 # all search results returned will be unique NOTE: for what

typeset -g DIRSTACKSIZE=20
typeset -g LISTMAX=50                               # Size of asking history
typeset -g ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;)'       # Don't eat space with | with tabs
typeset -g ZLE_SPACE_SUFFIX_CHARS=$'&|'
typeset -g MAILCHECK=0                 # Don't check for mail
typeset -g KEYTIMEOUT=25               # Key action time
typeset -g FCEDIT=$EDITOR              # History editor
typeset -g READNULLCMD=$PAGER          # Read contents of file with <file
typeset -g TMPPREFIX="${TMPDIR%/}/zsh" # Temporary file prefix for zsh
typeset -g PROMPT_EOL_MARK="%F{14}⏎%f" # Show non-newline ending # no_prompt_cr
# typeset -g REPORTTIME=5 # report about cpu/system/user-time of command if running longer than 5 seconds
# typeset -g LOGCHECK=0   # interval in between checks for login/logout activity
typeset -g PERIOD=3600                    # how often to execute $periodic
function periodic() { builtin rehash; }   # this overrides the $periodic_functions hooks
watch=(notme)

# History options (moved to 00-options.zsh to avoid duplication)
