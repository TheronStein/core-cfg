#!/usr/bin/env bash
# Generate sidebar-left keymap.toml based on main keymap with yazibar-sync integration
# This ensures sidebar keymaps inherit from main keymaps while adding sync functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YAZI_DIR="$CORE_CFG/yazi"
MAIN_KEYMAP="$YAZI_DIR/keymap.toml"
OUTPUT_KEYMAP="$YAZI_DIR/conf/sidebar-left/keymap.toml"

# Backup existing if it exists
if [ -f "$OUTPUT_KEYMAP" ]; then
    cp "$OUTPUT_KEYMAP" "$OUTPUT_KEYMAP.bak.$(date +%Y%m%d_%H%M%S)"
fi

# Navigation keys that need yazibar-sync
# These are the keys that change the hovered file and need to publish to tmux
SYNC_KEYS=(
    '"i"'           # Up
    '"k"'           # Down
    '"I"'           # Page up
    '"K"'           # Page down
    '"<C-i>"'       # Scroll up small
    '"<C-k>"'       # Scroll down small
    '"<C-I>"'       # Scroll up large
    '"<C-K>"'       # Scroll down large
    '"j"'           # Left (leave directory)
    '"J"'           # History back
    '"L"'           # History forward
    '"<Up>"'        # Arrow up
    '"<Down>"'      # Arrow down
    '"<Left>"'      # Arrow left
    '"<Right>"'     # Arrow right (enter)
    '"<PageUp>"'    # Page up
    '"<PageDown>"'  # Page down
)

echo "Generating sidebar-left keymap from main keymap..."

# Read main keymap and process
awk -v output="$OUTPUT_KEYMAP" '
BEGIN {
    # Navigation keys that need yazibar-sync
    sync_keys["\"i\""] = 1
    sync_keys["\"k\""] = 1
    sync_keys["\"I\""] = 1
    sync_keys["\"K\""] = 1
    sync_keys["\"<C-i>\""] = 1
    sync_keys["\"<C-k>\""] = 1
    sync_keys["\"<C-I>\""] = 1
    sync_keys["\"<C-K>\""] = 1
    sync_keys["\"j\""] = 1
    sync_keys["\"J\""] = 1
    sync_keys["\"L\""] = 1
    sync_keys["\"<Up>\""] = 1
    sync_keys["\"<Down>\""] = 1
    sync_keys["\"<Left>\""] = 1
    sync_keys["\"<Right>\""] = 1
    sync_keys["\"<PageUp>\""] = 1
    sync_keys["\"<PageDown>\""] = 1

    in_mgr = 0
}

# Track if we'\''re in [mgr] section
/^\[mgr\]/ { in_mgr = 1 }
/^\[/ && !/^\[mgr\]/ { in_mgr = 0 }

# Process keymap lines in [mgr] section
in_mgr && /{ on =/ {
    line = $0

    # Extract the key binding
    if (match(line, /on = (\[.*?\]|"[^"]+"|'\''[^'\'']+'\'')/)) {
        key = substr(line, RSTART+5, RLENGTH-5)

        # Check if this key needs yazibar-sync
        needs_sync = 0
        if (key in sync_keys) {
            needs_sync = 1
        }

        # If it needs sync and has a run command
        if (needs_sync && match(line, /run = ("([^"]|\\")*"|\[.*?\])/)) {
            run_start = RSTART + 6
            run_length = RLENGTH - 6
            run_cmd = substr(line, run_start, run_length)

            # Check if yazibar-sync is already present
            if (index(run_cmd, "yazibar-sync") == 0) {
                # Add yazibar-sync to the run command
                if (substr(run_cmd, 1, 1) == "\"") {
                    # Single command - convert to array
                    cmd = substr(run_cmd, 2, length(run_cmd) - 2)
                    new_run = "[\"" cmd "\", \"plugin yazibar-sync\"]"
                } else if (substr(run_cmd, 1, 1) == "[") {
                    # Already an array - append to it
                    array_content = substr(run_cmd, 2, length(run_cmd) - 2)
                    new_run = "[" array_content ", \"plugin yazibar-sync\"]"
                } else {
                    # Unknown format, keep original
                    new_run = run_cmd
                }

                # Replace the run command in the line
                before_run = substr(line, 1, RSTART - 1)
                after_run = substr(line, run_start + run_length)
                line = before_run "run = " new_run after_run
            }
        }
    }

    print line
    next
}

# Print all other lines as-is
{ print }
' "$MAIN_KEYMAP" > "$OUTPUT_KEYMAP.tmp"

# Add header to the output file
{
    echo "# LEFT SIDEBAR KEYMAP"
    echo "# Auto-generated from: $MAIN_KEYMAP"
    echo "# Generated: $(date)"
    echo "# "
    echo "# This keymap inherits from the main yazi keymap with yazibar-sync integration."
    echo "# Navigation keys (i/k/j/L, arrows, etc.) have 'plugin yazibar-sync' appended"
    echo "# to publish the hovered file path to tmux for right sidebar preview sync."
    echo "#"
    echo "# To regenerate: $SCRIPT_DIR/$(basename "$0")"
    echo ""
    cat "$OUTPUT_KEYMAP.tmp"
} > "$OUTPUT_KEYMAP"

rm "$OUTPUT_KEYMAP.tmp"

echo "✓ Generated: $OUTPUT_KEYMAP"
echo "  Based on: $MAIN_KEYMAP"
echo ""
echo "Next steps:"
echo "  1. Review the generated keymap"
echo "  2. Update yazibar scripts to use: \$CORE_CFG/yazi/conf/sidebar-left"
echo "  3. Test the sidebar with: tmux"
