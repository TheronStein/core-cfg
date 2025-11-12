# Enhanced FZF functions from user's config

if (( $+commands[fzf] )); then
    # Set FZF defaults
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'#
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    
    # Source FZF key bindings if available
    if [[ -f "${ZINIT[PLUGINS_DIR]}/junegunn---fzf-binary/key-bindings.zsh" ]]; then
        source "${ZINIT[PLUGINS_DIR]}/junegunn---fzf-binary/key-bindings.zsh"
    elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
        source /usr/share/fzf/key-bindings.zsh
    fi

    # # Key bindings (if not already loaded by plugin)
    # if [[ ! -f "${ZINIT[PLUGINS_DIR]}/junegunn---fzf-binary/key-bindings.zsh" ]]; then
    #     bindkey '^R' fzf-history-widget 2>/dev/null
    #     bindkey '^T' fzf-file-widget 2>/dev/null
    # fi
    # Git functions
    # Checkout git branch/tag    
    fco() {
        local tags branches target
        branches=$(
            git --no-pager branch --all \
            --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
            | sed '/^$/d'
        ) || return
        tags=$(
            git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}'
        ) || return
        target=$(
            (echo "$branches"; echo "$tags") |
            fzf --no-hscroll --no-multi -n 2 \
                --ansi --preview="git --no-pager log -150 --pretty=format:%s '..{2}'"
        ) || return
        git checkout $(awk '{print $2}' <<<"$target")
    }

    fkill() {
        local pid
        if [ "$UID" != "0" ]; then
            pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
        else
            pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        fi
        
        if [ "x$pid" != "x" ]; then
            echo $pid | xargs kill -${1:-9}
        fi
    }
    
    # Git branch checkout
    fbr() {
        local branches branch
        branches=$(git branch --all | grep -v HEAD) &&
        branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    }

    # Edit file with fzf
    fe() {
        local file
        file=$(fzf --preview 'cat {}' --preview-window=right:50%) < /dev/tty
        [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
    }

    fcd() {
        local dir
        dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) < /dev/tty
        [[ -n "$dir" ]] && cd "$dir"
    }
    
    # cd to selected parent directory
    fup() {
        local dir
        dir=$(while true; do
            pwd
            [ "$PWD" = "/" ] && break
            cd ..
        done | fzf --tac)
        cd "$dir"
    }

    
    # Search and install packages (adjust for your package manager)
    if (( $+commands[paru] )); then
        fpac() {
            paru -Sl | 
            awk '{print $2($4=="" ? "" : " *")}' | 
            fzf --multi --preview 'paru -Si {1}' | 
            cut -d " " -f 1 |
            xargs -ro paru -S
        }
    fi
fi
