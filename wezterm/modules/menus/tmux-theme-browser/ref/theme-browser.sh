#!/bin/bash
# ~/.core/.sys/configs/wezterm/scripts/theme-browser.sh
# Enhanced WezTerm Theme Browser with live preview and session persistence

set -e

# Configuration paths
WEZTERM_DATA="$HOME/.core/.sys/configs/wezterm/data"
WEZTERM_SESSIONS="$HOME/.core/.sys/configs/wezterm/sessions"
THEMES_JSON="$WEZTERM_DATA/themes.json"
FAVORITES_JSON="$WEZTERM_DATA/themes_favorite.json"
DELETED_JSON="$WEZTERM_DATA/themes_deleted.json"
EXPORT_JSON="/tmp/wezterm_themes_export.json"

# Get tmux session for preview file
CURRENT_SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo "default")
PREVIEW_FILE="/tmp/wezterm_preview_${CURRENT_SESSION}.txt"
SELECTION_FILE="/tmp/wezterm_selected_theme.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Current state
FILTER_CATEGORY=""
SHOW_DELETED=false

# Initialize
init() {
    # Ensure directories exist
    mkdir -p "$WEZTERM_DATA"
    mkdir -p "$WEZTERM_SESSIONS"

    # Initialize preview file with INIT marker
    echo "INIT" >"$PREVIEW_FILE"

    # Check if theme data exists
    if [[ ! -f "$THEMES_JSON" ]]; then
        echo -e "${YELLOW}Initializing theme data for first time...${NC}" >&2

        # Run initialization script
        if command -v wezterm >/dev/null 2>&1; then
            wezterm --config-file "$HOME/.core/.sys/configs/wezterm/scripts/init-themes.lua" >/dev/null 2>&1 || {
                # Fallback: run as lua script
                lua "$HOME/.core/.sys/configs/wezterm/scripts/init-themes.lua" 2>/dev/null || {
                    echo -e "${RED}Failed to initialize theme data!${NC}" >&2
                    echo -e "${YELLOW}Creating manual theme export...${NC}" >&2

                    # Create a basic export file manually
                    create_manual_export
                }
            }
        else
            echo -e "${RED}WezTerm not found in PATH!${NC}" >&2
            create_manual_export
        fi
    fi

    # Initialize JSON files if they don't exist
    [[ ! -f "$FAVORITES_JSON" ]] && echo "{}" >"$FAVORITES_JSON"
    [[ ! -f "$DELETED_JSON" ]] && echo "{}" >"$DELETED_JSON"

    # Get current tmux session
    CURRENT_SESSION=$(tmux display-message -p '#S' 2>/dev/null || echo "default")

    # Export themes if needed
    if [[ -f "$THEMES_JSON" ]] && [[ ! -f "$EXPORT_JSON" ]]; then
        create_export_from_themes
    fi

    # Final check
    if [[ ! -f "$EXPORT_JSON" ]] && [[ ! -f "$THEMES_JSON" ]]; then
        echo -e "${RED}No theme data available!${NC}" >&2
        echo -e "${YELLOW}Please run: lua ~/.core/.sys/configs/wezterm/scripts/init-themes.lua${NC}" >&2
        exit 1
    fi

    echo -e "${GREEN}Theme browser initialized for session: ${CYAN}$CURRENT_SESSION${NC}" >&2
}

