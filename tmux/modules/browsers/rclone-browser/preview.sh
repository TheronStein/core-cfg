#!/usr/bin/env bash
# Preview generator for Rclone Mount Browser + KDE Connect Support

set -euo pipefail

FULL_LINE="${1:-}"

# Parse the line: format is "🟢/⚫/📱 REMOTE | STATUS | MOUNT_POINT"
# Remove emoji and split by |
LINE_CLEAN=$(echo "$FULL_LINE" | sed 's/^[🟢⚫📱] //')
REMOTE=$(echo "$LINE_CLEAN" | awk -F' \\| ' '{print $1}' | xargs)
STATUS=$(echo "$LINE_CLEAN" | awk -F' \\| ' '{print $2}' | xargs)
MOUNT_POINT=$(echo "$LINE_CLEAN" | awk -F' \\| ' '{print $3}' | xargs)

if [[ -z "$REMOTE" ]]; then
  echo "Error: Could not parse remote name"
  exit 1
fi

# Check if this is a KDE Connect device
IS_KDECONNECT=false
if [[ "$REMOTE" =~ ^kdeconnect: ]]; then
  IS_KDECONNECT=true
fi

# Get remote type (for rclone remotes) or device info (for KDE Connect)
if $IS_KDECONNECT; then
  REMOTE_TYPE="kdeconnect"
  DEVICE_NAME="${REMOTE#kdeconnect:}"
  # Get device ID
  DEVICE_ID=$(kdeconnect-cli -a --id-name-only 2>/dev/null | grep -F "$DEVICE_NAME" | awk '{print $1}' || echo "")
else
  REMOTE_TYPE=$(rclone config dump 2>/dev/null | jq -r ".\"${REMOTE%:}\".type // \"unknown\"" 2>/dev/null || echo "unknown")
fi

# Get terminal height to scale content
TERM_HEIGHT=${FZF_PREVIEW_LINES:-$(tput lines 2>/dev/null || echo 30)}
MAX_FILES=$((TERM_HEIGHT / 3))
[[ $MAX_FILES -lt 8 ]] && MAX_FILES=8
[[ $MAX_FILES -gt 20 ]] && MAX_FILES=20

# Build status icon
if [[ "$STATUS" == "MOUNTED" ]]; then
  STATUS_ICON="🟢 MOUNTED"
else
  STATUS_ICON="⚫ UNMOUNTED"
fi

# Header
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if $IS_KDECONNECT; then
  echo "📱  $DEVICE_NAME"
else
  echo "🌐  $REMOTE"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Status: $STATUS_ICON | Type: $REMOTE_TYPE"
echo "Mount: $MOUNT_POINT"
echo ""

# Show KDE Connect device information
if $IS_KDECONNECT && [[ -n "$DEVICE_ID" ]]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📱 Device Information"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Check for battery plugin
  BATTERY_LEVEL=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$DEVICE_ID"/battery org.kde.kdeconnect.device.battery.charge 2>/dev/null || echo "")
  BATTERY_CHARGING=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$DEVICE_ID"/battery org.kde.kdeconnect.device.battery.isCharging 2>/dev/null || echo "")

  if [[ -n "$BATTERY_LEVEL" ]]; then
    BATTERY_ICON="🔋"
    [[ "$BATTERY_CHARGING" == "true" ]] && BATTERY_ICON="⚡"
    echo "Battery: $BATTERY_ICON $BATTERY_LEVEL%"
  fi

  # Check connectivity
  IS_REACHABLE=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$DEVICE_ID" org.kde.kdeconnect.device.isReachable 2>/dev/null || echo "false")
  echo "Reachable: $IS_REACHABLE"

  echo ""
fi

# Storage Information
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Storage Information"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if $IS_KDECONNECT; then
  # For KDE Connect, only show storage when mounted
  if [[ "$STATUS" == "MOUNTED" ]]; then
    # Get the actual KDE Connect mount point (not the symlink)
    REAL_MOUNT_POINT=$(readlink -f "$MOUNT_POINT" 2>/dev/null || echo "$MOUNT_POINT")

    if [[ -d "$REAL_MOUNT_POINT" ]]; then
      df_output=$(df -h "$REAL_MOUNT_POINT" 2>/dev/null | tail -1)
      if [ -n "$df_output" ]; then
        total=$(echo "$df_output" | awk '{print $2}')
        used=$(echo "$df_output" | awk '{print $3}')
        avail=$(echo "$df_output" | awk '{print $4}')
        use_pct=$(echo "$df_output" | awk '{print $5}')

        echo "Total:     $total"
        echo "Used:      $used ($use_pct)"
        echo "Available: $avail"
      fi
    else
      echo "Storage info not available (device not mounted)"
    fi
  else
    echo "Mount device to see storage information"
  fi
elif [[ "$STATUS" == "MOUNTED" ]] && mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
  # Use df for mounted rclone remotes (faster)
  df_output=$(df -h "$MOUNT_POINT" 2>/dev/null | tail -1)
  if [ -n "$df_output" ]; then
    total=$(echo "$df_output" | awk '{print $2}')
    used=$(echo "$df_output" | awk '{print $3}')
    avail=$(echo "$df_output" | awk '{print $4}')
    use_pct=$(echo "$df_output" | awk '{print $5}')

    echo "Total:     $total"
    echo "Used:      $used ($use_pct)"
    echo "Available: $avail"
  fi
