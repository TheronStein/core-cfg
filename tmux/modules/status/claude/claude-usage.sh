#!/bin/bash
# Claude Code Usage Monitor for TMUX Status Bar
# Shows Claude token usage with color-coded percentage indicators
# Based on local-storage.sh template

# Cache file location
CACHE_FILE="${HOME}/.local/state/claude/usage-cache.json"
CACHE_DIR="${HOME}/.local/state/claude"

# Color Definitions
STATUS_BG_COLOR="#292D3E"
TAB_BG_COLOR="#313244"
TAB_TEXT_COLOR="#000000"

# Claude Icon
CLAUDE_ICON="󰚩 " # Brain/AI icon

# 󰚩
# 󱚡 󱚧
# 󱚣
# 󱜙
# 
# Divider Icons
TAB_DIVIDER="" # Left-facing half circle
TAB_SPACER=" "  # Left-facing half circle
STATUS_DIVIDER=""

# Get usage color based on percentage (low % = good, more room)
# Inverse of disk usage - we want to show how much is LEFT
get_usage_color() {
  local percent=$1

  if [ "$percent" -ge 90 ]; then
    echo "#FF5370" # Red - almost out
  elif [ "$percent" -ge 75 ]; then
    echo "#F78C6C" # Orange - getting low
  elif [ "$percent" -ge 50 ]; then
    echo "#FFCB6B" # Yellow - half used
  elif [ "$percent" -ge 25 ]; then
    echo "#B5E48C" # Lime - plenty left
  else
    echo "#81f8bf" # Mint green - lots of room
  fi
}

# Ensure cache directory exists
ensure_cache_dir() {
  [[ ! -d "$CACHE_DIR" ]] && mkdir -p "$CACHE_DIR"
}

# Read cached usage data
read_cache() {
  if [[ -f "$CACHE_FILE" ]]; then
    cat "$CACHE_FILE"
  else
    # Default values if no cache
    echo '{"session":0,"week":0,"extra":0,"extra_spent":"$0","extra_limit":"$20"}'
  fi
}

# Get Claude usage display
get_claude_usage() {
  ensure_cache_dir
  local cache
  cache=$(read_cache)

  # Parse values from cache
  local session_pct week_pct extra_pct extra_spent extra_limit
  session_pct=$(echo "$cache" | jq -r '.session // 0')
  week_pct=$(echo "$cache" | jq -r '.week // 0')
  extra_pct=$(echo "$cache" | jq -r '.extra // 0')

  # Use week percentage as primary indicator (most relevant for daily use)
  local display_pct="$week_pct"
  local color
  color=$(get_usage_color "$display_pct")

  # Build tab
  local tab=""

  # Beginning divider with usage color
  tab+="#[fg=${color},bg=${STATUS_BG_COLOR}]${TAB_DIVIDER}"

  # Icon on colored background
  tab+="#[fg=${TAB_TEXT_COLOR},bg=${color}]${CLAUDE_ICON} "

  # Percentage text
  tab+=" #[fg=${color},bg=${TAB_BG_COLOR}] ${display_pct}%"

  tab+=" #[fg=#444267,bg=${TAB_BG_COLOR}]${STATUS_DIVIDER}"

  echo "$tab"
}

# Update cache from manual input or API
# Usage: claude-usage.sh update <session> <week> <extra>
update_cache() {
  ensure_cache_dir
  local session="${1:-0}"
  local week="${2:-0}"
  local extra="${3:-0}"

  cat >"$CACHE_FILE" <<EOF
{
  "session": ${session},
  "week": ${week},
  "extra": ${extra},
  "updated": "$(date -Iseconds)"
}
EOF
  echo "Cache updated: session=${session}%, week=${week}%, extra=${extra}%"
}

# Parse usage from /usage command output
# Pipe the output to: claude-usage.sh parse
parse_usage() {
  local input
  input=$(cat)

  # Extract percentages from the formatted output
  # Looking for patterns like "4% used" or "20% used"
  local session_pct=0
  local week_pct=0
  local extra_pct=0

  # Current session
  if echo "$input" | grep -q "Current session"; then
    session_pct=$(echo "$input" | grep -A1 "Current session" | grep -oP '\d+(?=% used)' | head -1)
    [[ -z "$session_pct" ]] && session_pct=0
  fi

  # Current week (all models)
  if echo "$input" | grep -q "Current week (all models)"; then
    week_pct=$(echo "$input" | grep -A1 "Current week (all models)" | grep -oP '\d+(?=% used)' | head -1)
    [[ -z "$week_pct" ]] && week_pct=0
  fi

  # Extra usage
  if echo "$input" | grep -q "Extra usage"; then
    extra_pct=$(echo "$input" | grep -A1 "Extra usage" | grep -oP '\d+(?=% used)' | head -1)
    [[ -z "$extra_pct" ]] && extra_pct=0
  fi

  update_cache "$session_pct" "$week_pct" "$extra_pct"
}

# Main
case "${1:-display}" in
  update)
    shift
    update_cache "$@"
    ;;
  parse)
    parse_usage
    ;;
  display | "")
    get_claude_usage
    ;;
  *)
    echo "Usage: $0 [display|update <session> <week> <extra>|parse]"
    exit 1
    ;;
esac
