# ~/.core/zsh/06-snippets.zsh
# Snippets and abbreviations - magic-space expansion system for rapid command entry

#=============================================================================
# ABBREVIATION SYSTEM
# Type abbreviation then press space to expand
# Example: g<space> expands to git<space>
#=============================================================================

typeset -A abbreviations

# Define abbreviations
abbreviations=(
    #=========================================================================
    # GIT ABBREVIATIONS
    #=========================================================================
    "gst"     "git status"
    "gco"     "git checkout"
    "gcob"    "git checkout -b"
    "gcom"    "git checkout main"
    "gcod"    "git checkout develop"
    "gaa"     "git add --all"
    "gap"     "git add --patch"
    "gcm"     "git commit -m \""
    "gcam"    "git commit --amend"
    "gcane"   "git commit --amend --no-edit"
    "gd"      "git diff"
    "gds"     "git diff --staged"
    "gpl"     "git pull"
    "gplr"    "git pull --rebase"
    "gps"     "git push"
    "gpsf"    "git push --force-with-lease"
    "gpsu"    "git push -u origin HEAD"
    "grb"     "git rebase"
    "grbi"    "git rebase -i"
    "grbm"    "git rebase main"
    "grbc"    "git rebase --continue"
    "grba"    "git rebase --abort"
    "gcp"     "git cherry-pick"
    "grs"     "git reset"
    "grsh"    "git reset --hard"
    "gss"     "git stash save"
    "gsp"     "git stash pop"
    "gsl"     "git stash list"
    "gbl"     "git blame"
    "glog"    "git log --oneline --graph --all"
    "gwt"     "git worktree"
    "gwta"    "git worktree add"
    "gwtl"    "git worktree list"
    "gwtr"    "git worktree remove"
    
    #=========================================================================
    # DOCKER ABBREVIATIONS
    #=========================================================================
    "dco"     "docker compose"
    "dcup"    "docker compose up -d"
    "dcdn"    "docker compose down"
    "dclg"    "docker compose logs -f"
    "dcps"    "docker compose ps"
    "dcre"    "docker compose restart"
    "dcb"     "docker compose build"
    "dps"     "docker ps"
    "dpsa"    "docker ps -a"
    "dex"     "docker exec -it"
    "dim"     "docker images"
    "drm"     "docker rm -f"
    "drmi"    "docker rmi"
    "dpr"     "docker system prune -af"
    "dlg"     "docker logs -f"
    "dst"     "docker stop"
    "dsta"    'docker stop $(docker ps -q)'
    
    #=========================================================================
    # KUBERNETES ABBREVIATIONS
    #=========================================================================
    "k"       "kubectl"
    "kgp"     "kubectl get pods"
    "kgpa"    "kubectl get pods -A"
    "kgs"     "kubectl get services"
    "kgd"     "kubectl get deployments"
    "kgi"     "kubectl get ingress"
    "kgn"     "kubectl get nodes"
    "kga"     "kubectl get all"
    "kgaa"    "kubectl get all -A"
    "kdp"     "kubectl describe pod"
    "kds"     "kubectl describe service"
    "kdd"     "kubectl describe deployment"
    "kdn"     "kubectl describe node"
    "klog"    "kubectl logs -f"
    "kex"     "kubectl exec -it"
    "kaf"     "kubectl apply -f"
    "kdf"     "kubectl delete -f"
    "kpf"     "kubectl port-forward"
    "kcx"     "kubectl config use-context"
    "kns"     "kubectl config set-context --current --namespace"
    
    #=========================================================================
    # SYSTEMD ABBREVIATIONS
    #=========================================================================
    "scs"     "systemctl status"
    "scst"    "systemctl start"
    "scsp"    "systemctl stop"
    "scr"     "systemctl restart"
    "sce"     "systemctl enable"
    "scd"     "systemctl disable"
    "scdr"    "systemctl daemon-reload"
    "scus"    "systemctl --user status"
    "jcf"     "journalctl -f"
    "jcu"     "journalctl -u"
    "jcb"     "journalctl -b"
    
    #=========================================================================
    # TMUX ABBREVIATIONS
    #=========================================================================
    "tns"     "tmux new-session -s"
    "tat"     "tmux attach -t"
    "tls"     "tmux list-sessions"
    "tks"     "tmux kill-session -t"
    "tka"     "tmux kill-server"
    "tss"     "tmux switch-client -t"
    "tnw"     "tmux new-window -n"
    "trw"     "tmux rename-window"
    "trs"     "tmux rename-session"
    
    #=========================================================================
    # ANSIBLE ABBREVIATIONS
    #=========================================================================
    "ap"      "ansible-playbook"
    "apc"     "ansible-playbook --check"
    "apd"     "ansible-playbook --diff"
    "apcd"    "ansible-playbook --check --diff"
    "apv"     "ansible-playbook -v"
    "apvv"    "ansible-playbook -vvv"
    "apl"     "ansible-playbook --limit"
    "apt"     "ansible-playbook --tags"
    "avv"     "ansible-vault view"
    "ave"     "ansible-vault edit"
    "avc"     "ansible-vault create"
    "avd"     "ansible-vault decrypt"
    "aven"    "ansible-vault encrypt"
    "agi"     "ansible-galaxy install -r requirements.yml"
    "agc"     "ansible-galaxy collection install"
    "ai"      "ansible-inventory --list"
    "aig"     "ansible-inventory --graph"
    
    #=========================================================================
    # PACKAGE MANAGEMENT (ARCH)
    #=========================================================================
    "pss"     "paru -Ss"
    "psi"     "paru -Si"
    "pin"     "paru -S"
    "pup"     "paru -Syu"
    "pre"     "paru -Rs"
    "pqi"     "paru -Qi"
    "pql"     "paru -Ql"
    "pqo"     "paru -Qo"
    "pcl"     "paru -Sc"
    "por"     "paru -Qtdq"
    
    #=========================================================================
    # COMMON COMMANDS
    #=========================================================================
    "md"      "mkdir -p"
    "rd"      "rmdir"
    "rf"      "rm -rf"
    "cpv"     "cp -v"
    "mvv"     "mv -v"
    "lns"     "ln -s"
    "chr"     "chmod +x"
    "chw"     "chmod 755"
    "cho"     "chown -R $USER:$USER"
    
    #=========================================================================
    # NETWORKING
    #=========================================================================
    "ssp"     "ss -tulpn"
    "nst"     "netstat -tulpn"
    "myip"    "curl -s ifconfig.me && echo"
    "pg"      "ping -c 5"
    "wgt"     "wget -c"
    
    #=========================================================================
    # EDITORS
    #=========================================================================
    "nv"      "nvim"
    "nv."     "nvim ."
    "nvc"     "nvim ~/.config/nvim"
    "nvz"     "nvim ~/.zshrc"
    "nvt"     "nvim ~/.config/tmux/tmux.conf"
    "nvh"     "nvim ~/.config/hypr/hyprland.conf"
    "nvw"     "nvim ~/.config/wezterm/wezterm.lua"
    "nvy"     "nvim ~/.config/yazi"
    
    #=========================================================================
    # QUICK PATHS
    #=========================================================================
    "cdp"     "cd ~/projects"
    "cdc"     "cd ~/.config"
    "cdd"     "cd ~/Downloads"
    "cdco"    "cd ~/.core"
    "cdnv"    "cd ~/.config/nvim"
    "cdtm"    "cd ~/.config/tmux"
    "cdhy"    "cd ~/.config/hypr"
    "cdwz"    "cd ~/.config/wezterm"
    "cdya"    "cd ~/.config/yazi"
    
    #=========================================================================
    # MISC UTILITIES
    #=========================================================================
    "h"       "history"
    "hg"      "history | grep"
    "cl"      "clear"
    "rl"      "exec \$SHELL -l"
    "sz"      "source ~/.zshrc"
    "wh"      "which"
    "tf"      "tail -f"
    "pf"      "printf"
    "tn"      "terminal-notifier -message"  # macOS
    "not"     "notify-send"                  # Linux
)

