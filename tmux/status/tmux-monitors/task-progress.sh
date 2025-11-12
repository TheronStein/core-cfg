#!/bin/bash
# Task/Process Progress Monitor for TMUX Status Bar
# Shows active downloads, uploads, compression, and transfers with progress

# Color Definitions
STATUS_BG_COLOR="#1E2030"
TAB_BG_COLOR="#313244"
TAB_TEXT_COLOR="#cdd6f4"
TAB_TEXT_COLOR_2="#000000"

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

# Cloud Storage Definitions (color|icon)
declare -A CLOUD_STORAGE=(
  ["proton"]="#6948F5|󰢬 "
  ["onedrive"]="#FFB900|󰏊 "
  ["dropbox"]="#024CC4| "
  # ["gdrive"]="#34A853|󰊶 "
  ["chaoscore"]="#029494| "
  ["zfold"]="#182FAB|󰓷 "
)

# Compression task color
COMPRESSION_BG_COLOR="#444267"

# Divider Icons (both sides for center-aligned content)
TAB_LEFT_DIVIDER=""
TAB_RIGHT_DIVIDER=""

# Get progress color based on percentage (high % = good)
get_progress_color() {
  local percent=$1

  if [ "$percent" -ge 90 ]; then
    echo "#81f8bf" # Mint green
  elif [ "$percent" -ge 70 ]; then
    echo "#B5E48C" # Lime green
  elif [ "$percent" -ge 50 ]; then
    echo "#E5D68A" # Sandy yellow
  elif [ "$percent" -ge 35 ]; then
    echo "#FFCB6B" # Yellow
  elif [ "$percent" -ge 15 ]; then
    echo "#F78C6C" # Orange
  else
    echo "#FF5370" # Red
  fi
}

# Get progress icon based on percentage
get_progress_icon() {
  local percent=$1

  if [ "$percent" -lt 10 ]; then
    echo "󰋙"
  elif [ "$percent" -lt 25 ]; then
    echo "󰫃"
  elif [ "$percent" -lt 50 ]; then
    echo "󰫄"
  elif [ "$percent" -lt 65 ]; then
    echo "󰫅"
  elif [ "$percent" -lt 85 ]; then
    echo "󰫆"
  elif [ "$percent" -lt 100 ]; then
    echo "󰫇"
  else
    echo "󰫈"
  fi
}

