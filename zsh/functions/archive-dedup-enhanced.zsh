# ==============================================================================
# Archive Deduplication and Consolidation Functions - ENHANCED
# ==============================================================================
# Version: 2.0 - Enhanced FZF integrations, parallel search, popup support
#
# Improvements over original:
# - Rich fzf previews with bat integration
# - Keybinding actions (ctrl-t trash, ctrl-y copy, ctrl-o open)
# - Tmux popup support for overlay operations
# - Parallel search for large archives
# - Streaming results for responsiveness
# - Better result passing and aggregation
# ==============================================================================

# Source original for base functionality
# source "${0:A:h}/archive-dedup.zsh"

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
export ARCHIVE_CACHE_DIR="${ARCHIVE_STATE_DIR}/cache"

# Ensure directories exist
[[ -d "$ARCHIVE_STATE_DIR" ]] || mkdir -p "$ARCHIVE_STATE_DIR"
[[ -d "$ARCHIVE_FUSE_DIR" ]] || mkdir -p "$ARCHIVE_FUSE_DIR"
[[ -d "$ARCHIVE_RCLONE_DIR" ]] || mkdir -p "$ARCHIVE_RCLONE_DIR"
[[ -d "$ARCHIVE_CACHE_DIR" ]] || mkdir -p "$ARCHIVE_CACHE_DIR"

# ------------------------------------------------------------------------------
# FZF Enhancement Configuration
# ------------------------------------------------------------------------------
# Default fzf options for archive operations
export ARCHIVE_FZF_OPTS="
    --height=80%
    --border=rounded
    --info=inline
    --prompt='> '
    --pointer='>'
    --marker='*'
    --bind 'ctrl-a:toggle-all'
    --bind 'ctrl-d:half-page-down'
    --bind 'ctrl-u:half-page-up'
    --bind 'ctrl-/:toggle-preview'
"

# Preview command templates
_archive_preview_file() {
    local file="$1"
    echo "=== File Info ==="
    echo "Size: $(du -h "$file" 2>/dev/null | cut -f1)"
    echo "Type: $(file -b "$file" 2>/dev/null)"
    echo "Modified: $(stat -c '%y' "$file" 2>/dev/null | cut -d'.' -f1)"
    echo ""
    echo "=== Preview ==="
    bat --style=numbers --color=always --line-range :50 "$file" 2>/dev/null || \
    hexdump -C "$file" 2>/dev/null | head -30
}

_archive_preview_archive() {
    local archive="$1"
    echo "=== Archive Info ==="
    echo "Size: $(du -h "$archive" 2>/dev/null | cut -f1)"
    echo "Type: $(file -b "$archive" 2>/dev/null)"
    echo ""
    echo "=== Contents (first 40 entries) ==="
    (7z l "$archive" 2>/dev/null || tar -tvf "$archive" 2>/dev/null || unzip -l "$archive" 2>/dev/null) | head -40
}

# ------------------------------------------------------------------------------
# Logging Helper (inherited from original)
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
# ENHANCED FZF INTEGRATIONS
# ==============================================================================

# ------------------------------------------------------------------------------
# Enhanced Archive Selection with Rich Preview
# ------------------------------------------------------------------------------
_archive_select_enhanced() {
    local prompt="${1:-Select archives}"
    local multi="${2:-true}"
    local target="${3:-$HOME}"

    local multi_flag=""
    [[ "$multi" == "true" ]] && multi_flag="--multi"

    fd --type f \
       -e zip -e tar -e tar.gz -e tar.xz -e tar.zst -e tar.bz2 \
       -e 7z -e rar -e iso -e tgz -e txz \
       . "$target" 2>/dev/null | \
    fzf $multi_flag \
        $ARCHIVE_FZF_OPTS \
        --prompt="$prompt > " \
        --preview='
            echo "=== Archive Info ==="
            echo "Size: $(du -h {} 2>/dev/null | cut -f1)"
            echo "Type: $(file -b {} 2>/dev/null)"
            echo "Path: {}"
            echo ""
            echo "=== Contents (first 35 entries) ==="
            (7z l {} 2>/dev/null || tar -tvf {} 2>/dev/null || unzip -l {} 2>/dev/null) | head -35
        ' \
        --preview-window=right:55%:wrap \
        --header="TAB: select | ENTER: confirm | CTRL-/: toggle preview
CTRL-Y: copy path | CTRL-O: open location" \
        --bind "ctrl-y:execute-silent(echo {} | wl-copy)+abort" \
        --bind "ctrl-o:execute(xdg-open \$(dirname {}))"
}

