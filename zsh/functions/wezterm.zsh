# ~/.core/cfg/zsh/wezterm.zsh (or add to .zshrc/.bashrc)
# WezTerm shell integration

# Source WezTerm environment if in WezTerm
if [ -n "$WEZTERM_PANE" ]; then
    # Set terminal title to show tmux session
    if [ -n "$TMUX" ]; then
        # Get tmux session name
        TMUX_SESSION=$(tmux display-message -p '#S')
        export TMUX_SESSION

        # Update terminal title using proper hook system
        wezterm_update_title_tmux() {
            echo -ne "\033]0;[$TMUX_SESSION] ${PWD##*/}\007"
        }
        autoload -Uz add-zsh-hook
        add-zsh-hook precmd wezterm_update_title_tmux
    else
        # Non-tmux title
        wezterm_update_title_notmux() {
            echo -ne "\033]0;${PWD##*/}\007"
        }
        autoload -Uz add-zsh-hook
        add-zsh-hook precmd wezterm_update_title_notmux
    fi

    # Set user var for WezTerm to read
    printf "\033]1337;SetUserVar=%s=%s\007" "TMUX_SESSION" "$TMUX_SESSION"
fi

