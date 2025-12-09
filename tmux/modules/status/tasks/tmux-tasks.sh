#!/bin/bash
# Enhanced tmux task management script

# Set task for a session
set_task() {
    local session=${1:-$(tmux display-message -p '#S')}
    local task=$2

    if [ -z "$task" ]; then
        echo "Current task for $session: $(tmux show -t "$session" -qv @task)"
    else
        tmux set -t "$session" @task "$task"
        echo "Set task '$task' for session '$session'"
    fi
}

# Create session with position and task
create_workspace() {
    local position=$1
    local task=${2:-"shell"}
    local session_name="${position}_console"

    # Check if session exists
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Session $session_name exists. Updating task to: $task"
        set_task "$session_name" "$task"
    else
        tmux new-session -d -s "$session_name"
        tmux set -t "$session_name" @task "$task"
        tmux set -t "$session_name" @position "$position"
        echo "Created $session_name with task: $task"
    fi
}

# List all sessions with their tasks
list_tasks() {
    echo "Sessions and their tasks:"
    echo "------------------------"
    tmux list-sessions -F '#{session_name}' 2>/dev/null | while read -r session; do
        local task=$(tmux show -t "$session" -qv @task)
        local position=$(tmux show -t "$session" -qv @position)
        printf "%-15s | Task: %-15s | Pos: %s\n" "$session" "${task:-none}" "${position:-none}"
    done
}

# Transfer task between positions
transfer_task() {
    local from=$1
    local to=$2

    local task=$(tmux show -t "${from}_console" -qv @task)
    if [ -z "$task" ]; then
        echo "No task found in ${from}_console"
        return 1
    fi

    create_workspace "$to" "$task"
    echo "Transferred task '$task' from $from to $to"
}

# Interactive menu
menu() {
    echo "Tmux Task Manager"
    echo "================="
    echo "1) Create workspace"
    echo "2) Set task"
    echo "3) List tasks"
    echo "4) Transfer task"
    echo "5) Exit"

    read -rp "Choice: " choice

    case $choice in
    1)
        read -rp "Position (hub/l/r/top): " pos
        read -rp "Task name: " task
        create_workspace "$pos" "$task"
        ;;
    2)
        read -rp "Session name: " session
        read -rp "Task name: " task
        set_task "$session" "$task"
        ;;
    3)
        list_tasks
        ;;
    4)
        read -rp "From position: " from
        read -rp "To position: " to
        transfer_task "$from" "$to"
        ;;
    5)
        exit 0
        ;;
    esac
}

# Main command handling
case "${1:-menu}" in
set)
    set_task "$2" "$3"
    ;;
create)
    create_workspace "$2" "$3"
    ;;
list)
    list_tasks
    ;;
transfer)
    transfer_task "$2" "$3"
    ;;
menu | *)
    menu
    ;;
esac
