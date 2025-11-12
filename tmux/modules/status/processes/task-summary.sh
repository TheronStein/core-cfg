#!/bin/bash
# Active/Queued Task Summary for TMUX Status Bar
# Shows aggregate counts and speeds for each task type

# Color Definitions
STATUS_BG_COLOR="#1E2030"
TAB_BG_COLOR="#313244"
ACTIVE_TASK_BG_COLOR="#223344"
TAB_COLOR_DOWNLOAD="#69FF94"
TAB_COLOR_UPLOAD="#FF7043"
TAB_COLOR_COMPRESSION="#f1fc79"
TAB_COLOR_TRANSFER="#82AAFF"
TAB_TEXT_COLOR="#69FF94"
TAB_SEPARATOR_COLOR="#223344"

# Task Icons
DOWNLOAD_ICON="󰶡"
UPLOAD_ICON="󰶣"
COMPRESSION_ICON="󰗄"
TRANSFER_ICON="󰔰"

# Divider Icons
TAB_LEFT_SEPARATOR=""
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
  local speed=$3
  local total_count=$4
  local is_first=$5 # true if first tab, false otherwise
  local task_color=$6 # unique color for this task type

  local tab=""

  # Left divider - first tab uses STATUS_BG_COLOR, others use TAB_BG_COLOR
  if [ "$is_first" = "true" ]; then
    tab+="#[fg=${ACTIVE_TASK_BG_COLOR},bg=${STATUS_BG_COLOR}]${TAB_LEFT_DIVIDER}"
  else
    tab+="#[fg=${TAB_SEPARATOR_COLOR},bg=${ACTIVE_TASK_BG_COLOR}]${TAB_LEFT_SEPARATOR} "
  fi

  # Task icon with unique color
  tab+="#[fg=${task_color},bg=${ACTIVE_TASK_BG_COLOR}]${task_icon}  "

  # Speed with unique color
  tab+="#[fg=${task_color},bg=${TAB_BG_COLOR}] ${speed} "

  tab+="#[fg=${ACTIVE_TASK_BG_COLOR},bg=${TAB_BG_COLOR}]${TAB_LEFT_DIVIDER}"
  # Total count with unique color
  tab+="#[fg=${task_color},bg=${ACTIVE_TASK_BG_COLOR}]${active_count}/${total_count}"

  echo "$tab"
}

# Main
get_task_summary() {
  local output=""
  local summary_tabs=()
  local is_first="true"

  # Check downloads (rclone copy/sync to local)
  local download_count=$(count_rclone_tasks)
  if [ "$download_count" -gt 0 ]; then
    local speed=$(get_task_speed "download")
    local tab=$(build_summary_tab "$download_count" "$DOWNLOAD_ICON" "$speed" "$download_count" "$is_first" "$TAB_COLOR_DOWNLOAD")
    summary_tabs+=("$tab")
    is_first="false"
  fi

  # Check uploads (rclone copy/sync to remote)
  local upload_count=$(count_rclone_tasks)
  if [ "$upload_count" -gt 0 ]; then
    local speed=$(get_task_speed "upload")
    local tab=$(build_summary_tab "$upload_count" "$UPLOAD_ICON" "$speed" "$upload_count" "$is_first" "$TAB_COLOR_UPLOAD")
    summary_tabs+=("$tab")
    is_first="false"
  fi

  # Check compression
  local compression_count=$(count_compression_tasks)
  if [ "$compression_count" -gt 0 ]; then
    local speed=$(get_task_speed "compression")
    local tab=$(build_summary_tab "$compression_count" "$COMPRESSION_ICON" "$speed" "$compression_count" "$is_first" "$TAB_COLOR_COMPRESSION")
    summary_tabs+=("$tab")
    is_first="false"
  fi

  # Check transfers (rsync)
  local transfer_count=$(count_rsync_tasks)
  if [ "$transfer_count" -gt 0 ]; then
    local speed=$(get_task_speed "transfer")
    local tab=$(build_summary_tab "$transfer_count" "$TRANSFER_ICON" "$speed" "$transfer_count" "$is_first" "$TAB_COLOR_TRANSFER")
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
