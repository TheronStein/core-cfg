# ~/.core/cfg/zsh/zsh.d/91-learning-widgets.zsh
# Learning widgets for discovering Zsh features

# Widget to show what a key does before executing
widget-explain-key() {
    echo -n "Press key to explain: "
    read -k key
    echo ""
    local binding=$(bindkey "$key" 2>/dev/null | awk '{print $2}')
    if [[ -n "$binding" ]]; then
        echo "Key '$key' is bound to: $binding"
        # Show function code if it's a custom widget
        if type "$binding" >/dev/null 2>&1; then
            echo "Function definition:"
            type "$binding" | head -20
        fi
    else
        echo "Key '$key' has no binding"
    fi
    zle reset-prompt
}
zle -N widget-explain-key
bindkey '^X^?' widget-explain-key

# Show available completions for current context
widget-show-completions() {
    echo ""
    echo "Available completions for current context:"
    echo "=========================================="
    _complete_debug
    zle reset-prompt
}
zle -N widget-show-completions
bindkey '^X^=' widget-show-completions

# Learning mode - shows what each keypress does
widget-learning-mode() {
    echo "LEARNING MODE - Every keypress will be explained"
    echo "Press Ctrl+C to exit"
    # This would need more complex implementation
    zle reset-prompt
}
zle -N widget-learning-mode
bindkey '^X^L' widget-learning-mode

# Show current Zsh state
widget-show-state() {
    echo ""
    echo "Current Zsh State:"
    echo "=================="
    echo "PWD: $PWD"
    echo "History position: $HISTCMD"
    echo "Last exit code: $?"
    echo "Current keymap: $KEYMAP"
    echo "Buffer: $BUFFER"
    echo "Cursor: $CURSOR"
    zle reset-prompt
}
zle -N widget-show-state
bindkey '^X^V' widget-show-state
