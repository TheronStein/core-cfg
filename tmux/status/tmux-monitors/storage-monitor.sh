#!/bin/bash
# Monitor local drive storage usage - simplified

format_usage() {
  local icon=$1
  local percent=$2
  local label=$3

  # Color coding based on usage
  local color=""
  if [ "$percent" -ge 90 ]; then
    color="#[fg=red,bold]"
  elif [ "$percent" -ge 75 ]; then
    color="#[fg=yellow]"
  else
    color="#[fg=green]"
  fi

  local STATUS_BG_COLOR="#292D3E"
  local wrapped="#[fg=#444267,bg=${STATUS_BG_COLOR}]#[fg=#cdd6f4,bg=#444267] ${icon} #[fg=#444267,bg=${STATUS_BG_COLOR}]"

  echo "${wrapped}${color}${percent}%#[default] "
}

get_local_storage() {
  local output=""

  # Track seen devices to avoid btrfs subvolume duplicates
  declare -A seen_devices

  # Get major partitions (>10GB, excluding boot/efi and root)
  while IFS= read -r line; do
    local device=$(echo "$line" | awk '{print $1}')
    local size=$(echo "$line" | awk '{print $2}')
    local percent=$(echo "$line" | awk '{print $5}' | tr -d '%')
    local mount=$(echo "$line" | awk '{print $6}')

    # Skip root (already added), boot partitions, and small partitions
    if [ "$mount" = "/" ]; then
      continue
    fi
    if echo "$mount" | grep -qE '^/boot'; then
      continue
    fi

    # Extract simple device name (sda2, sda3, etc.)
    local label=$(echo "$device" | grep -oP '(nvme\d+n\d+p\d+|sd[a-z]\d+)$')
    if [ -z "$label" ]; then
      label=$(basename "$device")
    fi

    # Skip if we've already seen this device (btrfs subvolumes)
    if [ -n "${seen_devices[$label]}" ]; then
      continue
    fi
    seen_devices[$label]=1

    # Determine icon based on device type
    local icon=""
    if [[ "$label" == nvme* ]]; then
      icon="󱛟"
    else
      icon="󰋊"
    fi

    output+="$(format_usage "$icon" "$percent" "$label") "

  done < <(df -h | grep -E '^/dev/(nvme|sd)' | grep -v '^/dev/.*/$' | awk '$2 ~ /[0-9]+G/ && $2+0 > 10')

  echo "$output"
}

main() {
  local storage=$(get_local_storage)
  if [ -n "$storage" ]; then
    echo "$storage"
  else
    echo ""
  fi
}

main
