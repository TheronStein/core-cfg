#!/usr/bin/env bash
# utils/tmux.sh
# Utility functions for tmux version checking and display messages

# Source canonical libraries
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"
source "$TMUX_CONF/lib/state-utils.sh"

VERSION="$1"
UNSUPPORTED_MSG="$2"

tmux_version_int() {
  local tmux_version_string=$(tmux -V)
  echo "$(get_digits_from_string "$tmux_version_string")"
}

unsupported_version_message() {
  if [ -n "$UNSUPPORTED_MSG" ]; then
    echo "$UNSUPPORTED_MSG"
  else
    echo "Error, Tmux version unsupported! Please install Tmux version $VERSION or greater!"
  fi
}

exit_if_unsupported_version() {
  local current_version="$1"
  local supported_version="$2"
  if [ "$current_version" -lt "$supported_version" ]; then
    display_message "$(unsupported_version_message)"
    exit 1
  fi
}

# ============================================================================
# DISPLAY HELPERS
# ============================================================================

# Ensures a message is displayed for 5 seconds in tmux prompt.
# Does not override the 'display-time' tmux option.
display_message() {
  local message="$1"

  # display_duration defaults to 5 seconds, if not passed as an argument
  if [ "$#" -eq 2 ]; then
    local display_duration="$2"
  else
    local display_duration="5000"
  fi

  # saves user-set 'display-time' option
  local saved_display_time=$(get_tmux_option "display-time" "750")

  # sets message display time to 5 seconds
  tmux set-option -gq display-time "$display_duration"

  # displays message
  tmux display-message "$message"

  # restores original 'display-time' value
  tmux set-option -gq display-time "$saved_display_time"
}

display_error() {
  display_message "ERROR: $1" 5000
}

display_info() {
  display_message "$1" 2000
}

# Note: get_tmux_option, set_tmux_option, clear_tmux_option now from state-utils.sh

stored_key_vars() {
  tmux show-options -g \
    | \grep -i "^${VAR_KEY_PREFIX}-" \
    | cut -d ' ' -f1 \
    |
    # cut just the variable names
    xargs # splat var names in one line
}

# get the key from the variable name
get_key_from_option_name() {
  local option="$1"
  echo "$option" \
    | sed "s/^${VAR_KEY_PREFIX}-//"
}

get_value_from_option_name() {
  local option="$1"
  echo "$(get_tmux_option "$option" "")"
}
