#!/bin/bash

STATE=$BACKDROP_STATE
OVERRIDE=$!
WALLPAPERS="$HOME/Pictures/wallpapers"
BACKDROPS="$HOME/.core/.sys/configs/wezterm/backdrops"
WEZTERM_DIR="$HOME/.core/.sys/configs/wezterm"
METADATA_FILE="$WEZTERM_DIR/.data/backgrounds.json"
METADATA_BACKUP_DIR="$WEZTERM_DIR/.data/metadata-backups"

echo "State: ${STATE}"

# Create backup directory if it doesn't exist
mkdir -p "$METADATA_BACKUP_DIR"

# Function to get a hash identifier for a directory
get_dir_hash() {
    local dir="$1"
    echo "$dir" | sha256sum | cut -c1-8
}

# Function to backup metadata with directory hash
backup_metadata() {
    if [ -f "$METADATA_FILE" ]; then
        local current_link=$(readlink "$WEZTERM_DIR/backdrops")
        local hash=$(get_dir_hash "$current_link")
        local backup_file="$METADATA_BACKUP_DIR/backgrounds-${hash}.json"
        cp "$METADATA_FILE" "$backup_file"
        echo "Backed up metadata to: $backup_file"
    fi
}

# Function to restore metadata if available
restore_metadata() {
    local new_dir="$1"
    local hash=$(get_dir_hash "$new_dir")
    local backup_file="$METADATA_BACKUP_DIR/backgrounds-${hash}.json"

    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$METADATA_FILE"
        echo "Restored metadata from: $backup_file"
        return 0
    else
        echo "No previous metadata found for this directory"
        return 1
    fi
}

# Backup current metadata before switching
backup_metadata

# Determine new backdrop directory
rm -rf $HOME/.core/.sys/configs/wezterm/backdrops
if [[ $STATE == 0 ]]; then
  NEW_BACKDROPS=$WALLPAPERS
  export BACKDROP_STATE=1
else
  NEW_BACKDROPS=$BACKDROPS
  export BACKDROP_STATE=0
fi

echo "Switching to: $NEW_BACKDROPS"
ln -sf $NEW_BACKDROPS $HOME/.core/.sys/configs/wezterm/backdrops

# Try to restore metadata for the new directory
if ! restore_metadata "$NEW_BACKDROPS"; then
    # If no backup exists, clear current metadata and regenerate
    echo "Generating fresh metadata for new backdrop directory..."
    > "$METADATA_FILE"  # Clear the file
    "$WEZTERM_DIR/modules/menus/utilities/generate-image-metadata.sh"
fi

# Trigger WezTerm to reload backdrops
# Create a signal file that WezTerm can watch for
# SIGNAL_FILE="$WEZTERM_DIR/.data/.backdrop-refresh"
# touch "$SIGNAL_FILE"

# Force WezTerm to reload config which will trigger backdrop refresh
# This is more reliable than trying to send events
# echo "Triggering WezTerm config reload..."
# killall -SIGUSR1 wezterm-gui 2>/dev/null || true

# # Alternative: if wezterm cli is available, try that too
# if command -v wezterm &> /dev/null; then
#     echo "Attempting to trigger via CLI..."
#     # This forces all WezTerm instances to reload their config
#     wezterm cli spawn --new-window -- echo "refresh" 2>/dev/null && sleep 0.1 && wezterm cli kill-pane 2>/dev/null || true
# fi

echo "Backdrop rotation complete!"
