#!/bin/bash
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
# CORE_STATE_DIR="$HOME/.local/core/state/themes/"
TMUX_SESSION_THEMES="$HOME/.local/core/state/tmux/themes"
# TMUX_SESSION_THEMES="$CORE_LOCAL_STATE/tmux/themes"
# CORE_ENV_UTILS="$CORE_BIN/utils"
# COLOR_HELPERS="$CORE_ENV_UTILS/colors.sh"
# source "$COLOR_HELPERS"

list_sessions() {
  tmux ls | awk -F: '{print $1}'

  # Get all windows across all sessions with details
  SESSIONS=$(tmux list-windows -a -F "#{session_name}:#{window_index} #{window_name} #{pane_current_path}")
}

session_exists() {
  local server="$1"
  local session="$2"
  tmux -L "$server" has-session -t "$session" 2>/dev/null
}

# Get session preview for index
get_session_preview() {
  local idx="$1"

  # Read session data from temp file
  local session_data=$(sed -n "${idx}p" "$TEMP_SESSION_DATA")
  if [[ -z "$session_data" ]]; then
    echo "No session data found"
    return
  fi

  IFS='|' read -r type host session desc <<<"$session_data"

  # Format display name
  local display_name=""
  case "$type" in
    "local")
      local short_host=$(hostname -s)
      display_name="Theron@${short_host}"
      ;;
    "docker")
      display_name="Theron@${host}.docker"
      ;;
    "ssh")
      local short_host="$host"
      [[ "$host" == "chaoscore.org" ]] && short_host="chaoscore"
      display_name="Theron@${short_host}"
      ;;
  esac

  # Get theme
  local safe_name=$(echo "${type}_${host}_${session}" | sed 's/[^a-zA-Z0-9_-]/_/g')
  local theme_file="$SESSION_THEMES_DIR/${safe_name}.txt"
  local theme=$([[ -f "$theme_file" ]] && cat "$theme_file" || echo "Default")

  # Color based on type
  local color=""
  case "$type" in
    "local") color="\033[0;34m" ;;
    "docker") color="\033[0;32m" ;;
    "ssh") color="\033[0;35m" ;;
  esac
}

main() {
  case "$1" in
    list-sessions)
      list_sessions
      ;;
    session-exists)
      session_exists "$2" "$3"
      ;;
    get-session-preview)
      get_session_preview "$2"
      ;;
    *)
      echo "Usage: $0 {list-sessions|session-exists <server> <session>|get-session-preview <index>}"
      exit 1
      ;;
  esac
}
