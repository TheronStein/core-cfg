#!/bin/bash

RIGHT_ID="$1"
LEFT_ID="$2"

# Read stout events pipe from the right Yazi instance
while IFS=',' read -r kind _ sender body; do
  # 'hover' events provide the URL of the file currently highlighted
  if [[ "$kind" == "hover" ]]; then
    # Extract the URL from the JSON body using a tool like jq (install if you don't have it)
    URL=$(echo "$body" | jq -r '.url')

    # Use 'ya emit-to' to command the LEFT instance to 'reveal' (hover) that specific file path
    # Note: 'reveal' updates the preview panel in Yazi
    ya emit-to "$LEFT_ID" reveal "$URL"

  # 'cd' events signify a directory change
  elif [[ "$kind" == "cd" ]]; then
    URL=$(echo "$body" | jq -r '.url')
    # Use 'ya emit-to' to command the LEFT instance to 'cd' to the same directory
    ya emit-to "$LEFT_ID" cd "$URL"
  fi
done
# This script will be fed events via process redirection later
