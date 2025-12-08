#!/bin/bash
# Monitor cloud storage usage - simplified

CACHE_FILE="/tmp/cloud_storage_cache"
CACHE_TIMEOUT=300 # 5 minutes

STATUS_BG_COLOR="#292D3E"
TAB_BG_COLOR="#444267"

local cloud_colors =(
    "dropbox:#024CC4:"
    "proton:#7147F4"
    "onedrive:#0F47AA"
    "gdrive:#34A853"
)

get_cloud_colors() {
  local colors=""
  for entry in "${cloud_colors[@]}"; do
    local name="${entry%%:*}"
    local fg="${entry#*:}"
    fg="${fg%%:*}"
    local bg="${entry##*:}"
    colors+="$name:$fg:$bg;"
  done
  echo "$colors"
}


format_cloud_usage() {
  local remote=$1
  local percent=$2

  # Color coding based on usage
  local color=""
  if [ "$percent" -ge 90 ]; then
    color="#[fg=red,bold]"
  elif [ "$percent" -ge 75 ]; then
    color="#[fg=yellow]"
  else
    color="#[fg=cyan]"
  fi



  divider_icon_left="#[fg=${CLOUD_COLORS},bg=${STATUS_COLO}]"

  # Determine icon and color based on remote type
  local icon_color=""
  local icon=""
  case "$remote" in
    *dropbox*)
      # icon_color="#[fg=#444267,bg=${STATUS_BG_COLOR}]#[fg=#024CC4,bg=#444267] 󰉋 #[fg=#444267,bg=${STATUS_BG_COLOR}]"
      icon_color="#[fg=#024CC4,bg=#444267]#[fg=#444267,bg=${STATUS_BG_COLOR}] #[fg=#024CC4,bg=#444267]󰉋  #[fg=#444267,bg=${STATUS_BG_COLOR}]"
      icon=" "
      ;;
    *proton*)
      icon_color="#[fg=#444267,bg=${STATUS_BG_COLOR}]#[fg=#7147F4,bg=#444267] 󰢬 #[fg=#444267,bg=${STATUS_BG_COLOR}]"
      icon="󰢬 "
      ;;
    *onedrive*)
      icon_color="#[fg=#444267,bg=${STATUS_BG_COLOR}]#[fg=#0F47AA,bg=#444267] 󰣇 #[fg=#444267,bg=${STATUS_BG_COLOR}]"
      icon="󰏊 "
      ;;
    *drive* | *gdrive*)
      icon_color="#[fg=#444267,bg=${STATUS_BG_COLOR}]#[fg=#34A853,bg=#444267] 󰊶 #[fg=#444267,bg=${STATUS_BG_COLOR}]"
      icon="󰊶 "
      ;;
    *)
      icon_color="#[fg=#444267,bg=${STATUS_BG_COLOR}]#[fg=#87CEEB,bg=#444267] ☁️ #[fg=#444267,bg=${STATUS_BG_COLOR}]"
      icon="☁️"
      ;;
  esac

  echo "${icon_color}${color}${percent}%#[default] "
}

get_cloud_storage() {
  local output=""
  local cache_valid=false

  # Check if cache exists and is recent
  if [ -f "$CACHE_FILE" ]; then
    local cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ "$cache_age" -lt "$CACHE_TIMEOUT" ]; then
      cache_valid=true
      output=$(cat "$CACHE_FILE")
    fi
  fi

  if [ "$cache_valid" = false ]; then
    # Get list of configured remotes
    local remotes=$(rclone listremotes 2>/dev/null | tr -d ':')

    for remote in $remotes; do
      # Skip SFTP servers
      case "$remote" in
        chaoscore) continue ;;
      esac

      # Get storage info (with timeout to avoid hanging)
      local info=$(timeout 10 rclone about "${remote}:" 2>/dev/null)

      if [ $? -eq 0 ] && [ -n "$info" ]; then
        local total=$(echo "$info" | grep "Total:" | awk '{print $2, $3}')
        local used=$(echo "$info" | grep "Used:" | awk '{print $2, $3}')

        if [ -n "$total" ] && [ -n "$used" ]; then
          # Simple conversion: normalize to GiB
          local used_val=$(echo "$used" | awk '{print $1}')
          local used_unit=$(echo "$used" | awk '{print $2}')
          local total_val=$(echo "$total" | awk '{print $1}')
          local total_unit=$(echo "$total" | awk '{print $2}')

          # Convert to GiB
          local used_gib=$used_val
          local total_gib=$total_val

          [ "$used_unit" = "TiB" ] && used_gib=$(echo "$used_val * 1024" | bc)
          [ "$used_unit" = "MiB" ] && used_gib=$(echo "$used_val / 1024" | bc)
          [ "$total_unit" = "TiB" ] && total_gib=$(echo "$total_val * 1024" | bc)
          [ "$total_unit" = "MiB" ] && total_gib=$(echo "$total_val / 1024" | bc)

          local percent=$(echo "scale=0; ($used_gib * 100) / $total_gib" | bc 2>/dev/null || echo "0")

          local formatted=$(format_cloud_usage "$remote" "$percent")
          output+="$formatted "
        fi
      fi
    done

    # Cache the result
    echo "$output" >"$CACHE_FILE"
  fi

  echo "$output"
}

main() {
  local storage=$(get_cloud_storage)
  if [ -n "$storage" ]; then
    echo "$storage"
  else
    echo ""
  fi
}

main
