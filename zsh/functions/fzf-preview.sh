# ~/.config/zsh/defaults/fzf-previews.zsh
# Comprehensive fzf-tab preview configurations for all completion types

#=============================================================================
# DIRECTORY & FILE COMPLETIONS
#=============================================================================

# Directory preview (cd, z, zoxide, pushd, etc.)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null || ls -A --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null || ls -A --color=always $realpath'
zstyle ':fzf-tab:complete:pushd:*' fzf-preview 'eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null || ls -A --color=always $realpath'

# File argument completions (most commands that take file arguments)
zstyle ':fzf-tab:complete:-command-:*' fzf-preview '
  [[ -z $realpath ]] && realpath=$word
  if [[ -d $realpath ]]; then
    eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null || ls -A --color=always $realpath 2>/dev/null
  elif [[ -f $realpath ]]; then
    bat --color=always --style=numbers,changes --line-range :200 $realpath 2>/dev/null || head -n 200 $realpath 2>/dev/null
  fi
'

# Generic file/directory preview (fallback for everything else)
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  [[ -z $realpath ]] && realpath=$word
  if [[ -d $realpath ]]; then
    eza -1 --color=always --icons --group-directories-first $realpath 2>/dev/null || ls -A --color=always $realpath 2>/dev/null
  elif [[ -f $realpath ]]; then
    bat --color=always --style=numbers,changes --line-range :200 $realpath 2>/dev/null || head -n 200 $realpath 2>/dev/null
  fi
'

# Common file operation commands (cat, less, more, head, tail, etc.)
zstyle ':fzf-tab:complete:(cat|less|more|head|tail|bat):*' fzf-preview \
  '[[ -f $realpath ]] && { bat --color=always --style=numbers,changes $realpath 2>/dev/null || head -n 200 $realpath 2>/dev/null; } || [[ -d $realpath ]] && eza -1 --color=always --icons $realpath 2>/dev/null'

# File modification commands (cp, mv, rm, chmod, chown)
zstyle ':fzf-tab:complete:(cp|mv|rm|chmod|chown):*' fzf-preview \
  '[[ -f $realpath ]] && { bat --color=always --style=plain $realpath 2>/dev/null || head -n 100 $realpath 2>/dev/null; } || [[ -d $realpath ]] && eza -1 --color=always --icons $realpath 2>/dev/null'

# ls/eza completions
zstyle ':fzf-tab:complete:(ls|eza|exa):*' fzf-preview '
  if [[ -d $realpath ]]; then
    eza --tree --level=2 --color=always --icons $realpath 2>/dev/null || ls -lA --color=always $realpath 2>/dev/null
  elif [[ -f $realpath ]]; then
    bat --color=always --style=numbers,changes $realpath 2>/dev/null || head -n 200 $realpath 2>/dev/null
  fi
'

#=============================================================================
# GIT COMPLETIONS
#=============================================================================

# Git add/diff/restore - show file diff
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff --color=always $word 2>/dev/null | delta 2>/dev/null || git diff --color=always $word'

# Git log - show commit details
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
  'git show --color=always $word 2>/dev/null | delta 2>/dev/null || git show --color=always $word'

# Git checkout - context-aware preview
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case $group in
     "modified file") git diff --color=always $word | delta 2>/dev/null || git diff --color=always $word ;;
     "recent commit") git show --color=always $word | delta 2>/dev/null || git show --color=always $word ;;
     "remote branch") git log --oneline --graph --color=always $word | head -50 ;;
     *) git log --oneline --graph --color=always $word | head -50 ;;
   esac'

# Git branch - show branch info and recent commits
zstyle ':fzf-tab:complete:git-branch:*' fzf-preview \
  'git log --oneline --graph --color=always --decorate $word | head -50'

# Git stash - show stash contents
zstyle ':fzf-tab:complete:git-stash:*' fzf-preview \
  'git stash show --color=always -p $word 2>/dev/null | delta 2>/dev/null || git stash show --color=always -p $word'

#=============================================================================
# PROCESS MANAGEMENT
#=============================================================================

# Kill/pkill - detailed process info
zstyle ':fzf-tab:complete:(kill|pkill):*' fzf-preview \
  'ps --pid=$word -o pid,ppid,user,%cpu,%mem,stat,start,time,command --no-headers -ww 2>/dev/null || echo "Process: $word"'

# Top/htop/btm - process tree
zstyle ':fzf-tab:complete:(top|htop|btm|bottom):*' fzf-preview \
  'ps --pid=$word --forest -o pid,ppid,user,%cpu,%mem,command -ww'

#=============================================================================
# SYSTEMD/SERVICE MANAGEMENT
#=============================================================================

