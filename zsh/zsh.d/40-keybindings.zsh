# Simplified key bindings from user's config

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Basic movement
# bindkey '^A' beginning-of-line
# bindkey '^E' end-of-line
# bindkey '^K' kill-line
# bindkey '^W' backward-kill-word
# bindkey '^U' backward-kill-line
# bindkey '^Y' yank

# History navigation
bindkey '^P' up-history
bindkey '^N' down-history
# bindkey '^R' history-incremental-search-backward
# bindkey '^S' history-incremental-search-forward

# Edit command in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
bindkey '^X^E' edit-command-line

# Better word movement
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left

# Undo/redo
bindkey '^Z' undo
bindkey '^R' redo

# Accept autosuggestion
if (( $+functions[_zsh_autosuggest_accept] )); then
    # bindkey '^F' autosuggest-accept
    bindkey '^[[Z' autosuggest-accept  # Shift+Tab
fi

# === CUSTOM FUNCTION WIDGETS ===
# Create ZLE widgets for functions that aren't already widgets

# FZF function widgets
if (( $+commands[fzf] )); then
    # Directory navigation widget
    widget-fcd() {
        zle push-line
        BUFFER="fcd"
        zle accept-line
    }
    zle -N widget-fcd
    bindkey '^G' widget-fcd
    
    # Git checkout widget
    widget-fco() {
        zle push-line
        BUFFER="fco"
        zle accept-line
    }
    zle -N widget-fco
    bindkey '^X^G' widget-fco
    
    # Git branch browse widget
    widget-fbr() {
        zle push-line
        BUFFER="fbr"
        zle accept-line
    }
    zle -N widget-fbr
    bindkey '^X^B' widget-fbr
fi

# Directory stack with FZF
widget-dirs-fzf() {
    local dir
    dir=$(dirs -v | fzf --height 40% | awk '{print $1}')
    if [[ -n "$dir" ]]; then
        cd ~$dir
        zle reset-prompt
    fi
}
zle -N widget-dirs-fzf
bindkey '^X^P' widget-dirs-fzf

# Quick functions (from your other file if they exist)
if (( $+functions[clear-screen-keep-scrollback] )); then
    zle -N clear-screen-keep-scrollback
    bindkey '^L' clear-screen-keep-scrollback
fi

if (( $+functions[sudo-command-line] )); then
    zle -N sudo-command-line
    bindkey '^X^S' sudo-command-line
fi

if (( $+functions[copy-command-line] )); then
    zle -N copy-command-line
    bindkey '^X^C' copy-command-line
fi

# System information widget
widget-sysinfo() { 
    zle -I
    sysinfo
    zle reset-prompt
}
zle -N widget-sysinfo
bindkey '^X^I' widget-sysinfo

# Git status widget
widget-git-status() {
    zle -I
    git status -sb
    zle reset-prompt
}
zle -N widget-git-status
bindkey '^Xg' widget-git-status

# History statistics widget
widget-history-stats() {
    zle -I
    history-stats 10
    zle reset-prompt
}
zle -N widget-history-stats
bindkey '^X^H' widget-history-stats

# Per-directory history toggle (if plugin is loaded)
if (( $+functions[per-directory-history-toggle-history] )); then
    bindkey '^D' per-directory-history-toggle-history
fi