# Create manual export for basic functionality
create_manual_export() {
    # Get theme list from WezTerm if possible
    local theme_list=""

    if command -v wezterm >/dev/null 2>&1; then
        # Try to get themes from wezterm
        theme_list=$(wezterm ls-color-schemes 2>/dev/null | head -100) || true
    fi

    if [[ -z "$theme_list" ]]; then
        # Use a basic set of common themes
        theme_list="Tokyo Night
Dracula
Gruvbox Dark
Nord
Solarized Dark
Solarized Light
One Dark
Catppuccin Mocha
Catppuccin Latte
Rose Pine
Material
Palenight
Ayu Dark
Ayu Light"
    fi

    # Create basic export
    echo '{
  "themes": [' >"$EXPORT_JSON"

    local first=true
    while IFS= read -r theme; do
        [[ -z "$theme" ]] && continue

        if [[ "$first" == "false" ]]; then
            echo "," >>"$EXPORT_JSON"
        fi
        first=false

        # Guess category from name
        local category="dark"
        if echo "$theme" | grep -qiE "light|latte|dawn|day|paper"; then
            category="light"
        fi

        cat >>"$EXPORT_JSON" <<EOF
    {
      "name": "$theme",
      "category": "$category",
      "brightness": 128,
      "temperature": "neutral",
      "is_favorite": false,
      "tags": []
    }
EOF
    done <<<"$theme_list"

    echo '
  ],
  "favorites": {},
  "deleted": {},
  "current_session": "'$CURRENT_SESSION'",
  "current_theme": null
}' >>"$EXPORT_JSON"

    echo -e "${GREEN}Created basic theme export${NC}" >&2
}

# Create export from existing themes.json
create_export_from_themes() {
    if [[ ! -f "$THEMES_JSON" ]]; then
        return 1
    fi

    # Use jq to create simplified export
    jq --arg session "$CURRENT_SESSION" '{
        themes: [.themes[] | {
            name: .name,
            category: .metadata.category,
            brightness: .metadata.brightness,
            temperature: .metadata.temperature,
            is_favorite: false,
            tags: .tags
        }],
        favorites: {},
        deleted: {},
        current_session: $session,
        current_theme: null
    }' "$THEMES_JSON" >"$EXPORT_JSON" 2>/dev/null || {
        echo -e "${YELLOW}Failed to parse themes.json, creating basic export${NC}" >&2
        create_manual_export
    }
}

# Load theme data
load_themes() {
    if [[ -f "$EXPORT_JSON" ]]; then
        jq -r '.themes[] | "\(.name)|\(.category)|\(.brightness)|\(.temperature)|\(.is_favorite)"' "$EXPORT_JSON" 2>/dev/null
    elif [[ -f "$THEMES_JSON" ]]; then
        # Fallback to direct reading
        jq -r '.themes[] | "\(.name)|\(.metadata.category)|\(.metadata.brightness)|\(.metadata.temperature)|false"' "$THEMES_JSON" 2>/dev/null
    else
        echo -e "${RED}No theme data found!${NC}" >&2
        return 1
    fi
}

# Load favorites
load_favorites() {
    if [[ -f "$FAVORITES_JSON" ]]; then
        jq -r 'keys[]' "$FAVORITES_JSON" 2>/dev/null
    fi
}

# Load deleted themes
load_deleted() {
    if [[ -f "$DELETED_JSON" ]]; then
        jq -r 'keys[]' "$DELETED_JSON" 2>/dev/null
    fi
}

# Check if theme is favorite
is_favorite() {
    local theme="$1"
    jq -e ".[\"$theme\"]" "$FAVORITES_JSON" >/dev/null 2>&1
}

# Check if theme is deleted
is_deleted() {
    local theme="$1"
    jq -e ".[\"$theme\"]" "$DELETED_JSON" >/dev/null 2>&1
}

# Toggle favorite status
toggle_favorite() {
    local theme="$1"

    if is_favorite "$theme"; then
        # Remove from favorites
        jq "del(.[\"$theme\"])" "$FAVORITES_JSON" >"${FAVORITES_JSON}.tmp"
        mv "${FAVORITES_JSON}.tmp" "$FAVORITES_JSON"
        echo -e "${YELLOW}☆ Removed from favorites: $theme${NC}" >&2
    else
        # Add to favorites
        jq ". + {\"$theme\": true}" "$FAVORITES_JSON" >"${FAVORITES_JSON}.tmp"
        mv "${FAVORITES_JSON}.tmp" "$FAVORITES_JSON"
        echo -e "${GREEN}★ Added to favorites: $theme${NC}" >&2
    fi
}