#=============================================================================
# MAGIC SPACE FUNCTION
# Expands abbreviations when space is pressed
#=============================================================================
function magic-space() {
    # Get the word before cursor
    local word="${LBUFFER##* }"
    
    # Check if we're at the start of line or after a pipe/semicolon
    if [[ "${LBUFFER}" == "${word}" ]] || \
       [[ "${LBUFFER}" =~ '(\||;|&&|\|\|)[[:space:]]*'${word}'$' ]]; then
        # Check if it's an abbreviation
        if [[ -n "${abbreviations[$word]}" ]]; then
            # Replace the abbreviation with its expansion
            LBUFFER="${LBUFFER%$word}${abbreviations[$word]}"
        fi
    fi
    
    # Add the space
    zle self-insert
}
zle -N magic-space
bindkey ' ' magic-space

#=============================================================================
# MAGIC ENTER (expand and execute)
#=============================================================================
function magic-enter() {
    local word="${BUFFER%% *}"
    
    if [[ -n "${abbreviations[$word]}" ]] && [[ "${BUFFER}" == "${word}" ]]; then
        BUFFER="${abbreviations[$word]}"
    fi
    
    zle accept-line
}
zle -N magic-enter
bindkey '^M' magic-enter

#=============================================================================
# SNIPPET EXPANSION WITH PLACEHOLDERS
# More complex snippets with cursor positioning
#=============================================================================
typeset -A snippets

