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

# Get the current pane's path
get_current_pane_path() {
  local current_pane_path=$(tmux display-message -p -F "#{pane_current_path}")
  echo "$current_pane_path"
}

get_all_panes() {
  local panes=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}:#{pane_title}:#{pane_current_path}")
  echo "$panes"
}

pane_exists() {
  local pane_id="$1"
  local window_id="${2:-$(get_current_window)}"
  [ -n "$pane_id" ] && tmux list-panes -t "$window_id" -F "#{pane_id}" 2>/dev/null | grep -q "^${pane_id}$"
}

pane_exists_globally() {
  local pane_id="$1"
  [ -n "$pane_id" ] && tmux list-panes -a -F "#{pane_id}" 2>/dev/null | grep -q "^${pane_id}$"
}

get_current_pane() {
  tmux display-message -p '#{pane_id}'
}

get_current_dir() {
  tmux display-message -p '#{pane_current_path}'
}

get_pane_width() {
  local pane_id="${1:-$(get_current_pane)}"
  tmux display-message -p -t "$pane_id" '#{pane_width}'
}

get_pane_height() {
  local pane_id="${1:-$(get_current_pane)}"
  tmux display-message -p -t "$pane_id" '#{pane_height}'
}

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
