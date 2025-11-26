#!/usr/bin/env bash
# Analyze Dropbox conflict directories and provide merge recommendations

set -euo pipefail

DROPBOX_ROOT="${1:-$HOME/mnt/cachyos/Dropbox}"
REPORT_FILE="$CORE_CFG/yazi/logs/conflict-analysis-$(date +%Y%m%d-%H%M%S).txt"

mkdir -p "$(dirname "$REPORT_FILE")"

echo "=== DROPBOX CONFLICT ANALYSIS ===" | tee "$REPORT_FILE"
echo "Date: $(date)" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Find all conflict directories
echo "🔍 Scanning for conflict directories..." | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

CONFLICT_DIRS=$(find "$DROPBOX_ROOT" -maxdepth 1 \( -name "*Selective Sync Conflict*" -o -name "*conflicted copy*" \) -type d)

if [ -z "$CONFLICT_DIRS" ]; then
  echo "✅ No conflict directories found!" | tee -a "$REPORT_FILE"
  exit 0
fi

CONFLICT_COUNT=$(echo "$CONFLICT_DIRS" | wc -l)
echo "Found $CONFLICT_COUNT conflict directories:" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Analyze each conflict directory
while IFS= read -r conflict_dir; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$REPORT_FILE"
  echo "📁 Conflict: $(basename "$conflict_dir")" | tee -a "$REPORT_FILE"
  echo "   Path: $conflict_dir" | tee -a "$REPORT_FILE"

  # Count files
  FILE_COUNT=$(find "$conflict_dir" -type f 2>/dev/null | wc -l)
  TOTAL_SIZE=$(du -sh "$conflict_dir" 2>/dev/null | cut -f1)

  echo "   Files: $FILE_COUNT" | tee -a "$REPORT_FILE"
  echo "   Size: $TOTAL_SIZE" | tee -a "$REPORT_FILE"

  # Check if there's a matching non-conflict directory
  BASENAME=$(basename "$conflict_dir" | sed -E 's/ ?\((Selective Sync Conflict|.*conflicted copy.*)\)$//')

  if [ -d "$DROPBOX_ROOT/$BASENAME" ] && [ "$DROPBOX_ROOT/$BASENAME" != "$conflict_dir" ]; then
    echo "   ⚠️  Matching directory exists: $BASENAME" | tee -a "$REPORT_FILE"
    MAIN_FILE_COUNT=$(find "$DROPBOX_ROOT/$BASENAME" -type f 2>/dev/null | wc -l)
    MAIN_SIZE=$(du -sh "$DROPBOX_ROOT/$BASENAME" 2>/dev/null | cut -f1)
    echo "      Main dir - Files: $MAIN_FILE_COUNT, Size: $MAIN_SIZE" | tee -a "$REPORT_FILE"
  else
    echo "   ℹ️  No matching directory found" | tee -a "$REPORT_FILE"
  fi

  echo "" | tee -a "$REPORT_FILE"
done <<< "$CONFLICT_DIRS"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# Find conflict files (not directories)
echo "🔍 Scanning for conflict files..." | tee -a "$REPORT_FILE"
CONFLICT_FILES=$(find "$DROPBOX_ROOT" -type f \( -name "*Selective Sync Conflict*" -o -name "*conflicted copy*" \) 2>/dev/null | wc -l)
echo "Found $CONFLICT_FILES conflict files" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo "=== RECOMMENDATIONS ===" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "1. First, pause Dropbox sync:" | tee -a "$REPORT_FILE"
echo "   dropbox pause" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "2. Run duplicate content scanner:" | tee -a "$REPORT_FILE"
echo "   $CORE_CFG/yazi/scripts/find-duplicate-content.sh" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "3. For each conflict directory, you can:" | tee -a "$REPORT_FILE"
echo "   a) Merge into main directory: rsync -av 'conflict_dir/' 'main_dir/'" | tee -a "$REPORT_FILE"
echo "   b) Review and delete if content is duplicate" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "4. Resume Dropbox sync when ready:" | tee -a "$REPORT_FILE"
echo "   dropbox resume" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

echo "📄 Full report saved to: $REPORT_FILE"
