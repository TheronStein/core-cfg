#!/usr/bin/env bash
# Yazibar - DDS Event Handler
# Reads yazi --local-events output and syncs to right sidebar
#
# Event Format from yazi --local-events:
#   kind,receiver,sender,body
# Where body is a JSON object like: {"url":"/path/to/file"}
#
# Example:
#   hover,1234567,9876543,{"tab":0,"url":"/home/user/file.txt"}
#   cd,1234567,9876543,{"tab":0,"url":"/home/user/Downloads"}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/yazibar-utils.sh"

RIGHT_PANE="$1"

if [ -z "$RIGHT_PANE" ]; then
    debug_log "DDS handler: no right pane specified"
    exit 1
fi

debug_log "DDS handler started for right pane: $RIGHT_PANE"

# Track last URL to avoid duplicate syncs
last_hover_url=""

# Read comma-separated events from stdin (yazi --local-events output)
while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Parse CSV format: kind,receiver,sender,body
    # Use cut to extract fields (body may contain commas in JSON)
    kind=$(echo "$line" | cut -d',' -f1)
    # Body is everything after the third comma
    body=$(echo "$line" | cut -d',' -f4-)

    if [ -z "$kind" ]; then
        continue
    fi

    # Extract URL from JSON body using jq
    url=$(echo "$body" | jq -r '.url // empty' 2>/dev/null)

    if [ -z "$url" ]; then
        # Try alternate format without jq for speed
        url=$(echo "$body" | grep -oP '"url"\s*:\s*"\K[^"]+' 2>/dev/null)
    fi

    if [ -z "$url" ]; then
        continue
    fi

    case "$kind" in
        hover)
            # Only sync if URL changed (debounce)
            if [ "$url" != "$last_hover_url" ]; then
                last_hover_url="$url"

                debug_log "DDS hover event: $url"

                # Publish to tmux option for backwards compatibility with sync watcher
                set_tmux_option "@yazibar-hovered" "$url"

                # Send reveal command to right sidebar
                if pane_exists_globally "$RIGHT_PANE"; then
                    # Escape single quotes in path
                    escaped_url="${url//\'/\'\\\'\'}"
                    tmux send-keys -t "$RIGHT_PANE" ":reveal '${escaped_url}'" Enter 2>/dev/null
                else
                    debug_log "Right pane $RIGHT_PANE no longer exists"
                    break
                fi
            fi
            ;;
        cd)
            debug_log "DDS cd event: $url"

            # Publish to tmux option
            set_tmux_option "@yazibar-current-dir" "$url"

            # Optionally sync cd to right sidebar for directory changes
            # Send cd command so preview shows the directory contents
            if pane_exists_globally "$RIGHT_PANE"; then
                escaped_url="${url//\'/\'\\\'\'}"
                tmux send-keys -t "$RIGHT_PANE" ":cd '${escaped_url}'" Enter 2>/dev/null
            fi
            ;;
    esac
done

debug_log "DDS handler stopped"
