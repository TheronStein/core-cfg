stty intr '^C'
stty susp '^Z'
stty stop undef
stty discard undef <$TTY >$TTY

alias fned='zed -f' histed='zed -h'
alias zmv='noglob zmv -v'  zcp='noglob zmv -Cv' zmvn='noglob zmv -W'
alias zln='noglob zmv -Lv' zlns='noglob zmv -o "-s" -Lv'

# zmodload -F zsh/parameter p:functions_source
[[ -v aliases[run-help] ]] && unalias run-help
autoload -RUz run-help
autoload -Uz $^fpath/run-help-^*.zwc(N:t)
# autoload -Uz $functions_source[run-help]-*~*.zwc
