#!/usr/bin/env bash
# Yazibar - Simple Left Sidebar Toggle
# Stripped down version - no sync, no DDS, no core-ide server
# Just a yazi sidebar on the left side of the current window

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"
CORE_CFG="${CORE_CFG:-$HOME/.core/.sys/cfg}"

# ============================================================================
# CONFIGURATION
# ============================================================================

YAZI_CONFIG_DIR="${CORE_CFG}/yazi/profiles/sidebar-left"
LEFT_SIDEBAR_TITLE="yazibar-left"
DEFAULT_WIDTH="20%"

# ============================================================================
# STATE MANAGEMENT (window-scoped)
# ============================================================================

get_window_id() {
  tmux display-message -p '#{window_id}'
}

get_option_key() {
  echo "@yazibar-simple-left-pane-$(get_window_id)"
}

get_left_pane() {
  tmux show-option -gqv "$(get_option_key)"
}

set_left_pane() {
  tmux set-option -g "$(get_option_key)" "$1"
}

clear_left_pane() {
  tmux set-option -gu "$(get_option_key)" 2>/dev/null
}

pane_exists() {
  local pane_id="$1"
  [ -n "$pane_id" ] && tmux display-message -p -t "$pane_id" '#{pane_id}' 2>/dev/null | grep -q .
}

# ============================================================================
# SIDEBAR CREATION
# ============================================================================

create_left_sidebar() {
  local start_dir="${1:-$(tmux display-message -p '#{pane_current_path}')}"
  start_dir="${start_dir:-$HOME}"

  echo "Creating left sidebar from: $start_dir" >&2

  # Store current pane to return focus
  local current_pane=$(tmux display-message -p '#{pane_id}')

  # Create left split (full height, before current pane)
  local new_pane_id=$(tmux split-window -fhb -l "$DEFAULT_WIDTH" -c "$start_dir" -P -F "#{pane_id}" "
        # Set pane title
        printf '\033]2;%s\033\\\\' '$LEFT_SIDEBAR_TITLE'

        # Set yazi config location
        export YAZI_CONFIG_HOME='$YAZI_CONFIG_DIR'

        # CRITICAL: Bypass graphical/terminal detection to avoid DECRQSS timeout
        # tmux cannot handle DECRQSS escape sequences, causing 10-20 second delays
        # Setting these empty forces Chafa fallback and skips problematic queries
        export WAYLAND_DISPLAY=''
        export DISPLAY=''
        export XDG_SESSION_TYPE=''
        export SWAYSOCK=''

        # Run yazi directly - no wrapper scripts
        exec yazi '$start_dir'
    ")

  echo "Created pane: $new_pane_id" >&2

  # Wait briefly for yazi to start
  sleep 2

  # Verify yazi is running
  local cmd=$(tmux display-message -p -t "$new_pane_id" '#{pane_current_command}' 2>/dev/null)
  if [ "$cmd" = "yazi" ]; then
    echo "Yazi verified running" >&2
    set_left_pane "$new_pane_id"
  else
    echo "WARNING: yazi not detected (got: $cmd), registering anyway" >&2
    set_left_pane "$new_pane_id"
  fi

  # Return to previous pane
  tmux select-pane -t "$current_pane"

  tmux display-message "Left yazibar enabled"
}

# ============================================================================
# SIDEBAR DESTRUCTION
# ============================================================================

destroy_left_sidebar() {
  local left_pane=$(get_left_pane)

  if [ -z "$left_pane" ]; then
    echo "No left sidebar to destroy" >&2
    return 1
  fi

  if ! pane_exists "$left_pane"; then
    echo "Left sidebar pane doesn't exist, clearing state" >&2
    clear_left_pane
    return 1
  fi

  echo "Destroying left sidebar: $left_pane" >&2

  # Kill the pane
  tmux kill-pane -t "$left_pane"

  # Clear state
  clear_left_pane

  tmux display-message "Left yazibar disabled"
}

# ============================================================================
# TOGGLE
# ============================================================================

toggle_left_sidebar() {
  local left_pane=$(get_left_pane)

  if [ -n "$left_pane" ] && pane_exists "$left_pane"; then
    destroy_left_sidebar
  else
    # Clear stale reference if pane doesn't exist
    [ -n "$left_pane" ] && clear_left_pane
    create_left_sidebar "$1"
  fi
}

# ============================================================================
# STATUS
# ============================================================================

status() {
  local left_pane=$(get_left_pane)
  echo "=== Simple Left Yazibar Status ==="
  echo "Window ID: $(get_window_id)"
  echo "Option Key: $(get_option_key)"
  echo "Pane ID: ${left_pane:-none}"
  if [ -n "$left_pane" ]; then
    if pane_exists "$left_pane"; then
      echo "Pane exists: YES"
      echo "Command: $(tmux display-message -p -t "$left_pane" '#{pane_current_command}')"
      echo "Width: $(tmux display-message -p -t "$left_pane" '#{pane_width}')"
    else
      echo "Pane exists: NO (stale reference)"
    fi
  fi
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-toggle}" in
  toggle)
    toggle_left_sidebar "$2"
    ;;
  enable | create)
    create_left_sidebar "$2"
    ;;
  disable | destroy)
    destroy_left_sidebar
    ;;
  status)
    status
    ;;
  help | *)
    cat <<EOF
Simple Left Yazibar - Standalone yazi sidebar

COMMANDS:
  toggle [dir]    Toggle left sidebar (default)
  enable [dir]    Create left sidebar
  disable         Destroy left sidebar
  status          Show status

USAGE:
  $0              Toggle sidebar
  $0 enable       Enable sidebar
  $0 status       Show status
EOF
    ;;
esac
