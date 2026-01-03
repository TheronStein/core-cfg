# ~/.core/zsh/05-aliases.zsh
# Aliases configuration - shorthand commands and tool replacements

#=============================================================================
# MODERN REPLACEMENTS (use better alternatives when available)
#=============================================================================
# ls -> eza
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first --git'
  alias la='eza -a --icons --group-directories-first'
  alias lt='eza -T --icons --level=2'
  alias lta='eza -Ta --icons --level=2'
  alias ltd='eza -TD --icons --level=3'
  alias l='eza -l --icons --group-directories-first'
  alias lm='eza -la --icons --sort=modified'
  alias ls='eza -la --icons --sort=size'
  alias lr='eza -laR --icons --level=2'
  alias lg='eza -la --icons --git'
  alias lh='eza -la --icons --sort=modified --reverse | head -20'
else
  alias ls='ls --color=auto'
  alias ll='ls -lAh'
  alias la='ls -A'
fi

alias claude-all="claude --dangerously-skip-permissions"

# cat -> bat
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias catp='bat --plain'
  alias catl='bat --style=full'
  alias less='bat --paging=always'
fi

# find -> fd
if command -v fd &>/dev/null; then
  alias find='fd'
fi

# grep -> ripgrep
if command -v rg &>/dev/null; then
  alias grep='rg'
fi

# du -> dust
if command -v dust &>/dev/null; then
  alias du='dust'
fi

# df -> duf
if command -v duf &>/dev/null; then
  alias df='duf'
fi

# ps -> procs
if command -v procs &>/dev/null; then
  alias ps='procs'
fi

# top -> btm
if command -v btm &>/dev/null; then
  alias top='btm'
  alias htop='btm'
fi

#=============================================================================
# DIRECTORY NAVIGATION
#=============================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# Quick access
alias ~='cd ~'
alias dl='cd ~/Downloads'
alias doc='cd ~/Documents'
alias proj='cd ~/projects'
alias config='cd ~/.config'
alias core='cd ~/.core'
alias dots='cd ~/.dotfiles'

# Directory listing after cd
function cd() {
  builtin cd "$@" && ls
}

# Create and enter directory
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Back n directories
function up() {
  local d=""
  local limit=${1:-1}
  for ((i = 1; i <= limit; i++)); do
    d="../$d"
  done
  cd "$d"
}

#=============================================================================
# GIT ALIASES
#=============================================================================
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gl='git log --oneline -20'
alias glg='git log --graph --oneline --all'
alias gla='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --all'
alias gm='git merge'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gr='git remote'
alias grv='git remote -v'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grs='git reset'
alias grsh='git reset --hard'
alias gs='git status -sb'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gw='git worktree'

# Git info
alias gcount='git shortlog -sn'
alias gcontrib='git log --format="%aN" | sort -u'

#=============================================================================
# NEOVIM ALIASES
#=============================================================================
alias v='nvim'
alias vim='nvim'
alias vi='nvim'
alias nv='nvim'

# Open in different modes
alias nvdiff='nvim -d'
alias nvro='nvim -R'
alias nvmin='nvim -u NONE'

# Quick edits
alias zshrc='nvim ~/.zshrc'
alias vimrc='nvim ~/.config/nvim/init.lua'
alias tmuxrc='nvim ~/.config/tmux/tmux.conf'
alias hyprrc='nvim ~/.config/hypr/hyprland.conf'

# Edit configs by tool
alias e.='nvim .'
alias e-='nvim -'

#=============================================================================
# TMUX ALIASES
#=============================================================================
alias t='tmux'
alias ta='tmux attach'
alias tat='tmux attach -t'
alias tn='tmux new-session'
alias tns='tmux new-session -s'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'
alias tka='tmux kill-server'
alias ts='tmux switch -t'
alias td='tmux detach'

# Quick session names
alias tdev='tmux new-session -As dev'
alias tmain='tmux new-session -As main'
alias twork='tmux new-session -As work'

#=============================================================================
# YAZI ALIASES
#=============================================================================
alias y='yazi'
# alias ya='yazi .'
alias yh='yazi ~'

#=============================================================================
# DOCKER ALIASES
#=============================================================================
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dprune='docker system prune -af'
alias dstop='docker stop $(docker ps -q)'

#=============================================================================
# SYSTEMD ALIASES
#=============================================================================
alias sc='systemctl'
alias scu='systemctl --user'
alias scs='systemctl status'
alias sce='systemctl enable'
alias scd='systemctl disable'
alias scstart='systemctl start'
alias scstop='systemctl stop'
alias screstart='systemctl restart'
alias scdr='systemctl daemon-reload'
alias jc='journalctl'
alias jcf='journalctl -f'
alias jcu='journalctl --user'

