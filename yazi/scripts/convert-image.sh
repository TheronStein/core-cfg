#!/bin/bash

# Image converter for yazi
# Usage: convert-image.sh <format> <input-file>

FORMAT="$1"
INPUT_FILE="$2"

if [ -z "$INPUT_FILE" ] || [ ! -f "$INPUT_FILE" ]; then
    exit 1
fi

# Get filename without extension
FILENAME="${INPUT_FILE%.*}"
OUTPUT_FILE="${FILENAME}.${FORMAT}"

# Check if output file already exists
if [ -f "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${FILENAME}_converted.${FORMAT}"
fi

# Convert using ImageMagick or ffmpeg
if command -v convert &> /dev/null; then
    convert "$INPUT_FILE" "$OUTPUT_FILE" 2>/dev/null
elif command -v ffmpeg &> /dev/null; then
    ffmpeg -i "$INPUT_FILE" "$OUTPUT_FILE" -y 2>/dev/null
else
    exit 1
fi

# Notify user
if [ $? -eq 0 ]; then
    notify-send "Image Converted" "Saved as: $(basename "$OUTPUT_FILE")" 2>/dev/null || echo "Converted: $OUTPUT_FILE"
fi
