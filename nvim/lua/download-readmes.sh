#!/usr/bin/env bash
# download-readmes.sh
# Downloads README.md files from GitHub repositories listed in a file
# Usage: ./download-readmes.sh <source_file>
# Example: ./download-readmes.sh terminal.md

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if source file is provided
if [[ $# -lt 1 ]]; then
    echo -e "${RED}Error: Please provide a source file${NC}"
    echo "Usage: $0 <source_file>"
    echo "Example: $0 terminal.md"
    exit 1
fi

SOURCE_FILE="$1"

# Check if source file exists
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo -e "${RED}Error: File '$SOURCE_FILE' not found${NC}"
    exit 1
fi

# Extract the base filename without extension
SOURCE_BASENAME=$(basename "$SOURCE_FILE" .md)

# Set up paths
CORE_SYS="${CORE_SYS:-$HOME/.core/.sys/cfg}"
DOCS_DIR="${CORE_SYS}/nvim/docs"
PLUGINS_MD="${DOCS_DIR}/plugins.md"
PLUGINS_DIR="${DOCS_DIR}/plugins"

# Create output directory in the docs/plugins folder
OUTPUT_DIR="${PLUGINS_DIR}/${SOURCE_BASENAME}"
mkdir -p "$OUTPUT_DIR"

# Track successful downloads for index generation
declare -a DOWNLOADED_REPOS
declare -A SEEN_REPOS

echo -e "${GREEN}Downloading READMEs from repositories in: $SOURCE_FILE${NC}"
echo -e "${GREEN}Output directory: $OUTPUT_DIR${NC}"
echo ""

# Counter for statistics
TOTAL=0
SUCCESS=0
FAILED=0

# Read each line from the source file
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Extract GitHub URL from the line
    # Handles formats like:
    # - https://github.com/user/repo
    # - github.com/user/repo
    # - user/repo
    # - [text](https://github.com/user/repo)

    # Try to extract from markdown link format first
    if [[ "$line" =~ \[.*\]\((.*)\) ]]; then
        url="${BASH_REMATCH[1]}"
    else
        url="$line"
    fi

    # Remove query parameters and anchors from URL
    url="${url%%\?*}"
    url="${url%%\#*}"

    # Extract owner/repo from various URL formats
    if [[ "$url" =~ github\.com/([^/]+)/([^/[:space:]]+) ]]; then
        owner="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    elif [[ "$url" =~ ^([^/]+)/([^/[:space:]]+)$ ]]; then
        # Handle shorthand format: owner/repo
        owner="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    else
        echo -e "${YELLOW}⚠ Skipping invalid format: $line${NC}"
        continue
    fi

    # Clean up repo name (remove .git, trailing slashes, etc)
    repo="${repo%.git}"
    repo="${repo%/}"

    # Skip if this is not a real repository (e.g., just a fragment link)
    if [[ -z "$owner" || -z "$repo" ]]; then
        continue
    fi

    # Skip if we've already processed this repo
    repo_key="${owner}/${repo}"
    if [[ -n "${SEEN_REPOS[$repo_key]:-}" ]]; then
        continue
    fi
    SEEN_REPOS[$repo_key]=1

    TOTAL=$((TOTAL + 1))

    # Construct raw GitHub URL for README.md
    README_URL="https://raw.githubusercontent.com/${owner}/${repo}/master/README.md"
    README_URL_MAIN="https://raw.githubusercontent.com/${owner}/${repo}/main/README.md"

    OUTPUT_FILE="${OUTPUT_DIR}/${repo}.md"

    echo -n "Downloading ${owner}/${repo}... "

    # Try master branch first, then main branch
    if curl -sf -o "$OUTPUT_FILE" "$README_URL" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        SUCCESS=$((SUCCESS + 1))
        DOWNLOADED_REPOS+=("${owner}/${repo}")
    elif curl -sf -o "$OUTPUT_FILE" "$README_URL_MAIN" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        SUCCESS=$((SUCCESS + 1))
        DOWNLOADED_REPOS+=("${owner}/${repo}")
    else
        echo -e "${RED}✗ (README not found)${NC}"
        FAILED=$((FAILED + 1))
        # Remove empty file if created
        [[ -f "$OUTPUT_FILE" ]] && rm -f "$OUTPUT_FILE"
    fi

done < "$SOURCE_FILE"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Summary:${NC}"
echo -e "  Total repositories: $TOTAL"
echo -e "  ${GREEN}Successful: $SUCCESS${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Generate/Update plugins.md index file
echo ""
echo -e "${GREEN}Updating plugins index...${NC}"

# Create docs directory if it doesn't exist
mkdir -p "$DOCS_DIR"

# Convert SOURCE_BASENAME to title case for header
CATEGORY_TITLE=$(echo "$SOURCE_BASENAME" | sed 's/\b\(.\)/\u\1/g')

# Create a temporary section for this category
TEMP_SECTION=$(mktemp)
echo "## ${CATEGORY_TITLE}" > "$TEMP_SECTION"
echo "" >> "$TEMP_SECTION"

# Add links to downloaded READMEs
for repo_full in "${DOWNLOADED_REPOS[@]}"; do
    # Extract just the repo name from owner/repo
    repo_name="${repo_full##*/}"

    # Create relative path from plugins.md to the README
    # plugins.md is at: $DOCS_DIR/plugins.md
    # README is at: $DOCS_DIR/plugins/$SOURCE_BASENAME/$repo_name.md
    relative_path="plugins/${SOURCE_BASENAME}/${repo_name}.md"

    # Add markdown link
    echo "- [${repo_full}](${relative_path})" >> "$TEMP_SECTION"
done

echo "" >> "$TEMP_SECTION"

# Update or create plugins.md
if [[ -f "$PLUGINS_MD" ]]; then
    # Check if section already exists
    if grep -q "^## ${CATEGORY_TITLE}$" "$PLUGINS_MD"; then
        # Remove old section and replace with new one
        # This uses awk to replace the section
        awk -v section="$CATEGORY_TITLE" -v newfile="$TEMP_SECTION" '
        BEGIN { skip=0; section_found=0 }
        /^## / {
            if ($0 == "## " section) {
                skip=1
                section_found=1
                while ((getline line < newfile) > 0) {
                    print line
                }
                close(newfile)
                next
            } else {
                skip=0
            }
        }
        !skip { print }
        END {
            if (!section_found) {
                while ((getline line < newfile) > 0) {
                    print line
                }
            }
        }
        ' "$PLUGINS_MD" > "${PLUGINS_MD}.tmp"
        mv "${PLUGINS_MD}.tmp" "$PLUGINS_MD"
    else
        # Append new section
        cat "$TEMP_SECTION" >> "$PLUGINS_MD"
    fi
else
    # Create new plugins.md with header
    cat > "$PLUGINS_MD" << 'EOF'
# Neovim Plugins Documentation

This file contains links to README documentation for various Neovim plugins, organized by category.

EOF
    cat "$TEMP_SECTION" >> "$PLUGINS_MD"
fi

# Clean up
rm -f "$TEMP_SECTION"

echo -e "${GREEN}Updated: $PLUGINS_MD${NC}"

# Remove the source file
echo ""
echo -e "${YELLOW}Removing source file: $SOURCE_FILE${NC}"
rm -f "$SOURCE_FILE"
echo -e "${GREEN}Done!${NC}"
