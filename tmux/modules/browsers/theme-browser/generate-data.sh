#!/usr/bin/env bash
# Generate keymap data for the keymap browser

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
OUTPUT_FILE="$DATA_DIR/keymaps.json"
TEMP_FILE="/tmp/wezterm-keymap-gen-$$.lua"

# Create data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Create a temporary wrapper script
cat > "$TEMP_FILE" << 'EOLUA'
local wezterm = require("wezterm")

-- Set up package path to find our modules
package.path = package.path
	.. ";"
	.. wezterm.home_dir
	.. "/.core/cfg/wezterm/?.lua;"
	.. wezterm.home_dir
	.. "/.core/cfg/wezterm/?/init.lua"

-- Load keymaps module to get all keybindings
local keymaps = require("keymaps")

-- Create config object and populate it
_G.config = {
	keys = {},
	key_tables = {},
}

-- Setup keymaps (this populates config.keys and config.key_tables)
keymaps.setup(_G.config)

-- Now execute the data generator
dofile(wezterm.home_dir .. "/.core/cfg/wezterm/scripts/keymap-browser/generate-keymap-data.lua")

return {}
EOLUA

# Generate the data using WezTerm
echo "Generating keymap data..."
TEMP_OUTPUT="/tmp/wezterm-keymap-output-$$.txt"
wezterm --config-file "$TEMP_FILE" start --class org.wezfurlong.wezterm.keymap-gen -- sleep 0 > "$TEMP_OUTPUT" 2>&1

# Extract only the JSON from the output
# The JSON appears in the lua log output, we need to extract it
grep 'logging > lua: {' "$TEMP_OUTPUT" | sed 's/^.*logging > lua: //' | head -1 > "$OUTPUT_FILE"

# Clean up temp files
rm -f "$TEMP_FILE" "$TEMP_OUTPUT"

if [[ -f "$OUTPUT_FILE" ]] && [[ -s "$OUTPUT_FILE" ]]; then
    echo "✓ Keymap data generated: $OUTPUT_FILE"
    if command -v jq &>/dev/null; then
        cat_count=$(jq '.categories | length' "$OUTPUT_FILE" 2>/dev/null || echo "?")
        echo "  Total categories: $cat_count"
        # Pretty print the JSON
        jq '.' "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
    fi
else
    echo "✗ Failed to generate keymap data"
    exit 1
fi