snippets=(
    #=========================================================================
    # BASH/ZSH SNIPPETS
    #=========================================================================
    "shb"     '#!/usr/bin/env bash\nset -euo pipefail\nIFS=$'"'"'\\n\\t'"'"'\n\n'
    "shz"     '#!/usr/bin/env zsh\nset -euo pipefail\n\n'
    "iff"     'if [[ CURSOR ]]; then\n    \nfi'
    "elif"    'elif [[ CURSOR ]]; then\n    '
    "forr"    'for item in CURSOR; do\n    echo "$item"\ndone'
    "fori"    'for ((i=0; i<CURSOR; i++)); do\n    \ndone'
    "whil"    'while [[ CURSOR ]]; do\n    \ndone'
    "unti"    'until [[ CURSOR ]]; do\n    \ndone'
    "case"    'case $CURSOR in\n    pattern)\n        ;;\n    *)\n        ;;\nesac'
    "func"    'function CURSOR() {\n    \n}'
    "arr"     'declare -a CURSOR=()'
    "assoc"   'declare -A CURSOR=()'
    "here"    'cat <<EOF\nCURSOR\nEOF'
    "trap"    'trap '"'"'CURSOR'"'"' EXIT'
    "try"     '{\n    CURSOR\n} || {\n    echo "Error"\n}'
    
    #=========================================================================
    # GIT SNIPPETS
    #=========================================================================
    "gfc"     'git log --oneline --all | fzf | cut -d" " -f1 | xargs git checkout'
    "gfb"     'git branch | fzf | xargs git checkout'
    "gfd"     'git log --oneline --all | fzf --multi | cut -d" " -f1'
    "gwip"    'git add -A && git commit -m "WIP: CURSOR"'
    "gunwip"  'git reset HEAD~1'
    "gclean"  'git branch --merged | grep -v "\\*\\|main\\|master\\|develop" | xargs -r git branch -d'
    
    #=========================================================================
    # DOCKER SNIPPETS
    #=========================================================================
    "drun"    'docker run -it --rm --name CURSOR'
    "drunv"   'docker run -it --rm -v "$(pwd):/app" -w /app CURSOR'
    "dbash"   'docker exec -it CURSOR /bin/bash'
    "dcexec"  'docker compose exec CURSOR'
    "dinsp"   'docker inspect --format="{{json .}}" CURSOR | jq'
    
    #=========================================================================
    # FIND/SEARCH SNIPPETS
    #=========================================================================
    "fdf"     'fd --type f --hidden --exclude .git CURSOR'
    "fdd"     'fd --type d --hidden --exclude .git CURSOR'
    "rgf"     'rg --files-with-matches CURSOR'
    "rgi"     'rg --ignore-case CURSOR'
    "rgc"     'rg --count CURSOR'
    
    #=========================================================================
    # FZF SNIPPETS
    #=========================================================================
    "fzp"     'fzf --preview '"'"'bat --style=numbers --color=always {}'"'"''
    "fze"     'nvim $(fzf --preview '"'"'bat --style=numbers --color=always {}'"'"')'
    "fzd"     'cd $(fd --type d | fzf --preview '"'"'eza -la {}'"'"')'
    "fzk"     'ps aux | fzf | awk '"'"'{print $2}'"'"' | xargs kill'
    "fzh"     'history | fzf --tac | cut -c8-'
    
    #=========================================================================
    # ANSIBLE SNIPPETS
    #=========================================================================
    "aph"     'ansible-playbook -i inventory CURSOR playbook.yml'
    "aphl"    'ansible-playbook -i inventory --limit CURSOR playbook.yml'
    "acheck"  'ansible all -i inventory -m ping'
    "afact"   'ansible CURSOR -i inventory -m setup'
    "acmd"    'ansible CURSOR -i inventory -m shell -a ""'
    
    #=========================================================================
    # SYSTEMD SNIPPETS
    #=========================================================================
    "sclog"   'journalctl -u CURSOR -f'
    "scedit"  'systemctl edit CURSOR'
    "sccat"   'systemctl cat CURSOR'
    
    #=========================================================================
    # NETWORK SNIPPETS
    #=========================================================================
    "curlj"   'curl -sS CURSOR | jq'
    "curlh"   'curl -sS -I CURSOR'
    "curlp"   'curl -X POST -H "Content-Type: application/json" -d '"'"'{}'"'"' CURSOR'
    "sshp"    'ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null CURSOR'
    "scpd"    'scp -r CURSOR:~/ ./'
    
    #=========================================================================
    # TMUX SNIPPETS  
    #=========================================================================
    "tdev"    'tmux new-session -d -s dev -n editor \; \\\n    send-keys "nvim" Enter \; \\\n    new-window -n shell \; \\\n    attach-session -t dev'
    "twork"   'tmux new-session -d -s work \; \\\n    split-window -h \; \\\n    split-window -v \; \\\n    select-pane -t 0 \; \\\n    attach-session -t work'
    
    #=========================================================================
    # PYTHON SNIPPETS
    #=========================================================================
    "pyv"     'python -m venv .venv && source .venv/bin/activate'
    "pyact"   'source .venv/bin/activate'
    "pipr"    'pip install -r requirements.txt'
    "pipf"    'pip freeze > requirements.txt'
    
    #=========================================================================
    # DATE/TIME SNIPPETS
    #=========================================================================
    "diso"    '$(date +%Y-%m-%d)'
    "dtiso"   '$(date +%Y-%m-%dT%H:%M:%S)'
    "dts"     '$(date +%Y%m%d%H%M%S)'
    "dutc"    '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
)

