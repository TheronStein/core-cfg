```bash
zmodload -i zsh/complist
zmodload -F zsh/parameter +p:dirstack
autoload -Uz chpwd_recent_dirs add-zsh-hook cdr zstyle+
add-zsh-hook chpwd chpwd_recent_dirs
# add-zsh-hook -Uz zsh_directory_name zsh_directory_name_cdr # cd ~[1]

zstyle+ ':chpwd:*' recent-dirs-default true \
      + ''         recent-dirs-max     20 \
      + ''         recent-dirs-file    "${Zfiles[CHPWD]}" \
      + ''         recent-dirs-prune   'pattern:/tmp(|/*)'
# + ''         recent-dirs-file    "${ZDOTDIR}/chpwd-recent-dirs-${TTY##*/}" "${ZDOTDIR}/chpwd-recent-dirs" + \
# + ''         recent-dirs-file    "${ZDOTDIR}/chpwd-recent-dirs-${TTY##*/}" \

zstyle ':completion:*' recent-dirs-insert  both

# Can be called across sessions to update the dirstack without sourcing
# This should be fixed to update across sessions without ever needing to be called
function set-dirstack() {
  [[ -v dirstack ]] || typeset -gaU dirstack
  dirstack=(
    ${(u)^${(@fQ)$(<${$(zstyle -L ':chpwd:*' recent-dirs-file)[4]} 2>/dev/null)}[@]:#(\.|$PWD|/tmp/*)}(N-/)
  )
}
set-dirstack

# Taken from romkatv/zsh4humans
# ${(D)PWD}
local dir=${(%):-%~}
[[ $dir = ('~'|/)* ]] && () {
  # if (( ! $#dirstack && (DIRSTACKSIZE || ! $+DIRSTACKSIZE) )); then
    local d stack=()
    foreach d ($dirstack) {
      {
        if [[ ($#stack -ne 0 || $d != $dir) ]]; then
          d=${~d}
          if [[ -d ${d::=${(g:ceo:)d}} ]]; then
            stack+=($d)
            (( $+DIRSTACKSIZE && $#stack >= DIRSTACKSIZE - 1 )) && break
          fi
        fi
      } always {
        let TRY_BLOCK_ERROR=0
      }
    } 2>/dev/null
    dirstack=($stack)
  # fi
}
```

`@append_dir-history-var`

```bash
# @desc: helper function for per-dir-hist

emulate -L zsh

[[ -v dir_history ]] || return

dir_history=( "${1%%$'\n'}" "${(u)dir_history[@]}" )

# vim:ft=zsh:et
```

`@chpwd_dir-history-var`

```bash
# @desc: helper function for per-dir-hist

emulate -L zsh

[[ $1 = "now" ]] || {
  [[ -z "$funcstack[2]" ]] || {
    (( ${chpwd_dir_history_funcs[(I)$funcstack[2]]} )) || {
      return
    }
  }
}

if [[ -r "$_per_directory_history_path" ]]; then
    fc -a -p "$_per_directory_history_path"
fi

typeset -ga dir_history

dir_history=( "${(v)history[@]}" )

# vim: ft=zsh:et:sw=2:ts=2:sts=-1:fdm=marker:fmr=[[[,]]]:
```

`chpwd_ls`

```bash
# @desc: func ran on every cd

emulate -L zsh

[[ "$OLDPWD" != "$PWD" ]] && {
    eza -Fh --git --icons --group-directories-first
}
# vim:ft=zsh:
```
