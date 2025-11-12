# Extended aliases from user's config

# Global aliases (use with caution)
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g NUL='>/dev/null 2>&1'

# Advanced ls aliases (if eza available)
if (($+commands[eza])); then
  alias ls='eza -ax --color=auto --icons --git -w 100' # directories only
  alias li='eza -Dh  --icons --git'                     # directories only
  alias ll='eza -lah --group-directories-first --icons --git'                    # directories only
  alias tree='eza -T --icons --git'                    # tree view
  alias llm='eza -lah --group-directories-first --sort=modified --icons --git'   # by modification
  alias lls='eza -lah --group-directories-first --sort=size --icons --git'       # by size
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety
alias cp='cp -ivp --reflink=auto'
alias mv='mv -iv'
alias rm='rm -i'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias gst='git stash'
alias gstp='git stash pop'

# System
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'

# Conditional aliases from user config
(($+commands[bat])) && alias cat='bat'
(($+commands[nvim])) && alias vi='nvim'

# Docker (if available)
if (($+commands[docker])); then
  alias dps='docker ps'
  alias dpsa='docker ps -a'
  alias dimg='docker images'
  alias dexec='docker exec -it'
fi

# Tmux (if available)
if (($+commands[tmux])); then
  alias ta='tmux attach -t'
  alias tl='tmux list-sessions'
  alias tn='tmux new-session -s'
  alias tk='tmux kill-session -t'
fi

# Convenient aliases
alias gf='grab_files'           # Quick grab files
alias ygrab='yazi::grab_files'  # Yazi grab
alias fgrab='grab_files_widget' # Fzf grab (though widget is better with keybind)

alias y='yazi'
alias yd='yazi::dev'
alias ys='yazi::select'

# Quick function to edit yazi configs
yazi-edit-config() {
  local config_dir="${1:-$HOME/.config/yazi}"
  $EDITOR "$config_dir/yazi.toml"
}
