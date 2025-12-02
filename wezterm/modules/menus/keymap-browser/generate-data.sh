#!/usr/bin/env bash
# Generate keymap data for the keymap browser

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
OUTPUT_FILE="$DATA_DIR/keymaps.json"
TEMP_FILE="/tmp/wezterm-keymap-gen-$$.lua"

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Create a temporary wrapper script that uses current config
cat > "$TEMP_FILE" << 'EOLUA'
local wezterm = require("wezterm")

-- Set up package path to find our modules
package.path = package.path
	.. ";"
	.. wezterm.home_dir
	.. "/.core/.sys/configs/wezterm/?.lua;"
	.. wezterm.home_dir
	.. "/.core/.sys/configs/wezterm/?/init.lua"

-- Execute the data generator script (which now loads keymaps internally)
dofile(wezterm.home_dir .. "/.core/.sys/configs/wezterm/modules/menus/keymap-browser/generate-keymap-data.lua")

return {}
EOLUA

# Generate the data using WezTerm
echo "Generating keymap data..."
TEMP_OUTPUT="/tmp/wezterm-keymap-output-$$.txt"
wezterm --config-file "$TEMP_FILE" start --class org.wezfurlong.wezterm.keymap-gen -- sleep 0 > "$TEMP_OUTPUT" 2>&1

# Extract the JSON from wezterm logging output
if command -v jq &>/dev/null; then
    # The JSON is in a log line that contains '> lua: {'
    # Extract everything after '> lua: ' and take the first valid JSON object
    grep '> lua: {' "$TEMP_OUTPUT" | sed 's/^.*> lua: //' | head -1 > "$OUTPUT_FILE"

    # Validate and pretty-print
    if jq '.' "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" 2>/dev/null; then
        mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
        cat_count=$(jq '.categories | length' "$OUTPUT_FILE" 2>/dev/null || echo "?")
        key_count=$(jq '[.categories[].keybinds | length] | add' "$OUTPUT_FILE" 2>/dev/null || echo "?")
        echo "✓ Keymap data generated: $OUTPUT_FILE"
        echo "  Total categories: $cat_count"
        echo "  Total keybindings: $key_count"
    else
        echo "✗ Failed to validate JSON output"
        cat "$TEMP_OUTPUT" | tail -20
        rm -f "$TEMP_FILE" "$TEMP_OUTPUT"
        exit 1
    fi
else
    # Fallback without jq
    grep '> lua: {' "$TEMP_OUTPUT" | sed 's/^.*> lua: //' | head -1 > "$OUTPUT_FILE"
    if [[ ! -s "$OUTPUT_FILE" ]]; then
        echo "✗ Failed to extract JSON from output"
        rm -f "$TEMP_FILE" "$TEMP_OUTPUT"
        exit 1
    fi
    echo "✓ Keymap data generated: $OUTPUT_FILE"
fi

rm -f "$TEMP_OUTPUT"

# Clean up temp files
rm -f "$TEMP_FILE"

if [[ ! -f "$OUTPUT_FILE" ]] || [[ ! -s "$OUTPUT_FILE" ]]; then
    echo "✗ Failed to generate keymap data"
    exit 1
fi
