# Get the current pane's path
get_current_pane_path() {
  local current_pane_path=$(tmux display-message -p -F "#{pane_current_path}")
  echo "$current_pane_path"
}

get_all_panes() {
  local panes=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}:#{pane_title}:#{pane_current_path}")
  echo "$panes"
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
