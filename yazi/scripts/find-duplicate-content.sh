#!/usr/bin/env bash
# Find files with identical content (regardless of name) using checksums
# Usage: ./find-duplicate-content.sh <directory> [--delete-duplicates]

set -euo pipefail

SEARCH_DIR="${1:-$HOME/mnt/cachyos/Dropbox}"
DELETE_MODE="${2:-}"
TEMP_DB="/tmp/dropbox-checksums-$(date +%s).db"
DUPLICATES_LOG="$CORE_CFG/yazi/logs/duplicates-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "$(dirname "$DUPLICATES_LOG")"

echo "=== Content-Based Duplicate Finder ==="
echo "Scanning: $SEARCH_DIR"
echo "Log file: $DUPLICATES_LOG"
echo ""

# Create checksums database
echo "Step 1: Computing checksums for all files..."
find "$SEARCH_DIR" -type f -size +0 ! -path "*/\.dropbox.cache/*" ! -name ".dropbox" -print0 | \
  xargs -0 -P $(nproc) -I {} sh -c 'md5sum "{}" 2>/dev/null || true' | \
  tee "$TEMP_DB" | pv -l -s $(find "$SEARCH_DIR" -type f -size +0 ! -path "*/\.dropbox.cache/*" ! -name ".dropbox" | wc -l) > /dev/null

echo ""
echo "Step 2: Finding duplicates..."

# Find duplicate checksums
awk '{print $1}' "$TEMP_DB" | sort | uniq -d > "$TEMP_DB.dupes"

# Process each duplicate checksum
TOTAL_DUPES=0
TOTAL_WASTED_SPACE=0

{
  echo "=== DUPLICATE FILES BY CONTENT ==="
  echo "Generated: $(date)"
  echo ""

  while IFS= read -r checksum; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Checksum: $checksum"
    echo ""

    # Get all files with this checksum
    grep "^$checksum " "$TEMP_DB" | while IFS= read -r line; do
      filepath="${line#* }"
      filesize=$(stat -f %z "$filepath" 2>/dev/null || stat -c %s "$filepath" 2>/dev/null || echo "0")
      echo "  📄 $filepath"
      echo "     Size: $(numfmt --to=iec-i --suffix=B "$filesize" 2>/dev/null || echo "$filesize bytes")"
      TOTAL_DUPES=$((TOTAL_DUPES + 1))
    done

    # Calculate wasted space (keep first, count rest as waste)
    DUPE_COUNT=$(grep -c "^$checksum " "$TEMP_DB")
    if [ "$DUPE_COUNT" -gt 1 ]; then
      FIRST_FILE=$(grep "^$checksum " "$TEMP_DB" | head -1 | cut -d' ' -f2-)
      FILE_SIZE=$(stat -f %z "$FIRST_FILE" 2>/dev/null || stat -c %s "$FIRST_FILE" 2>/dev/null || echo "0")
      WASTED=$((FILE_SIZE * (DUPE_COUNT - 1)))
      TOTAL_WASTED_SPACE=$((TOTAL_WASTED_SPACE + WASTED))

      echo ""
      echo "  ⚠️  Duplicates: $DUPE_COUNT copies"
      echo "  💾 Wasted space: $(numfmt --to=iec-i --suffix=B "$WASTED" 2>/dev/null || echo "$WASTED bytes")"

      if [ "$DELETE_MODE" = "--delete-duplicates" ]; then
        echo "  🗑️  Keeping: $FIRST_FILE"
        grep "^$checksum " "$TEMP_DB" | tail -n +2 | while IFS= read -r line; do
          dupe_file="${line#* }"
          echo "  ❌ Deleting: $dupe_file"
          rm -f "$dupe_file"
        done
      fi
    fi
    echo ""
  done < "$TEMP_DB.dupes"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "=== SUMMARY ==="
  echo "Total duplicate files found: $TOTAL_DUPES"
  echo "Total wasted space: $(numfmt --to=iec-i --suffix=B "$TOTAL_WASTED_SPACE" 2>/dev/null || echo "$TOTAL_WASTED_SPACE bytes")"

  if [ "$DELETE_MODE" = "--delete-duplicates" ]; then
    echo ""
    echo "✅ Duplicates have been deleted (kept oldest/first occurrence)"
  else
    echo ""
    echo "ℹ️  To delete duplicates, run with --delete-duplicates flag"
  fi
} | tee "$DUPLICATES_LOG"

# Cleanup
rm -f "$TEMP_DB" "$TEMP_DB.dupes"

echo ""
echo "Full log saved to: $DUPLICATES_LOG"
