#!/bin/bash

# BACKDROP_DIR="$HOME/.config/wezterm/backdrops"
BACKDROP_DIR="$HOME/Pictures/wallpapers"
METADATA_FILE="$HOME/.config/wezterm/data/backgrounds.json"
LOCK_FILE="$HOME/.config/wezterm/data/.metadata.lock"

# Create data directory
mkdir -p "$(dirname "$METADATA_FILE")"

# Check for lock file to prevent concurrent runs
if [ -f "$LOCK_FILE" ]; then
  exit 0
fi

touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# Load existing metadata or create empty object
if [ -f "$METADATA_FILE" ]; then
  TEMP_DATA=$(cat "$METADATA_FILE")
else
  TEMP_DATA="{}"
fi

NEW_IMAGES=0

# Use process substitution to avoid subshell issues with while loop
while IFS= read -r img; do
  # Check if already in metadata
  HAS_ENTRY=$(echo "$TEMP_DATA" | jq -e --arg path "$img" 'has($path)' 2>/dev/null)

  if [ "$HAS_ENTRY" != "true" ]; then
    dimensions=$(identify -format "%wx%h" "$img" 2>/dev/null)

    if [ -n "$dimensions" ]; then
      width=$(echo "$dimensions" | cut -d'x' -f1)
      height=$(echo "$dimensions" | cut -d'x' -f2)

      TEMP_DATA=$(echo "$TEMP_DATA" | jq --arg path "$img" \
        --argjson width "$width" \
        --argjson height "$height" \
        '. + {($path): {width: $width, height: $height}}')

      NEW_IMAGES=$((NEW_IMAGES + 1))
      echo "Added: $img ($width x $height)"
    fi
  fi
done < <(find "$BACKDROP_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.jpeg" -o -iname "*.avif" \))

# Always write the file
echo "$TEMP_DATA" | jq '.' >"$METADATA_FILE"

if [ $NEW_IMAGES -gt 0 ]; then
  echo "Added $NEW_IMAGES new images to metadata"
else
  echo "No new images found. Metadata file exists with $(jq 'length' "$METADATA_FILE") entries."
fi
