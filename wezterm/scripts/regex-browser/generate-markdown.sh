#!/usr/bin/env bash
# Script to generate Markdown files from txt data

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
CATEGORIES_FILE="$DATA_DIR/regex_categories.json"

# Generate MD for each category
jq -r '.categories[] | .file' "$CATEGORIES_FILE" | while read -r file; do
  if [[ -z "$file" ]]; then continue; fi
  file_path="$DATA_DIR/$file"
  if [[ ! -f "$file_path" ]]; then
    echo "Warning: File not found: $file_path" >&2
    continue
  fi

  category_name=$(jq -r --arg f "$file" '.categories[] | select(.file == $f) | .name' "$CATEGORIES_FILE")
  description=$(jq -r --arg f "$file" '.categories[] | select(.file == $f) | .description' "$CATEGORIES_FILE")

  md_file="$DATA_DIR/${file%.txt}.md"

  echo "# $category_name" >"$md_file"
  echo "" >>"$md_file"
  echo "$description" >>"$md_file"
  echo "" >>"$md_file"

  grep -v '^#' "$file_path" | grep -v '^$' | while read -r item_line; do
    IFS=$'\t' read -r pattern name short_desc full_explanation example <<<"$item_line"
    echo "## $pattern - $name" >>"$md_file"
    echo "" >>"$md_file"
    echo "**Short Description:** $short_desc" >>"$md_file"
    echo "" >>"$md_file"
    echo "**Explanation:**" >>"$md_file"
    echo "$full_explanation" >>"$md_file"
    echo "" >>"$md_file"
    echo "**Example:**" >>"$md_file"
    echo "\`\`\`" >>"$md_file"
    echo "$example" >>"$md_file"
    echo "\`\`\`" >>"$md_file"
    echo "" >>"$md_file"
  done
  echo "Generated: $md_file"
done
