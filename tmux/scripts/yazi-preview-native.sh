#!/usr/bin/env bash
# Yazi preview pane - uses native yazi preview in preview-only mode
# This shows yazi's built-in preview column in the right pane

# Use a separate config that shows only the preview column
export YAZI_CONFIG_HOME="${YAZI_CONFIG_HOME:-$CORE_CFG/yazi}/profiles/sidebar-right"

# Ensure the preview-only config exists
if [ ! -d "$YAZI_CONFIG_HOME" ]; then
    mkdir -p "$YAZI_CONFIG_HOME"

    # Create yazi.toml for preview-only mode (single column)
    cat > "$YAZI_CONFIG_HOME/yazi.toml" <<'EOF'
#:schema ../.schemas/yazi.json

[mgr]
# Preview-only mode: show ONLY the preview column
ratio = [0, 0, 1]
sort_by = "alphabetical"
sort_sensitive = false
sort_reverse = false
sort_dir_first = true
show_hidden = true
show_symlink = true
scrolloff = 5
mouse_events = ["click", "scroll"]  # Allow mouse interaction
title_format = "Yazi Preview"

[preview]
# Enable all preview features
tab_size = 2
max_width = 600
max_height = 900
cache_dir = ""
image_filter = "lanczos3"
image_quality = 90
sixel_fraction = 15
ueberzug_scale = 1
ueberzug_offset = [0, 0, 0, 0]

[opener]
# Disable opening files from preview (read-only)
# Keep empty to prevent accidental opens

EOF

    # Symlink shared configs from main yazi directory
    local YAZI_MAIN="${YAZI_CONFIG_HOME%/profiles/*}"
    ln -sf "$YAZI_MAIN/init.lua" "$YAZI_CONFIG_HOME/init.lua" 2>/dev/null || true
    ln -sf "$YAZI_MAIN/keymap.toml" "$YAZI_CONFIG_HOME/keymap.toml" 2>/dev/null || true
    ln -sf "$YAZI_MAIN/theme.toml" "$YAZI_CONFIG_HOME/theme.toml" 2>/dev/null || true
    ln -sf "$YAZI_MAIN/plugins" "$YAZI_CONFIG_HOME/plugins" 2>/dev/null || true
    ln -sf "$YAZI_MAIN/flavors" "$YAZI_CONFIG_HOME/flavors" 2>/dev/null || true
fi

# Get the starting directory
START_DIR="${1:-$PWD}"

# Run yazi in preview-only mode (single column = preview only)
# With ratio [0, 0, 1], yazi shows ONLY the preview pane
# Navigate in this pane to see previews, or it can follow the sidebar via DDS

# The preview column will show:
# - Images (kitty/sixel/inline protocol)
# - Videos (thumbnails/metadata)
# - Text files (syntax highlighted)
# - Archives (contents)
# - PDFs (if supported)
# - And all other yazi preview features

exec yazi "$START_DIR"
