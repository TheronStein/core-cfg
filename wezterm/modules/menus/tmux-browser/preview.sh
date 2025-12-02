#!/usr/bin/env bash
# Preview script for tmux sessions

set -euo pipefail

SESSION_NAME="$1"

if [[ -z "$SESSION_NAME" ]]; then
  echo "No session selected"
  exit 0
fi

# Check if session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Session '$SESSION_NAME' not found"
  exit 0
fi

# Header
echo "╔════════════════════════════════════════════════════════╗"
echo "║  Session: $SESSION_NAME"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Get session info
SESSION_INFO=$(tmux list-sessions -t "$SESSION_NAME" -F \
  'Created: #{session_created}|Attached: #{session_attached}|Windows: #{session_windows}|Activity: #{session_activity}' 2>/dev/null)

if [[ -n "$SESSION_INFO" ]]; then
  IFS='|' read -r created attached windows activity <<< "$SESSION_INFO"

  # Convert timestamps to readable dates
  created_date="unknown"
  if command -v date &>/dev/null && [[ -n "$created" ]]; then
    created_date=$(date -d "@$created" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
  fi

  activity_date="unknown"
  if command -v date &>/dev/null && [[ -n "$activity" ]]; then
    activity_date=$(date -d "@$activity" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
  fi

  echo "📊 Session Info:"
  echo "   Created: $created_date"
  echo "   Last Activity: $activity_date"
  echo "   Windows: $windows"
  echo "   Attached: $([ "$attached" == "1" ] && echo "Yes 📌" || echo "No")"
  echo ""
fi

# List windows
echo "📂 Windows:"
echo "─────────────────────────────────────────────────────────"

tmux list-windows -t "$SESSION_NAME" -F \
  '#{window_index}: #{window_name} (#{window_panes} panes) #{?window_active,(active),}' 2>/dev/null | \
while IFS= read -r line; do
  if [[ "$line" == *"(active)"* ]]; then
    echo "  ▶ $line"
  else
    echo "    $line"
  fi
done

echo ""

# Show layout of active window
ACTIVE_WINDOW=$(tmux list-windows -t "$SESSION_NAME" -F '#{?window_active,#{window_index},}' 2>/dev/null | grep -v '^$' | head -1)

if [[ -n "$ACTIVE_WINDOW" ]]; then
  echo "🔍 Active Window Layout (Window $ACTIVE_WINDOW):"
  echo "─────────────────────────────────────────────────────────"

  tmux list-panes -t "$SESSION_NAME:$ACTIVE_WINDOW" -F \
    '  Pane #{pane_index}: #{pane_current_command} #{?pane_active,(active),}' 2>/dev/null

  echo ""

  # Show current path for each pane
  echo "📁 Working Directories:"
  tmux list-panes -t "$SESSION_NAME:$ACTIVE_WINDOW" -F \
    '  Pane #{pane_index}: #{pane_current_path}' 2>/dev/null
fi
