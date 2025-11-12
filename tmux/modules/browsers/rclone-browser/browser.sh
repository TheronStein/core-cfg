#!/usr/bin/env bash
# Rclone Mount/Unmount Browser with FZF + KDE Connect Support

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure dependencies
for cmd in fzf rclone; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done

# Check if KDE Connect is available
KDECONNECT_AVAILABLE=false
if command -v kdeconnect-cli &>/dev/null && command -v qdbus &>/dev/null; then
  KDECONNECT_AVAILABLE=true
fi

# Check if a remote is a KDE Connect device
is_kdeconnect_device() {
  local remote="$1"
  [[ "$remote" =~ ^kdeconnect: ]]
}

# Get KDE Connect device ID from remote name
get_kdeconnect_device_id() {
  local remote="$1"
  local device_name="${remote#kdeconnect:}"

  if ! $KDECONNECT_AVAILABLE; then
    return 1
  fi

  # Get device ID by name
  kdeconnect-cli -a --id-name-only 2>/dev/null | grep -F "$device_name" | awk '{print $1}'
}

# Get mount point for a remote
get_mount_point() {
  local remote="$1"
  local remote_name="${remote%:}"

  # Handle KDE Connect devices
  if is_kdeconnect_device "$remote"; then
    local device_name="${remote#kdeconnect:}"
    case "$device_name" in
      "Theron Z Fold6"|"zfold")
        echo "$HOME/mnt/zfold"
        ;;
      *)
        # Fallback for other KDE Connect devices
        echo "$HOME/mnt/${device_name// /_}"
        ;;
    esac
    return
  fi

  # Handle rclone remotes
  case "$remote_name" in
    onedrive)
      echo "$HOME/mnt/onedrive"
      ;;
    proton)
      echo "$HOME/mnt/proton"
      ;;
    chaoscore)
      echo "$HOME/mnt/chaoscore/theron"
      ;;
    dropbox)
      echo "$HOME/mnt/dropbox"
      ;;
    *)
      # Fallback for any other remotes
      echo "$HOME/mnt/${remote_name}"
      ;;
  esac
}

# Get mount status for a remote
get_mount_status() {
  local remote="$1"
  local mount_point
  mount_point=$(get_mount_point "$remote")

  # Handle KDE Connect devices
  if is_kdeconnect_device "$remote"; then
    local device_id
    device_id=$(get_kdeconnect_device_id "$remote")
    if [[ -n "$device_id" ]]; then
      local is_mounted
      is_mounted=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$device_id"/sftp org.kde.kdeconnect.device.sftp.isMounted 2>/dev/null || echo "false")
      if [[ "$is_mounted" == "true" ]]; then
        echo "MOUNTED"
        return
      fi
    fi
    echo "UNMOUNTED"
    return
  fi

  # Handle rclone remotes
  if mountpoint -q "$mount_point" 2>/dev/null; then
    echo "MOUNTED"
  else
    echo "UNMOUNTED"
  fi
}