# Delete/undelete theme
toggle_delete() {
    local theme="$1"

    if is_deleted "$theme"; then
        # Undelete theme
        jq "del(.[\"$theme\"])" "$DELETED_JSON" >"${DELETED_JSON}.tmp"
        mv "${DELETED_JSON}.tmp" "$DELETED_JSON"
        echo -e "${GREEN}✓ Restored: $theme${NC}" >&2
    else
        # Delete theme
        jq ". + {\"$theme\": {\"deleted_at\": \"$(date -Iseconds)\"}}" "$DELETED_JSON" >"${DELETED_JSON}.tmp"
        mv "${DELETED_JSON}.tmp" "$DELETED_JSON"
        echo -e "${RED}🗑 Deleted: $theme${NC}" >&2
    fi
}

# Apply theme preview - CRITICAL FUNCTION
apply_preview() {
    local theme="$1"
    [[ -z "$theme" ]] && return

    # Write theme name to preview file for WezTerm watcher
    echo "$theme" >"$PREVIEW_FILE"

    # Force sync to ensure file is written
    sync

    # Log for debugging
    echo "Preview: $theme" >&2
}

apply_to_session() {
    local theme="$1"
    local session="${2:-$CURRENT_SESSION}"

    [[ -z "$theme" ]] && return

    if [[ -n "$session" ]]; then
        # Save to global tmux session location
        local session_file="$HOME/.core/.sys/configs/sessions/tmux/${session}.lua"

        cat >"$session_file" <<EOF
-- Tmux session configuration: $session
-- Type: tmux
-- Generated: $(date '+%Y-%m-%d %H:%M:%S')

return {
    color_scheme = "$theme",
}
EOF

        echo -e "${GREEN}✔ Applied '$theme' to tmux session '$session'${NC}" >&2
    else
        echo -e "${YELLOW}⚠ No tmux session detected${NC}" >&2
    fi
}

# Generate list for fzf
generate_list() {
    local themes_data=$(load_themes)
    local line_num=1

    while IFS='|' read -r name category brightness temperature is_fav; do
        [[ -z "$name" ]] && continue

        # Skip deleted themes unless showing them
        if [[ "$SHOW_DELETED" == "false" ]] && is_deleted "$name"; then
            continue
        fi

        # Apply category filter
        if [[ -n "$FILTER_CATEGORY" ]] && [[ "$category" != "$FILTER_CATEGORY" ]]; then
            continue
        fi

        # Build status indicators
        local status=""
        is_favorite "$name" && status="★"
        is_deleted "$name" && status="${status}🗑"

        # Category icon
        local cat_icon=""
        case "$category" in
        light) cat_icon="☀" ;;
        dark) cat_icon="🌙" ;;
        high-contrast) cat_icon="🔲" ;;
        pastel) cat_icon="🎨" ;;
        esac

        # Temperature indicator
        local temp_icon=""
        case "$temperature" in
        warm) temp_icon="🔥" ;;
        cool) temp_icon="❄️" ;;
        neutral) temp_icon="⚪" ;;
        esac

        # Format: line_num|status|category|name|brightness|temperature
        printf "%d|%s|%s %s|%s|%s|%s\n" \
            "$line_num" "$status" "$cat_icon" "$category" "$name" "$brightness" "$temp_icon"

        ((line_num++))
    done <<<"$themes_data"
}