# ------------------------------------------------------------------------------
# Enhanced File Selection with Actions
# ------------------------------------------------------------------------------
_file_select_enhanced() {
    local prompt="${1:-Select files}"
    local target="${2:-$PWD}"
    local size_filter="${3:-}"

    local fd_args="--type f"
    [[ -n "$size_filter" ]] && fd_args="$fd_args --size +$size_filter"

    fd $fd_args . "$target" 2>/dev/null | \
    fzf --multi \
        $ARCHIVE_FZF_OPTS \
        --prompt="$prompt > " \
        --preview='
            echo "=== File Info ==="
            echo "Size: $(du -h {} | cut -f1)"
            echo "Type: $(file -b {})"
            echo "Modified: $(stat -c "%y" {} 2>/dev/null | cut -d"." -f1)"
            echo ""
            echo "=== Preview ==="
            bat --style=numbers --color=always --line-range :40 {} 2>/dev/null || hexdump -C {} | head -20
        ' \
        --preview-window=right:55%:wrap \
        --header="TAB: select | ENTER: confirm | CTRL-D: page down
CTRL-T: trash | CTRL-Y: copy path | CTRL-O: open dir" \
        --bind "ctrl-t:execute(trash-put {})+reload(fd $fd_args . '$target')" \
        --bind "ctrl-y:execute-silent(echo {} | wl-copy)" \
        --bind "ctrl-o:execute(xdg-open \$(dirname {}))"
}

# ------------------------------------------------------------------------------
# Tmux Popup Wrapper
# ------------------------------------------------------------------------------
# Runs a command in tmux popup if in tmux, otherwise runs directly
_run_in_popup() {
    local title="$1"
    shift
    local cmd="$*"

    if [[ -n "$TMUX" ]]; then
        tmux display-popup -E -w 90% -h 85% \
            -T " $title " \
            -b rounded \
            -S "fg=#89b4fa,bg=#1e1e2e" \
            "bash -c '$cmd'"
    else
        eval "$cmd"
    fi
}

# Runs fzf in popup with result capture
_fzf_popup() {
    local title="$1"
    local fzf_cmd="$2"
    local result_file="/tmp/fzf-popup-result-$$"

    if [[ -n "$TMUX" ]]; then
        tmux display-popup -E -w 90% -h 85% \
            -T " $title " \
            -b rounded \
            "bash -c '$fzf_cmd > $result_file 2>/dev/null'"

        if [[ -s "$result_file" ]]; then
            cat "$result_file"
            rm -f "$result_file"
        fi
    else
        eval "$fzf_cmd"
    fi
}

# ==============================================================================
# PARALLEL SEARCH SYSTEM
# ==============================================================================

