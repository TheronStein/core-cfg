# ~/.core/zsh/fzf-consolidated.zsh
# Consolidated FZF configuration - merged from various sources
# Includes plugin loading, core config, functions, widgets, and integrations
# Original sources: 02-zinit.zsh (fzf parts), integrations/fzf.zsh, integrations/.archv/plugins/fzf.zsh

# # ~/.core/zsh/fzf-consolidated.zsh
# # Consolidated FZF configuration - merged from various sources
# # Includes plugin loading, core config, functions, widgets, and integrations
# # Original sources: 02-zinit.zsh (fzf parts), integrations/fzf.zsh, integrations/.archv/plugins/fzf.zsh
# # Human-readable fzf colors (edit freely, one per line)
# # ── Get raw multiline colors (from your theme script or fallback) ──
_fzf_tab_colors=$(
  "$HOME/.core/.sys/cfg/wezterm/scripts/theme-browser/get-current-fzf-colors.zsh" 2>/dev/null || cat <<'EOF'
bg+:#313244
bg:#1e1e2e
spinner:#f5e0dc
hl:#f38ba8
fg:#cdd6f4
header:#f38ba8
info:#cba6f7
pointer:#f5e0dc
marker:#f5e0dc
fg+:#cdd6f4
prompt:#cba6f7
hl+:#f38ba8
border:#f38ba8
label:#89b4fa
query:#cdd6f4
EOF
)
# Convert multiline → comma-separated string that fzf-tab actually accepts
_fzf_tab_colors=$(echo "$_fzf_tab_colors" | paste -sd, -)
# ── Keybindings ──
_fzf_binds=(
  'ctrl-/:toggle-preview'
  'ctrl-a:select-all'
  'ctrl-d:deselect-all'
  'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
  'ctrl-u:preview-page-up'
  'ctrl-n:preview-page-down'
  'alt-j:preview-down'
  'alt-k:preview-up'
  'ctrl-f:page-down'
  'ctrl-b:page-up'
  'tab:toggle+down'
  'shift-tab:toggle+up'
)
_fzf_border=(
  --border=double
  --border-label-pos=3
  --border-label='╣    CORE - FZF  ╠'
)
_fzf_prompt_icons=(
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
)
# ── Header, border, icons ──
_fzf_header='Navigate: ↑↓ | Select: Enter | Toggle Preview: Ctrl+/ | Quit: Esc\n─────────────────────────────────────────'
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags \
  --height=50% \
  --reverse \
  ${_fzf_border[@]} \
  ${_fzf_prompt_icons[@]} \
  --header="$_fzf_header" \
  --color="$_fzf_tab_colors" \
  ${_fzf_binds[@]/#/--bind=}
zstyle ':fzf-tab:*' fzf-preview-window 'right:60%:wrap:rounded'                                                                                         
zstyle ':fzf-tab:*' switch-group ',' '.'                                                                                                                
zstyle ':fzf-tab:*' continuous-trigger '/'
# # Load fzf-tab (only once!)

# Check for fzf
(( $+commands[fzf] )) || return 0

# =============================================================================
# PLUGIN LOADING (from 02-zinit.zsh)
# =============================================================================
# FZF core
zinit ice from"gh-r" as"program"
zinit light junegunn/fzf

# FZF-tab
zinit light Aloxaf/fzf-tab

# =============================================================================
# CORE CONFIGURATION (from integrations/fzf.zsh)
# =============================================================================
export FZF_PREVIEW="${ZDOTDIR:-$HOME/.core/.sys/cfg/zsh}/functions/fzf-preview"

# Dynamic FZF theme system
_fzf_colors() {
  "$HOME/.core/.sys/cfg/wezterm/scripts/theme-browser/get-current-fzf-colors.zsh" 2>/dev/null || cat <<'EOF'
bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4
header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc
fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,border:#89b4fa
label:#89b4fa,query:#cdd6f4
EOF
}

_fzf_base_opts() {
  local colors
  colors=$(_fzf_colors | tr '\n' ',')
  colors=${colors%,}  # Remove trailing comma

  local -a opts
  opts=(
    --ansi
    --height=50%
    --reverse
    --border=rounded
    --border-label-pos=3
    "--prompt=❯ "
    "--pointer=▶"
    "--marker=✓"
    "--color=$colors"
    --bind=ctrl-/:toggle-preview
    --preview-window=right:60%:wrap:rounded
  )
  echo "${opts[@]}"
}

# FZF environment configuration
if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
    export FZF_ALT_C_COMMAND='find . -type d -not -path "*/\.git/*"'
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS="
    --height=80%
    --layout=reverse
    --border=rounded
    --info=inline
    --margin=1
    --padding=1
    --prompt='> '
    --pointer='>'
    --marker='*'
    --header-first
    --ansi
    --cycle
    --multi
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-a:select-all'
    --bind='ctrl-d:deselect-all'
    --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
    --bind='ctrl-u:preview-page-up'
    --bind='ctrl-n:preview-page-down'
    --bind='alt-j:preview-down'
    --bind='alt-k:preview-up'
    --bind='ctrl-f:page-down'
    --bind='ctrl-b:page-up'
    --bind='tab:down'
    --bind='shift-tab:up'
    --bind='ctrl-m:toggle+down'
    --bind='ctrl-k:up'
    --bind='enter:accept'
    --preview-window='right:60%:wrap'
"

export FZF_CTRL_T_OPTS="
    --preview 'bash \"$FZF_PREVIEW\" {} 2>/dev/null || true'
    --preview-window='right:90%:wrap'
    --bind='ctrl-/:toggle-preview'
    --header='Files | C-/: toggle preview | C-y: copy'
"

export FZF_ALT_C_OPTS="
    --preview 'bash \"$FZF_PREVIEW\" {} 2>/dev/null || true'
    --preview-window='right:10%:wrap'
    --header='Directories | C-/: toggle preview'
"

export FZF_CTRL_R_OPTS="
    --preview 'echo {} | sed \"s/^ *[0-9]* *//\" | bat --style=plain --color=always -l bash'
    --preview-window='down:3:wrap'
    --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
    --header='History | C-y: copy command'
    --exact
"

# FZF completion configuration
_fzf_compgen_path() {
    fd --hidden --follow --exclude .git . "$1"
}

_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude .git . "$1"
}

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd)           fzf --preview "bash \"$FZF_PREVIEW\" {} 2>/dev/null || true" "$@" ;;
        export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
        ssh)          fzf --preview 'dig +short {}' "$@" ;;
        git)          fzf --preview 'git log --oneline --graph --color=always {}' "$@" ;;
        kill)         fzf --preview 'ps -p {} -o comm,pid,user,time,stat' "$@" ;;
        *)            fzf --preview "bash \"$FZF_PREVIEW\" {} 2>/dev/null || true" "$@" ;;
    esac
}