#=============================================================================
# PACKAGE MANAGEMENT (ARCH)
#=============================================================================
if command -v paru &>/dev/null; then
  alias p='paru'
  alias pup='paru -Syu'                    # Update everything
  alias pin='paru -S'                      # Install
  alias pre='paru -R'                      # Remove
  alias prs='paru -Rs'                     # Remove with deps
  alias pss='paru -Ss'                     # Search
  alias psi='paru -Si'                     # Info
  alias pqi='paru -Qi'                     # Local info
  alias pql='paru -Ql'                     # List files
  alias pqo='paru -Qo'                     # Who owns file
  alias pclean='paru -Sc'                  # Clean cache
  alias porphan='paru -Qtdq'               # List orphans
  alias prorphan='paru -Rns $(paru -Qtdq)' # Remove orphans
fi

#=============================================================================
# NETWORK UTILITIES
#=============================================================================
alias ip='ip -c'
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me'
alias localip='ip addr show | grep -E "inet .* brd" | awk "{print \$2}"'
alias ping='ping -c 5'
alias wget='wget -c'

#=============================================================================
# SAFETY ALIASES
#=============================================================================
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Dangerous versions (be careful!)
alias rmf='rm -rf'
alias mvf='mv -f'
alias cpf='cp -f'

#=============================================================================
# PROCESS MANAGEMENT
#=============================================================================
alias pgrep='pgrep -l'
alias psk='pkill -9'
alias jobs='jobs -l'
alias fg='fg %'
alias bg='bg %'

#=============================================================================
# MISC UTILITIES
#=============================================================================
# Colorized output
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias dmesg='dmesg --color=always'

# Disk usage
alias usage='du -sh * | sort -h'
alias big='du -sh * 2>/dev/null | sort -rh | head -20'

# Date/time
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias nowutc='date -u +"%Y-%m-%dT%H:%M:%SZ"'
alias week='date +%V'

# Quick edit
alias sshconfig='nvim ~/.ssh/config'

# Clipboard
if command -v wl-copy &>/dev/null; then
  alias pbcopy='wl-copy'
  alias pbpaste='wl-paste'
fi

# Weather
alias weather='curl "wttr.in?format=3"'
alias weatherfull='curl "wttr.in"'

# Colors test
alias colortest='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done'

# Path pretty print
alias path='echo -e ${PATH//:/\\n}'

# Reload shell
alias reload='exec $SHELL -l'
alias src='source ~/.zshrc'

#=============================================================================
# ANSIBLE ALIASES
#=============================================================================
alias ans='ansible'
alias ansp='ansible-playbook'
alias ansv='ansible-vault'
alias ansg='ansible-galaxy'
alias ansi='ansible-inventory'
alias ansd='ansible-doc'

# Common ansible tasks
alias anspcheck='ansible-playbook --check'
alias anspdiff='ansible-playbook --diff'
alias anspv='ansible-playbook -v'
alias anspvv='ansible-playbook -vvv'

#=============================================================================
# HASH BASED DIRECTORY SHORTCUTS
#=============================================================================

# In your .zshrc
hash -d careview=~/.core/.work/careview
hash -d care=~/.core/.work/careview
hash -d work=~/.core/.work/careview
hash -d core-cfg=~/.core/.sys/cfg
hash -d core-proj=~/.core/.proj
hash -d core-sys=~/.core/.sys
hash -d cortex=~/.core/.cortex
hash -d core-env=~/.core/.sys/env/desktop
hash -d tmux-cfg=~/.core/.sys/cfg/tmux
hash -d zsh-cfg=~/.core/.sys/cfg/zsh
hash -d wezterm-cfg=~/.core/.sys/cfg/wezterm
hash -d yazi-cfg=~/.core/.sys/cfg/yazi
hash -d nvim-cfg=~/.core/.sys/cfg/nvim
hash -d hypr-cfg=~/.core/.sys/env/desktop/hypr
hash -d rofi-cfg=~/.core/.sys/env/desktop/rofi
hash -d dunst-cfg=~/.core/.sys/env/desktop/dunst
hash -d waybar-cfg=~/.core/.sys/env/desktop/waybar

hash -d docs-input=~/.core/.cortex/core/sys/input
hash -d docs-kb=~/.core/.cortex/core/sys/input/keyboard
hash -d docs-cfg=~/.core/.cortex/core/sys/configs
hash -d docs-tmux=~/.core/.cortex/core/sys/configs/tmux
hash -d docs-nvim=~/.core/.cortex/core/sys/configs/nvim
hash -d docs-yazi=~/.core/.cortex/core/sys/configs/yazi
hash -d docs-wez=~/.core/.cortex/core/sys/configs/wezterm
hash -d docs-zsh=~/.core/.cortex/core/sys/configs/zsh

hash -d docs-env=~/.core/.cortex/core/sys/environment
hash -d docs-hypr=~/.core/.cortex/core/sys/environment/hyprland
hash -d docs-rofi=~/.core/.cortex/core/sys/environment/rofi
hash -d docs-waybar=~/.core/.cortex/core/sys/environment/waybar
hash -d docs-dunst=~/.core/.cortex/core/sys/environment/dunst

hash -d ref-lmburns=~/.core/.ref/lmburns
hash -d burns-zsh=~/.core/.ref/lmburns/.config/zsh
hash -d burns-tmux=~/.core/.ref/lmburns/.config/tmux