else
  # Use rclone about for unmounted remotes
  about_output=$(timeout 5 rclone about "$REMOTE" 2>/dev/null || echo "")

  if [ -n "$about_output" ]; then
    # Parse rclone about output
    total=$(echo "$about_output" | grep "^Total:" | awk '{print $2, $3}')
    used=$(echo "$about_output" | grep "^Used:" | awk '{print $2, $3}')
    free=$(echo "$about_output" | grep "^Free:" | awk '{print $2, $3}')

    if [ -n "$total" ]; then
      echo "Total:     $total"
    fi
    if [ -n "$used" ]; then
      echo "Used:      $used"
    fi
    if [ -n "$free" ]; then
      echo "Available: $free"
    fi
  else
    echo "Storage info not available (timeout or unsupported)"
  fi
fi

echo ""

# Directory Contents
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Root Directory Contents (top $MAX_FILES)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if $IS_KDECONNECT; then
  # For KDE Connect devices
  if [[ "$STATUS" == "MOUNTED" ]]; then
    # Get the actual KDE Connect mount point (not the symlink)
    REAL_MOUNT_POINT=$(readlink -f "$MOUNT_POINT" 2>/dev/null || echo "$MOUNT_POINT")

    if [[ -d "$REAL_MOUNT_POINT" ]]; then
      # Use eza or ls for mounted KDE Connect devices
      if command -v eza &>/dev/null; then
        timeout 3 eza -1 --icons --group-directories-first --color=always "$REAL_MOUNT_POINT" 2>/dev/null | head -n "$MAX_FILES" || echo "  (error reading directory)"
      else
        timeout 3 ls -1 --color=always "$REAL_MOUNT_POINT" 2>/dev/null | head -n "$MAX_FILES" | while IFS= read -r name; do
          if [ -d "$REAL_MOUNT_POINT/$name" ]; then
            echo "📁 $name"
          else
            echo "📄 $name"
          fi
        done || echo "  (error reading directory)"
      fi

      # Count total items
      echo ""
      total_items=$(timeout 2 ls -1 "$REAL_MOUNT_POINT" 2>/dev/null | wc -l || echo "?")
      echo "Total items: $total_items"
    else
      echo "  (device not mounted)"
    fi
  else
    echo "  Mount device to browse contents"
  fi
elif [[ "$STATUS" == "MOUNTED" ]] && mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
  # Use eza or ls for mounted rclone remotes
  if command -v eza &>/dev/null; then
    timeout 3 eza -1 --icons --group-directories-first --color=always "$MOUNT_POINT" 2>/dev/null | head -n "$MAX_FILES" || echo "  (error reading directory)"
  else
    timeout 3 ls -1 --color=always "$MOUNT_POINT" 2>/dev/null | head -n "$MAX_FILES" | while IFS= read -r name; do
      if [ -d "$MOUNT_POINT/$name" ]; then
        echo "📁 $name"
      else
        echo "📄 $name"
      fi
    done || echo "  (error reading directory)"
  fi

  # Count total items
  echo ""
  total_items=$(timeout 2 ls -1 "$MOUNT_POINT" 2>/dev/null | wc -l || echo "?")
  echo "Total items: $total_items"
else
  # Use rclone lsd for unmounted rclone remotes
  if command -v eza &>/dev/null; then
    # Use rclone with eza-like formatting
    timeout 5 rclone lsf --dirs-only --max-depth 1 "$REMOTE" 2>/dev/null | head -n "$MAX_FILES" | while IFS= read -r dir; do
      echo "📁 ${dir%/}"
    done

    # Show files too
    timeout 5 rclone lsf --files-only --max-depth 1 "$REMOTE" 2>/dev/null | head -n $((MAX_FILES / 2)) | while IFS= read -r file; do
      echo "📄 $file"
    done
  else
    # Simple rclone listing
    timeout 5 rclone lsd "$REMOTE" 2>/dev/null | head -n "$MAX_FILES" | awk '{for(i=5;i<=NF;i++) printf "%s ", $i; print ""}' | while IFS= read -r name; do
      echo "📁 $name"
    done || echo "  (timeout or error listing remote)"
  fi

  # Count with rclone
  echo ""
  dir_count=$(timeout 3 rclone lsf --dirs-only --max-depth 1 "$REMOTE" 2>/dev/null | wc -l || echo "?")
  file_count=$(timeout 3 rclone lsf --files-only --max-depth 1 "$REMOTE" 2>/dev/null | wc -l || echo "?")
  echo "Directories: $dir_count | Files: $file_count"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮 Actions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$STATUS" == "MOUNTED" ]]; then
  echo "Enter/Ctrl-U : Unmount | Ctrl-O : Open | Ctrl-R : Refresh"
else
  echo "Enter/Ctrl-M : Mount | Ctrl-R : Refresh"
fi
echo "Alt-W/S/A/D  : Navigate panes | Esc : Close"
