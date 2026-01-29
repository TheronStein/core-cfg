#!/bin/bash
# spotify_player notification script with album art
# Triggered via player_event_hook_command

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/spotify-player/covers"
mkdir -p "$CACHE_DIR"

# Only notify on track change
[[ "$1" != "Changed" ]] && exit 0

TRACK_ID="$2"

# Get track info from spotify_player's internal API
# Using playerctl as fallback since it works with MPRIS
TITLE=$(playerctl -p spotify_player metadata title 2>/dev/null)
ARTIST=$(playerctl -p spotify_player metadata artist 2>/dev/null)
ALBUM=$(playerctl -p spotify_player metadata album 2>/dev/null)
ART_URL=$(playerctl -p spotify_player metadata mpris:artUrl 2>/dev/null)

# Exit if no track info
[[ -z "$TITLE" ]] && exit 0

# Download album art if URL exists
COVER_PATH=""
if [[ -n "$ART_URL" ]]; then
    # Create filename from track ID or URL hash
    COVER_FILE="$CACHE_DIR/$(echo "$ART_URL" | md5sum | cut -d' ' -f1).jpg"

    # Download if not cached
    if [[ ! -f "$COVER_FILE" ]]; then
        curl -s -o "$COVER_FILE" "$ART_URL" 2>/dev/null
    fi

    [[ -f "$COVER_FILE" ]] && COVER_PATH="$COVER_FILE"
fi

# Send notification
if [[ -n "$COVER_PATH" ]]; then
    notify-send -a "spotify_player" -i "$COVER_PATH" "$TITLE • $ARTIST" "$ALBUM"
else
    notify-send -a "spotify_player" "$TITLE • $ARTIST" "$ALBUM"
fi
