#!/bin/bash
# Theme switcher for TMUX menu themes

THEMES_DIR="$HOME/.core/.sys/cfg/tmux/conf/themes"
CURRENT_THEME_FILE="$HOME/.local/state/tmux/current-menu-theme"

# Get list of available themes
get_themes() {
  find "$THEMES_DIR" -name "*.conf" -type f | sort | while read -r theme_file; do
    basename "$theme_file" .conf
  done
}

# Get current theme
get_current_theme() {
  if [[ -f "$CURRENT_THEME_FILE" ]]; then
    cat "$CURRENT_THEME_FILE"
  else
    echo "chaoscore"
  fi
}

# Set theme
set_theme() {
  local theme="$1"
  local theme_file="$THEMES_DIR/${theme}.conf"

  if [[ ! -f "$theme_file" ]]; then
    echo "Error: Theme '$theme' not found"
    return 1
  fi

  # Save current theme
  mkdir -p "$(dirname "$CURRENT_THEME_FILE")"
  echo "$theme" > "$CURRENT_THEME_FILE"

  # Source the theme file
  tmux source-file "$theme_file"

  echo "Switched to theme: $theme"
}

# Interactive menu
show_menu() {
  local current_theme=$(get_current_theme)

  # Build menu items
  local menu_items=()
  while IFS= read -r theme; do
    local marker=""
    [[ "$theme" == "$current_theme" ]] && marker=" ●"
    menu_items+=("$theme$marker" "" "run-shell '$0 set $theme'")
  done < <(get_themes)

  tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] Theme Selector " \
    "${menu_items[@]}"
}

# Preview theme colors
preview_theme() {
  local theme="$1"
  local theme_file="$THEMES_DIR/${theme}.conf"

  if [[ ! -f "$theme_file" ]]; then
    echo "Theme not found: $theme"
    return 1
  fi

  # Extract colors and display preview
  echo "Theme: $theme"
  echo "----------------------------------------"
  grep -E "set -g menu-" "$theme_file" | while read -r line; do
    echo "  $line"
  done
}

# Main command dispatcher
case "${1:-menu}" in
  list)
    get_themes
    ;;
  current)
    get_current_theme
    ;;
  set)
    set_theme "$2"
    ;;
  preview)
    preview_theme "$2"
    ;;
  menu|*)
    show_menu
    ;;
esac