# Preview generator for fzf preview window
generate_preview() {
    local selection="$1"
    local name=$(echo "$selection" | cut -d'|' -f5)

    [[ -z "$name" ]] && return

    # Apply the preview immediately
    apply_preview "$name"

    echo "═══════════════════════════════════════"
    echo "  Theme: $name"
    echo "═══════════════════════════════════════"
    echo ""
    echo "  Session: $CURRENT_SESSION"

    is_favorite "$name" && echo "  Status: ★ Favorited" || echo "  Status: Not favorited"
    is_deleted "$name" && echo "  Deleted: Yes 🗑"

    echo ""
    echo "  Category: $(echo "$selection" | cut -d'|' -f3)"
    echo "  Brightness: $(echo "$selection" | cut -d'|' -f6)"
    echo "  Temperature: $(echo "$selection" | cut -d'|' -f7)"
    echo ""
    echo "  Controls:"
    echo "  Ctrl+F - Toggle favorite"
    echo "  Ctrl+D - Toggle delete"
    echo "  Ctrl+A - Apply to session"
    echo "  Enter  - Select and apply"
    echo "═══════════════════════════════════════"
}

# Main browser
main() {
    init

    # Header
    cat <<HEADER
🎨 WezTerm Theme Browser - Session: ${CYAN}$CURRENT_SESSION${NC}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
↑↓ Navigate │ Ctrl+F Favorite │ Ctrl+D Delete │ Ctrl+A Apply
Ctrl+L Light │ Ctrl+K Dark │ Ctrl+R Show Deleted │ Enter Select
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HEADER

    # Export functions for fzf to use
    export -f load_themes load_favorites load_deleted
    export -f is_favorite is_deleted
    export -f toggle_favorite toggle_delete
    export -f apply_preview apply_to_session
    export -f generate_list generate_preview
    export CURRENT_SESSION WEZTERM_DATA WEZTERM_SESSIONS PREVIEW_FILE
    export FAVORITES_JSON DELETED_JSON THEMES_JSON EXPORT_JSON
    export RED GREEN YELLOW BLUE MAGENTA CYAN WHITE NC
    export FILTER_CATEGORY SHOW_DELETED

    # Run fzf with enhanced features
    local selected
    selected=$(
        generate_list | fzf \
            --height=100% \
            --layout=reverse \
            --border=none \
            --with-nth=2.. \
            --delimiter='|' \
            --ansi \
            --cycle \
            --prompt="🎨 Theme: " \
            --pointer="▶" \
            --marker="●" \
            --preview-window='right:40%:wrap' \
            --preview='bash -c "generate_preview \"{}\""' \
            --bind="ctrl-f:execute(bash -c 'theme=\"\$(echo {} | cut -d\"|\" -f5)\"; toggle_favorite \"\$theme\"')+reload(bash -c 'generate_list')" \
            --bind="ctrl-d:execute(bash -c 'theme=\"\$(echo {} | cut -d\"|\" -f5)\"; toggle_delete \"\$theme\"')+reload(bash -c 'generate_list')" \
            --bind="ctrl-a:execute(bash -c 'theme=\"\$(echo {} | cut -d\"|\" -f5)\"; apply_to_session \"\$theme\"')" \
            --bind='ctrl-l:reload(FILTER_CATEGORY=light generate_list)' \
            --bind='ctrl-k:reload(FILTER_CATEGORY=dark generate_list)' \
            --bind='ctrl-r:reload(SHOW_DELETED=true generate_list)' \
            --bind='ctrl-/:toggle-preview'
    ) || true

    # Process selection
    if [[ -n "$selected" ]]; then
        local theme_name=$(echo "$selected" | cut -d'|' -f5)
        echo -e "\n${GREEN}✅ Selected: $theme_name${NC}"
        echo "$theme_name" >"$SELECTION_FILE"

        # Apply to session
        apply_to_session "$theme_name"
    else
        echo -e "\n${YELLOW}❌ Cancelled${NC}"
        echo "CANCEL" >"$SELECTION_FILE"
        # Reset preview
        echo "CANCEL" >"$PREVIEW_FILE"
    fi

    # Cleanup preview file after a delay
    (sleep 2 && echo "" >"$PREVIEW_FILE") &
}

# Run main
main "$@"
