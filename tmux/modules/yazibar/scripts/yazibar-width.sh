#!/usr/bin/env bash
# Yazibar - Width Persistence
# Saves and restores user-adjusted sidebar widths per directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

# ============================================================================
# WIDTH FILE MANAGEMENT
# ============================================================================

get_width_file() {
  yazibar_width_file
}

ensure_width_file() {
  local width_file=$(get_width_file)
  touch "$width_file"
}

# ============================================================================
# WIDTH PERSISTENCE
# ============================================================================

# Get saved width for a directory
# Args: $1 = directory path, $2 = sidebar (left|right), $3 = default width
get_saved_width() {
  local dir="$1"
  local sidebar="${2:-left}"
  local default="${3:-30%}"

  ensure_width_file
  local width_file=$(get_width_file)

  # Format: directory<TAB>sidebar<TAB>width
  local saved=$(grep "^${dir}[[:space:]]${sidebar}[[:space:]]" "$width_file" | awk '{print $3}')

  if [ -n "$saved" ]; then
    echo "$saved"
  else
    echo "$default"
  fi
}

# Save width for a directory
# Args: $1 = directory path, $2 = sidebar (left|right), $3 = width
save_width() {
  local dir="$1"
  local sidebar="$2"
  local width="$3"

  ensure_width_file
  local width_file=$(get_width_file)

  debug_log "Saving width: dir=$dir sidebar=$sidebar width=$width"

  # Remove existing entry for this dir+sidebar
  local temp_file="${width_file}.tmp"

  grep -v "^${dir}[[:space:]]${sidebar}[[:space:]]" "$width_file" >"$temp_file" 2>/dev/null || true

  # Append new entry
  echo -e "${dir}\t${sidebar}\t${width}" >>"$temp_file"

  # Replace original file
  mv "$temp_file" "$width_file"

  debug_log "Width saved successfully"
}

# Get width for left sidebar
# Args: $1 = directory path
get_left_width() {
  local dir="${1:-$(get_current_dir)}"
  local default=$(yazibar_left_width)
  get_saved_width "$dir" "left" "$default"
}

# Get width for right sidebar
# Args: $1 = directory path
get_right_width() {
  local dir="${1:-$(get_current_dir)}"
  local default=$(yazibar_right_width)
  get_saved_width "$dir" "right" "$default"
}

# Save current pane width for directory
# Args: $1 = pane_id, $2 = sidebar (left|right), $3 = directory (optional)
save_current_width() {
  local pane_id="$1"
  local sidebar="$2"
  local dir="${3:-$(tmux display-message -p -t "$pane_id" '#{pane_current_path}')}"

  local width=$(get_pane_width "$pane_id")
  save_width "$dir" "$sidebar" "$width"

  display_info "Saved $sidebar sidebar width: $width"
}

# ============================================================================
# AUTOMATIC WIDTH TRACKING
# ============================================================================

# Check if sidebar is in correct position
is_sidebar_position_valid() {
  local pane_id="$1"
  local expected_position="$2" # left or right

  if ! pane_exists "$pane_id"; then
    return 1
  fi

  local window_id=$(tmux display-message -p -t "$pane_id" '#{window_id}')

  case "$expected_position" in
    left)
      # Check if pane is leftmost
      local leftmost=$(tmux list-panes -t "$window_id" -F "#{pane_left} #{pane_id}" | sort -n | head -1 | awk '{print $2}')
      [ "$pane_id" = "$leftmost" ]
      ;;
    right)
      # Check if pane is rightmost
      local rightmost=$(tmux list-panes -t "$window_id" -F "#{e|+:#{pane_left},#{pane_width}} #{pane_id}" | sort -rn | head -1 | awk '{print $2}')
      [ "$pane_id" = "$rightmost" ]
      ;;
    *)
      return 1
      ;;
  esac
}

# Check if width is reasonable (not too small or too large)
is_width_reasonable() {
  local width="$1"
  local min_width=10
  local max_width=30

  # Strip % if present and check numeric value
  local numeric_width="${width%\%}"

  # If it's a percentage
  if [[ "$width" == *% ]]; then
    [ "$numeric_width" -ge 5 ] && [ "$numeric_width" -le 80 ]
  else
    # Absolute width
    [ "$numeric_width" -ge "$min_width" ] && [ "$numeric_width" -le "$max_width" ]
  fi
}