#=============================================================================
# SNIPPET EXPANSION FUNCTION
# Usage: Type snippet name, press Ctrl+X Ctrl+S to expand
#=============================================================================
function expand-snippet() {
    local word="${LBUFFER##* }"
    
    if [[ -n "${snippets[$word]}" ]]; then
        local expansion="${snippets[$word]}"
        
        # Handle CURSOR placeholder
        if [[ "$expansion" == *"CURSOR"* ]]; then
            # Split at CURSOR
            local before="${expansion%%CURSOR*}"
            local after="${expansion#*CURSOR}"
            
            # Expand newlines
            before="${before//\\n/$'\n'}"
            after="${after//\\n/$'\n'}"
            
            LBUFFER="${LBUFFER%$word}${before}"
            RBUFFER="${after}${RBUFFER}"
        else
            expansion="${expansion//\\n/$'\n'}"
            LBUFFER="${LBUFFER%$word}${expansion}"
        fi
    fi
    zle redisplay
}
zle -N expand-snippet
bindkey '^X^S' expand-snippet

#=============================================================================
# LIST ABBREVIATIONS
#=============================================================================
function abbr-list() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    ABBREVIATIONS REFERENCE                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    local -a sorted_keys
    sorted_keys=(${(ko)abbreviations})
    
    local prev_category=""
    for key in ${sorted_keys}; do
        printf "  %-10s → %s\n" "$key" "${abbreviations[$key]}"
    done | less
}
alias abbrs='abbr-list'

#=============================================================================
# LIST SNIPPETS
#=============================================================================
function snippet-list() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                      SNIPPETS REFERENCE                        ║"
    echo "║              Expand with Ctrl+X Ctrl+S                         ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    local -a sorted_keys
    sorted_keys=(${(ko)snippets})
    
    for key in ${sorted_keys}; do
        printf "  %-10s\n" "$key"
        echo "${snippets[$key]}" | sed 's/^/    /' | head -3
        echo ""
    done | less
}
alias snips='snippet-list'
