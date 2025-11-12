# Autoload useful functions

# Zsh utilities
autoload -Uz zmv zcalc zargs zed
alias zmv='noglob zmv -v'
alias zcp='noglob zmv -C'
alias zln='noglob zmv -L'

# Run help
autoload -Uz run-help
autoload -Uz run-help-git
autoload -Uz run-help-ip
autoload -Uz run-help-openssl
autoload -Uz run-help-sudo

# URL tools
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Math functions
autoload -Uz zmathfunc
zmathfunc

# Module loading
zmodload -i zsh/mathfunc
zmodload -i zsh/complist
