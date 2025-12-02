#!/usr/bin/env bash
# Preview script for tab color browser

set -euo pipefail

COLOR_HEX="${1:-#89b4fa}"
TAB_TITLE="${2:-Tab}"
TAB_ICON="${3:-}"
TMUX_WORKSPACE="${4:-}"

# Function to convert hex to RGB
hex_to_rgb() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "$r;$g;$b"
}

# Function to dim a color (for inactive tabs)
dim_color() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    # Reduce brightness by 40%
    r=$((r * 60 / 100))
    g=$((g * 60 / 100))
    b=$((b * 60 / 100))

    printf "#%02x%02x%02x" "$r" "$g" "$b"
}

# Function to determine if background needs dark text
needs_dark_text() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    # Calculate perceived brightness
    local brightness=$(( (r * 299 + g * 587 + b * 114) / 1000 ))

    [[ $brightness -gt 128 ]]
}

# Handle special CLEAR case
if [[ "$COLOR_HEX" == "CLEAR" ]]; then
    echo "╔════════════════════════════════════════╗"
    echo "║     DEFAULT MODE COLOR (NO OVERRIDE)   ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "This will use the default WezTerm mode color"
    echo "for the tab, which changes based on the"
    echo "current mode (normal, copy, search, etc.)"
    echo ""
    echo "Example:"
    echo "  • Normal mode: Cyan (#01F9C6)"
    echo "  • Copy mode: Orange (#FFB86C)"
    echo "  • Search mode: Yellow (#F1FA8C)"
    exit 0
fi

# Get RGB values
RGB=$(hex_to_rgb "$COLOR_HEX")
DIMMED_HEX=$(dim_color "$COLOR_HEX")
DIMMED_RGB=$(hex_to_rgb "$DIMMED_HEX")

# Determine text color
if needs_dark_text "$COLOR_HEX"; then
    FG_ACTIVE="30;30;46"  # Dark gray
    FG_INACTIVE="30;30;46"
else
    FG_ACTIVE="186;194;222"  # Light blue-gray
    FG_INACTIVE="186;194;222"
fi

# Background color for tab bar
BG_BAR="41;45;62"  # Dark background

# Icon and title
DISPLAY_TEXT="${TAB_ICON:+$TAB_ICON  }$TAB_TITLE"

echo "╔════════════════════════════════════════╗"
echo "║           TAB COLOR PREVIEW            ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Color: $COLOR_HEX"
echo "Dimmed: $DIMMED_HEX"
echo ""

# Show TMUX override warning if applicable
if [[ -n "$TMUX_WORKSPACE" ]]; then
    echo "⚠️  TMUX WORKSPACE OVERRIDE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "This tab is in tmux workspace:"
    echo "  $TMUX_WORKSPACE"
    echo ""
    echo "The workspace color will OVERRIDE this"
    echo "custom color when attached to tmux."
    echo ""
fi

echo "ACTIVE TAB PREVIEW:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Active tab with color
printf "\e[48;2;%sm\e[38;2;%sm %s \e[0m" "$BG_BAR" "$BG_BAR" ""
printf "\e[38;2;%sm\e[48;2;%sm\e[0m" "$RGB" "$BG_BAR" ""
printf "\e[38;2;%sm\e[48;2;%sm %s \e[0m" "$FG_ACTIVE" "$RGB" "$DISPLAY_TEXT"
printf "\e[38;2;%sm\e[48;2;%sm\e[0m" "$RGB" "$BG_BAR" ""
printf "\e[48;2;%sm\e[38;2;%sm \e[0m\n" "$BG_BAR" "$BG_BAR" ""

echo ""
echo "INACTIVE TAB PREVIEW:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Inactive tab with dimmed color
printf "\e[48;2;%sm\e[38;2;%sm %s \e[0m" "$BG_BAR" "$BG_BAR" ""
printf "\e[38;2;%sm\e[48;2;%sm\e[0m" "$DIMMED_RGB" "$BG_BAR" ""
printf "\e[38;2;%sm\e[48;2;%sm %s \e[0m" "$FG_INACTIVE" "$DIMMED_RGB" "$DISPLAY_TEXT"
printf "\e[38;2;%sm\e[48;2;%sm\e[0m" "$DIMMED_RGB" "$BG_BAR" ""
printf "\e[48;2;%sm\e[38;2;%sm \e[0m\n" "$BG_BAR" "$BG_BAR" ""

echo ""
echo "HOW IT WORKS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "• Active tabs: Full color brightness"
echo "• Inactive tabs: 60% dimmed"
echo "• Text color: Auto-adjusted for readability"
echo ""

if [[ -z "$TMUX_WORKSPACE" ]]; then
    echo "PRIORITY:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. Custom tab color (this color)"
    echo "2. Default mode color (if no custom)"
else
    echo "PRIORITY:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. Tmux workspace color (HIGHEST)"
    echo "2. Custom tab color (OVERRIDDEN)"
    echo "3. Default mode color (fallback)"
fi