# Systemctl - service status
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview \
  'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null'

# Journalctl - recent logs
zstyle ':fzf-tab:complete:journalctl:*' fzf-preview \
  'journalctl -u $word --no-pager -n 50 --output=cat 2>/dev/null'

#=============================================================================
# PACKAGE MANAGEMENT
#=============================================================================

# Pacman (Arch Linux)
zstyle ':fzf-tab:complete:pacman:*' fzf-preview \
  'pacman -Si $word 2>/dev/null || pacman -Qi $word 2>/dev/null'

# Yay/Paru (AUR helpers)
zstyle ':fzf-tab:complete:(yay|paru):*' fzf-preview \
  'yay -Si $word 2>/dev/null || paru -Si $word 2>/dev/null || pacman -Si $word 2>/dev/null'

# Apt (Debian/Ubuntu)
zstyle ':fzf-tab:complete:apt:*' fzf-preview \
  'apt-cache show $word 2>/dev/null'

# DNF/YUM (Fedora/RHEL)
zstyle ':fzf-tab:complete:(dnf|yum):*' fzf-preview \
  'dnf info $word 2>/dev/null || yum info $word 2>/dev/null'

#=============================================================================
# DOCKER & CONTAINERS
#=============================================================================

# Docker images
zstyle ':fzf-tab:complete:docker-image:*' fzf-preview \
  'docker image inspect $word 2>/dev/null | bat --color=always -l json || docker images $word'

# Docker containers
zstyle ':fzf-tab:complete:docker-(run|exec|start|stop|rm):*' fzf-preview \
  'docker inspect $word 2>/dev/null | bat --color=always -l json || docker ps -a --filter name=$word'

# Docker compose
zstyle ':fzf-tab:complete:docker-compose:*' fzf-preview \
  'docker-compose config 2>/dev/null | bat --color=always -l yaml'

#=============================================================================
# ENVIRONMENT & VARIABLES
#=============================================================================

# Environment variables
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview \
  'echo ${(P)word} | bat --color=always -l bash --style=plain || echo ${(P)word}'

# Man pages
zstyle ':fzf-tab:complete:(man|tldr):*' fzf-preview \
  'man $word 2>/dev/null | col -bx | bat --color=always -l man --style=grid || tldr $word 2>/dev/null'

#=============================================================================
# SSH & NETWORKING
#=============================================================================

# SSH hosts
zstyle ':fzf-tab:complete:ssh:*' fzf-preview \
  'echo "Host: $word" && grep -A 10 "^Host $word" ~/.ssh/config 2>/dev/null | bat --color=always -l sshconfig --style=plain'

# Ping/networking
zstyle ':fzf-tab:complete:(ping|curl|wget):*' fzf-preview \
  'echo "Target: $word" && host $word 2>/dev/null || echo "Hostname/IP: $word"'

#=============================================================================
# TMUX
#=============================================================================

# Tmux sessions
zstyle ':fzf-tab:complete:tmux-(attach|switch-client):*' fzf-preview \
  'tmux list-windows -t $word 2>/dev/null | head -20'

# Tmux windows
zstyle ':fzf-tab:complete:tmux-select-window:*' fzf-preview \
  'tmux list-panes -t $word 2>/dev/null'

#=============================================================================
# ARCHIVES & COMPRESSED FILES
#=============================================================================

# Tar/zip archives
zstyle ':fzf-tab:complete:(tar|unzip|7z):*' fzf-preview \
  'case ${realpath##*.} in
    tar|tgz|tar.gz|tar.bz2|tar.xz) tar -tvf $realpath 2>/dev/null | head -100 ;;
    zip) unzip -l $realpath 2>/dev/null | head -100 ;;
    7z) 7z l $realpath 2>/dev/null | head -100 ;;
    *) [[ -f $realpath ]] && { bat --color=always $realpath 2>/dev/null || head -n 200 $realpath 2>/dev/null; } ;;
  esac'

#=============================================================================
# EDITOR & FILE OPERATIONS
#=============================================================================

# Nvim/vim - show file with syntax highlighting
zstyle ':fzf-tab:complete:(nvim|vim|vi|nano|code):*' fzf-preview \
  '[[ -f $realpath ]] && { bat --color=always --style=numbers,changes --line-range :200 $realpath 2>/dev/null || head -n 200 $realpath 2>/dev/null; } || [[ -d $realpath ]] && eza -1 --color=always --icons $realpath 2>/dev/null'

# Grep/rg/ag results
zstyle ':fzf-tab:complete:(grep|rg|ag):*' fzf-preview \
  '[[ -f {1} ]] && { bat --color=always --highlight-line {2} {1} 2>/dev/null || head -n 200 {1} 2>/dev/null; }'
