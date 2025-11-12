#!/bin/bash
# Active/Queued Task Summary for TMUX Status Bar
# Shows aggregate counts and speeds for each task type

# Color Definitions
STATUS_BG_COLOR="#1E2030"
TAB_BG_COLOR="#313244"
ACTIVE_TASK_BG_COLOR="#FCBF49"
TAB_TEXT_COLOR="#cdd6f4"
TAB_SEPARATOR_COLOR="#E5A000"

# Task Icons
DOWNLOAD_ICON="󰶡"
UPLOAD_ICON="󰶣"
COMPRESSION_ICON="󰗄"
TRANSFER_ICON="󰔰"

# Task Type Colors
DOWNLOAD_COLOR="#81C8BE"
UPLOAD_COLOR="#C9A0DC"
COMPRESSION_COLOR="#F5E0A3"
TRANSFER_COLOR="#A8DADC"

# Divider Icons
TAB_LEFT_SEPARATOR=""
TAB_LEFT_DIVIDER=""
TAB_RIGHT_DIVIDER=""

# Count active tasks by type
count_rclone_tasks() {
  local task_type=$1
  local count=0

  # Get rclone processes but exclude mount operations
  local pids=$(pgrep -x rclone | while read pid; do
    ps -p $pid -o args= | grep -qv "rclone mount" && echo $pid
  done)

  if [ -n "$pids" ]; then
    count=$(echo "$pids" | wc -l)
  fi

  echo "$count"
}

count_rsync_tasks() {
  local pids=$(pgrep -x rsync)
  local count=0

  if [ -n "$pids" ]; then
    count=$(echo "$pids" | wc -l)
  fi

  echo "$count"
}

count_compression_tasks() {
  local count=0

  if pgrep -f "tar.*czf\|tar.*cjf\|tar.*cJf\|zstd" >/dev/null 2>&1; then
    count=$(pgrep -f "tar.*czf\|tar.*cjf\|tar.*cJf\|zstd" | wc -l)
  fi

  echo "$count"
}

# Get speed for task type (placeholder - would need actual implementation)
get_task_speed() {
  local task_type=$1
  # This is a placeholder - actual implementation would parse log files
  echo "1.5 MB/s"
}

# Build summary tab
build_summary_tab() {
  local active_count=$1
  local task_icon=$2
  local task_color=$3
  local speed=$4
  local total_count=$5
  local is_first=$6 # true if first tab, false otherwise

  local tab=""

  # Left divider - first tab uses STATUS_BG_COLOR, others use TAB_BG_COLOR
  if [ "$is_first" = "true" ]; then
    tab+="#[fg=${ACTIVE_TASK_BG_COLOR},bg=${STATUS_BG_COLOR}]${TAB_LEFT_DIVIDER}"
  else
    tab+="#[fg=${TAB_SEPARATOR_COLOR},bg=${ACTIVE_TASK_BG_COLOR}]${TAB_LEFT_SEPARATOR} "
  fi

  # Task icon with task-specific color
  tab+="#[fg=${task_color},bg=${ACTIVE_TASK_BG_COLOR}]${task_icon}  "

  # Speed with task-specific color
  tab+="#[fg=${task_color},bg=${TAB_BG_COLOR}] ${speed} "

  tab+="#[fg=${ACTIVE_TASK_BG_COLOR},bg=${TAB_BG_COLOR}]${TAB_LEFT_DIVIDER}"
  # Total count with task-specific color
  tab+="#[fg=${task_color},bg=${ACTIVE_TASK_BG_COLOR}]${active_count}/${total_count}"

  echo "$tab"
}

# Main
get_task_summary() {
  local output=""
  local summary_tabs=()
  local is_first="true"

  # Check downloads
  local download_count=1
  local download_total=2
  if [ "$download_count" -gt 0 ]; then
    local speed=$(get_task_speed "download")
    local tab=$(build_summary_tab "$download_count" "$DOWNLOAD_ICON" "$DOWNLOAD_COLOR" "$speed" "$download_total" "$is_first")
    summary_tabs+=("$tab")
    is_first="false"
  fi

  # Check uploads
  local upload_count=$(count_rclone_tasks "upload")
  if [ "$upload_count" -gt 0 ]; then
    local speed=$(get_task_speed "upload")
    local tab=$(build_summary_tab "$upload_count" "$UPLOAD_ICON" "$UPLOAD_COLOR" "$speed" "$upload_count" "$is_first")
    summary_tabs+=("$tab")
    is_first="false"
  fi

  # Check compression
  local compression_count=$(count_compression_tasks)
  if [ "$compression_count" -gt 0 ]; then
    local speed=$(get_task_speed "compression")
    local tab=$(build_summary_tab "$compression_count" "$COMPRESSION_ICON" "$COMPRESSION_COLOR" "$speed" "$compression_count" "$is_first")
    summary_tabs+=("$tab")
    is_first="false"
  fi

  # Check transfers
  local transfer_count=$(count_rsync_tasks)
  if [ "$transfer_count" -gt 0 ]; then
    local speed=$(get_task_speed "transfer")
    local tab=$(build_summary_tab "$transfer_count" "$TRANSFER_ICON" "$TRANSFER_COLOR" "$speed" "$transfer_count" "$is_first")
    summary_tabs+=("$tab")
    is_first="false"
  fi

  # Build output with spacing between tabs
  local tab_count=${#summary_tabs[@]}
  for i in "${!summary_tabs[@]}"; do
    output+="${summary_tabs[$i]}"
    # Add space between tabs, but not after the last one
    if [ $((i + 1)) -lt "$tab_count" ]; then
      output+=" "
    fi
  done

  echo "$output"
}

# Main
get_task_summary
