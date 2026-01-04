#!/usr/bin/env bash
# Rclone Browser - Toggle Script
# Manages rclone browser in left sidebar with preview in right sidebar

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source canonical libraries
TMUX_CONF="${TMUX_CONF:-$HOME/.tmux}"
source "$TMUX_CONF/lib/state-utils.sh"
source "$TMUX_CONF/lib/pane-utils.sh"

# Tmux variables for state tracking
LEFT_PANE_VAR="@rclone-browser-left-pane"
RIGHT_PANE_VAR="@rclone-browser-right-pane"
ENABLED_VAR="@rclone-browser-enabled"

# Get current pane IDs
get_left_pane() {
  get_tmux_option "$LEFT_PANE_VAR" ""
}

get_right_pane() {
  get_tmux_option "$RIGHT_PANE_VAR" ""
}

is_enabled() {
  [ "$(get_tmux_option "$ENABLED_VAR" "0")" = "1" ]
}

# Enable rclone browser mode
enable_browser() {
  # Check if already enabled
  if is_enabled; then
    local left_pane=$(get_left_pane)
    local right_pane=$(get_right_pane)

    if pane_exists "$left_pane" && pane_exists "$right_pane"; then
      tmux display-message "Rclone browser already active"
      tmux select-pane -t "$left_pane"
      return 0
    fi

    # Stale state, clean up
    disable_browser
  fi

  # Store current pane
  local current_pane=$(tmux display-message -p "#{pane_id}")
  local current_dir=$(tmux display-message -p "#{pane_current_path}")

  # Create left sidebar (browser)
  local left_pane=$(tmux split-window -fhb -l 30% -c "$current_dir" -P -F "#{pane_id}" "
    printf '\033]2;rclone-browser\033\\\\'
    exec '$SCRIPT_DIR/left-browser.sh'
  ")

  # Store left pane ID
  tmux set-option -g "$LEFT_PANE_VAR" "$left_pane"

  # Create right sidebar (preview)
  local right_pane=$(tmux split-window -fh -l 25% -c "$current_dir" -P -F "#{pane_id}" "
    printf '\033]2;rclone-preview\033\\\\'
    exec '$SCRIPT_DIR/right-preview.sh'
  ")

  # Store right pane ID
  tmux set-option -g "$RIGHT_PANE_VAR" "$right_pane"

  # Mark as enabled
  tmux set-option -g "$ENABLED_VAR" "1"

  # Return focus to original pane
  tmux select-pane -t "$current_pane"

  tmux display-message "Rclone browser enabled (Left: browser, Right: preview)"
}

# Disable rclone browser mode
disable_browser() {
  local left_pane=$(get_left_pane)
  local right_pane=$(get_right_pane)

  # Kill right pane first
  if pane_exists "$right_pane"; then
    tmux kill-pane -t "$right_pane" 2>/dev/null || true
  fi

  # Kill left pane
  if pane_exists "$left_pane"; then
    tmux kill-pane -t "$left_pane" 2>/dev/null || true
  fi

  # Clean up state
  tmux set-option -gu "$LEFT_PANE_VAR"
  tmux set-option -gu "$RIGHT_PANE_VAR"
  tmux set-option -gu "$ENABLED_VAR"

  # Clean up any stale selection files
  rm -f /tmp/rclone-browser-selection-* 2>/dev/null || true

  tmux display-message "Rclone browser disabled"
}

# Toggle rclone browser mode
toggle_browser() {
  if is_enabled; then
    disable_browser
  else
    enable_browser
  fi
}

# Focus left pane (browser)
focus_browser() {
  local left_pane=$(get_left_pane)

  if ! is_enabled || ! pane_exists "$left_pane"; then
    enable_browser
    left_pane=$(get_left_pane)
  fi

  if pane_exists "$left_pane"; then
    tmux select-pane -t "$left_pane"
  fi
}

# Focus right pane (preview)
focus_preview() {
  local right_pane=$(get_right_pane)

  if ! is_enabled || ! pane_exists "$right_pane"; then
    enable_browser
    right_pane=$(get_right_pane)
  fi

  if pane_exists "$right_pane"; then
    tmux select-pane -t "$right_pane"
  fi
}

# Show status
show_status() {
  echo "=== Rclone Browser Status ==="
  echo "Enabled: $(is_enabled && echo "YES" || echo "NO")"
  echo "Left pane: $(get_left_pane || echo "none")"
  echo "Right pane: $(get_right_pane || echo "none")"

  local left_pane=$(get_left_pane)
  local right_pane=$(get_right_pane)

  if [ -n "$left_pane" ]; then
    echo "Left exists: $(pane_exists "$left_pane" && echo "YES" || echo "NO")"
  fi

  if [ -n "$right_pane" ]; then
    echo "Right exists: $(pane_exists "$right_pane" && echo "YES" || echo "NO")"
  fi
}

# Main command dispatcher
case "${1:-toggle}" in
  enable)
    enable_browser
    ;;
  disable)
    disable_browser
    ;;
  toggle)
    toggle_browser
    ;;
  focus-left|focus-browser)
    focus_browser
    ;;
  focus-right|focus-preview)
    focus_preview
    ;;
  status)
    show_status
    ;;
  help|*)
    cat << 'EOF'
Rclone Browser Toggle Script

COMMANDS:
  enable              Enable rclone browser mode
  disable             Disable rclone browser mode
  toggle              Toggle rclone browser mode
  focus-left          Focus browser (left pane)
  focus-right         Focus preview (right pane)
  status              Show current status

USAGE:
  toggle-rclone-browser.sh toggle
  toggle-rclone-browser.sh enable
  toggle-rclone-browser.sh disable
EOF
    ;;
esac