# Mount a remote
mount_remote() {
  local remote="$1"
  local mount_point
  mount_point=$(get_mount_point "$remote")

  # Handle KDE Connect devices
  if is_kdeconnect_device "$remote"; then
    local device_id
    device_id=$(get_kdeconnect_device_id "$remote")

    if [[ -z "$device_id" ]]; then
      echo "Device not found or not available: $remote" >&2
      return 1
    fi

    # Check if already mounted
    local is_mounted
    is_mounted=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$device_id"/sftp org.kde.kdeconnect.device.sftp.isMounted 2>/dev/null || echo "false")

    if [[ "$is_mounted" == "true" ]]; then
      # Already mounted, just ensure symlink exists
      local kde_mount_point
      kde_mount_point=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$device_id"/sftp org.kde.kdeconnect.device.sftp.mountPoint 2>/dev/null)

      if [[ -n "$kde_mount_point" && -d "$kde_mount_point" ]]; then
        # Remove existing directory or symlink
        if [[ -e "$mount_point" || -L "$mount_point" ]]; then
          rm -rf "$mount_point"
        fi
        ln -sfn "$kde_mount_point" "$mount_point"
        echo "Already mounted: $remote at $mount_point" >&2
        return 0
      fi
    fi

    # Mount via KDE Connect (use mountAndWait for better reliability)
    mount_success=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$device_id"/sftp org.kde.kdeconnect.device.sftp.mountAndWait 2>/dev/null || echo "false")

    if [[ "$mount_success" != "true" ]]; then
      mount_error=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$device_id"/sftp org.kde.kdeconnect.device.sftp.getMountError 2>/dev/null || echo "Unknown error")
      echo "Failed to mount $remote: $mount_error" >&2
      return 1
    fi

    # Get the actual KDE Connect mount point and create symlink
    local kde_mount_point
    kde_mount_point=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$device_id"/sftp org.kde.kdeconnect.device.sftp.mountPoint 2>/dev/null)

    if [[ -z "$kde_mount_point" || ! -d "$kde_mount_point" ]]; then
      echo "Failed to mount $remote" >&2
      return 1
    fi

    # Remove existing directory or symlink before creating new one
    if [[ -e "$mount_point" || -L "$mount_point" ]]; then
      rm -rf "$mount_point"
    fi

    # Create symlink to user's desired mount point
    ln -sfn "$kde_mount_point" "$mount_point"

    echo "Successfully mounted: $remote at $mount_point"
    return 0
  fi

  # Handle rclone remotes
  mkdir -p "$mount_point"

  if mountpoint -q "$mount_point" 2>/dev/null; then
    echo "Already mounted: $remote at $mount_point" >&2
    return 1
  fi

  # Mount in background with common options
  # Try with allow-other first, fallback without it
  if ! rclone mount "$remote" "$mount_point" \
    --vfs-cache-mode writes \
    --daemon \
    --allow-other 2>/dev/null; then
    # Try without allow-other if that fails
    if ! rclone mount "$remote" "$mount_point" \
      --vfs-cache-mode writes \
      --daemon 2>&1; then
      echo "Failed to mount $remote" >&2
      return 1
    fi
  fi

  sleep 1  # Wait for mount to stabilize

  if mountpoint -q "$mount_point" 2>/dev/null; then
    echo "Successfully mounted: $remote at $mount_point"
    return 0
  else
    echo "Mount verification failed for $remote" >&2
    return 1
  fi
}

# Unmount a remote
unmount_remote() {
  local remote="$1"
  local mount_point
  mount_point=$(get_mount_point "$remote")

  # Handle KDE Connect devices
  if is_kdeconnect_device "$remote"; then
    local device_id
    device_id=$(get_kdeconnect_device_id "$remote")

    if [[ -z "$device_id" ]]; then
      echo "Device not found: $remote" >&2
      return 1
    fi

    # Check if mounted
    local is_mounted
    is_mounted=$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$device_id"/sftp org.kde.kdeconnect.device.sftp.isMounted 2>/dev/null || echo "false")

    if [[ "$is_mounted" != "true" ]]; then
      echo "Not mounted: $remote" >&2
      # Clean up symlink if it exists
      [[ -L "$mount_point" ]] && rm -f "$mount_point"
      return 1
    fi

    # Unmount via KDE Connect
    qdbus org.kde.kdeconnect /modules/kdeconnect/devices/"$device_id"/sftp org.kde.kdeconnect.device.sftp.unmount 2>/dev/null

    # Remove symlink
    [[ -L "$mount_point" ]] && rm -f "$mount_point"

    echo "Successfully unmounted: $remote"
    return 0
  fi

  # Handle rclone remotes
  if ! mountpoint -q "$mount_point" 2>/dev/null; then
    echo "Not mounted: $remote" >&2
    return 1
  fi

  # Try fusermount3 first, then fusermount
  local unmount_cmd="fusermount3"
  if ! command -v fusermount3 &>/dev/null; then
    unmount_cmd="fusermount"
  fi

  $unmount_cmd -u "$mount_point" 2>/dev/null || {
    echo "Failed to unmount $remote (trying force unmount...)" >&2
    $unmount_cmd -uz "$mount_point" 2>/dev/null || {
      echo "Force unmount failed for $remote" >&2
      return 1
    }
  }

  echo "Successfully unmounted: $remote"
  return 0
}