# =============================================================================
# HELPER FUNCTIONS (from integrations/fzf.zsh)
# =============================================================================
function fzf-git-add() {
    local files
    files=$(git status --short | \
        fzf $(_fzf_base_opts) --multi --ansi \
            --preview 'git diff --color=always -- {-1} | delta' \
            --header 'Select files to stage' \
            --bind 'ctrl-a:select-all,ctrl-d:deselect-all' | \
        awk '{print $2}')

    if [[ -n "$files" ]]; then
        echo "$files" | xargs git add
        git status --short
    fi
}

function fzf-git-checkout-file() {
    local files
    files=$(git diff --name-only | \
        fzf $(_fzf_base_opts) --multi --ansi \
            --preview 'git diff --color=always -- {} | delta' \
            --header 'Select files to restore' | \
        tr '\n' ' ')

    if [[ -n "$files" ]]; then
        git checkout -- $files
    fi
}

function fzf-docker-logs() {
    local container
    container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | \
        fzf $(_fzf_base_opts) --header-lines=1 \
            --preview 'docker logs --tail 50 $(echo {} | awk "{print \$1}")' | \
        awk '{print $1}')

    if [[ -n "$container" ]]; then
        docker logs -f "$container"
    fi
}

function fzf-docker-exec() {
    local container
    container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | \
        fzf $(_fzf_base_opts) --header-lines=1 \
            --preview 'docker inspect $(echo {} | awk "{print \$1}")' | \
        awk '{print $1}')

    if [[ -n "$container" ]]; then
        local cmd="${1:-/bin/bash}"
        docker exec -it "$container" "$cmd"
    fi
}