hash -d dev-kb=~/.core/.cortex/core/projects/keyboard
hash -d dev-sms=~/.core/.cortex/core/projects/kdesms-tui
hash -d dev-sms=~/.core/.cortex/core/projects/

hash -d docs-dev-ide=~/.core/.proj/core-ide
hash -d docs-dev-yazi=~/.core/.proj/core-ide
hash -d docs-dev-sms=~/.core/.proj/core-ide
hash -d docs-dev-kb=~/.core/.proj/core-ide
hash -d docs-dev-yazi=~/.core/.proj/core-ide

hash -d docs-src-tmux=~/.core/.cortex/terminal/multiplexers/tmux
hash -d docs-src-zsh=~/.core/.cortex/terminal/shells/zsh
hash -d docs-src-wezterm=~/.core/.cortex/terminal/emulators/wezterm
hash -d docs-src-nvim=~/.core/.cortex/terminal/editors/neovim
hash -d docs-src-yazi=~/.core/.cortex/terminal/file-managers/yazi

#=============================================================================
# GLOBAL ALIASES (can be used anywhere in command)
#=============================================================================
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc -l'
alias -g S='| sort'
alias -g U='| uniq'
alias -g J='| jq'
alias -g C='| wl-copy'
alias -g NE='2>/dev/null'
alias -g NUL='>/dev/null 2>&1'

#=============================================================================
# SUFFIX ALIASES (open files by extension)
#=============================================================================
# Note: Don't add suffix aliases for executable script types (.sh, .py, etc.)
# as they prevent script execution. Use explicit editor commands instead.
alias -s txt=nvim
alias -s md=nvim
alias -s json=nvim
alias -s yaml=nvim
alias -s yml=nvim
alias -s toml=nvim
alias -s conf=nvim
alias -s cfg=nvim
# Removed: .sh, .zsh, .py, .lua, .js, .ts - these should be executable
# If you want to edit them, use: nvim script.sh
alias -s html=browser
alias -s pdf=zathura
alias -s png=imv
alias -s jpg=imv
alias -s gif=imv

alias dc-dupes='dedupe-dirs'
alias dc-big='bigfiles'
alias dc-inspect='disk-inspect'
alias dc-empty='clean-empty'
alias dc-cloud='cloud-backup-large'
alias dc-pkgs='clean-pkg-cache'
alias dc-system='clean-system-cruft'
alias dc-git='clean-git-repos'

# Quick cleanup combo
alias dc-all='clean-pkg-cache && clean-system-cruft && clean-empty'

# NEW: Enhanced function aliases
alias dc-scan='disk-scan'            # GDU popup scan
alias dc-overview='disk-overview'    # Quick disk summary
alias dc-wizard='clean-wizard'       # Interactive cleanup wizard
alias dc-inodes='check-inodes'       # Inode usage checker
alias dc-search='search-archives'    # Search inside archives
alias dc-trends='storage-log show'   # Storage trends viewer
alias dc-suggest='space-suggestions' # Quick space recovery tips
alias dc-dedupe='dedupe-interactive' # Interactive duplicate finder
alias dc-menu='disk-menu-enhanced'   # Enhanced disk menu

# Tool shortcuts with sensible defaults
alias gdu-home='gdu ~'
alias gdu-root='sudo gdu /'
alias ncdu='ncdu --color dark'
alias dust='dust -d 2'
alias dua='dua interactive'

# Size-based file finding shortcuts
alias big50='fd --type f --size +50M'
alias big100='fd --type f --size +100M'
alias big500='fd --type f --size +500M'
alias big1g='fd --type f --size +1G'
alias big5g='fd --type f --size +5G'

# Quick duplicate detection
alias dupes-here='rmlint --types=duplicates --progress .'
alias dupes-home='rmlint --types=duplicates --progress ~'

# Storage info
alias dfh='df -h'
alias dfi='df -i' # Inode usage

# Trash operations (only if not already defined)
if ! alias trash >/dev/null 2>&1; then
  alias trash='trash-put'
  alias trash-list='trash-list'
  alias trash-restore='trash-restore'
  alias trash-empty='trash-empty'
fi

# Cloud operations
alias cloud-remotes='rclone listremotes'
alias cloud-about='rclone about'
alias cloud-size='rclone size'
alias cloud-ncdu='rclone ncdu'

# Journal cleanup
alias journal-size='journalctl --disk-usage'
alias journal-clean='sudo journalctl --vacuum-time=2weeks'

# Package cache info (Arch-specific)
if command -v paccache &>/dev/null; then
  alias pkg-cache-size='du -sh /var/cache/pacman/pkg'
  alias pkg-cache-clean='paccache -r'
  alias pkg-orphans='paru -Qtdq'
  alias pkg-orphans-remove='paru -Rns $(paru -Qtdq)'
fi

alias disk-ws='source ~/.core/.sys/cfg-disk-cleaning-tools/scripts/disk-cleaning-workspace.tmux'
