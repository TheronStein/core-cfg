#!/usr/bin/env zsh
# Zinit installation and initialization

# Set zinit directories
declare -gA ZINIT
ZINIT[HOME_DIR]="${ZDOTDIR}/zinit"
ZINIT[BIN_DIR]="${ZINIT[HOME_DIR]}/bin"
ZINIT[PLUGINS_DIR]="${ZINIT[HOME_DIR]}/plugins"
ZINIT[COMPLETIONS_DIR]="${ZINIT[HOME_DIR]}/completions"
ZINIT[SNIPPETS_DIR]="${ZINIT[HOME_DIR]}/snippets"
ZINIT[ZCOMPDUMP_PATH]="${ZSH_CACHE_DIR:-${ZDOTDIR}/cache}/zcompdump-${ZSH_VERSION}"

# Install zinit if not present
if [[ ! -f ${ZINIT[BIN_DIR]}/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "${ZINIT[HOME_DIR]}" && command chmod g-rwX "${ZINIT[HOME_DIR]}"
    command git clone https://github.com/zdharma-continuum/zinit "${ZINIT[BIN_DIR]}" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# Source zinit - THIS IS THE CRITICAL LINE
if [[ -f ${ZINIT[BIN_DIR]}/zinit.zsh ]]; then
    source "${ZINIT[BIN_DIR]}/zinit.zsh"
    
    # Load zinit completion
    autoload -Uz _zinit
    (( ${+_comps} )) && _comps[zinit]=_zinit
else
    echo "ERROR: ${ZINIT[BIN_DIR]}/zinit.zsh not found!" >&2
    return 1
fi
