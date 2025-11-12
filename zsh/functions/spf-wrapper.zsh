
# File: ~/.config/zsh/functions/superfile-wrapper.zsh
# Location: Function to launch superfile and change directory on exit

function spf() {
  local tmp="$(mktemp -t "superfile-cwd.XXXXXX")"
  local last_dir_file="${XDG_DATA_HOME:-$HOME/.local/share}/superfile/.lastdir"
  
  # Run superfile
  command superfile "$@"
  
  # Check if superfile wrote a last directory file
  if [[ -f "$last_dir_file" ]]; then
    local dir="$(cat "$last_dir_file")"
    if [[ -d "$dir" && "$dir" != "$PWD" ]]; then
      cd -- "$dir"
    fi
  fi
  
  rm -f -- "$tmp"
}
