# Custom ZLE widgets

# Sudo prefix toggle
function sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line
bindkey '^X^S' sudo-command-line

# Insert last word from previous command
function insert-last-word-again() {
    zle insert-last-word -- -1
}
zle -N insert-last-word-again
bindkey '^X^L' insert-last-word-again

# Copy current command line to clipboard
function copy-command-line() {
    print -n $BUFFER | xsel -ib 2>/dev/null || pbcopy 2>/dev/null
    zle -M "Command copied to clipboard"
}
zle -N copy-command-line
bindkey '^X^C' copy-command-line

# Clear screen but keep scrollback
function clear-screen-keep-scrollback() {
    echo -n '\e[2J\e[3J\e[H'
    zle reset-prompt
}
zle -N clear-screen-keep-scrollback
bindkey '^L' clear-screen-keep-scrollback

# Expand aliases in command line
function expand-alias() {
    zle _expand_alias
    zle expand-word
}
zle -N expand-alias
bindkey '^Xa' expand-alias

# Vi mode indicators
function zle-keymap-select() {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'  # block cursor
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'  # beam cursor
    fi
}
zle -N zle-keymap-select

function zle-line-init() {
    echo -ne '\e[5 q'  # beam cursor on startup
}
zle -N zle-line-init
