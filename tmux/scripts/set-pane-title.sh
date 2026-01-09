#!/bin/bash
# Set the title of a tmux pane
# Usage: set-pane-title.sh [title] [pane_id]
# If no pane_id, uses current pane

title="${1:-}"
pane="${2:-}"

if [[ -z "$title" ]]; then
  echo "Usage: set-pane-title.sh <title> [pane_id]"
  exit 1
fi

if [[ -n "$pane" ]]; then
  tty=$(tmux display-message -p -t "$pane" '#{pane_tty}')
else
  tty=$(tmux display-message -p '#{pane_tty}')
fi

if [[ -n "$tty" ]]; then
  printf '\033]0;%s\007' "$title" > "$tty"
fi
