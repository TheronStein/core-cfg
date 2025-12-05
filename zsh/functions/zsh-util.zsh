# @desc: `which` tool which has all information from `whence`
function ww() {
  (alias; declare -f) |
    /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@;
}

function zsh-minimal() {
  builtin cd "$(mktemp -d)"
  ZDOTDIR=$PWD HOME=$PWD zsh -df
}

# @desc: reload zsh function without sourcing zshrc
function freload() {
  while (($#)) { unfunction $1 && autoload -U $1 && shift }
}

# @desc: reload zwc functions
function freloadz() {
  local -a zwcdirs=(${Zdirs[FUNC]}/${(P)^Zdirs[FUNC_D_zwc]}.zwc)
  for dir ($zwcdirs[@]) {
    dir=${dir%.zwc}
    zwc=${dir:t}
    if [[ ! -d $dir ]]; then
      zinfo -v "$dir is not a directory to compile"
      continue
    fi
    if [[ $dir == (.|..) || $dir == (.|..)/* ]]; then
      continue
    fi
    files=($dir/*~*.zwc(|.old)(#qN-.))
    if [[ -w $dir:h && -n $files ]]; then
      files=(${${(M)files%/*/*}#/})
      if ( builtin cd -q $dir:h &&
          zrecompile -p -U -z $zwc $files ); then
        zinfo -v "updated: $dir"
      fi
    fi
  }
  fpath=${fpath[@]:|zwcdirs}
  fpath[1,$#zwcdirs]=($zwcdirs)
  autoload -Uwz ${(@z)fpath[1,$#zwcdirs]}
}

# @desc: edit an alias via zle (whim -a)
function ealias() {
  [[ -z "$1" ]] && {
    print::usage "ealias" "<alias_to_edit>"; return 1;
  }
  vared aliases'[$1]' ;
}

# @desc: edit a function via zle (whim -f)
function efunc() {
  [[ -z "$1" ]] && {
    print::usage "efunc" "<func_to_edit>"; return 1;
  }
  zed -f "$1"
}

# @desc: find functions that follow this pattern: func()
function ffunc() {
  eval "() { $functions[RG] } ${@}\\\\\(";
}

# @desc: list loaded ZLE modules
function lszle() {
  # print -rl -- \
  #   ${${${(@f):-"$(zle -Ll)"}//(#m)*/${${(ws: :)MATCH}[1,3]}}//*(autosuggest|orig-s)*/} | \
  print -rl -- ${${(@f):-"$(zle -la)"}//*(autosuggest|orig-s)*/} \
    | command bat --terminal-width=$(( COLUMNS-2 ))
}

# @desc: list zstyle modules
function lszstyle() {
  emulate -L zsh -o extendedglob
  print -Plr -- \
    ${${(@)${(@f):-"$(zstyle -L ':*')"}/*list-colors*/}//(#b)(zstyle) (*) (*) (*)/\
%F{1}$match[1]%f %F{3}$match[2]%f %F{14}%B$match[3]%b%f %F{2}$match[4]} \
  | command bat --terminal-width=$(( COLUMNS-2 ))
}

# @desc: list all commands
function lscmds() {
  emulate -L zsh
  # zmodload -Fa zsh/parameter p:commands
  # print -rl -- $^path/${(ok)^commands[@]}(#qN) \
    # | lscolors \

  # hash \
  #   | perl -F= -lane 'printf "%-30s %s\n", $F[0], $F[1]' \

  print -rl -- ${(ov)commands[@]} \
    | lscolors \
    | command bat --terminal-width=$(( COLUMNS-2 ))
}

# @desc: list functions
function lsfuncs() {
  emulate -L zsh -o extendedglob
  zmodload -Fa zsh/parameter p:functions

  (
    [[ $1 = -a ]] && {
      print -rl -- ${${(@o)${(k)functions[(I)^[→_.+:@-]*]}}}
    } || {
      print -rl -- $^fpath/${^${(@o)${(k)functions[(I)^[→_.+:@-]*]}}}(#qN) | lscolors
    }
  ) | bat
}

# @desc: print path of zsh function
function wherefunc() {
  (( $+functions[$1] )) || zerr "$1 is not a function"
  for 1; do
    (
      local out=${${(j: :):-$(print -r ${^fpath}/$1(#qNP-$1-))}//(#b)(*) (*)/%F{1}%B$match[1]%b %F{2}$match[2]}
      if ((!$#out)) {
        zinfo -s "{func}$1{%} is a function, but it is in a {file}zwc{%} file"
        out=${${(j: :):-$(\
          print -r ${Zdirs[FUNC]}/${(P)^Zdirs[FUNC_D_zwc]}/$1(#qNP-$1-))}//(#b)(*) (*)/%F{1}%B$match[1]%b %F{2}$match[2]}
      }
      print -PraC 2 -- $out

    )
  done
}

# @desc: tells from-where a zsh completion is coming from
function from-where {
  print -l -- $^fpath/$_comps[$1](N)
  whence -v $_comps[$1]
  #which $_comps[$1] 2>&1 | head
}
functions -c from-where wherefrom

# @desc: tell which completion a command is using
function whichcomp() {
  for 1; do
      ( print -raC 2 -- $^fpath/${_comps[$1]:?unknown command}(NP-$1-) )
  done
}

# @desc: disown a process
function run_diso {
  sh -c "${(z)@}" &>/dev/null &
  disown
}

# @desc: nohup a process
function background() {
  nohup "${(z)@}" >/dev/null 2>&1 &
}

# @desc: nohup a process and immediately disown
function background!() {
  nohup "${(z)@}" >/dev/null 2>&1 &!
}

# @desc: reinstall completions
function creinstall() {
  ___creinstall() {
    emulate zsh -ic "zinit creinstall -q $GENCOMP_DIR 1>/dev/null" &!
  }

  (( $+functions[defer] )) && { defer -c '___creinstall && src' }
  unfunction 'creinstall'
}