# ------------------------------------------------------------------------------
# Parallel RGA Search - File Partitioning Method
# ------------------------------------------------------------------------------
parallel-rga-search() {
    local pattern="$1"
    local target="${2:-$PWD}"
    local num_agents="${3:-4}"

    if [[ -z "$pattern" ]]; then
        read "pattern?Search pattern: "
        [[ -z "$pattern" ]] && return 1
    fi

    _archive_log INFO "Starting parallel search for '$pattern' with $num_agents agents"

    echo "=== Parallel Archive Search ==="
    echo "Pattern: $pattern"
    echo "Target: $target"
    echo "Agents: $num_agents"
    echo ""

    # Find all searchable files
    local file_list=$(mktemp)
    echo "Indexing files..."
    fd --type f . "$target" 2>/dev/null > "$file_list"

    local total_files=$(wc -l < "$file_list")
    echo "Found $total_files files to search"

    if [[ $total_files -lt $num_agents ]]; then
        echo "Too few files for parallel search, using single thread"
        rga --files-with-matches "$pattern" "$target" 2>/dev/null
        rm -f "$file_list"
        return 0
    fi

    local per_agent=$((total_files / num_agents + 1))
    local results_dir=$(mktemp -d)
    local progress_dir=$(mktemp -d)

    echo ""
    echo "Starting $num_agents search agents..."

    # Split file list and launch agents
    split -l "$per_agent" "$file_list" "$results_dir/part_"

    local agent_num=0
    for part in "$results_dir"/part_*; do
        ((agent_num++))
        (
            local count=0
            local matches=0
            while IFS= read -r file; do
                ((count++))
                if rga -l "$pattern" "$file" 2>/dev/null; then
                    ((matches++))
                    echo "$file" >> "${part}.results"
                fi
                # Progress indicator every 10 files
                if ((count % 10 == 0)); then
                    echo "$count" > "$progress_dir/agent_$agent_num"
                fi
            done < "$part"
            echo "done:$matches" > "$progress_dir/agent_$agent_num"
        ) &
    done

    # Monitor progress
    echo ""
    while true; do
        local all_done=true
        local status=""
        for i in $(seq 1 $agent_num); do
            if [[ -f "$progress_dir/agent_$i" ]]; then
                local prog=$(cat "$progress_dir/agent_$i")
                if [[ "$prog" == done:* ]]; then
                    status="$status Agent$i: done (${prog#done:} matches) |"
                else
                    status="$status Agent$i: $prog files |"
                    all_done=false
                fi
            else
                status="$status Agent$i: starting |"
                all_done=false
            fi
        done
        printf "\r%-80s" "$status"

        $all_done && break
        sleep 0.5
    done

    wait
    echo ""
    echo ""

    # Aggregate results
    local all_results=$(mktemp)
    cat "$results_dir"/*.results 2>/dev/null | sort -u > "$all_results"
    local match_count=$(wc -l < "$all_results")

    echo "=== Search Complete ==="
    echo "Found $match_count matching files"
    echo ""

    # Display results with fzf
    if [[ $match_count -gt 0 ]]; then
        cat "$all_results" | \
            fzf --multi \
                $ARCHIVE_FZF_OPTS \
                --prompt="Results for '$pattern' > " \
                --preview="rga --context 5 --color=always '$pattern' {} 2>/dev/null | head -50" \
                --preview-window=right:60%:wrap \
                --header="$match_count matches | TAB: select | ENTER: view | CTRL-O: open dir" \
                --bind "enter:execute(rga --context 10 --color=always '$pattern' {} | less -R)" \
                --bind "ctrl-o:execute(xdg-open \$(dirname {}))" \
                --bind "ctrl-y:execute-silent(echo {} | wl-copy)"
    fi

    # Cleanup
    rm -rf "$results_dir" "$progress_dir" "$file_list" "$all_results"

    _archive_log INFO "Parallel search completed: $match_count matches"
}

# ------------------------------------------------------------------------------
# Bidirectional Search (Experimental)
# ------------------------------------------------------------------------------
parallel-rga-bidirectional() {
    local pattern="$1"
    local target="${2:-$PWD}"

    if [[ -z "$pattern" ]]; then
        read "pattern?Search pattern: "
        [[ -z "$pattern" ]] && return 1
    fi

    echo "=== Bidirectional Archive Search ==="
    echo "Pattern: $pattern"
    echo ""

    local file_list=$(mktemp)
    fd --type f . "$target" | sort > "$file_list"

    local total=$(wc -l < "$file_list")
    local midpoint=$((total / 2))

    echo "Files to search: $total (midpoint: $midpoint)"

    local results_dir=$(mktemp -d)

    # Agent 1: top to middle
    echo "Starting Agent 1 (top -> middle)..."
    (
        head -n "$midpoint" "$file_list" | while IFS= read -r file; do
            rga -l "$pattern" "$file" 2>/dev/null
        done > "$results_dir/agent1.results"
    ) &
    local pid1=$!

    # Agent 2: bottom to middle
    echo "Starting Agent 2 (bottom -> middle)..."
    (
        tail -n +"$((midpoint + 1))" "$file_list" | tac | while IFS= read -r file; do
            rga -l "$pattern" "$file" 2>/dev/null
        done > "$results_dir/agent2.results"
    ) &
    local pid2=$!

    # Wait with progress
    echo ""
    while kill -0 $pid1 2>/dev/null || kill -0 $pid2 2>/dev/null; do
        local c1=$(wc -l < "$results_dir/agent1.results" 2>/dev/null || echo 0)
        local c2=$(wc -l < "$results_dir/agent2.results" 2>/dev/null || echo 0)
        printf "\rAgent1: %d matches | Agent2: %d matches" "$c1" "$c2"
        sleep 0.5
    done

    wait
    echo ""
    echo ""

    # Combine results
    cat "$results_dir"/*.results | sort -u | \
        fzf --multi \
            $ARCHIVE_FZF_OPTS \
            --prompt="Results > " \
            --preview="rga --context 5 --color=always '$pattern' {} | head -40" \
            --preview-window=right:60%:wrap

    rm -rf "$results_dir" "$file_list"
}

# ==============================================================================
# ENHANCED ARCHIVE OPERATIONS
# ==============================================================================

# ------------------------------------------------------------------------------
# Enhanced Archive Search with Popup Support
# ------------------------------------------------------------------------------
archive-search-popup() {
    local pattern="$1"
    local target="${2:-$PWD}"

    if [[ -z "$pattern" ]]; then
        read "pattern?Search pattern: "
    fi
    [[ -z "$pattern" ]] && return 1

    local fzf_cmd="rga --files-with-matches '$pattern' '$target' 2>/dev/null | \
        fzf --multi \
            --prompt=\"Archives with '$pattern' > \" \
            --preview=\"rga --context 5 --color=always '$pattern' {} 2>/dev/null | head -50\" \
            --preview-window=right:60%:wrap \
            --header='ENTER: view full | CTRL-O: open dir | CTRL-Y: copy path' \
            --bind \"enter:execute(rga --context 10 --color=always '$pattern' {} | less -R)\" \
            --bind 'ctrl-o:execute(xdg-open \$(dirname {}))' \
            --bind 'ctrl-y:execute-silent(echo {} | wl-copy)'"

    _fzf_popup "Archive Search: $pattern" "$fzf_cmd"
}

# ------------------------------------------------------------------------------
# Enhanced Duplicate Detection with Preview
# ------------------------------------------------------------------------------
archive-dedupe-enhanced() {
    local target="${1:-$PWD}"
    local tool="${2:-}"

    echo "=== Enhanced Duplicate Detection ==="
    echo "Target: $target"
    echo ""

    # Tool selection if not provided
    if [[ -z "$tool" ]]; then
        tool=$(printf '%s\n' \
            "fclones - Fast Rust-based scanner (recommended)" \
            "rmlint - Generates safe removal script" \
            "jdupes - High-performance hash-based" \
            "czkawka - Feature-rich with similarity" | \
            fzf --prompt="Select tool > " \
                --header="Choose deduplication tool" \
                --height=30% | \
            cut -d' ' -f1)
    fi

    [[ -z "$tool" ]] && return 1

    echo "Using: $tool"
    echo ""

    local results_file=$(mktemp)

    case "$tool" in
        fclones)
            echo "Scanning for duplicates..."
            fclones group "$target" > "$results_file" 2>/dev/null

            if [[ -s "$results_file" ]]; then
                # Parse fclones output for fzf
                grep -v '^#' "$results_file" | grep -v '^$' | \
                    fzf --multi \
                        $ARCHIVE_FZF_OPTS \
                        --prompt="Select duplicates to remove > " \
                        --preview='
                            echo "=== File Info ==="
                            du -h {}
                            file -b {}
                            echo ""
                            echo "=== Preview ==="
                            bat --style=plain --color=always --line-range :30 {} 2>/dev/null || hexdump -C {} | head -15
                        ' \
                        --preview-window=right:55%:wrap \
                        --header="First file in each group is original
TAB: select | CTRL-T: trash selected | ENTER: view" \
                        --bind "ctrl-t:execute(echo {} | xargs -I@ trash-put @)+reload(cat '$results_file' | grep -v '^#' | grep -v '^$')" \
                        --bind "enter:execute(bat --style=numbers --color=always {} | less -R)"
            else
                echo "No duplicates found."
            fi
            ;;

        rmlint)
            echo "Scanning with rmlint..."
            local report_dir="${ARCHIVE_STATE_DIR}/reports/$(date +%Y%m%d-%H%M%S)"
            mkdir -p "$report_dir"

            rmlint --types=duplicates --progress \
                   --output=json:"${report_dir}/duplicates.json" \
                   --output=sh:"${report_dir}/duplicates.sh" \
                   "$target"

            echo ""
            echo "Reports generated in: $report_dir"
            echo ""

            # Parse JSON for interactive review
            if command -v jq >/dev/null 2>&1 && [[ -f "${report_dir}/duplicates.json" ]]; then
                jq -r '.[] | select(.type == "duplicate_file") | .path' "${report_dir}/duplicates.json" | \
                    fzf --multi \
                        $ARCHIVE_FZF_OPTS \
                        --prompt="Review duplicates > " \
                        --preview='bat --style=plain --color=always --line-range :30 {} 2>/dev/null || file {}' \
                        --preview-window=right:55% \
                        --header="Review duplicates - script at: ${report_dir}/duplicates.sh"
            fi

            echo ""
            echo "To execute removal:"
            echo "  Review:  bat ${report_dir}/duplicates.sh"
            echo "  Dry-run: ${report_dir}/duplicates.sh -d -p"
            echo "  Execute: ${report_dir}/duplicates.sh -d"
            ;;

        jdupes)
            echo "Scanning with jdupes..."
            jdupes -r -S "$target" | \
                fzf --multi \
                    $ARCHIVE_FZF_OPTS \
                    --prompt="Duplicates > " \
                    --preview='bat --style=plain --color=always {} 2>/dev/null || file {}' \
                    --preview-window=right:55%
            ;;

        czkawka)
            if command -v czkawka-cli >/dev/null 2>&1; then
                echo "Scanning with czkawka..."
                czkawka-cli dup -d "$target" -f "$results_file"

                if [[ -s "$results_file" ]]; then
                    cat "$results_file" | \
                        fzf --multi \
                            $ARCHIVE_FZF_OPTS \
                            --prompt="Duplicates > " \
                            --preview='file {} && echo "" && bat --style=plain --color=always {} 2>/dev/null | head -30'
                fi
            else
                echo "czkawka-cli not installed"
            fi
            ;;
    esac

    rm -f "$results_file"
}

# ------------------------------------------------------------------------------
# Enhanced Cross-Archive Comparison
# ------------------------------------------------------------------------------
archive-compare-enhanced() {
    echo "=== Enhanced Archive Comparison ==="
    echo ""

    # Select archives
    echo "Step 1: Select archives to compare"
    local selected=$(_archive_select_enhanced "Select archives to compare" "true" "$HOME")

    [[ -z "$selected" ]] && { echo "No archives selected"; return 1; }

    local archive_count=$(echo "$selected" | wc -l)
    echo "Selected $archive_count archives"
    echo ""

    if [[ $archive_count -lt 2 ]]; then
        echo "[ERROR] Need at least 2 archives for comparison"
        return 1
    fi

    # Create index directory
    local index_dir="${ARCHIVE_CACHE_DIR}/compare-$(date +%s)"
    mkdir -p "$index_dir"

    echo "Step 2: Indexing archive contents..."
    local archive_num=0
    while IFS= read -r archive; do
        ((archive_num++))
        local name=$(basename "$archive")
        echo "  [$archive_num] Indexing: $name"

        (7z l -slt "$archive" 2>/dev/null | grep "^Path = " | sed 's/^Path = //' || \
         tar -tf "$archive" 2>/dev/null || \
         unzip -l "$archive" 2>/dev/null | awk 'NR>3 {print $4}') | \
            sort > "$index_dir/$archive_num.index"

        echo "$archive" > "$index_dir/$archive_num.name"
    done <<< "$selected"

    echo ""
    echo "Step 3: Comparing contents..."
    echo ""

    # Build comparison report
    local report="${index_dir}/comparison.md"
    {
        echo "# Archive Comparison Report"
        echo "Generated: $(date)"
        echo ""
        echo "## Archives"
        for i in $(seq 1 $archive_num); do
            local name=$(cat "$index_dir/$i.name")
            local count=$(wc -l < "$index_dir/$i.index")
            echo "- **Archive $i**: $(basename "$name") ($count files)"
        done
        echo ""

        if [[ $archive_num -eq 2 ]]; then
            echo "## Comparison Results"
            echo ""

            local common=$(comm -12 "$index_dir/1.index" "$index_dir/2.index" | wc -l)
            local only1=$(comm -23 "$index_dir/1.index" "$index_dir/2.index" | wc -l)
            local only2=$(comm -13 "$index_dir/1.index" "$index_dir/2.index" | wc -l)

            echo "| Metric | Count |"
            echo "|--------|-------|"
            echo "| Common files | $common |"
            echo "| Only in Archive 1 | $only1 |"
            echo "| Only in Archive 2 | $only2 |"
            echo ""

            local total1=$(wc -l < "$index_dir/1.index")
            local total2=$(wc -l < "$index_dir/2.index")

            if [[ $total1 -gt 0 ]]; then
                local pct1=$((common * 100 / total1))
                echo "Archive 1 overlap: ${pct1}%"
            fi
            if [[ $total2 -gt 0 ]]; then
                local pct2=$((common * 100 / total2))
                echo "Archive 2 overlap: ${pct2}%"
            fi
        fi
    } > "$report"

    # Display report
    if command -v bat >/dev/null 2>&1; then
        bat --style=plain "$report"
    else
        cat "$report"
    fi

    echo ""

    # Interactive exploration
    if [[ $archive_num -eq 2 ]]; then
        echo "Interactive exploration:"
        local choice=$(printf '%s\n' \
            "common - View common files" \
            "unique1 - View files only in Archive 1" \
            "unique2 - View files only in Archive 2" \
            "done - Exit" | \
            fzf --prompt="Select > " --height=30%)

        case "$choice" in
            common*)
                comm -12 "$index_dir/1.index" "$index_dir/2.index" | \
                    fzf --prompt="Common files > " --preview="echo {}"
                ;;
            unique1*)
                comm -23 "$index_dir/1.index" "$index_dir/2.index" | \
                    fzf --prompt="Only in Archive 1 > " --preview="echo {}"
                ;;
            unique2*)
                comm -13 "$index_dir/1.index" "$index_dir/2.index" | \
                    fzf --prompt="Only in Archive 2 > " --preview="echo {}"
                ;;
        esac
    fi

    echo ""
    echo "Report saved: $report"

    # Cleanup prompt
    read "?Clean up temporary files? [Y/n] " response
    if [[ ! "$response" =~ ^[Nn]$ ]]; then
        rm -rf "$index_dir"
        echo "Cleaned up."
    fi
}

# ==============================================================================
# POPUP-ENABLED OPERATIONS
# ==============================================================================

# Quick disk scan in popup
disk-scan-popup() {
    local target="${1:-$PWD}"
    _run_in_popup "Disk Usage: $target" "gdu '$target'"
}

# Large files finder in popup
large-files-popup() {
    local threshold="${1:-100M}"
    local target="${2:-$PWD}"

    local cmd="fd --type f --size +$threshold . '$target' | \
        fzf --multi \
            --prompt='Files > $threshold > ' \
            --preview='du -h {} && file {} && echo \"\" && bat --style=plain --color=always --line-range :30 {} 2>/dev/null' \
            --preview-window=right:55%:wrap \
            --header='CTRL-T: trash | CTRL-Y: copy path' \
            --bind 'ctrl-t:execute(trash-put {})+reload(fd --type f --size +$threshold . \"$target\")' \
            --bind 'ctrl-y:execute-silent(echo {} | wl-copy)'"

    _fzf_popup "Large Files (>$threshold)" "$cmd"
}

# Duplicate finder in popup
duplicates-popup() {
    local target="${1:-$PWD}"

    local cmd="fclones group '$target' 2>/dev/null | grep -v '^#' | grep -v '^$' | \
        fzf --multi \
            --prompt='Duplicates > ' \
            --preview='du -h {} && file {} && echo \"\" && bat --style=plain --color=always --line-range :30 {} 2>/dev/null' \
            --preview-window=right:55%:wrap \
            --header='TAB: select | CTRL-T: trash | ENTER: view' \
            --bind 'ctrl-t:execute(trash-put {})' \
            --bind 'enter:execute(bat --style=numbers --color=always {} | less -R)'"

    _fzf_popup "Duplicate Files" "$cmd"
}

# ==============================================================================
# ENHANCED MENU
# ==============================================================================

archive-menu-enhanced() {
    local option=$(cat <<'EOF' | fzf --prompt="Archive Operations > " \
        --preview='echo {}' \
        --preview-window=up:3:wrap \
        --height=80% \
        --border=rounded \
        --header="Enhanced Archive Deduplication & Management"
 1. List Active Mounts     - Show all fuse-archive and rclone mounts
 2. Clean Stale Mounts     - Remove orphaned mount directories
 3. Cross-Archive Dedupe   - Mount and compare multiple archives
 4. Quick Duplicate Scan   - Fast fclones-based scan (popup)
 5. Enhanced Comparison    - Rich archive content comparison
 6. Archive Search         - Search content inside archives (popup)
 7. Parallel Search        - Multi-agent rga search for speed
 8. Hash-Based Dedupe      - Build hash database and find duplicates
 9. Large Files (popup)    - Find large files with actions
10. Disk Scan (popup)      - Interactive GDU in popup
11. Mount Remote           - Mount rclone remote for browsing
12. Compare with Remote    - Compare local vs remote archives
13. Sync to Remote         - Upload archives to cloud
14. Unmount All            - Unmount all archive mounts
EOF
)

    [[ -z "$option" ]] && return 0

    case ${option%%. *} in
         1) archive-mounts-list 2>/dev/null || echo "Run archive-mounts-list" ;;
         2) archive-mounts-clean 2>/dev/null || echo "Run archive-mounts-clean" ;;
         3) archive-dedupe-cross 2>/dev/null || echo "Run archive-dedupe-cross" ;;
         4) duplicates-popup ;;
         5) archive-compare-enhanced ;;
         6) archive-search-popup ;;
         7) parallel-rga-search ;;
         8) archive-hash-dedupe 2>/dev/null || echo "Run archive-hash-dedupe" ;;
         9) large-files-popup ;;
        10) disk-scan-popup ;;
        11) rclone-mount-remote 2>/dev/null || echo "Run rclone-mount-remote" ;;
        12) archive-compare-remote 2>/dev/null || echo "Run archive-compare-remote" ;;
        13) archive-sync-to-remote 2>/dev/null || echo "Run archive-sync-to-remote" ;;
        14) archive-unmount-all 2>/dev/null || echo "Run archive-unmount-all" ;;
    esac
}

# ==============================================================================
# ALIASES
# ==============================================================================

alias arcme="archive-menu-enhanced"
alias arcsearch="archive-search-popup"
alias arcdupes="duplicates-popup"
alias arcpar="parallel-rga-search"
alias arclarge="large-files-popup"

# ==============================================================================
# Help Function
# ==============================================================================

archive-help-enhanced() {
    cat <<'EOF'
=== Enhanced Archive Deduplication Functions ===

POPUP OPERATIONS (tmux overlay, yazi stays visible):
  archive-search-popup [pattern] [target]  - Search archives in popup
  duplicates-popup [target]                - Find duplicates in popup
  large-files-popup [threshold] [target]   - Find large files in popup
  disk-scan-popup [target]                 - Run GDU in popup

PARALLEL SEARCH:
  parallel-rga-search <pattern> [target] [agents]
    - Search archives using multiple parallel agents
    - Default: 4 agents for moderate hardware

  parallel-rga-bidirectional <pattern> [target]
    - Experimental: two agents searching from opposite ends

ENHANCED OPERATIONS:
  archive-compare-enhanced    - Rich archive content comparison
  archive-dedupe-enhanced     - Interactive duplicate detection
  archive-menu-enhanced       - Full enhanced menu

ALIASES:
  arcme     = archive-menu-enhanced
  arcsearch = archive-search-popup
  arcdupes  = duplicates-popup
  arcpar    = parallel-rga-search
  arclarge  = large-files-popup

FZF KEYBINDINGS (in fzf selections):
  TAB       - Select/deselect item
  CTRL-A    - Toggle all
  CTRL-T    - Trash selected file
  CTRL-Y    - Copy path to clipboard
  CTRL-O    - Open containing directory
  CTRL-/    - Toggle preview
  ENTER     - Confirm or execute action

EOF
}
