# ~/.core/.sys/configs/zsh/zsh.d/120-late-binds.zsh
# Late-loading keybindings that require plugins to be loaded first

# History substring search bindings (after plugin is loaded)
if (( $+widgets[history-substring-search-up] )); then
    # Arrow keys
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
    [[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
    
    # Vi mode
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
    
    # Emacs mode
    bindkey -M emacs '^P' history-substring-search-up
    bindkey -M emacs '^N' history-substring-search-down
fi

# FZF bindings (if fzf is loaded)
if (( $+functions[fzf-file-widget] )); then
    bindkey '^T' fzf-file-widget
fi

if (( $+functions[fzf-history-widget] )); then
    bindkey '^R' fzf-history-widget
fi

if (( $+functions[fzf-cd-widget] )); then
    bindkey '\ec' fzf-cd-widget
fi

# Autosuggest bindings (if plugin is loaded)
if (( $+functions[_zsh_autosuggest_accept] )); then
    bindkey '^F' autosuggest-accept
    bindkey '^[[Z' autosuggest-accept  # Shift+Tab
fi

# Per-directory history (if plugin is loaded)
if (( $+functions[per-directory-history-toggle-history] )); then
    bindkey '^G' per-directory-history-toggle-history
fi
