#!/usr/bin/env bash

# Popup Window Handler
# Prevents nested popups by detecting if we're already in a popup
# If in popup: switch to app window in apps session
# If not in popup: open popup with app window

APP="$1"

if [ -z "$APP" ]; then
  echo "Usage: popup-handler.sh <app_name>"
  exit 1
fi

SESSION="apps"

# Map app names to custom window names and commands
case "$APP" in
  neomutt)
    WINDOW_NAME="mail"
    APP_CMD="$APP"
    ;;
  spotify_player|ncspot)
    WINDOW_NAME="music"
    APP_CMD="$APP"
    ;;
  disk-menu)
    WINDOW_NAME="disk-menu"
    APP_CMD="zsh -ic disk-menu-enhanced"
    ;;
  disk-inspect)
    WINDOW_NAME="disk-scan"
    APP_CMD="zsh -ic 'gdu .'"
    ;;
  bigfiles)
    WINDOW_NAME="big-files"
    APP_CMD="zsh -ic 'find-by-size 100M'"
    ;;
  *)
    WINDOW_NAME="$APP"
    APP_CMD="$APP"
    ;;
esac

# Check if we're currently in a popup by checking if current client is in a popup
IN_POPUP=$(tmux display-message -p '#{client_flags}' | grep -q 'active-pane' && echo 0 || echo 1)

# Alternative: check if current session is the apps session
CURRENT_SESSION=$(tmux display-message -p '#{session_name}')

# Create apps session if it doesn't exist
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -n "$WINDOW_NAME"
  # Hide status bar for apps session
  tmux set-option -t "$SESSION" status off
fi

# Check if app is running in any window of the apps session
t_window=$(tmux list-panes -t "$SESSION" -a -F "#{window_index} #{pane_current_command}" 2>/dev/null \
  | grep "^[0-9]* $APP$" | head -n 1 | awk '{print $1}')

if [ -z "$t_window" ]; then
  # App not running, find next available window
  next_window=$(tmux list-windows -t "$SESSION" -F "#{window_index}" 2>/dev/null | sort -n | tail -1)
  next_window=$((next_window + 1))

  # Create new window with custom name
  tmux new-window -t "$SESSION:$next_window" -n "$WINDOW_NAME"

  # Hide status bar for this session
  tmux set-option -t "$SESSION" status off

  # Launch app with the correct command
  tmux send-keys -t "$SESSION:$next_window" "$APP_CMD" C-m

  # Give app a moment to start
  sleep 0.5

  target_window=$next_window
else
  # App is running, use its window
  target_window=$t_window
fi

# If we're already in the apps session (i.e., in a popup), just switch windows
if [ "$CURRENT_SESSION" = "$SESSION" ]; then
  # We're already in apps session, just switch to the target window
  tmux select-window -t "$SESSION:$target_window"
else
  # We're not in apps session, open popup
  tmux display-popup -E -w 90% -h 90% -x C -y C \
    -T " $WINDOW_NAME " -b rounded -S "fg=#89b4fa,bg=#1e1e2e" \
    "tmux attach-session -t $SESSION:$target_window"
fi
