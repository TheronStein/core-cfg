#!/bin/bash
# =============================================================================
# Menu Settings - Global theme and configuration for all tmux menus
# Location: ~/.tmux/modules/menus/menu-settings.sh
# Usage: source "$TMUX_MENUS/menu-settings.sh" at the top of each menu script
# =============================================================================

# =============================================================================
# POSITION SETTINGS
# =============================================================================
# Position options: C (center), P (pane position), R (right), S (status line)
# Or pixel/percentage values

MENU_POS_X="55"  # Horizontal position
MENU_POS_Y="100" # Vertical position

# =============================================================================
# COLOR PALETTE
# =============================================================================
# Base colors
MENU_BG="#292D3E" # Menu background
MENU_FG="#cdd6f4" # Default text color

# Selection colors
MENU_SELECT_BG="#313244" # Selected item background
MENU_SELECT_FG="#01F9C6" # Selected item foreground

# Title colors (per menu type - can be overridden)
# MENU_TITLE_FG="#e0af68"   # Default title color (gold)
# MENU_TITLE_MAIN="#e0af68" # Main menu title
# MENU_TITLE_TMUX="#e0af68" # Main menu title
MENU_TITLE_FG="#FFD700"   # Default title color (gold)
MENU_TITLE_MAIN="#FFD700" # Main menu title
MENU_TITLE_TMUX="#FFD700" # Main menu title
# MENU_TITLE_TMUX="#7aa2f7"    # Tmux submenu title (blue)
MENU_TITLE_CONFIG="#e0af68"  # Config menu title (gold)
MENU_TITLE_PANE="#89b4fa"    # Pane menu title (light blue)
MENU_TITLE_WINDOW="#bb9af7"  # Window menu title (purple)
MENU_TITLE_SESSION="#9ece6a" # Session menu title (green)
MENU_TITLE_APP="#f7768e"     # App menu title (red/pink)
MENU_TITLE_MODULE="#7dcfff"  # Module menu title (cyan)

# Section separator
MENU_SEPARATOR_FG="#f1fa8c" # Section header color (cyan)
MENU_SEPARATOR_CHAR="━"     # Character for separators

# Border
MENU_BORDER_FG="#01F9C6"   # Border color
MENU_BORDER_LINES="double" # Border line type: single, double, heavy, simple, rounded, padded, none
# MENU_BORDER_LINES="padded" # Border line type: single, double, heavy, simple, rounded, padded, none
# MENU_BORDER_LINES="rounded" # Border line type: single, double, heavy, simple, rounded, padded, none

# Disabled/special states
MENU_DISABLED_FG="#565f89"  # Disabled item color
MENU_WARNING_FG="#f7768e"   # Warning/danger color
MENU_SUCCESS_FG="#9ece6a"   # Success color
MENU_HIGHLIGHT_FG="#bb9af7" # Highlighted text

# =============================================================================
# STYLE STRINGS (computed from colors above)
# =============================================================================
MENU_STYLE="fg=${MENU_FG},bg=${MENU_BG}"
MENU_SELECT_STYLE="fg=${MENU_SELECT_FG},bg=${MENU_SELECT_BG},bold"
MENU_BORDER_STYLE="fg=${MENU_BORDER_FG},bg=${MENU_BG}"

# =============================================================================
# ICONS
# =============================================================================
MENU_ICON_BACK="󰌑"
MENU_ICON_SECTION_L="━━━"
MENU_ICON_SECTION_R="━━━"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Build a styled title string
# Usage: menu_title "Icon" "Text" [color]
menu_title() {
  local icon="$1"
  local text="$2"
  local color="${3:-$MENU_TITLE_FG}"
  echo "#[fg=${color},bold]${icon}  ${text}  ${icon}"
}

# Build a section separator
# Usage: menu_sep "Section Name"
menu_sep() {
  local text="$1"
  echo "#[fg=${MENU_SEPARATOR_FG},bold]${MENU_ICON_SECTION_L} ${text} ${MENU_ICON_SECTION_R}"
}

# Empty separator (just a blank line marker)
menu_blank() {
  echo ""
}

# Build the display-menu command prefix with all styling
# Usage: eval "$(menu_cmd)" followed by menu items
menu_cmd() {
  echo "tmux display-menu -x ${MENU_POS_X} -y ${MENU_POS_Y} -s '${MENU_STYLE}' -H '${MENU_SELECT_STYLE}'"
}

# Full menu with title
# Usage: menu_display "Title" "Icon" [title_color]
menu_display() {
  local title="$1"
  local icon="$2"
  local color="${3:-$MENU_TITLE_FG}"
  echo "tmux display-menu -x ${MENU_POS_X} -y ${MENU_POS_Y} -T \"$(menu_title "$icon" "$title" "$color")\" -s '${MENU_STYLE}' -H '${MENU_SELECT_STYLE}'"
}

# Back button helper
# Usage: menu_back [parent_script]
menu_back() {
  local parent="${1:-main-menu.sh}"
  echo "\"${MENU_ICON_BACK} Back\" Tab \"run-shell '\$TMUX_MENUS/${parent}'\""
}

# =============================================================================
# MENU NAVIGATION HELPERS (from menu-nav.sh integration)
# =============================================================================

# Open submenu with parent tracking
# Usage: om "submenu/path.sh"
om() {
  local submenu="$1"
  if [[ -n "$MENU_NAV" && -x "$MENU_NAV" ]]; then
    "$MENU_NAV" set "$(basename "$submenu")" "${CURRENT_MENU:-main-menu.sh}"
  fi
  echo "run-shell '\$TMUX_MENUS/$submenu'"
}

# Get parent menu
# Usage: PARENT=$(get_parent)
get_parent() {
  local current="${CURRENT_MENU:-$(basename "$0")}"
  local default="${1:-main-menu.sh}"
  if [[ -n "$MENU_NAV" && -x "$MENU_NAV" ]]; then
    "$MENU_NAV" get "$current" "$default"
  else
    echo "$default"
  fi
}

# =============================================================================
# FZF POPUP HELPER
# =============================================================================

# Run FZF picker in popup
# Usage: fzf_popup "picker-script.sh [args]"
fzf_popup() {
  echo "run-shell '\$TMUX_CONF/modules/fzf/pickers/$1'"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Set MENU_NAV path if not already set
MENU_NAV="${MENU_NAV:-$TMUX_MENUS/menu-nav.sh}"

# Export for subshells
export MENU_POS_X MENU_POS_Y
export MENU_BG MENU_FG MENU_SELECT_BG MENU_SELECT_FG
export MENU_TITLE_FG MENU_SEPARATOR_FG MENU_BORDER_FG MENU_BORDER_LINES
export MENU_STYLE MENU_SELECT_STYLE MENU_BORDER_STYLE
