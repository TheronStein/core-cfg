# ==============================================================================
# Archive Deduplication and Consolidation Functions
# ==============================================================================
# Comprehensive workflows for:
# - Cross-archive duplicate detection
# - Content-based archive comparison
# - Hash-based deduplication
# - Remote repository comparison
# - Mount state management
#
# Optimized for large archives (15-20GB+)
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
export ARCHIVE_MOUNT_BASE="${HOME}/Mount/yazi"
export ARCHIVE_FUSE_DIR="${ARCHIVE_MOUNT_BASE}/fuse-archive"
export ARCHIVE_RCLONE_DIR="${HOME}/Mount/rclone"
export ARCHIVE_STATE_DIR="${HOME}/.local/state/archive-dedup"
export ARCHIVE_MOUNT_REGISTRY="${ARCHIVE_STATE_DIR}/mount-registry.json"
export ARCHIVE_HASH_DB="${ARCHIVE_STATE_DIR}/file-hashes.db"
export ARCHIVE_LOG="${ARCHIVE_STATE_DIR}/operations.log"

# Ensure directories exist
[[ -d "$ARCHIVE_STATE_DIR" ]] || mkdir -p "$ARCHIVE_STATE_DIR"
[[ -d "$ARCHIVE_FUSE_DIR" ]] || mkdir -p "$ARCHIVE_FUSE_DIR"
[[ -d "$ARCHIVE_RCLONE_DIR" ]] || mkdir -p "$ARCHIVE_RCLONE_DIR"

# ------------------------------------------------------------------------------
# Logging Helper
# ------------------------------------------------------------------------------
_archive_log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date -Iseconds)
    echo "[$timestamp] [$level] $message" >> "$ARCHIVE_LOG"

    case "$level" in
        INFO)  echo "[INFO] $message" ;;
        WARN)  echo "[WARN] $message" >&2 ;;
        ERROR) echo "[ERROR] $message" >&2 ;;
        DEBUG) [[ -n "$ARCHIVE_DEBUG" ]] && echo "[DEBUG] $message" ;;
    esac
}

# ==============================================================================
# MOUNT STATE MANAGER
# ==============================================================================

