# Zinit helper patterns from user

# Their zt function with wait patterns
# 0a = wait 0 seconds, load after prompt
# 0b = wait 0 seconds, load after first prompt
# 0c = wait 0 seconds, load after first command

# Advanced ice modifiers they use
function zt_advanced() {
    zinit ice \
        depth'3' \
        lucid \
        ${1/#[0-9][a-c]/wait"${1}"} \
        "${@:2}"
}

# Pattern for patch/compile
function zt_patch() {
    local plugin="$1"
    shift
    zinit ice \
        patch"${ZDOTDIR}/patches/${plugin//\//%}.patch" \
        reset \
        nocompile'!' \
        atclone'local f; for f in *~*.zwc(N.); zcompile -Uz $f' \
        atpull'%atclone' \
        "$@"
    zinit light "$plugin"
}

# ========================== Advanced Helper Functions ==========================
# From lmburns' config - enhanced zinit workflow

# Zinit wait if command is already installed
# Usage: has git vim -> "[[ ! -v commands[git] ]] && [[ ! -v commands[vim] ]]"
has() { print -lr -- ${(j: && :):-"[[ ! -v commands[${^@}] ]]"}; }

# Print command to be executed by zinit for cargo builds
# Usage in zinit: atclone"$(mv_clean ripgrep)"
mv_clean() { print -lr -- "command mv -f tar*/rel*/${1:-%PLUGIN%} . && cargo clean"; }

# Shorten GitHub raw URL with `dl` annex
# Usage: grman man/man1/
grman() {
  local graw="https://raw.githubusercontent.com"; local -A opts
  zparseopts -D -E -A opts -- r: e:
  print -r "${graw}/%USER%/%PLUGIN%/master/${@:1}${opts[-r]:-%PLUGIN%}${opts[-e]:-.1}";
}

# Show the url <owner/repo> from cargo
# Usage: id_as ripgrep
id_as() {
  print -rl \
    -- ${${(S)${(M)${(@f)"$(cargo show $1)"}:#repository: *}/repository: https:\/\/*\//}//(#m)*/<$MATCH>}
}
