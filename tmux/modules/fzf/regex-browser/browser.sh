#!/usr/bin/env bash
# Regex Cheatsheet Viewer with FZF

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
CATEGORIES_FILE="$DATA_DIR/regex_categories.json"

# Ensure dependencies
for cmd in fzf jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done

# Check if data exists
if [[ ! -f "$CATEGORIES_FILE" ]]; then
  echo "Error: Categories file not found: $CATEGORIES_FILE"
  echo "Please create the JSON file with regex data (see documentation)."
  exit 1
fi

# Browse categories
browse_categories() {
  jq -r '.categories[] | "\(.name)|\(.icon_name)|\(.description)|\(.count)"' "$CATEGORIES_FILE" \
    | while IFS='|' read -r name icon_name desc count; do
      # Use | as delimiter so we can extract exact name
      printf "%s | %s (%d)\n" "$name" "$desc" "$count"
    done \
    | fzf \
      --ansi \
      --height=100% \
      --layout=reverse \
      --border=rounded \
      --border-label="╣ Regex Cheatsheet Categories ╠" \
      --prompt="Category ❯ " \
      --pointer="▶" \
      --marker="✓" \
      --delimiter=' | ' \
      --with-nth=1,2 \
      --header=$'Navigate: ↑↓ PageUp/PageDown | Select: Enter | Quit: Esc | Open MD: Ctrl-O\n─────────────────────────────────────────' \
      --preview="$SCRIPT_DIR/preview.sh category {}" \
      --preview-window=right:60%:wrap:rounded \
      --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
      --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
      --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
      --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
      --bind="ctrl-/:toggle-preview" \
      --bind="ctrl-o:execute( category=\$(echo {} | cut -d' | ' -f1); file=\$(jq -r --arg name \"\$category\" '.categories[] | select(.name == \$name) | .file' \"$CATEGORIES_FILE\"); md=\"\${file%.txt}.md\"; \${MARKDOWN_VIEWER:-neovim} \"$DATA_DIR/\$md\" )+abort"
}

# Browse items within a category
browse_items() {
  local category_name="$1"
  local file_name="$2"
  local file_path="$DATA_DIR/$file_name"

  if [[ ! -f "$file_path" ]]; then
    echo "Error: File not found: $file_path" >&2
    return 1
  fi

  # Read item names and show pattern + name (short_desc)
  grep -v '^#' "$file_path" | grep -v '^$' \
    | while read -r item_line; do
      IFS=$'\t' read -r pattern name short_desc _ _ <<<"$item_line"
      printf "%s  %s (%s)\n" "$pattern" "$name" "$short_desc"
    done \
    | fzf \
      --ansi \
      --height=100% \
      --layout=reverse \
      --border=rounded \
      --border-label="╣ $category_name ╠" \
      --prompt="Item ❯ " \
      --pointer="▶" \
      --marker="✓" \
      --header=$'Select: Enter (copy pattern) | Back: Esc/Alt+← | Preview: Ctrl-/ | Open MD: Ctrl-O | PageUp/PageDown\n─────────────────────────────────────────' \
      --preview="$SCRIPT_DIR/regex-preview.sh item {}" \
      --preview-window=right:60%:wrap:rounded \
      --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
      --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
      --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
      --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
      --bind="ctrl-/:toggle-preview" \
      --bind="alt-left:abort" \
      --bind="ctrl-o:execute( file=\$(jq -r --arg name \"$category_name\" '.categories[] | select(.name == \$name) | .file' \"$CATEGORIES_FILE\"); md=\"\${file%.txt}.md\"; \${MARKDOWN_VIEWER:-neovim} \"$DATA_DIR/\$md\" )+abort" \
      --bind="enter:execute-silent($SCRIPT_DIR/copy-pattern.sh {})+accept"
}

# Main loop
main() {
  while true; do
    # Browse categories
    selected=$(browse_categories)

    if [[ -z "$selected" ]]; then
      break
    fi

    # Extract category name (field 1 with delimiter ' | ')
    category_name=$(echo "$selected" | cut -d'|' -f1 | xargs)

    # Get file name from JSON
    file_name=$(jq -r --arg name "$category_name" \
      '.categories[] | select(.name == $name) | .file' "$CATEGORIES_FILE")

    if [[ -z "$file_name" ]]; then
      echo "Error: Could not find file for category: '$category_name'" >&2
      sleep 2
      continue
    fi

    # Browse items in selected category (allow abort without exiting script)
    item_result=$(browse_items "$category_name" "$file_name" || true)

    if [[ -n "$item_result" ]]; then
      # Item was selected and pattern copied, exit the browser
      break
    fi
  done
}

main
