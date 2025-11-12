#!/bin/bash
# Cloud Storage Monitor for TMUX Status Bar
# Shows cloud/remote storage usage with mount state indicators

# Color Definitions
STATUS_BG_COLOR="#1E2030"
TAB_BG_COLOR="#313244"
TAB_TEXT_COLOR_2="#000000"
TAB_TEXT_COLOR="#cdd6f4"

# Mount State Colors
MOUNTED_COLOR="#acf200"
NOT_MOUNTED_COLOR="#FF5370"

# Cloud Storage Definitions (color|icon)
declare -A CLOUD_STORAGE=(
  ["proton"]="#6948F5|󰢬 "
  ["onedrive"]="#FFB900|󰏊 "
  ["dropbox"]="#024CC4| "
  # ["gdrive"]="#34A853|󰊶 "
  ["chaoscore"]="#029494| "
  ["zfold"]="#182FAB|󰓷 "
)

# Divider Icons (right-facing for left-aligned content)
# TAB_DIVIDER="" # Right-facing half circle
TAB_DIVIDER="" # Right-facing half circle[106;5u

# Get storage usage color based on percentage (high % = bad)
get_usage_color() {
  local percent=$1

  if [ "$percent" -ge 90 ]; then
    echo "#FF5370" # Red
  elif [ "$percent" -ge 75 ]; then
    echo "#F78C6C" # Orange
  elif [ "$percent" -ge 50 ]; then
    echo "#FFCB6B" # Yellow
  elif [ "$percent" -ge 35 ]; then
    echo "#E5D68A" # Sandy yellow
  elif [ "$percent" -ge 15 ]; then
    echo "#B5E48C" # Lime green
  else
    echo "#81f8bf" # Mint green
  fi
}

# Check if a mount point is mounted
is_mounted() {
  local mount_point=$1
  mountpoint -q "$mount_point" 2>/dev/null
  return $?
}

# Get cloud storage usage
get_cloud_storage_usage() {
  local mount_point=$1
  local usage_percent=""

  if is_mounted "$mount_point"; then
    # Get usage from df
    usage_percent=$(df -h "$mount_point" 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
  fi

  echo "$usage_percent"
}

# Get cloud storage tabs
get_cloud_storage() {
  local output=""
  local cloud_tabs=()
  local mnt_dir="$HOME/mnt"

  # Check each cloud storage type
  for service in "${!CLOUD_STORAGE[@]}"; do
    local mount_point="${mnt_dir}/${service}"

    # Skip if mount directory doesn't exist
    if [[ ! -d "$mount_point" ]]; then
      continue
    fi

    # Get cloud storage color and icon
    IFS='|' read -r cloud_color icon <<<"${CLOUD_STORAGE[$service]}"

    # Check mount status
    local mounted=false
    local mount_state_color="$NOT_MOUNTED_COLOR"
    local usage_percent=""

    if is_mounted "$mount_point"; then
      mounted=true
      mount_state_color="$MOUNTED_COLOR"
      usage_percent=$(get_cloud_storage_usage "$mount_point")
    fi

    # Build tab
    local tab=""

    if [[ -n "$usage_percent" ]]; then
      # Get usage color
      local usage_color=$(get_usage_color "$usage_percent")

      # Percentage text with usage color on tab background
      tab+="#[fg=${usage_color},bg=${TAB_BG_COLOR}] ${usage_percent}% "
    else
      # Not mounted - show unmounted indicator
      tab+="#[fg=${NOT_MOUNTED_COLOR},bg=${TAB_BG_COLOR}] -- "
    fi

    # Icon with cloud storage color background
    if [ "$cloud_color" == "#FFB900" ] || [ "$cloud_color" == "#01F9C6" ]; then
      tab+="#[fg=${TAB_TEXT_COLOR_2},bg=${cloud_color}] ${icon}"
    else
      tab+="#[fg=${TAB_TEXT_COLOR},bg=${cloud_color}] ${icon}"
    fi

    # Store tab with service name, cloud color for sorting and divider handling
    cloud_tabs+=("${service}|${tab}|${cloud_color}")
  done

  # Sort cloud tabs alphabetically
  IFS=$'\n' cloud_tabs=($(sort -t'|' -k1 <<<"${cloud_tabs[*]}"))
  unset IFS

  # Build output with proper dividers
  local tab_count=${#cloud_tabs[@]}
  for i in "${!cloud_tabs[@]}"; do
    IFS='|' read -r service tab cloud_color <<<"${cloud_tabs[$i]}"

    output+="$tab"

    # Add divider
    if [ $((i + 1)) -lt "$tab_count" ]; then
      # Not the last tab - divider to next tab background
      output+="#[fg=${cloud_color},bg=${TAB_BG_COLOR}]${TAB_DIVIDER}"
    else
      # Last tab - divider to status bar background
      output+="#[fg=${cloud_color},bg=${STATUS_BG_COLOR}]${TAB_DIVIDER}"
    fi
  done

  echo "$output"
}

# Main
get_cloud_storage
