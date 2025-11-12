#!/usr/bin/env bash
# Copy WezTerm nerdfonts icon to clipboard

set -euo pipefail

full_line="$1"
# Parse the line: format is "glyph  icon_name"
# Extract glyph (first field before double space)
glyph=$(echo "$full_line" | awk '{print $1}')

# Copy glyph to clipboard
if [[ -n "$glyph" && "$glyph" != "?" ]]; then
    echo -n "$glyph" | wl-copy
fi
