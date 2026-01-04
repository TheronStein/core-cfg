#!/usr/bin/env bash
# utils/panes.sh
# Pane utility functions

# Source canonical libraries
TMUX_CONF="${TMUX_CONF:-$HOME/.core/.sys/cfg/tmux}"
source "$TMUX_CONF/lib/pane-utils.sh"
source "$TMUX_CONF/lib/layout-utils.sh"

# Get locked panes from layout-manager
get_locked_pane_ids() {
  tmux show-option -qv "@locked-panes" | tr ',' '\n' | cut -d: -f1 | sort -u
}

# Check if a pane is locked
is_pane_locked() {
  local pane_id="$1"
  local locked_panes
  locked_panes=$(get_locked_pane_ids)
  echo "$locked_panes" | grep -q "^${pane_id}$"
}

# Get all panes with details
get_all_panes() {
  local panes=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}:#{pane_title}:#{pane_current_path}")
  echo "$panes"
}

# Legacy aliases (use canonical functions instead)
get_current_pane_path() {
  get_pane_cwd
}

get_current_pane() {
  get_pane_id
}

get_current_dir() {
  get_pane_cwd
}

# Note: pane_exists, get_pane_width, get_pane_height now from pane-utils.sh / layout-utils.sh

main() {
  case "$1" in
    get-current-pane-path)
      get_current_pane_path
      ;;
    list-all-panes)
      get_all_panes
      ;;
    --help | help | -h)
      echo "Usage: $0 {get-current-pane-path|list-all-panes}"
      echo ""
      echo "Commands:"
      echo "  get-current-pane-path            Get the current pane's path"
      echo "  list-all-panes                   List all panes across all sessions with details"
      ;;
    *)
      echo "Usage: $0 {get-current-pane-path|list-all-panes}"
      exit 1
      ;;
  esac
}
