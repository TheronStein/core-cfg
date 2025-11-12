
# File: ~/.config/zsh/functions/yazi-tmux.zsh  
# Location: Function for tmux split-pane yazi integration

function _zyazi() {
  emulate -L zsh
  local d=$(mktemp -d) || return 1
  {
    mkfifo -m 600 $d/fifo || return 1
    tmux split -bf zsh -c "
      cd '$PWD'
      exec {ZLE_FIFO}>$d/fifo
      export ZLE_FIFO
      yazi --chooser-file=$d/chosen
      [[ -f $d/chosen ]] && echo \"BUFFER='cd \$(cat $d/chosen)'\" >&\$ZLE_FIFO
      echo 'zle accept-line' >&\$ZLE_FIFO
    " || return 1
    local fd
    exec {fd}<$d/fifo
    zle -Fw $fd *zyazi*handler
  } always {
    command rm -rf $d
  }
}

zle -N _zyazi

function *zyazi*handler() {
  emulate -L zsh
  local line
  if ! read -r line <&$1; then
    zle -F $1
    exec {1}<&-
    return 1
  fi
  eval "$line"
  zle -R
}

zle -N *zyazi*handler
bindkey 'C-x C-o' _zyazi
