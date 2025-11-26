#!/usr/bin/env bash
# Use rmlint to find duplicate files in Dropbox (content-based, not name-based)

set -euo pipefail

DROPBOX_DIR="${1:-$HOME/mnt/cachyos/Dropbox}"
OUTPUT_DIR="$CORE_CFG/yazi/logs/rmlint-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$OUTPUT_DIR"

echo "=== rmlint Duplicate Finder ==="
echo "Scanning: $DROPBOX_DIR"
echo "Output: $OUTPUT_DIR"
echo ""
echo "This will find files with IDENTICAL CONTENT regardless of filename"
echo ""

cd "$OUTPUT_DIR"

# Run rmlint with optimal settings for duplicate finding
# -T df = only find duplicates (not other lint)
# -D = don't cross filesystem boundaries
# -g = match by content hash (not just size)
# -S a = sort by alphabetical (keep first alphabetically)
# --hidden = include hidden files
# --keep-all-tagged = don't delete anything from first path (if you specify one)
# --max-depth = limit recursion depth (remove this to scan everything)

rmlint \
  --progress \
  --with-color \
  -T df \
  -g \
  -S a \
  --hidden \
  --keep-all-untagged \
  -o pretty \
  -o sh:rmlint.sh \
  -o json:rmlint.json \
  "$DROPBOX_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results saved to: $OUTPUT_DIR"
echo ""
echo "Files generated:"
echo "  📄 rmlint.json  - Full report in JSON format"
echo "  📜 rmlint.sh    - Auto-generated deletion script"
echo ""
echo "To review duplicates:"
echo "  cat $OUTPUT_DIR/rmlint.json | jq"
echo ""
echo "To DELETE duplicates (CAREFUL!):"
echo "  1. Review the script first:"
echo "     less $OUTPUT_DIR/rmlint.sh"
echo "  2. Run it (with -d for dry-run first):"
echo "     $OUTPUT_DIR/rmlint.sh -d"
echo "  3. If satisfied, run for real:"
echo "     $OUTPUT_DIR/rmlint.sh"
echo ""
echo "⚠️  IMPORTANT: Review before deleting!"