function fzf-man() {
    local page
    page=$(apropos . | \
        fzf $(_fzf_base_opts) \
            --preview 'man $(echo {} | awk "{print \$1}")' | \
        awk '{print $1}')

    if [[ -n "$page" ]]; then
        man "$page"
    fi
}

function fzf-systemctl() {
    local unit
    unit=$(systemctl list-units --all --no-legend | \
        fzf $(_fzf_base_opts) \
            --preview 'SYSTEMD_COLORS=1 systemctl status $(echo {} | awk "{print \$1}")' \
            --header 'Select systemd unit' | \
        awk '{print $1}')

    if [[ -n "$unit" ]]; then
        local action
        action=$(echo -e "status\nstart\nstop\nrestart\nenable\ndisable\nlogs" | \
            fzf $(_fzf_base_opts) --header "Select action for $unit")

        case "$action" in
            logs) journalctl -u "$unit" -f ;;
            status|start|stop|restart|enable|disable) sudo systemctl "$action" "$unit" ;;
        esac
    fi
}

function fzf-pacman-install() {
    local packages
    local installer="${1:-paru}"

    if command -v "$installer" &>/dev/null; then
        packages=$($installer -Slq | \
            fzf $(_fzf_base_opts) --multi --preview "$installer -Si {}" \
                --header 'Select packages to install')

        if [[ -n "$packages" ]]; then
            echo "$packages" | xargs $installer -S
        fi
    else
        echo "Package manager $installer not found"
    fi
}

function fzf-kill-port() {
    local process
    process=$(ss -tulpn 2>/dev/null | grep LISTEN | \
        fzf $(_fzf_base_opts) --header 'Select port to kill process' \
            --preview 'echo {} | grep -oP "pid=\K[0-9]+" | xargs ps -p' | \
        grep -oP 'pid=\K[0-9]+')

    if [[ -n "$process" ]]; then
        kill -9 "$process"
        echo "Killed process $process"
    fi
}

function fzf-npm-scripts() {
    [[ ! -f package.json ]] && echo "No package.json found" && return 1

    local script
    script=$(jq -r '.scripts | keys[]' package.json 2>/dev/null | \
        fzf $(_fzf_base_opts) \
            --preview 'jq -r ".scripts.\"{}\"" package.json' \
            --preview-window 'down:3:wrap' \
            --header 'Select npm script to run')

    if [[ -n "$script" ]]; then
        npm run "$script"
    fi
}

function fzf-environment() {
    local var
    var=$(env | sort | \
        fzf $(_fzf_base_opts) \
            --preview 'echo {} | cut -d= -f2-' \
            --preview-window 'down:3:wrap' \
            --header 'Environment Variables' | \
        cut -d= -f1)

    if [[ -n "$var" ]]; then
        echo "Current value: ${(P)var}"
        echo -n "New value: "
        read new_value
        if [[ -n "$new_value" ]]; then
            export "$var=$new_value"
            echo "Updated $var"
        fi
    fi
}

function fzf-wifi() {
    (( $+commands[nmcli] )) || { echo "nmcli not found"; return 1; }

    local network
    network=$(nmcli device wifi list | sed 1d | \
        fzf $(_fzf_base_opts) \
            --preview 'echo "Signal: $(echo {} | awk \"{print \$7}\")"' \
            --header 'Select WiFi network' | \
        sed 's/^[* ] //' | awk '{print $2}')

    if [[ -n "$network" ]]; then
        nmcli device wifi connect "$network"
    fi
}

