#!/bin/bash
#!/usr/bin/env bash

readonly DEFAULT_FIND_PATH="$HOME/.core"
readonly DEFAULT_SHOW_NTH="-2,-1"
readonly DEFAULT_MAX_DEPTH="2"
readonly DEFAULT_PREVIEW_POSITION="top"
readonly DEFAULT_LAYOUT="reverse"
readonly DEFAULT_SESSION_NAME_STYLE="basename"
readonly DEFAULT_FZF_TMUX_OPTIONS="-p 90%"

readonly COREMUX_ICON=''
readonly COREMUX_LABEL= '  [COREMUX] '
readonly PROMPT=' '
readonly MARKER=''
readonly ICON_WORSPACE=''
readonly ICON_SESSION=' '
readonly ICON_WINDOW=' '
readonly ICON_PANE='󱂬'
readonly ICON_FLOATING=''
readonly BORDER_LABEL_WORKSPACES= ' $(COREMUX_LABEL) [WORKSPACES]'
readonly BORDER_LABEL_SESSIONS= ' $(COREMUX_LABEL) [SESSIONS] '
readonly BORDER_LABEL_WINDOWS= '$(COREMUX_LABEL) $(ICON_WINDOW) [WINDOWS]'
readonly BORDER_LABEL_PANES= ' $(COREMUX_LABEL) PANES] '
readonly HEADER='^f   ^j   ^s   ^w   ^x '

fzf_tmux_options=${FZF_TMUX_OPTS:-"$DEFAULT_FZF_TMUX_OPTIONS"}
TMUX_OPTIONS=$(tmux show-options -g | grep "^@coremux-")

# Window command handler using fzf for selection
REQUEST_TYPE=$1
SELECTED=$2
WINDOW_ID=$3

t_bind="ctrl-t:abort"
tab_bind="tab:down,btab:up"
preview="$session_preview_cmd {} 2&>/dev/null"
show_nth=$(get_tmux_option "@tea-show-nth" "$DEFAULT_SHOW_NTH")
max_depth=$(get_tmux_option "@tea-max-depth" "$DEFAULT_MAX_DEPTH")
session_name_style=$(get_tmux_option "@tea-session-name" "$DEFAULT_SESSION_NAME_STYLE")
preview_position=$(get_tmux_option "@tea-preview-position" "$DEFAULT_PREVIEW_POSITION")
layout=$(get_tmux_option "@tea-layout" "$DEFAULT_LAYOUT")

tmux list-sessions -F '#S')+change-preview-window($preview_position,85%)
tmux list-windows -a -F '#{session_name}:#{window_index}')+change-preview($session_preview_cmd {})+change-preview-window($preview_position)
tmux list-panes -t {})+change-preview(eval $dir_preview_cmd {})+change-preview-window(right)"



switch_to_window() {
    if [ -n "$SELECTED" ]; then
        WINDOW_ID=$(echo "$SELECTED" | cut -d' ' -f1)
        tmux switch-client -t "$WINDOW_ID"
    fi
}

move_window_to_current_session() {
    if [ -n "$WINDOW_ID" ]; then
        CURRENT_SESSION=$(tmux display-message -p "#{session_name}")
        tmux move-window -s "$WINDOW_ID" -t "$CURRENT_SESSION:"
    fi
}

move_window_to_session() {
    TARGET_SESSION=$4
    if [ -n "$WINDOW_ID" ] && [ -n "$TARGET_SESSION" ]; then
        tmux move-window -s "$WINDOW_ID" -t "$TARGET_SESSION:"
    fi
}

delete_window() {
    if [ -n "$WINDOW_ID" ]; then
        tmux kill-window -t "$WINDOW_ID"
    fi
}

pick_window() {
    local header="$1"
    local prompt="$2"

    WINDOWS=$(tmux list-windows -a -F "#{session_name}:#{window_index} #{window_name} #{pane_current_path}")

    if [ -z "$WINDOWS" ]; then
        echo "No windows found"
        sleep 2
        exit 1
    fi

    SELECTED=$(echo "$WINDOWS" | fzf \
        --height=100% \
        --layout=reverse \
        --border \
        --preview='
            window_id=$(echo {} | cut -d" " -f1)
            session=$(echo $window_id | cut -d":" -f1)
            index=$(echo $window_id | cut -d":" -f2)
            
            echo "=== Window Preview ==="
            echo "Session: $session"
            echo "Window: #$index"
            echo ""
            echo "=== Panes in this window ==="
            tmux list-panes -t "$session:$index" -F "  Pane #{pane_index}: #{pane_current_command}"
            echo ""
            echo "=== Last 20 lines from active pane ==="
            tmux capture-pane -t "$session:$index" -p -S -20 -E -1 2>/dev/null || echo "Unable to capture pane content"
        ' \
        --preview-window=right:60% \
        --header="$header" \
        --prompt="$prompt" \
        --bind="esc:cancel")

    case $REQUEST_TYPE in
        switch)
            switch_to_window
            ;;
        move_current)
            move_window_to_current_session
            ;;
        move_session)
            move_window_to_session "$4"
            ;;
        delete)
            delete_window
            ;;
    esac
}


main() {
    case $REQUEST_TYPE in
        switch)
            pick_window "Select window to switch to (ESC to cancel)" "Window > "
            ;;
        move_current)
            pick_window "Select window to move to current session (ESC to cancel)" "Window > "
            ;;
        move_session)
            pick_window "Select window to move to target session (ESC to cancel)" "Window > "
            ;;
        delete)
            pick_window "Select window to delete (ESC to cancel)" "Window > "
            ;;
        *)
            echo "Invalid request type"
            exit 1
            ;;
    esac
}
