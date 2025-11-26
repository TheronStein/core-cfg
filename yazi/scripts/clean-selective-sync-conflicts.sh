#!/usr/bin/env bash
# Safely remove Dropbox "Selective Sync Conflict" directories (metadata/cache)
# These are NOT your actual files - just Dropbox internal cache

set -euo pipefail

DROPBOX_ROOT="${1:-$HOME/mnt/cachyos/Dropbox}"
DRY_RUN="${2:---dry-run}"  # Use --execute to actually delete

echo "=== Selective Sync Conflict Cleaner ==="
echo "Dropbox: $DROPBOX_ROOT"
echo "Mode: $DRY_RUN"
echo ""

# Find all "Selective Sync Conflict" directories (NOT "conflicted copy")
SELECTIVE_CONFLICTS=$(find "$DROPBOX_ROOT" -maxdepth 1 -type d -name "*Selective Sync Conflict*")

if [ -z "$SELECTIVE_CONFLICTS" ]; then
  echo "✅ No Selective Sync Conflict directories found!"
  exit 0
fi

TOTAL_SIZE=0
COUNT=0

echo "Found Selective Sync Conflict directories:"
echo ""

while IFS= read -r conflict_dir; do
  COUNT=$((COUNT + 1))
  DIR_SIZE=$(du -sb "$conflict_dir" 2>/dev/null | cut -f1 || echo "0")
  TOTAL_SIZE=$((TOTAL_SIZE + DIR_SIZE))
  READABLE_SIZE=$(du -sh "$conflict_dir" 2>/dev/null | cut -f1)

  echo "$COUNT. $(basename "$conflict_dir")"
  echo "   Size: $READABLE_SIZE"
  echo "   Path: $conflict_dir"

  # Sample a few files to confirm they're metadata
  echo "   Sample files:"
  find "$conflict_dir" -type f | head -3 | while read -r file; do
    echo "     - $(basename "$file")"
  done

  if [ "$DRY_RUN" = "--execute" ]; then
    echo "   🗑️  DELETING..."
    rm -rf "$conflict_dir"
    echo "   ✅ Deleted"
  else
    echo "   ℹ️  Would delete (use --execute to confirm)"
  fi
  echo ""
done <<< "$SELECTIVE_CONFLICTS"

READABLE_TOTAL=$(numfmt --to=iec-i --suffix=B "$TOTAL_SIZE" 2>/dev/null || echo "$TOTAL_SIZE bytes")

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary:"
echo "  Directories: $COUNT"
echo "  Total size: $READABLE_TOTAL"

if [ "$DRY_RUN" = "--execute" ]; then
  echo "  ✅ All Selective Sync Conflict directories have been removed"
else
  echo ""
  echo "ℹ️  This was a DRY RUN - no files were deleted"
  echo "   To actually delete these directories, run:"
  echo "   $0 \"$DROPBOX_ROOT\" --execute"
fi