function fzf-cliphist() {
    (( $+commands[cliphist] )) || { echo "cliphist not found"; return 1; }
    (( $+commands[wl-copy] )) || { echo "wl-copy not found"; return 1; }

    local selection
    selection=$(cliphist list | \
        fzf $(_fzf_base_opts) \
            --preview 'echo {} | cliphist decode' \
            --preview-window 'down:3:wrap' \
            --header 'Clipboard History | Enter: yank to clipboard')

    if [[ -n "$selection" ]]; then
        echo "$selection" | cliphist decode | wl-copy
        echo "✓ Copied to clipboard"
    fi
}

function fzf-tmux-layouts() {
    [[ -z "$TMUX" ]] && { echo "Not in a tmux session"; return 1; }

    local layouts=(
        "even-horizontal|Split panes evenly horizontally|┌──┬──┬──┬──┐\n│  │  │  │  │\n└──┴──┴──┴──┘"
        "even-vertical|Split panes evenly vertically|┌────────────┐\n├────────────┤\n├────────────┤\n└────────────┘"
        "main-horizontal|One large pane on top, others below|┌────────────┐\n│   MAIN     │\n├────┬───┬───┤\n└────┴───┴───┘"
        "main-vertical|One large pane on left, others on right|┌─────┬──┬──┐\n│     │  │  │\n│MAIN │  │  │\n└─────┴──┴──┘"
        "tiled|Tile all panes evenly|┌──────┬──────┐\n│      │      │\n├──────┼──────┤\n│      │      │\n└──────┴──────┘"
    )

    local selection
    selection=$(printf '%s\n' "${layouts[@]}" | \
        fzf $(_fzf_base_opts) \
            --delimiter='|' \
            --with-nth=1,2 \
            --preview 'echo {3} | sed "s/\\\\n/\n/g"' \
            --preview-window='right:40%:wrap' \
            --header='Select tmux layout' | \
        cut -d'|' -f1)

    if [[ -n "$selection" ]]; then
        tmux select-layout "$selection"
        echo "✓ Applied layout: $selection"
    fi
}

# Aliases from integrations/fzf.zsh
alias fga='fzf-git-add'
alias fgco='fzf-git-checkout-file'
alias fdl='fzf-docker-logs'
alias fde='fzf-docker-exec'
alias fman='fzf-man'
alias fsys='fzf-systemctl'
alias fpac='fzf-pacman-install'
alias fkill='fzf-kill-port'
alias fnpm='fzf-npm-scripts'
alias fenv='fzf-environment'
alias fwifi='fzf-wifi'
alias fclip='fzf-cliphist'
alias flayout='fzf-tmux-layouts'

# Key bindings from integrations/fzf.zsh
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

zle -N fzf-git-add
zle -N fzf-git-checkout-file

if ! bindkey | grep -q "fzf-git-add"; then
    bindkey '^G^A' fzf-git-add
fi

# FZF-TAB integration from integrations/fzf.zsh
if (( $+commands[fzf] )) && (( $+functions[fzf-tab] )); then
    local fzf_tab_colors_converted
    fzf_tab_colors_converted=$(_fzf_colors | tr '\n' ',')
    fzf_tab_colors_converted=${fzf_tab_colors_converted%,}  # Remove trailing comma
    zstyle ':fzf-tab:*' fzf-flags --height=60% --color="$fzf_tab_colors_converted"
fi

if [[ -n "$TMUX" ]]; then
    export FZF_TMUX_OPTS="-p 80%,80%"
    ftb-tmux-popup() {
        fzf-tmux -p 80%,80% "$@"
    }
fi

# =============================================================================
# ADDITIONAL FUNCTIONS AND WIDGETS (from integrations/.archv/plugins/fzf.zsh)
# =============================================================================
function fcd-zle() {
  local dir
  dir=$(fd ${1:-.} --prune -td | fzf +m)
  if [[ -d "$dir" ]]; then
    builtin cd "$dir"
    (($+WIDGET)) && zle zredraw-prompt
  else
    (($+WIDGET)) && zle redisplay
  fi
}; zle -N fcd-zle