# Watch for pane resizes and save width
# This should be called via tmux hook: window-layout-changed
auto_save_width() {
  local left_pane=$(get_left_pane)
  local right_pane=$(get_right_pane)

  # Save left sidebar width if it exists and is in correct position
  if [ -n "$left_pane" ] && pane_exists "$left_pane"; then
    if is_sidebar_position_valid "$left_pane" "left"; then
      local left_dir=$(tmux display-message -p -t "$left_pane" '#{pane_current_path}')
      local left_width=$(get_pane_width "$left_pane")

      # Only save if width is reasonable
      if is_width_reasonable "$left_width"; then
        save_width "$left_dir" "left" "$left_width"
        debug_log "Auto-saved left width: $left_width"
      else
        debug_log "Skipped saving left width (unreasonable): $left_width"
      fi
    else
      debug_log "Skipped saving left width (wrong position)"
    fi
  fi

  # Save right sidebar width if it exists and is in correct position
  if [ -n "$right_pane" ] && pane_exists "$right_pane"; then
    if is_sidebar_position_valid "$right_pane" "right"; then
      local right_dir=$(tmux display-message -p -t "$right_pane" '#{pane_current_path}')
      local right_width=$(get_pane_width "$right_pane")

      # Only save if width is reasonable
      if is_width_reasonable "$right_width"; then
        save_width "$right_dir" "right" "$right_width"
        debug_log "Auto-saved right width: $right_width"
      else
        debug_log "Skipped saving right width (unreasonable): $right_width"
      fi
    else
      debug_log "Skipped saving right width (wrong position)"
    fi
  fi
}

# ============================================================================
# WIDTH CLEANUP
# ============================================================================

# Remove entries for non-existent directories
cleanup_widths() {
  ensure_width_file
  local width_file=$(get_width_file)
  local temp_file="${width_file}.tmp"

  while IFS=$'\t' read -r dir sidebar width; do
    if [ -d "$dir" ]; then
      echo -e "${dir}\t${sidebar}\t${width}" >>"$temp_file"
    else
      debug_log "Removing entry for non-existent dir: $dir"
    fi
  done <"$width_file"

  if [ -f "$temp_file" ]; then
    mv "$temp_file" "$width_file"
    display_info "Width database cleaned up"
  fi
}

# List all saved widths
list_widths() {
  ensure_width_file
  local width_file=$(get_width_file)

  echo "=== Saved Sidebar Widths ==="
  echo ""

  if [ -s "$width_file" ]; then
    printf "%-50s %-10s %s\n" "Directory" "Sidebar" "Width"
    printf "%-50s %-10s %s\n" "$(printf '%.0s-' {1..50})" "$(printf '%.0s-' {1..10})" "$(printf '%.0s-' {1..10})"

    while IFS=$'\t' read -r dir sidebar width; do
      # Truncate dir if too long
      local display_dir="$dir"
      if [ ${#display_dir} -gt 47 ]; then
        display_dir="...${display_dir: -44}"
      fi

      printf "%-50s %-10s %s\n" "$display_dir" "$sidebar" "$width"
    done <"$width_file"
  else
    echo "No saved widths found"
  fi
}

# ============================================================================
# COMMAND DISPATCHER
# ============================================================================

case "${1:-help}" in
  get-left)
    get_left_width "$2"
    ;;
  get-right)
    get_right_width "$2"
    ;;
  save)
    save_width "$2" "$3" "$4"
    ;;
  save-current)
    save_current_width "$2" "$3" "$4"
    ;;
  auto-save)
    auto_save_width
    ;;
  cleanup)
    cleanup_widths
    ;;
  list)
    list_widths
    ;;
  help | *)
    cat <<EOF
Yazibar Width Persistence

COMMANDS:
  get-left [dir]                Get saved left sidebar width
  get-right [dir]               Get saved right sidebar width
  save <dir> <side> <width>     Save width for directory
  save-current <pane> <side> [dir]
                                Save current pane width
  auto-save                     Auto-save all sidebar widths
  cleanup                       Remove entries for deleted directories
  list                          List all saved widths

USAGE:
  $0 get-left /home/user/projects
  $0 save /home/user/docs left 40
  $0 save-current %5 left
  $0 list
EOF
    ;;
esac