# List all active fuse-archive mounts
archive-mounts-list() {
    echo "=== Active Fuse-Archive Mounts ==="
    mount | grep -E "fuse-archive|fuse\.archive" | while read -r line; do
        local mountpoint=$(echo "$line" | awk '{print $3}')
        local size=$(du -sh "$mountpoint" 2>/dev/null | cut -f1)
        echo "  $mountpoint ($size)"
    done

    echo ""
    echo "=== Active Rclone Mounts ==="
    mount | grep "fuse\.rclone" | while read -r line; do
        local mountpoint=$(echo "$line" | awk '{print $3}')
        echo "  $mountpoint"
    done

    echo ""
    echo "=== Stale Mount Directories ==="
    local stale_count=0
    for dir in "$ARCHIVE_FUSE_DIR"/*; do
        [[ -d "$dir" ]] || continue
        if ! mountpoint -q "$dir" 2>/dev/null; then
            echo "  [STALE] $dir"
            ((stale_count++))
        fi
    done
    [[ $stale_count -eq 0 ]] && echo "  (none)"
}

# Clean stale mount directories
archive-mounts-clean() {
    local dry_run="${1:-}"
    local cleaned=0

    _archive_log INFO "Cleaning stale mount directories (dry_run=$dry_run)"

    echo "=== Cleaning Stale Mount Directories ==="

    for dir in "$ARCHIVE_FUSE_DIR"/*; do
        [[ -d "$dir" ]] || continue

        if mountpoint -q "$dir" 2>/dev/null; then
            echo "[ACTIVE] $dir (skipping)"
            continue
        fi

        # Check if directory is empty or has only empty subdirs
        if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]] || [[ "$(find "$dir" -type f 2>/dev/null | wc -l)" -eq 0 ]]; then
            if [[ "$dry_run" == "--dry-run" ]]; then
                echo "[DRY-RUN] Would remove: $dir"
            else
                echo "[REMOVING] $dir"
                rm -rf "$dir"
                ((cleaned++))
            fi
        else
            echo "[SKIPPING] $dir (contains files - check manually)"
        fi
    done

    echo ""
    echo "Cleaned: $cleaned directories"
    _archive_log INFO "Cleaned $cleaned stale directories"
}

# Mount an archive with tracking
archive-mount() {
    local archive_path="$1"
    local mount_name="${2:-}"

    if [[ ! -f "$archive_path" ]]; then
        _archive_log ERROR "Archive not found: $archive_path"
        return 1
    fi

    # Generate mount name from archive basename if not provided
    if [[ -z "$mount_name" ]]; then
        mount_name=$(basename "$archive_path")
        # Add timestamp to avoid collisions
        mount_name="${mount_name}.$(date +%s)"
    fi

    local mount_point="${ARCHIVE_FUSE_DIR}/${mount_name}"

    # Create mount point
    mkdir -p "$mount_point"

    # Mount the archive
    _archive_log INFO "Mounting $archive_path to $mount_point"

    if fuse-archive "$archive_path" "$mount_point"; then
        _archive_log INFO "Successfully mounted $archive_path"
        echo "$mount_point"

        # Update registry
        _archive_registry_add "$archive_path" "$mount_point"
        return 0
    else
        _archive_log ERROR "Failed to mount $archive_path"
        rmdir "$mount_point" 2>/dev/null
        return 1
    fi
}

# Unmount an archive
archive-unmount() {
    local mount_point="$1"

    if [[ ! -d "$mount_point" ]]; then
        _archive_log ERROR "Mount point not found: $mount_point"
        return 1
    fi

    _archive_log INFO "Unmounting $mount_point"

    if fusermount3 -u "$mount_point" 2>/dev/null || umount "$mount_point" 2>/dev/null; then
        _archive_log INFO "Successfully unmounted $mount_point"

        # Remove empty directory
        rmdir "$mount_point" 2>/dev/null

        # Update registry
        _archive_registry_remove "$mount_point"
        return 0
    else
        _archive_log ERROR "Failed to unmount $mount_point"
        return 1
    fi
}

# Unmount all archive mounts
archive-unmount-all() {
    _archive_log INFO "Unmounting all archive mounts"

    mount | grep -E "fuse-archive|fuse\.archive" | awk '{print $3}' | while read -r mp; do
        archive-unmount "$mp"
    done

    # Clean stale directories
    archive-mounts-clean
}

# Registry helpers
_archive_registry_add() {
    local archive="$1"
    local mount_point="$2"
    local timestamp=$(date -Iseconds)

    # Simple append to registry (JSON-lines format for easy parsing)
    echo "{\"archive\": \"$archive\", \"mount\": \"$mount_point\", \"time\": \"$timestamp\", \"status\": \"mounted\"}" >> "$ARCHIVE_MOUNT_REGISTRY"
}

_archive_registry_remove() {
    local mount_point="$1"
    # Mark as unmounted (append new entry)
    local timestamp=$(date -Iseconds)
    echo "{\"mount\": \"$mount_point\", \"time\": \"$timestamp\", \"status\": \"unmounted\"}" >> "$ARCHIVE_MOUNT_REGISTRY"
}

# ==============================================================================
# WORKFLOW A: Cross-Archive Duplicate Detection (Mounted)
# ==============================================================================

# Mount multiple archives and run duplicate detection
archive-dedupe-cross() {
    local -a archives
    local tool="${1:-rmlint}"

    echo "=== Cross-Archive Duplicate Detection ==="
    echo ""
    echo "Step 1: Select archives to compare"

    # Find archives with size info
    local selected=$(fd --type f -e zip -e tar -e tar.gz -e tar.xz -e tar.zst -e 7z -e rar . ~ 2>/dev/null | \
        fzf --multi \
            --prompt="Select archives to compare > " \
            --preview='echo "Size: $(du -h {} | cut -f1)"; echo "Type: $(file -b {})"; echo "---"; (7z l {} 2>/dev/null || tar -tf {} 2>/dev/null || unzip -l {} 2>/dev/null) | head -30' \
            --preview-window=right:50%:wrap \
            --header="TAB: select multiple | ENTER: confirm")

    [[ -z "$selected" ]] && { echo "No archives selected"; return 1; }

    # Mount selected archives
    echo ""
    echo "Step 2: Mounting archives..."
    local -a mount_points

    while IFS= read -r archive; do
        echo "  Mounting: $(basename "$archive")"
        local mp=$(archive-mount "$archive")
        if [[ -n "$mp" ]]; then
            mount_points+=("$mp")
        else
            echo "  [WARN] Failed to mount: $archive"
        fi
    done <<< "$selected"

    if [[ ${#mount_points[@]} -lt 2 ]]; then
        echo "[ERROR] Need at least 2 mounted archives for comparison"
        archive-unmount-all
        return 1
    fi

    echo ""
    echo "Step 3: Running duplicate detection with $tool"
    echo "  Mount points: ${mount_points[*]}"

    local report_dir="${ARCHIVE_STATE_DIR}/reports/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$report_dir"

    case "$tool" in
        rmlint)
            _archive_log INFO "Running rmlint on ${mount_points[*]}"
            rmlint --types=duplicates --progress \
                   --output=json:"${report_dir}/duplicates.json" \
                   --output=sh:"${report_dir}/duplicates.sh" \
                   "${mount_points[@]}"

            echo ""
            echo "Reports generated in: $report_dir"
            echo "  - duplicates.json (machine-readable)"
            echo "  - duplicates.sh (safe removal script)"
            echo ""
            echo "Review with: bat ${report_dir}/duplicates.sh"
            echo "Dry-run:     ${report_dir}/duplicates.sh -d -p"
            ;;

        fclones)
            _archive_log INFO "Running fclones on ${mount_points[*]}"
            fclones group "${mount_points[@]}" > "${report_dir}/duplicates.txt"

            # Parse and display summary
            local dup_count=$(grep -c "^#" "${report_dir}/duplicates.txt" || echo "0")
            echo ""
            echo "Found $dup_count duplicate groups"
            echo "Report: ${report_dir}/duplicates.txt"

            # Interactive selection
            if [[ "$dup_count" -gt 0 ]]; then
                echo ""
                read "?Review duplicates interactively? [y/N] " response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    cat "${report_dir}/duplicates.txt" | \
                        fzf --multi \
                            --prompt="Select files to keep/remove > " \
                            --preview="bat --style=plain --color=always {} 2>/dev/null || file {}" \
                            --header="First file in each group is the 'original'"
                fi
            fi
            ;;

        jdupes)
            _archive_log INFO "Running jdupes on ${mount_points[*]}"
            jdupes -r -S "${mount_points[@]}" > "${report_dir}/duplicates.txt"

            echo ""
            echo "Report: ${report_dir}/duplicates.txt"
            ;;
    esac

    echo ""
    echo "Step 4: Cleanup"
    read "?Unmount all archives? [Y/n] " response
    if [[ ! "$response" =~ ^[Nn]$ ]]; then
        for mp in "${mount_points[@]}"; do
            archive-unmount "$mp"
        done
    else
        echo "Archives still mounted at: ${mount_points[*]}"
        echo "Unmount with: archive-unmount-all"
    fi
}

# Quick duplicate check with fclones (fastest)
archive-dedupe-quick() {
    local target="${1:-$PWD}"

    echo "=== Quick Duplicate Scan ==="
    echo "Target: $target"
    echo ""

    if command -v fclones >/dev/null 2>&1; then
        # For large files, use size-only first pass
        local size_threshold="${2:-1M}"

        echo "Scanning files > $size_threshold..."
        fclones group --min-size "$size_threshold" "$target" | \
            fzf --multi \
                --prompt="Duplicate groups > " \
                --preview='echo "--- File Info ---"; du -h {}; file {}; echo ""; echo "--- Preview ---"; bat --style=plain --color=always --line-range :30 {} 2>/dev/null || hexdump -C {} | head -20' \
                --preview-window=right:60%:wrap \
                --header="TAB: select | CTRL-D: trash selected | ENTER: view"
    else
        echo "fclones not installed. Using rmlint..."
        rmlint --types=duplicates --progress "$target"
    fi
}

# ==============================================================================
# WORKFLOW B: Content-Based Archive Comparison (rga)
# ==============================================================================

# Index archive contents using rga
archive-index() {
    local archive="$1"
    local output_file="${2:-}"

    if [[ ! -f "$archive" ]]; then
        echo "[ERROR] Archive not found: $archive"
        return 1
    fi

    [[ -z "$output_file" ]] && output_file="${ARCHIVE_STATE_DIR}/indexes/$(basename "$archive").index"
    mkdir -p "$(dirname "$output_file")"

    echo "Indexing: $archive"

    # Use rga to list files in archive
    if command -v rga >/dev/null 2>&1; then
        # rga --files lists all files it can see
        rga --files "$archive" > "$output_file" 2>/dev/null

        # If rga fails, try other methods
        if [[ ! -s "$output_file" ]]; then
            # Fallback to archive-specific tools
            case "$archive" in
                *.zip)    unzip -l "$archive" 2>/dev/null | awk 'NR>3 {print $4}' > "$output_file" ;;
                *.tar*)   tar -tf "$archive" 2>/dev/null > "$output_file" ;;
                *.7z)     7z l "$archive" 2>/dev/null | awk '/^[0-9]/ {print $NF}' > "$output_file" ;;
                *.rar)    unrar l "$archive" 2>/dev/null | awk '/^[- ]/ {print $NF}' > "$output_file" ;;
            esac
        fi
    fi

    local file_count=$(wc -l < "$output_file")
    echo "  Indexed $file_count files -> $output_file"
    echo "$output_file"
}

# Compare multiple archives by content listing
archive-compare-content() {
    echo "=== Content-Based Archive Comparison ==="
    echo ""

    # Select archives
    local selected=$(fd --type f -e zip -e tar -e tar.gz -e tar.xz -e tar.zst -e 7z -e rar . ~ 2>/dev/null | \
        fzf --multi \
            --prompt="Select archives to compare > " \
            --preview='echo "Size: $(du -h {} | cut -f1)"; echo "---"; (unzip -l {} 2>/dev/null || tar -tf {} 2>/dev/null || 7z l {} 2>/dev/null) | head -40' \
            --preview-window=right:50%:wrap)

    [[ -z "$selected" ]] && return 1

    local -a index_files
    local index_dir="${ARCHIVE_STATE_DIR}/indexes"
    mkdir -p "$index_dir"

    echo ""
    echo "Indexing archives..."
    while IFS= read -r archive; do
        local idx=$(archive-index "$archive")
        index_files+=("$idx:$archive")
    done <<< "$selected"

    echo ""
    echo "Comparing file lists..."
    echo ""

    # Create comparison report
    local report="${ARCHIVE_STATE_DIR}/reports/comparison-$(date +%Y%m%d-%H%M%S).md"
    mkdir -p "$(dirname "$report")"

    {
        echo "# Archive Comparison Report"
        echo "Generated: $(date)"
        echo ""
        echo "## Archives Compared"
        for entry in "${index_files[@]}"; do
            local idx="${entry%%:*}"
            local arch="${entry#*:}"
            local count=$(wc -l < "$idx")
            echo "- \`$(basename "$arch")\`: $count files"
        done
        echo ""

        # Find common files across archives
        echo "## Common Files"

        # Sort and compare using comm
        if [[ ${#index_files[@]} -eq 2 ]]; then
            local idx1="${index_files[1]%%:*}"
            local idx2="${index_files[2]%%:*}"

            local common=$(comm -12 <(sort "$idx1") <(sort "$idx2") | wc -l)
            local only1=$(comm -23 <(sort "$idx1") <(sort "$idx2") | wc -l)
            local only2=$(comm -13 <(sort "$idx1") <(sort "$idx2") | wc -l)

            echo "- Common files: $common"
            echo "- Only in archive 1: $only1"
            echo "- Only in archive 2: $only2"
            echo ""
            echo "### Overlap Analysis"
            local total1=$(wc -l < "$idx1")
            local total2=$(wc -l < "$idx2")
            local overlap_pct1=$((common * 100 / total1))
            local overlap_pct2=$((common * 100 / total2))
            echo "- Archive 1 contains ${overlap_pct1}% of shared content"
            echo "- Archive 2 contains ${overlap_pct2}% of shared content"
        else
            echo "(Multi-archive comparison - showing unique file counts)"
            for entry in "${index_files[@]}"; do
                local idx="${entry%%:*}"
                local arch="${entry#*:}"
                local total=$(wc -l < "$idx")
                echo "- $(basename "$arch"): $total files"
            done
        fi

    } > "$report"

    echo "Report saved: $report"
    echo ""

    # Display with bat if available
    if command -v bat >/dev/null 2>&1; then
        bat "$report"
    else
        cat "$report"
    fi

    echo ""
    echo "View detailed differences?"
    read "?Show common files? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]] && [[ ${#index_files[@]} -eq 2 ]]; then
        local idx1="${index_files[1]%%:*}"
        local idx2="${index_files[2]%%:*}"
        comm -12 <(sort "$idx1") <(sort "$idx2") | fzf --prompt="Common files > "
    fi
}

# Search for pattern across multiple archives
archive-search() {
    local pattern="$1"
    local target="${2:-$PWD}"

    if [[ -z "$pattern" ]]; then
        read "pattern?Search pattern: "
    fi

    [[ -z "$pattern" ]] && return 1

    echo "=== Searching Archives for: $pattern ==="
    echo "Target: $target"
    echo ""

    if ! command -v rga >/dev/null 2>&1; then
        echo "[ERROR] ripgrep-all (rga) not installed"
        echo "Install with: paru -S ripgrep-all"
        return 1
    fi

    # Find archives containing the pattern
    rga --files-with-matches "$pattern" "$target" 2>/dev/null | \
        fzf --multi \
            --prompt="Archives matching '$pattern' > " \
            --preview="rga --context 5 '$pattern' {} 2>/dev/null | bat --style=plain --color=always" \
            --preview-window=right:60%:wrap \
            --header="ENTER: view matches | TAB: select multiple" \
            --bind "enter:execute(rga --context 10 '$pattern' {} | less -R)"
}

# ==============================================================================
# WORKFLOW C: Hash-Based Archive Deduplication
# ==============================================================================

# Initialize hash database
_archive_hash_db_init() {
    if [[ ! -f "$ARCHIVE_HASH_DB" ]]; then
        _archive_log INFO "Initializing hash database: $ARCHIVE_HASH_DB"
        sqlite3 "$ARCHIVE_HASH_DB" <<EOF
CREATE TABLE IF NOT EXISTS file_hashes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    archive TEXT NOT NULL,
    filepath TEXT NOT NULL,
    size INTEGER NOT NULL,
    hash_xxh64 TEXT,
    hash_sha256 TEXT,
    mtime INTEGER,
    indexed_at TEXT DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(archive, filepath)
);
CREATE INDEX IF NOT EXISTS idx_hash ON file_hashes(hash_xxh64);
CREATE INDEX IF NOT EXISTS idx_size ON file_hashes(size);
CREATE INDEX IF NOT EXISTS idx_archive ON file_hashes(archive);
EOF
    fi
}

# Hash files in a mounted archive
archive-hash-index() {
    local mount_point="$1"
    local archive_name="$2"

    _archive_hash_db_init

    if [[ ! -d "$mount_point" ]]; then
        echo "[ERROR] Mount point not found: $mount_point"
        return 1
    fi

    echo "Indexing hashes for: $archive_name"
    echo "Mount point: $mount_point"

    local count=0
    local total=$(find "$mount_point" -type f 2>/dev/null | wc -l)

    find "$mount_point" -type f 2>/dev/null | while read -r file; do
        ((count++))

        # Progress indicator
        printf "\r  Processing: %d / %d" "$count" "$total"

        local rel_path="${file#$mount_point/}"
        local size=$(stat -c %s "$file" 2>/dev/null || stat -f %z "$file" 2>/dev/null)
        local mtime=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)

        # Use xxhash for speed (fallback to sha256)
        local hash
        if command -v xxhsum >/dev/null 2>&1; then
            hash=$(xxhsum "$file" 2>/dev/null | awk '{print $1}')
        elif command -v xxh64sum >/dev/null 2>&1; then
            hash=$(xxh64sum "$file" 2>/dev/null | awk '{print $1}')
        else
            hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
        fi

        # Insert into database
        sqlite3 "$ARCHIVE_HASH_DB" <<EOF
INSERT OR REPLACE INTO file_hashes (archive, filepath, size, hash_xxh64, mtime)
VALUES ('$archive_name', '$rel_path', $size, '$hash', $mtime);
EOF
    done

    echo ""
    echo "  Indexed $count files"
}

# Find duplicates across all indexed archives
archive-hash-find-dupes() {
    _archive_hash_db_init

    echo "=== Hash-Based Duplicate Detection ==="
    echo ""

    # Find duplicate hashes across different archives
    local dupes=$(sqlite3 -header -column "$ARCHIVE_HASH_DB" <<EOF
SELECT
    h1.hash_xxh64,
    COUNT(DISTINCT h1.archive) as archive_count,
    SUM(h1.size) as total_size,
    GROUP_CONCAT(DISTINCT h1.archive) as archives
FROM file_hashes h1
GROUP BY h1.hash_xxh64
HAVING COUNT(DISTINCT h1.archive) > 1
ORDER BY total_size DESC
LIMIT 100;
EOF
)

    if [[ -z "$dupes" ]]; then
        echo "No cross-archive duplicates found."
        return 0
    fi

    echo "$dupes" | column -t

    echo ""
    echo "Total duplicate groups: $(echo "$dupes" | tail -n +2 | wc -l)"

    # Save report
    local report="${ARCHIVE_STATE_DIR}/reports/hash-dupes-$(date +%Y%m%d-%H%M%S).txt"
    echo "$dupes" > "$report"
    echo ""
    echo "Report saved: $report"
}

# Interactive hash-based deduplication
archive-hash-dedupe() {
    echo "=== Hash-Based Archive Deduplication ==="
    echo ""

    # Select archives to index
    local selected=$(fd --type f -e zip -e tar -e tar.gz -e tar.xz -e tar.zst -e 7z . ~ 2>/dev/null | \
        fzf --multi \
            --prompt="Select archives to hash-index > " \
            --preview='du -h {}; file -b {}' \
            --preview-window=right:30%:wrap)

    [[ -z "$selected" ]] && return 1

    # Mount and index each archive
    local -a mount_points

    while IFS= read -r archive; do
        echo ""
        echo "Processing: $(basename "$archive")"

        local mp=$(archive-mount "$archive")
        if [[ -n "$mp" ]]; then
            mount_points+=("$mp")
            archive-hash-index "$mp" "$(basename "$archive")"
        fi
    done <<< "$selected"

    # Find duplicates
    echo ""
    archive-hash-find-dupes

    # Cleanup
    echo ""
    read "?Unmount archives? [Y/n] " response
    if [[ ! "$response" =~ ^[Nn]$ ]]; then
        for mp in "${mount_points[@]}"; do
            archive-unmount "$mp"
        done
    fi
}

# ==============================================================================
# REMOTE REPOSITORY COMPARISON
# ==============================================================================

# Mount rclone remote
rclone-mount-remote() {
    local remote="${1:-}"

    if [[ -z "$remote" ]]; then
        # Select remote interactively
        remote=$(rclone listremotes | fzf \
            --prompt="Select remote > " \
            --preview='rclone about {} 2>/dev/null || echo "Remote: {}"' \
            --preview-window=up:5:wrap)
    fi

    [[ -z "$remote" ]] && return 1

    # Remove trailing colon if present
    remote="${remote%:}"

    local mount_point="${ARCHIVE_RCLONE_DIR}/${remote}"
    mkdir -p "$mount_point"

    echo "Mounting ${remote}: to $mount_point"

    # Optimized settings for large files
    rclone mount "${remote}:" "$mount_point" \
        --daemon \
        --vfs-cache-mode full \
        --vfs-cache-max-size 5G \
        --vfs-read-chunk-size 64M \
        --vfs-read-ahead 128M \
        --dir-cache-time 1h \
        --poll-interval 30s \
        --log-file="${ARCHIVE_STATE_DIR}/rclone-${remote}.log" \
        --log-level INFO

    sleep 2

    if mountpoint -q "$mount_point" 2>/dev/null; then
        _archive_log INFO "Mounted ${remote}: to $mount_point"
        echo "Mounted at: $mount_point"
        echo "$mount_point"
    else
        _archive_log ERROR "Failed to mount ${remote}:"
        echo "[ERROR] Mount failed"
        rmdir "$mount_point" 2>/dev/null
        return 1
    fi
}

# Unmount rclone remote
rclone-unmount-remote() {
    local mount_point="$1"

    if [[ -z "$mount_point" ]]; then
        # Select from active mounts
        mount_point=$(mount | grep "fuse\.rclone" | awk '{print $3}' | \
            fzf --prompt="Select mount to unmount > ")
    fi

    [[ -z "$mount_point" ]] && return 1

    echo "Unmounting: $mount_point"

    if fusermount3 -u "$mount_point" 2>/dev/null || umount "$mount_point" 2>/dev/null; then
        rmdir "$mount_point" 2>/dev/null
        _archive_log INFO "Unmounted $mount_point"
        echo "Unmounted successfully"
    else
        _archive_log ERROR "Failed to unmount $mount_point"
        echo "[ERROR] Unmount failed"
        return 1
    fi
}

# Compare local archives with remote
archive-compare-remote() {
    echo "=== Local vs Remote Archive Comparison ==="
    echo ""

    # Select local directory
    local local_dir=$(fd --type d . ~ 2>/dev/null | \
        fzf --prompt="Select local archive directory > " \
            --preview='ls -la {} | head -20')

    [[ -z "$local_dir" ]] && return 1

    # Select and mount remote
    local remote_mount=$(rclone-mount-remote)
    [[ -z "$remote_mount" ]] && return 1

    echo ""
    echo "Comparing:"
    echo "  Local:  $local_dir"
    echo "  Remote: $remote_mount"
    echo ""

    # Use rclone check for comparison
    echo "Running comparison..."
    local report="${ARCHIVE_STATE_DIR}/reports/remote-compare-$(date +%Y%m%d-%H%M%S).txt"
    mkdir -p "$(dirname "$report")"

    rclone check "$local_dir" "$remote_mount" \
        --size-only \
        --one-way \
        2>&1 | tee "$report"

    echo ""
    echo "Report saved: $report"

    echo ""
    read "?Unmount remote? [Y/n] " response
    if [[ ! "$response" =~ ^[Nn]$ ]]; then
        rclone-unmount-remote "$remote_mount"
    fi
}

# Sync local archives to remote
archive-sync-to-remote() {
    local local_dir="${1:-}"
    local remote="${2:-}"

    echo "=== Sync Archives to Remote ==="
    echo ""

    # Select local directory if not provided
    if [[ -z "$local_dir" ]]; then
        local_dir=$(fd --type f -e zip -e tar -e tar.gz -e tar.xz -e tar.zst -e 7z . ~ 2>/dev/null | \
            fzf --multi \
                --prompt="Select archives to sync > " \
                --preview='du -h {}' | \
            head -1 | xargs dirname)
    fi

    [[ -z "$local_dir" ]] && return 1

    # Select remote if not provided
    if [[ -z "$remote" ]]; then
        remote=$(rclone listremotes | fzf \
            --prompt="Select destination remote > " \
            --preview='rclone about {} 2>/dev/null')
    fi

    [[ -z "$remote" ]] && return 1

    echo "Source:      $local_dir"
    echo "Destination: ${remote}archives/"
    echo ""

    # Dry run first
    echo "=== Dry Run ==="
    rclone sync "$local_dir" "${remote}archives/" \
        --progress \
        --dry-run \
        --stats-one-line \
        --transfers 4 \
        --checkers 8

    echo ""
    read "?Proceed with sync? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        _archive_log INFO "Syncing $local_dir to ${remote}archives/"
        rclone sync "$local_dir" "${remote}archives/" \
            --progress \
            --stats 10s \
            --transfers 4 \
            --checkers 8
        _archive_log INFO "Sync completed"
    fi
}

# ==============================================================================
# INTEGRATED MENU
# ==============================================================================

archive-menu() {
    local option=$(cat <<'EOF' | fzf --prompt="Archive Operations > " \
        --preview='echo {}' \
        --preview-window=up:3:wrap \
        --height=70% \
        --border=rounded \
        --header="Archive Deduplication & Consolidation"
 1. List Active Mounts     - Show all fuse-archive and rclone mounts
 2. Clean Stale Mounts     - Remove orphaned mount directories
 3. Cross-Archive Dedupe   - Mount and compare multiple archives
 4. Quick Duplicate Scan   - Fast fclones-based scan
 5. Content Comparison     - Compare archives by file listing
 6. Search Archives        - Search content inside archives (rga)
 7. Hash-Based Dedupe      - Build hash database and find duplicates
 8. Mount Remote           - Mount rclone remote for browsing
 9. Unmount Remote         - Unmount rclone remote
10. Compare with Remote    - Compare local vs remote archives
11. Sync to Remote         - Upload archives to cloud
12. Unmount All            - Unmount all archive mounts
EOF
)

    [[ -z "$option" ]] && return 0

    case ${option%%. *} in
         1) archive-mounts-list ;;
         2) archive-mounts-clean ;;
         3) archive-dedupe-cross ;;
         4) archive-dedupe-quick ;;
         5) archive-compare-content ;;
         6) archive-search ;;
         7) archive-hash-dedupe ;;
         8) rclone-mount-remote ;;
         9) rclone-unmount-remote ;;
        10) archive-compare-remote ;;
        11) archive-sync-to-remote ;;
        12) archive-unmount-all ;;
    esac
}

# Alias for quick access
alias arcm="archive-menu"
alias arcd="archive-dedupe-cross"
alias arcs="archive-search"