# Get rclone upload/download progress
get_rclone_progress() {
  # Get rclone processes but exclude mount operations
  local pids=$(pgrep -x rclone | while read pid; do
    ps -p $pid -o args= | grep -qv "rclone mount" && echo $pid
  done)

  if [ -z "$pids" ]; then
    return 1
  fi

  # Check rclone log files
  for logfile in /tmp/*rclone*.log /tmp/proton*.log /tmp/stream_backup.log; do
    if [ -f "$logfile" ]; then
      # Look for "Transferred: X / Y, Z%"
      local last_lines=$(tail -20 "$logfile" 2>/dev/null | tac)
      local transfer_line=$(echo "$last_lines" | grep -m1 "Transferred:" 2>/dev/null)

      if [ -n "$transfer_line" ]; then
        # Extract percentage
        local percent=$(echo "$transfer_line" | grep -oP '\d+%' | head -1 | tr -d '%')

        if [ -n "$percent" ] && [ "$percent" != "0" ]; then
          # Determine if upload or download based on log filename/content
          local task_type="upload"
          echo "rclone:$task_type:$percent:proton"
          return 0
        fi
      fi
    fi
  done

  return 1
}

# Get rsync progress
get_rsync_progress() {
  local pids=$(pgrep -x rsync)
  if [ -z "$pids" ]; then
    return 1
  fi

  # Try to extract progress from common log files
  for logfile in /tmp/migration_log.txt /tmp/*rsync*.log; do
    if [ -f "$logfile" ]; then
      local last_line=$(tail -1 "$logfile" 2>/dev/null)

      # Format: to-chk=5627/185512
      if echo "$last_line" | grep -qP 'ir-chk=\d+/\d+'; then
        local numbers=$(echo "$last_line" | grep -oP 'ir-chk=\d+/\d+' | head -1)
        local remaining=$(echo "$numbers" | cut -d= -f2 | cut -d/ -f1)
        local total=$(echo "$numbers" | cut -d= -f2 | cut -d/ -f2)

        if [ "$total" -gt 0 ]; then
          local percent=$((100 - (remaining * 100 / total)))
          echo "rsync:transfer:$percent:"
          return 0
        fi
      fi
    fi
  done

  return 1
}

# Get compression progress
get_compression_progress() {
  # Check for active compression processes
  if pgrep -f "tar.*czf\|tar.*cjf\|tar.*cJf\|zstd" >/dev/null 2>&1; then
    # Check progress file
    if [ -f /tmp/backup-compression-progress ]; then
      local processed=$(cat /tmp/backup-compression-progress 2>/dev/null)
      # This would need total files to calculate percentage
      # For now, just show it's active
      echo "compression:tar:?:"
      return 0
    fi
  fi

  return 1
}

# Build task tab
build_task_tab() {
  local task_type=$1
  local subtype=$2
  local percent=$3
  local remote=$4
  local remote_target=$5 # For transfers between two remotes

  local tab=""
  local task_icon=""
  local task_color=""
  local remote_icon=""
  local remote_color=""
  local remote_target_icon=""
  local remote_target_color=""
  local left_divider_color=""

  # Determine task icon and color
  case "$task_type" in
    upload)
      task_icon="$UPLOAD_ICON"
      task_color="$UPLOAD_COLOR"
      ;;
    download)
      task_icon="$DOWNLOAD_ICON"
      task_color="$DOWNLOAD_COLOR"
      ;;
    transfer | rsync)
      task_icon="$TRANSFER_ICON"
      task_color="$TRANSFER_COLOR"
      ;;
    compression)
      task_icon="$COMPRESSION_ICON"
      task_color="$COMPRESSION_COLOR"
      ;;
  esac

  # Get remote color and icon from CLOUD_STORAGE if specified
  if [ -n "$remote" ]; then
    IFS='|' read -r remote_color remote_icon <<<"${CLOUD_STORAGE[$remote]}"
    left_divider_color="$remote_color"
  fi

  # Get target remote color and icon for transfers
  if [ -n "$remote_target" ]; then
    IFS='|' read -r remote_target_color remote_target_icon <<<"${CLOUD_STORAGE[$remote_target]}"
  fi

  # For compression tasks without remote, use compression color
  if [ "$task_type" = "compression" ] && [ -z "$remote" ]; then
    left_divider_color="$COMPRESSION_BG_COLOR"
  fi

  # If no valid percentage, skip
  if [ "$percent" = "?" ] || [ -z "$percent" ]; then
    return 1
  fi

  # Get progress color and icon
  local progress_color=$(get_progress_color "$percent")
  local progress_icon=$(get_progress_icon "$percent")

  # Build tab with dividers on both sides
  # Left divider with remote or compression color
  if [ -n "$left_divider_color" ]; then
    tab+="#[fg=${left_divider_color},bg=${STATUS_BG_COLOR}]${TAB_LEFT_DIVIDER}"
  else

    tab+="#[fg=${left_divider_color},bg=${STATUS_BG_COLOR}]${TAB_LEFT_DIVIDER}"
  # tab+="#[fg=${TAB_BG_COLOR},bg=${STATUS_BG_COLOR}]${TAB_LEFT_DIVIDER}"
  fi

  # Remote icon with cloud storage color background
  if [ -n "$remote_icon" ] && [ -n "$remote_color" ]; then
    tab+="#[fg=${TAB_TEXT_COLOR},bg=${remote_color}]${remote_icon} "
  fi

  # Special handling for transfer tabs with target remote
  if [ -n "$remote_target_icon" ] && [ -n "$remote_target_color" ]; then
    tab+="#[fg=${progress_color},bg=${TAB_BG_COLOR}] ${percent}% "
    tab+="#[fg=${task_color},bg=${TAB_BG_COLOR}]${task_icon} "
    tab+=" #[fg=${TAB_TEXT_COLOR},bg=${remote_target_color}] ${remote_target_icon}"
    tab+="#[fg=${remote_target_color},bg=${STATUS_BG_COLOR}]${TAB_RIGHT_DIVIDER}"
  else
    # Non-transfer tabs (download, upload, compression)

    # Task icon with task-specific color
    if [ "$task_icon" = "$COMPRESSION_ICON" ]; then
      tab+="#[fg=${task_color},bg=${COMPRESSION_BG_COLOR}]${task_icon}  "
      tab+="#[fg=${task_color},bg=${TAB_BG_COLOR}]"
    else
      tab+="#[fg=${task_color},bg=${TAB_BG_COLOR}] ${task_icon}"
    fi

    # Compression subtype label
    if [ "$task_type" = "compression" ] && [ -n "$subtype" ]; then
      tab+=" ${subtype}"
    fi

    # Percentage with progress color
    tab+=" #[fg=${progress_color},bg=${TAB_BG_COLOR}]${percent}%"

    # Progress icon in black with progress color background
    tab+=" #[fg=${TAB_TEXT_COLOR_2},bg=${progress_color}] ${progress_icon} "

    # Right divider
    tab+="#[fg=${progress_color},bg=${STATUS_BG_COLOR}]${TAB_RIGHT_DIVIDER}"
  fi

  echo "$tab"
}

# Main
get_task_progress() {
  local output=""
  local task_tabs=()

  # Check for rclone uploads/downloads
  local rclone_info=$(get_rclone_progress)
  if [ $? -eq 0 ]; then
    IFS=':' read -r type subtype percent remote <<<"$rclone_info"
    local tab=$(build_task_tab "$type" "$subtype" "$percent" "$remote")
    if [ -n "$tab" ]; then
      task_tabs+=("$tab")
    fi
  fi

  # Check for rsync transfers
  local rsync_info=$(get_rsync_progress)
  if [ $? -eq 0 ]; then
    IFS=':' read -r type subtype percent remote <<<"$rsync_info"
    local tab=$(build_task_tab "$type" "$subtype" "$percent" "$remote")
    if [ -n "$tab" ]; then
      task_tabs+=("$tab")
    fi
  fi

  # Check for compression
  local compression_info=$(get_compression_progress)
  if [ $? -eq 0 ]; then
    IFS=':' read -r type subtype percent remote <<<"$compression_info"
    local tab=$(build_task_tab "$type" "$subtype" "$percent" "$remote")
    if [ -n "$tab" ]; then
      task_tabs+=("$tab")
    fi
  fi

  # Build output with spacing between tabs
  for tab in "${task_tabs[@]}"; do
    output+="$tab "
  done

  echo "$output"
}

# Main
get_task_progress