# Browse remotes
browse_remotes() {
  # Get all remotes and their status (both rclone and KDE Connect)
  {
    # List rclone remotes
    rclone listremotes | while read -r remote; do
      [[ -z "$remote" ]] && continue
      local status
      status=$(get_mount_status "$remote")
      local mount_point
      mount_point=$(get_mount_point "$remote")

      # Format: REMOTE_NAME | STATUS | MOUNT_POINT
      if [[ "$status" == "MOUNTED" ]]; then
        printf "🟢 %s | %s | %s\n" "$remote" "$status" "$mount_point"
      else
        printf "⚫ %s | %s | %s\n" "$remote" "$status" "$mount_point"
      fi
    done

    # List KDE Connect devices
    if $KDECONNECT_AVAILABLE; then
      kdeconnect-cli -a --name-only 2>/dev/null | while read -r device_name; do
        [[ -z "$device_name" ]] && continue
        local remote="kdeconnect:$device_name"
        local status
        status=$(get_mount_status "$remote")
        local mount_point
        mount_point=$(get_mount_point "$remote")

        # Format: REMOTE_NAME | STATUS | MOUNT_POINT
        if [[ "$status" == "MOUNTED" ]]; then
          printf "🟢 %s | %s | %s\n" "$remote" "$status" "$mount_point"
        else
          printf "📱 %s | %s | %s\n" "$remote" "$status" "$mount_point"
        fi
      done
    fi
  } | fzf \
    --ansi \
    --height=100% \
    --layout=reverse \
    --border=rounded \
    --border-label="╣ Rclone Mount Manager ╠" \
    --prompt="Remote ❯ " \
    --pointer="▶" \
    --marker="✓" \
    --delimiter=' | ' \
    --with-nth=1,2 \
    --header=$'Navigate: ↑↓ | Toggle Mount: Enter | Mount: Ctrl-M | Unmount: Ctrl-U | Open: Ctrl-O | Refresh: Ctrl-R | Quit: Esc\n─────────────────────────────────────────' \
    --preview="$SCRIPT_DIR/preview.sh {}" \
    --preview-window=right:60%:wrap:rounded \
    --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
    --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
    --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
    --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
    --bind="ctrl-/:toggle-preview" \
    --bind="ctrl-r:reload(bash $SCRIPT_DIR/browser.sh --reload)" \
    --bind="enter:execute(remote=\$(echo {} | awk '{print \$2}'); status=\$(echo {} | awk '{print \$4}'); if [[ \"\$status\" == \"MOUNTED\" ]]; then bash $SCRIPT_DIR/browser.sh --unmount \"\$remote\"; else bash $SCRIPT_DIR/browser.sh --mount \"\$remote\"; fi; read -p 'Press ENTER to continue...')+reload(bash $SCRIPT_DIR/browser.sh --reload)" \
    --bind="ctrl-m:execute(remote=\$(echo {} | awk '{print \$2}'); bash $SCRIPT_DIR/browser.sh --mount \"\$remote\"; read -p 'Press ENTER to continue...')+reload(bash $SCRIPT_DIR/browser.sh --reload)" \
    --bind="ctrl-u:execute(remote=\$(echo {} | awk '{print \$2}'); bash $SCRIPT_DIR/browser.sh --unmount \"\$remote\"; read -p 'Press ENTER to continue...')+reload(bash $SCRIPT_DIR/browser.sh --reload)" \
    --bind="ctrl-o:execute-silent(remote=\$(echo {} | awk '{print \$2}'); mount_point=\$(bash $SCRIPT_DIR/browser.sh --get-mount-point \"\$remote\"); if mountpoint -q \"\$mount_point\" 2>/dev/null; then xdg-open \"\$mount_point\" || nautilus \"\$mount_point\" || thunar \"\$mount_point\" || echo 'No file manager found'; else echo 'Not mounted'; fi)"
}

# Handle command line arguments
case "${1:-browse}" in
  --reload)
    # Used for fzf reload - just output the list (both rclone and KDE Connect)
    # List rclone remotes
    rclone listremotes | while read -r remote; do
      [[ -z "$remote" ]] && continue
      status=$(get_mount_status "$remote")
      mount_point=$(get_mount_point "$remote")

      if [[ "$status" == "MOUNTED" ]]; then
        printf "🟢 %s | %s | %s\n" "$remote" "$status" "$mount_point"
      else
        printf "⚫ %s | %s | %s\n" "$remote" "$status" "$mount_point"
      fi
    done

    # List KDE Connect devices
    if $KDECONNECT_AVAILABLE; then
      kdeconnect-cli -a --name-only 2>/dev/null | while read -r device_name; do
        [[ -z "$device_name" ]] && continue
        remote="kdeconnect:$device_name"
        status=$(get_mount_status "$remote")
        mount_point=$(get_mount_point "$remote")

        if [[ "$status" == "MOUNTED" ]]; then
          printf "🟢 %s | %s | %s\n" "$remote" "$status" "$mount_point"
        else
          printf "📱 %s | %s | %s\n" "$remote" "$status" "$mount_point"
        fi
      done
    fi
    ;;
  --get-mount-point)
    get_mount_point "${2:-}"
    ;;
  --mount)
    mount_remote "${2:-}"
    ;;
  --unmount)
    unmount_remote "${2:-}"
    ;;
  browse|*)
    browse_remotes
    ;;
esac
