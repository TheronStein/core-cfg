#!/bin/bash

list_all_windows(){
    tmux list-windows -a -F "#{session_name}:#{window_index} #{window_name} #{pane_current_path}"
}

get_window_info(){
    local window_id="$1"
    tmux list-panes -t "$window_id" -F "Pane #{pane_index}: #{pane_current_command} (#{pane_current_path})"
}

main(){

case "$1" in
    list-windows)
        list_all_windows
        ;;
    window-info)
        if [ -z "$2" ]; then
            echo "Usage: $0 window-info <session_name:window_index>"
            exit 1
        fi
        get_window_info "$2"
        ;;
    
    --help|help|-h)
        echo "Usage: $0 {list-windows|window-info <session_name:window_index>}"
        echo ""
        echo "Commands:"
        echo "  list-windows                     List all windows across all sessions"
        echo "  window-info <session:window>     Get detailed info about panes in the specified window"
        ;;
    *)
        echo "Usage: $0 {list-windows|window-info <session_name:window_index>}"
        exit 1
        ;;
}

main "$@"
