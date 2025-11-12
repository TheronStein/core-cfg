#!/usr/bin/env bash
# Preview generator for Regex Cheatsheet Viewer

set -euo pipefail

MODE="${1:-category}"
ITEM="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

# Markdown renderer - use glow if available, else cat
MD_RENDERER="cat -"
if command -v glow &>/dev/null; then
  MD_RENDERER="glow -s dark --width 70 -"
fi

# Color definitions (fallback if no glow)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BRIGHT_CYAN='\033[0;96m'
BRIGHT_WHITE='\033[0;97m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
RESET='\033[0m'

# Get detailed info for a specific item from its data file
get_item_details() {
  local category_file="$1"
  local pattern="$2"
  # Search for the line starting with the pattern (escape special chars if needed, but for simplicity assume unique)
  grep "^${pattern//\\/\\\\}" "$category_file" || echo ""
}

# Show category preview in Markdown format
show_category_preview() {
  local full_line="$1"
  # Extract category name (everything before ' | ')
  local category_name="${full_line%% | *}"
  local json_file="$DATA_DIR/regex_categories.json"

  local category_info=$(jq -r --arg name "$category_name" \
    '.categories[] | select(.name == $name)' "$json_file" 2>/dev/null)

  if [[ -z "$category_info" ]]; then
    echo -e "${RED}Category not found: $category_name${RESET}"
    return 1
  fi

  local file=$(echo "$category_info" | jq -r '.file')
  local description=$(echo "$category_info" | jq -r '.description')
  local count=$(echo "$category_info" | jq -r '.count')
  local icon_name=$(echo "$category_info" | jq -r '.icon_name') # Optional, can be empty

  # Build Markdown content
  local md="# ${icon_name:-} $category_name

$description

**Total Items:** $count  
**Source File:** $file

### Sample Items

"

  # Show first 20 items from this category using the data file
  local file_path="$DATA_DIR/$file"

  if [[ -f "$file_path" ]]; then
    # Get items, skip comments and empty lines, take first 20
    grep -v '^#' "$file_path" | grep -v '^$' | head -20 | while read -r item_line; do
      IFS=$'\t' read -r pattern name short_desc <<<"$item_line"
      md+="- \`$pattern\` : $name - $short_desc\n"
    done
  fi

  md+="

*Press ENTER to browse items • ESC to go back*"

  # Render MD
  echo -e "$md" | $MD_RENDERER
}

# Show item preview in Markdown format
show_item_preview() {
  local full_line="$1"

  # Parse the line: format is "pattern  name (short_desc)"
  # Extract pattern (first field)
  local pattern=$(echo "$full_line" | awk '{print $1}')
  # Extract name (second field)
  local name=$(echo "$full_line" | awk '{print $2}')
  # Extract short_desc (everything after name)
  local short_desc=$(echo "$full_line" | sed 's/^[^ ]*  [^ ]* (//' | sed 's/)$//')

  # Find the category by searching JSON for the file containing this item
  local category_name="Unknown Category"
  local category_desc=""
  local file=""
  local json_file="$DATA_DIR/regex_categories.json"
  for cat_file in $(jq -r '.categories[].file' "$json_file"); do
    if grep -q "^${pattern//\\/\\\\}" "$DATA_DIR/$cat_file"; then
      file="$cat_file"
      category_name=$(jq -r --arg f "$cat_file" '.categories[] | select(.file == $f) | .name' "$json_file")
      category_desc=$(jq -r --arg f "$cat_file" '.categories[] | select(.file == $f) | .description' "$json_file")
      break
    fi
  done

  # Get full details from the category file (assume extended format in file: pattern<TAB>name<TAB>short_desc<TAB>full_explanation<TAB>example)
  local item_details=$(get_item_details "$DATA_DIR/$file" "$pattern")
  IFS=$'\t' read -r _ _ _ full_explanation example <<<"$item_details"

  # Build Markdown content
  local md="# $pattern - $name

**Category:** $category_name  
**Short Desc:** $short_desc  

**Explanation:**  
$full_explanation

**Example:**  
\`\`\`
$example
\`\`\`

### Actions
*Press ENTER to copy pattern • ESC to go back*"

  # Render MD
  echo -e "$md" | $MD_RENDERER
}

# Main logic
case "$MODE" in
  category)
    show_category_preview "$ITEM"
    ;;
  item)
    show_item_preview "$ITEM"
    ;;
  *)
    echo "Invalid mode: $MODE"
    exit 1
    ;;
esac
