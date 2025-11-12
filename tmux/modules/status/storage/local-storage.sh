#!/bin/bash
# Local Storage Monitor for TMUX Status Bar
# Shows local disk usage with color-coded percentage indicators

# Color Definitions
STATUS_BG_COLOR="#292D3E"
TAB_BG_COLOR="#313244"
TAB_TEXT_COLOR="#000000"

# Storage Icons
declare -A STORAGE_ICONS=(
  ["nvme2"]=""
  ["nvme"]="󰨆"
  ["ssd"]="󰨊"
  ["hdd"]="󰋊"
)

# Divider Icons
TAB_DIVIDER="" # Left-facing half circle
STATUS_DIVIDER=""

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

# Detect storage type from device name
get_storage_icon() {
  local device=$1

  if [[ "$device" =~ nvme[0-9]n[0-9]p[0-9] ]]; then
    # Check if it's the second nvme drive
    if [[ "$device" =~ nvme1 ]]; then
      echo "${STORAGE_ICONS[nvme2]}"
    else
      echo "${STORAGE_ICONS[nvme]}"
    fi
  elif [[ "$device" =~ sd[a-z][0-9] ]]; then
    # Check if it's an SSD or HDD (default to HDD icon for now)
    # Could enhance this with rotational check if needed
    echo "${STORAGE_ICONS[hdd]}"
  else
    echo "${STORAGE_ICONS[hdd]}"
  fi
}

# Get local storage devices and their usage
get_local_storage() {
  local output=""
  local storage_tabs=()
  declare -A seen_devices

  # Get mounted filesystems, excluding temporary/virtual filesystems
  while IFS= read -r line; do
    # Parse df output: Filesystem Size Used Avail Use% Mounted
    read -r device size used avail percent mountpoint <<<"$line"

    # Skip if not a real device or if it's a loop/snap device
    if [[ ! "$device" =~ ^/dev/(sd|nvme|vd) ]] || [[ "$device" =~ loop ]]; then
      continue
    fi

    # Skip boot and recovery partitions
    if [[ "$mountpoint" =~ ^/boot|^/recovery ]]; then
      continue
    fi

    # Skip if we've already seen this device (handles btrfs subvolumes)
    if [[ -n "${seen_devices[$device]}" ]]; then
      continue
    fi
    seen_devices[$device]=1

    # Get percentage as number
    percent_num="${percent%\%}"

    # Get storage icon
    icon=$(get_storage_icon "$device")

    # Get usage color
    color=$(get_usage_color "$percent_num")

    # Build tab
    # Format: ${TAB_BEGINNING_DIVIDER}${TAB_ICON} ${TAB_TEXT} ${TAB_ENDING_DIVIDER}
    local tab=""

    # Beginning divider with usage color
    tab+="#[fg=${color},bg=${STATUS_BG_COLOR}]${TAB_DIVIDER}"

    # Icon on tab background
    tab+="#[fg=${TAB_TEXT_COLOR},bg=${color}]${icon} "

    # Percentage text with usage color
    tab+="#[fg=${color},bg=${TAB_BG_COLOR}] ${percent_num}%"

    # Store tab with device for sorting (root partition first)
    local sort_key="1"
    [[ "$mountpoint" != "/" ]] && sort_key="2"
    storage_tabs+=("${sort_key}|${device}|${tab}|${color}")

  done < <(df -h | tail -n +2)

  # Sort storage tabs (root first, then alphabetically)
  IFS=$'\n' storage_tabs=($(sort -t'|' -k1 <<<"${storage_tabs[*]}"))
  unset IFS

  # Build output with proper dividers
  local tab_count=${#storage_tabs[@]}
  for i in "${!storage_tabs[@]}"; do
    IFS='|' read -r sort_key device tab color <<<"${storage_tabs[$i]}"

    output+="$tab"

    # Ending divider
    if [ $((i + 1)) -lt "$tab_count" ]; then
      # Not the last tab - divider to next tab background
      output+=" #[fg=${color},bg=${TAB_BG_COLOR}]"
    else
      # Last tab - use status divider (left-pointing arrow)
      # fg = tab background color, bg = next section background (time section)
      output+=" #[fg=#444267,bg=${TAB_BG_COLOR}]${STATUS_DIVIDER}"
    fi
  done

  echo "$output"
}

# Main
get_local_storage
