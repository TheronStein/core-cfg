#!/usr/bin/env bash
# Preview script for tmux servers

set -euo pipefail

SERVER_NAME="$1"

if [[ -z "$SERVER_NAME" ]]; then
  echo "No server selected"
  exit 0
fi

# Check if server exists (has sessions)
if ! tmux -L "$SERVER_NAME" list-sessions &>/dev/null; then
  echo "Server '$SERVER_NAME' has no sessions or is not running"
  exit 0
fi

# Header
echo "╔════════════════════════════════════════════════════════╗"
echo "║  Tmux Server: $SERVER_NAME"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Get server info
SESSION_COUNT=$(tmux -L "$SERVER_NAME" list-sessions 2>/dev/null | wc -l)
ATTACHED_COUNT=$(tmux -L "$SERVER_NAME" list-sessions -F '#{session_attached}' 2>/dev/null | grep -c '^1$' || echo 0)
TOTAL_WINDOWS=$(tmux -L "$SERVER_NAME" list-sessions -F '#{session_windows}' 2>/dev/null | awk '{sum+=$1} END {print sum}')

echo "📊 Server Info:"
echo "   Total Sessions: $SESSION_COUNT"
echo "   Attached Sessions: $ATTACHED_COUNT"
echo "   Total Windows: $TOTAL_WINDOWS"
echo ""

# List all sessions on this server
echo "📂 Sessions on '$SERVER_NAME':"
echo "─────────────────────────────────────────────────────────"
echo ""

tmux -L "$SERVER_NAME" list-sessions -F '#{session_name}|#{session_windows}|#{session_attached}|#{session_created}|#{session_activity}' 2>/dev/null | \
while IFS='|' read -r name windows attached created activity; do
  # Convert timestamps to readable dates
  created_date="unknown"
  if command -v date &>/dev/null && [[ -n "$created" ]]; then
    created_date=$(date -d "@$created" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")
  fi

  activity_date="unknown"
  if command -v date &>/dev/null && [[ -n "$activity" ]]; then
    activity_date=$(date -d "@$activity" "+%H:%M:%S" 2>/dev/null || echo "unknown")
  fi

  # Set icon and status based on attachment
  icon="○"
  status="detached"
  if [[ "$attached" == "1" ]]; then
    icon="📌"
    status="attached"
  fi

  echo "  $icon $name"
  echo "     Windows: $windows | Status: $status"
  echo "     Created: $created_date | Last Activity: $activity_date"

  # List windows for this session
  echo "     Windows:"
  tmux -L "$SERVER_NAME" list-windows -t "$name" -F '#{window_index}: #{window_name} (#{window_panes} panes) #{?window_active,*,}' 2>/dev/null | \
  while IFS= read -r window_line; do
    if [[ "$window_line" == *"*"* ]]; then
      echo "       ▶ $window_line"
    else
      echo "         $window_line"
    fi
  done

  echo ""
done

echo "─────────────────────────────────────────────────────────"
echo "Tip: Use Ctrl-D to kill this server (will end all sessions)"
