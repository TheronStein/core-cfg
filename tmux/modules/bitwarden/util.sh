#!/usr/bin/env bash

# Source shared library for core tmux operations
if [ -f "$TMUX_CONF/modules/lib/tmux-core.sh" ]; then
    source "$TMUX_CONF/modules/lib/tmux-core.sh"
fi
if [ -f "$TMUX_CONF/modules/lib/tmux-display.sh" ]; then
    source "$TMUX_CONF/modules/lib/tmux-display.sh"
fi

# Copy text to the clipboard
cp_to_clipboard() {
  if [[ "$(uname)" == "Darwin" ]] && is_binary_exist "pbcopy"; then
    echo -n "$1" | pbcopy
  elif [[ "$(uname)" == "Linux" ]] && is_binary_exist "wl-copy"; then
    echo -n "$1" | wl-copy
  elif [[ "$(uname)" == "Linux" ]] && is_binary_exist "xsel"; then
    echo -n "$1" | xsel -b
  elif [[ "$(uname)" == "Linux" ]] && is_binary_exist "xclip"; then
    echo -n "$1" | xclip -i
  else
    return 1
  fi
}

# Check if binary exist
is_binary_exist() {
  local binary=$1

  command -v "$binary" &>/dev/null
  return $?
}

# Note: get_tmux_option is now provided by modules/lib/tmux-core.sh

# Display tmux message in status bar (module-specific wrapper)
display_tmux_message() {
  local message=$1
  tmux display-message "tmux-bitwarden: $message"
}
