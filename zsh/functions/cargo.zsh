# ~/.core/.sys/configs/zsh/functions/cargo.zsh (or wherever you keep shell functions)

cargo() {
  local manifest="${CORE:-$HOME/.core}/.sys/cfg/cargo/install.manifest"
  local cmd="$1"

  case "$cmd" in
    install)
      command cargo "$@"
      local ret=$?
      if ((ret == 0)); then
        shift # remove 'install'
        for arg in "$@"; do
          # skip flags and git/path installs
          [[ "$arg" == -* ]] && continue
          [[ "$arg" == */* ]] && continue
          # add if not already present
          grep -qxF "$arg" "$manifest" 2>/dev/null || echo "$arg" >>"$manifest"
        done
      fi
      return $ret
      ;;
    uninstall)
      command cargo "$@"
      local ret=$?
      if ((ret == 0)); then
        shift
        for arg in "$@"; do
          [[ "$arg" == -* ]] && continue
          # remove from manifest
          sed -i "/^${arg}$/d" "$manifest"
        done
      fi
      return $ret
      ;;
    *)
      command cargo "$@"
      ;;
  esac
}
