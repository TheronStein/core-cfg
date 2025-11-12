
# File: ~/.config/zsh/functions/superfile-tmux.zsh
# Location: Tmux split pane integration for superfile

function _zspf() {
  emulate -L zsh
  tmux split-window -h "superfile; tmux send-keys -t ! C-m"
}

zle -N _zspf
bindkey '^o' _zspf  # Ctrl-O to open in split
