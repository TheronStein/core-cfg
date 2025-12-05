#!/usr/bin/env bash
# extract-github-urls.sh
# Extracts GitHub repository URLs from markdown files
# Usage: ./extract-github-urls.sh <input_file> [output_file]
# Example: ./extract-github-urls.sh statusline.md statusline-urls.txt

set -euo pipefail

# Check if input file is provided
if [[ $# -lt 1 ]]; then
    echo "Error: Please provide an input file"
    echo "Usage: $0 <input_file> [output_file]"
    echo "Example: $0 statusline.md statusline-urls.txt"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-}"

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: File '$INPUT_FILE' not found"
    exit 1
fi

# If no output file specified, use stdout
if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_MODE="stdout"
else
    OUTPUT_MODE="file"
    # Clear/create output file
    > "$OUTPUT_FILE"
fi

# Process each line
declare -A seen_repos
count=0

while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Extract GitHub URL from the line
    # Try markdown link format first
    if [[ "$line" =~ \[.*\]\((.*)\) ]]; then
        url="${BASH_REMATCH[1]}"
    else
        url="$line"
    fi

    # Remove query parameters and anchors
    url="${url%%\?*}"
    url="${url%%\#*}"

    # Extract owner/repo from various URL formats
    if [[ "$url" =~ github\.com/([^/]+)/([^/[:space:]]+) ]]; then
        owner="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    elif [[ "$url" =~ ^([^/]+)/([^/[:space:]]+)$ ]]; then
        owner="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    else
        continue
    fi

    # Clean up repo name
    repo="${repo%.git}"
    repo="${repo%/}"

    # Skip if invalid or already seen
    [[ -z "$owner" || -z "$repo" ]] && continue

    repo_key="${owner}/${repo}"
    if [[ -n "${seen_repos[$repo_key]:-}" ]]; then
        continue
    fi

    seen_repos[$repo_key]=1
    count=$((count + 1))

    # Output the clean URL
    clean_url="https://github.com/${owner}/${repo}"

    if [[ "$OUTPUT_MODE" == "file" ]]; then
        echo "$clean_url" >> "$OUTPUT_FILE"
    else
        echo "$clean_url"
    fi

done < "$INPUT_FILE"

if [[ "$OUTPUT_MODE" == "file" ]]; then
    echo "Extracted $count unique GitHub repository URLs to: $OUTPUT_FILE"
else
    echo "Extracted $count unique GitHub repository URLs" >&2
fi