function fzf-ghq() {
  local repo
  repo=$(\
    command ghq list -p \
      | xargs ls -dt1 \
      | lscolors \
      | fzf --ansi \
            --no-multi \
            --prompt='GHQ> ' \
            --reverse \
            --height=50% \
            --preview="\
            bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*" \
            --preview-window="right:50%" \
            --delimiter=/ \
            --with-nth=5..
  )
  [[ -d "$repo" ]] && {
    if (( $+WIDGET )); then
      BUFFER="cd $repo"
      zle accept-line
    else
      builtin cd "$repo"
    fi
  }
}; zle -N fzf-ghq
Zkeymaps[M-x]=fzf-ghq

function f1lsof() {
  local pid args; args=${${${(M)UID:#0}:+-f -u $UID}:--fe}
  pid=$(ps ${(z)args} | sed 1d | fzf -m | awk '{print $2}')
  dunstify $pid
  (( $+pid )) && {
    LBUFFER="lsof -p $pid"
    (($+WIDGET)) && zle zredraw-prompt
  }
}; zle -N f1lsof

function f1env() {
  local out
  out=$(fzf <<<${(@f)"$(env)"})
  [[ -n $out ]] && hck -d '=' -f2<<<$out
}

function f1set() {
  local out
  out=$(fzf <<<${(F)${(@f)"$(set)"}//prompt=*/})
  [[ -n $out ]] && hck -d '=' -f2<<<$out
}

function f1fig() (
  emulate -L zsh
  builtin cd -q /usr/share/figlet/fonts
  command ls *.flf | sort | fzf --no-multi --reverse --preview "figlet -f {} Hello World!"
)

function f1mates() {
  mutt "$(MATES_GREP='fzf -q' mates email-query)"
}

function f1jrnl() {
  local title
  title=$(jrnl --short | fzf --tac --no-sort)
  jrnl -on "$(echo $title | cut -c 1-16)" $1
}

function f1fg() {
  local job
  job="$(builtin jobs | fzf -0 -1 | sed -E 's/\[(.+)\].*/\1/')" && print '' && fg %$job;
}

function f1z-ctrlz() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER=" f1fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}; zle -N f1z-ctrlz
Zkeymaps[C-z]=f1z-ctrlz

function f1uni() {
  ruby \
    -e '0x100.upto(0xFFFF) do |i| puts "%04X%8d%6s" % [i, i, i.chr("UTF-8")] rescue true end' \
  | fzf -m
}

function f1ssh() {
  local -a hosts
  local choice

  hosts=( ${=${${${${(@M)${(f)"$(<$HOME/.ssh/config)"}}:#Host *}#Host }:#*\**}:#*\?*} )
  choice=$(builtin print -rl "$hosts[@]" | fzf +m)

  [[ -n $choice ]] && command ssh $choice
}

function f1twf() {
  (( ! $+commands[twf] )) && {
    zerr "{cmd}twf{%} is needed for this"
    return 1
  }
  local -a files; files=("$(
    twf \
      --height=0.8 \
      --previewCmd='([[ -f {} ]] && (bat --style=numbers --color=always {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
  )") || return
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

function f1mpc() {
  local song_pos; song_pos=$(\
    mpc -f "%position%) %artist% - %title%" playlist \
      | fzf-tmux --query="$1" --reverse --select-1 --exit-0 \
      | sed -n 's/^\([0-9]\+\)).*/\1/p') \
    || return 1
  [[ -n "$song_pos" ]] && mpc -q play $song_pos
}

function f1pdf() {
  local prog='zathura'

  fd --no-ignore-vcs -tf -e pdf \
    | fast-p \
    | fzf \
        --read0 \
        --reverse \
        --delimiter $'\t'  \
        --preview-window='nohidden,down:80%' \
        --preview='local v=$(print -r {q} | tr " " "|");
                   print -- {1}"\n"{2} | grep -E "^|$v" -i --color=always;' \
    | cut -z -f 1 -d $'\t' \
    | tr -d '\n' \
    | xargs -r --null $open > /dev/null 2> /dev/null
}

function fzf-file-edit-widget() {
  setopt localoptions pipefail
  local files
  files=$(eval "$FZF_ALT_E_COMMAND" |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_E_OPTS" fzf -m |
      sed 's/^\s\+.\s//')
  local ret=$?

  [[ $ret -eq 0 ]] && echo $files | xargs sh -c "$EDITOR \$@ </dev/tty" $EDITOR

  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}; zle -N fzf-file-edit-widget

function f1zfe() {
  local -a sel
  sel=("$(rgf --bind='enter:accept' --multi)")
  [[ -n "$sel" ]] && ${EDITOR:-vim} "${sel[@]}"
  (( $+WIDGET )) && {
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
  }
}; zle -N f1zfe
Zkeymaps[Esc-f]=f1zfe

function :fzf-histdb() {
  local query="
SELECT commands.argv
FROM   history
  LEFT JOIN commands
    ON history.command_id = commands.rowid
  LEFT JOIN places
    ON history.place_id = places.rowid
GROUP BY commands.argv
ORDER BY places.dir != '${PWD//'/''}',
    commands.argv LIKE '${BUFFER//'/''}%' DESC,
    Count(*) DESC
"
  local selected=$(_histdb_query "$query" | ftb-tmux-popup -n "2.." --tiebreak=index --prompt="cmd> " ${BUFFER:+-q$BUFFER})

  BUFFER=${selected}
  CURSOR=${#BUFFER}
}; zle -N :fzf-histdb
Zkeymaps+=('C-x r' :fzf-histdb)

function :fzf-find() {
  local selected dir cut
  cut=$(grep -oP '[^* ]+(?=\*{1,2}$ )' <<< $BUFFER)
  eval "dir=${cut:-.}"
  if [[ $BUFFER == *"**"* ]] {
    selected=$(fd -H . $dir \
      | ftb-tmux-popup --tiebreak=end,length --prompt="cd> " --border=none)
  } elif [[ $BUFFER == *"*"* ]] {
    selected=$(fd -d 1 . $dir \
      | ftb-tmux-popup --tiebreak=end --prompt="cd> " --border=none)
  }
  BUFFER=${BUFFER/%'*'*/}
  BUFFER=${BUFFER/%$cut/$selected}
  zle end-of-line
}; zle -N :fzf-find
Zkeymaps+=('C-x C-f' :fzf-find)

function fzf-dmenu() {
  local selected="$(\
    command ls /usr/share/applications \
      | sed 's/\(.*\)\.desktop/\1/g' \
      | fzf -e
  ).desktop"
  [[ -n "${selected%.desktop}" && $? -eq 0 ]] && {
    nohup $(\
      grep '^Exec' "/usr/share/applications/$selected" \
        | tail -1 \
        | sed 's/^Exec=//' \
        | sed 's/%.//'
    ) >/dev/null 2>&1 &
  }
}

function f1dockrm() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -q "$1" | awk '{print $1}')
  [[ -n "$cid" ]] && docker rm "$cid"
}

function f1docka() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -1 -q "$1" | awk '{print $1}')
  [[ -n "$cid" ]] && docker start "$cid" && docker attach "$cid"
}

function f1dockrmi() {
  docker images | sed 1d | fzf -q "$1" --no-sort -m --tac | awk '{ print $3 }' | xargs -r docker rmi
}

function f1docks() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -1 -q "$1" | awk '{print $1}')
  [[ -n "$cid" ]] && docker stop "$cid"
}

# =============================================================================
# FZF-TAB CONFIGURATION (from 02-zinit.zsh)
# =============================================================================
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 80 20
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-pad 4

zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
    'git log --color=always --oneline --graph $word'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
    'case "$group" in
        "modified file") git diff --color=always $word ;;
        "recent commit object name") git show --color=always $word ;;
        *) git log --color=always --oneline --graph $word ;;
    esac'
zstyle ':fzf-tab:complete:kill:*' fzf-preview \
    'ps --pid=$word -o cmd,pid,user,comm -w -w'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview \
    'SYSTEMD_COLORS=1 systemctl status $word'
