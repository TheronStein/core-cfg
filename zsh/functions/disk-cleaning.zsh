# ------------------------------------------------------------
# Interactive multi-directory deduplication with fzf + czkawka/rmlint
# ------------------------------------------------------------
dedupe-dirs() {
  local dirs=$(fd . / --type d --hidden --exclude '.git' --exclude 'node_modules' 2>/dev/null | \
    fzf --multi --prompt="Select directories to scan for duplicates > " \
        --preview="du -sh {} | bat --style=numbers --color=always -l toml" \
        --preview-window=right:50%)

  [[ -z "$dirs" ]] && echo "No directories selected" && return 1

  echo "Selected directories:"
  echo "$dirs" | sed 's/^/  /'

  # Choose tool
  local tool=$(printf "czkawka\nrmlint\nrdfind\nfdupes" | fzf --prompt="Choose deduplication tool > ")

  case $tool in
    czkawka)
      echo "Running czkawka (interactive GUI will open)..."
      czkawka dup -d $(echo $dirs | tr '\n' ':')
      ;;
    rmlint)
      echo "Running rmlint..."
      rmlint $dirs
      echo "Report generated. Run: cat ./rmlint.log"
      echo "To act: ./rmlint.sh -d -p  # dry-run with preview"
      ;;
    rdfind)
      rdfind -makeresultfile false -deletefirst true $dirs
      ;;
    fdupes)
      fdupes -r -d --noprompt $dirs  # dangerous! removes without asking if --noprompt
      ;;
  esac
}

# ------------------------------------------------------------
# Enhanced interactive duplicate finder with tool selection
# ------------------------------------------------------------
dedupe-interactive() {
    local target_dir="${1:-$PWD}"

    echo "Scanning: $target_dir"
    echo ""

    # Tool selection with descriptions
    local tool=$(printf "rmlint - Generates safe removal script (recommended)\nfclones - Fast parallel scanning (Rust)\njdupes - High-performance hash-based\nczkawka-cli - Feature-rich with GUI option\nrdfind - Priority-based deletion" | \
        fzf --prompt="Select deduplication tool > " \
            --header="Choose a tool for duplicate detection" \
            --preview-window=hidden)

    [[ -z "$tool" ]] && return 1

    case "$tool" in
        rmlint*)
            if command -v rmlint >/dev/null 2>&1; then
                echo "Running rmlint (safe mode)..."
                rmlint --types=duplicates --progress "$target_dir"
                echo ""
                echo "Generated files:"
                echo "  - rmlint.json (machine-readable results)"
                echo "  - rmlint.sh   (safe removal script)"
                echo ""
                echo "To review and execute:"
                echo "  1. Review: bat rmlint.sh"
                echo "  2. Dry-run: ./rmlint.sh -d -p"
                echo "  3. Execute: ./rmlint.sh -d"
            else
                echo "rmlint not installed. Install with: paru -S rmlint"
            fi
            ;;
        fclones*)
            if command -v fclones >/dev/null 2>&1; then
                echo "Running fclones..."
                local dupes=$(fclones group "$target_dir")
                if [[ -n "$dupes" ]]; then
                    echo "$dupes" | \
                        fzf --multi --prompt="Select duplicates to remove > " \
                            --preview="bat --style=numbers --color=always {} 2>/dev/null || file {}" \
                            --header="TAB to select, ENTER to trash" | \
                        xargs -I{} trash-put "{}"
                else
                    echo "No duplicates found."
                fi
            else
                echo "fclones not installed (being installed). Install with: paru -S fclones"
            fi
            ;;
        jdupes*)
            if command -v jdupes >/dev/null 2>&1; then
                echo "Running jdupes..."
                jdupes -r -S "$target_dir" | \
                    fzf --multi --prompt="Select duplicates > " \
                        --preview="bat --style=numbers --color=always {} 2>/dev/null || file {}"
            else
                echo "jdupes not installed (being installed). Install with: paru -S jdupes"
            fi
            ;;
        czkawka*)
            if command -v czkawka-cli >/dev/null 2>&1; then
                echo "Running czkawka-cli..."
                local results="/tmp/czkawka-results-$$.txt"
                czkawka-cli dup -d "$target_dir" -f "$results"
                if [[ -f "$results" ]]; then
                    cat "$results" | fzf --multi --prompt="Review duplicates > "
                    rm -f "$results"
                fi
            else
                echo "czkawka-cli not installed (being installed). Install with: paru -S czkawka-cli"
            fi
            ;;
        rdfind*)
            if command -v rdfind >/dev/null 2>&1; then
                echo "Running rdfind (dry-run first)..."
                rdfind -dryrun true "$target_dir"
                echo ""
                read "?Proceed with deletion? [y/N] " response
                [[ "$response" =~ ^[Yy]$ ]] && rdfind -deleteduplicates true "$target_dir"
            else
                echo "rdfind not installed. Install with: paru -S rdfind"
            fi
            ;;
    esac
}

# ------------------------------------------------------------
# Find and compare contents of multiple archive files (.zip, .tar.gz, etc.)
# ------------------------------------------------------------
archive-compare() {
  local archives=$(fd --extension zip --extension tar.gz --extension tar.xz --extension 7z --type f . ~ | \
    fzf --multi --prompt="Select archives to compare > " \
        --preview="7z l {} | bat --style=plain --color=always" \
        --preview-window=right:60%)

  [[ -z "$archives" ]] && return 1

  local tmpdir=$(mktemp -d)
  trap 'rm -rf $tmpdir' EXIT

  local selected=(${(f)archives})

  for arch in $selected; do
    echo "Extracting $arch..."
    7z x "$arch" -o"$tmpdir/$(basename $arch)" -y >/dev/null 2>&1 || \
      tar -xf "$arch" -C "$tmpdir/$(basename $arch)" 2>/dev/null || \
      unzip -q "$arch" -d "$tmpdir/$(basename $arch)" 2>/dev/null
  done

  echo "Running czkawka on extracted contents..."
  czkawka dup -d $tmpdir/*/
}

# ------------------------------------------------------------
# Smart archive deduplication: keep largest, remove duplicates from others
# ------------------------------------------------------------
archive-dedupe-smart() {
  local archives=$(fd --extension zip --extension tar.gz --extension tar.xz --extension 7z --type f . ~ | \
    fzf --multi --prompt="Select archives (largest will be kept) > " \
        --preview="echo Size: $(du -h {} | cut -f1); 7z l {} | tail -20 | bat --style=plain")

  [[ -z "$archives" ]] && return 1

  local tmpdir=$(mktemp -d)
  trap 'rm -rf $tmpdir' EXIT

  # Sort by size descending, first one is the "master"
  local sorted=($(echo $archives | tr ' ' '\n' | xargs du -h | sort -hr | cut -f2-))
  local master=${sorted[1]}
  local others=(${sorted[2,-1]})

  echo "Master archive (kept): $master"
  7z x "$master" -o"$tmpdir/master" -y >/dev/null 2>&1 || tar -xf "$master" -C "$tmpdir/master"

  for arch in $others; do
    local extract_dir="$tmpdir/$(basename $arch)"
    mkdir -p "$extract_dir"
    7z x "$arch" -o"$extract_dir" -y >/dev/null 2>&1 || tar -xf "$arch" -C "$extract_dir" 2>/dev/null || unzip -q "$arch" -d "$extract_dir"

    echo "Removing duplicates from $(basename $arch)..."
    czkawka dup -d "$tmpdir/master" "$extract_dir" --delete 2>/dev/null || \
      rmlint "$tmpdir/master" "$extract_dir" --merge-directories

    # Re-compress cleaned archive
    local newname="${arch}.deduped$(echo $arch | grep -o '\.[^.]*$')"
    (cd "$extract_dir" && find . -type f | sort | 7z a -tzip "$newname" . >/dev/null 2>&1 || tar -czf "$newname" .)
    mv "$extract_dir/$newname" "$(dirname $arch)/"
    echo "Saved cleaned: $(dirname $arch)/$newname"
  done

  echo "Deduplication complete. Master: $master"
}

# ------------------------------------------------------------
# Interactive disk usage inspector with fzf drill-down (like ncdu but better)
# ------------------------------------------------------------
disk-inspect() {
  dua interactive /home/$USER /mnt /media 2>/dev/null || dua interactive ~
}

# ------------------------------------------------------------
# Find big files/directories with fzf preview
# ------------------------------------------------------------
bigfiles() {
  local threshold="100M"
  [[ -n $1 ]] && threshold=$1

  du -ah . 2>/dev/null | \
    awk -v thresh="$threshold" '$1 ~ /M|G$/ && $1+0 >= thresh+0 {print $0}' | \
    sort -hr | \
    fzf --preview='echo {} | cut -d$"\t" -f2- | xargs -I% du -h %' \
        --preview-window=right:50% \
        --bind 'enter:execute(trash {} > /dev/null && echo "Trashed: {}")+reload(du -ah . | grep -v "^0")'
}

# ------------------------------------------------------------
# Remove empty directories interactively
# ------------------------------------------------------------
clean-empty() {
  fd --type empty --type d . | \
    fzf --multi --prompt="Select empty dirs to delete > " \
        --preview="echo Will delete: {}" \
        --bind "enter:execute(rmdir {} && echo Deleted {})+reload(fd --type empty --type d .)"
}

# Sync large files to cloud before deletion
cloud-backup-large() {
  local threshold=${1:-500M}
  local remote=${2:-"your-remote:backup"}
  
  fd --type f --size "+${threshold}" . | \
    fzf --multi --prompt="Select files to backup to cloud > " \
        --preview="du -h {} && rclone lsf $remote | grep -q $(basename {}) && echo '[ALREADY BACKED UP]'" | \
    while read file; do
      echo "Uploading $file to $remote..."
      rclone copy "$file" "$remote/$(dirname $file)" --progress
    done
}

# Interactive rclone mount browser
cloud-browse() {
  local remote=$(rclone listremotes | fzf --prompt="Select remote > ")
  [[ -z "$remote" ]] && return 1
  
  local mountpoint="/tmp/rclone-${remote%:}"
  mkdir -p "$mountpoint"
  
  rclone mount "$remote" "$mountpoint" --daemon
  yazi "$mountpoint"
  fusermount -u "$mountpoint"
}

# Arch-specific package cache cleaning
clean-pkg-cache() {
  echo "==> Pacman cache:"
  paccache -d  # dry run first
  
  read "?Remove all but 3 recent versions? [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]] && paccache -r
  
  if command -v yay &>/dev/null; then
    echo "==> AUR cache:"
    yay -Sc
  fi
}

# Clean system logs, thumbnails, cache
clean-system-cruft() {
  echo "==> Journal logs older than 2 weeks:"
  sudo journalctl --disk-usage
  read "?Clean? [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]] && sudo journalctl --vacuum-time=2weeks
  
  echo "==> Thumbnail cache:"
  du -sh ~/.cache/thumbnails
  read "?Clean? [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]] && rm -rf ~/.cache/thumbnails/*
  
  echo "==> Browser caches:"
  du -sh ~/.cache/mozilla ~/.cache/chromium 2>/dev/null
}

# Docker cleanup
clean-docker() {
  echo "==> Docker disk usage:"
  docker system df
  
  read "?Prune unused images/containers? [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]] && docker system prune -a
}

# Clean up git repositories
clean-git-repos() {
  fd --type d --hidden '^\.git$' ~ | \
    fzf --multi --prompt="Select repos to clean > " \
        --preview="git -C {//} status && echo '\n--- Size ---' && du -sh {//}" | \
    while read gitdir; do
      repo="${gitdir%/.git}"
      echo "Cleaning $repo..."
      git -C "$repo" gc --aggressive --prune=now
      git -C "$repo" remote prune origin
      git -C "$repo" worktree prune
    done
}

cloud-backup-large() {
  local threshold=${1:-500M}
  
  # First, pick remote with preview
  local remote=$(rclone listremotes | fzf \
    --prompt="Select backup remote > " \
    --preview="rclone about {} 2>/dev/null || echo 'Remote: {}'" \
    --preview-window=up:5:wrap)
  
  [[ -z "$remote" ]] && return 1
  
  # Then select files with size preview
  local files=$(fd --type f --size "+${threshold}" . | \
    fzf --multi \
        --prompt="Select files to backup to ${remote} > " \
        --preview="du -h {} && echo '\n--- Remote Status ---' && rclone lsf ${remote} | grep -q \$(basename {}) && echo '[✓ ALREADY BACKED UP]' || echo '[✗ NOT BACKED UP]'" \
        --preview-window=right:50%:wrap \
        --header="TAB: select | ENTER: confirm upload")
  
  [[ -z "$files" ]] && return 1
  
  echo "$files" | while read file; do
    echo "Uploading $file to $remote..."
    rclone copy "$file" "$remote/$(dirname $file)" --progress
  done
}

# Browse and restore from cloud
cloud-restore() {
  local remote=$(rclone listremotes | fzf --prompt="Select remote > ")
  [[ -z "$remote" ]] && return 1
  
  local file=$(rclone lsf "$remote" --recursive | \
    fzf --prompt="Select file to restore > " \
        --preview="rclone cat ${remote}/{} | head -100" \
        --preview-window=right:60%)
  
  [[ -z "$file" ]] && return 1
  
  local dest=$(fd --type d . ~ | fzf --prompt="Restore to > " --preview="ls -la {}")
  [[ -z "$dest" ]] && return 1
  
  rclone copy "${remote}${file}" "$dest" --progress
  echo "Restored to $dest/$(basename $file)"
}

# Find big files → backup → delete pipeline
clean-big-files-pipeline() {
  echo "Step 1: Find big files"
  local files=$(bigfiles 500M)
  [[ -z "$files" ]] && return 1
  
  echo "Step 2: Backup to cloud?"
  read "?Backup first? [Y/n] " response
  if [[ ! "$response" =~ ^[Nn]$ ]]; then
    echo "$files" | while read file; do
      cloud-backup-large 0 "your-remote:backup/${file}"
    done
  fi
  
  echo "Step 3: Delete?"
  echo "$files" | fzf --multi --prompt="Select files to delete > " | \
    xargs -I{} trash {}
}

# Dedupe → compress → upload pipeline
dedupe-compress-upload() {
  dedupe-dirs
  
  echo "Compress deduped directories?"
  local dirs=$(fd --type d . | fzf --multi --prompt="Select dirs to compress > ")
  [[ -z "$dirs" ]] && return 1
  
  echo "$dirs" | while read dir; do
    tar -czf "${dir}.tar.gz" "$dir"
    cloud-backup-large 0 "your-remote:archives" "${dir}.tar.gz"
  done
}


# Master disk cleaning menu
disk-menu() {
  local option=$(cat <<EOF | fzf --prompt="Disk Cleaning > " \
    --preview='echo {}' \
    --preview-window=up:3:wrap \
    --height=60% \
    --border=rounded \
    --header="Select disk cleaning operation"
1. Deduplicate directories
2. Find big files (>100M)
3. Interactive disk inspector
4. Remove empty directories
5. Backup large files to cloud
6. Clean package cache
7. Clean system cruft (logs/thumbnails)
8. Clean Docker containers
9. Clean git repositories
10. Archive comparison
11. Archive deduplication
EOF
)

  case ${option%%. *} in
    1) dedupe-dirs ;;
    2) bigfiles ;;
    3) disk-inspect ;;
    4) clean-empty ;;
    5) cloud-backup-large ;;
    6) clean-pkg-cache ;;
    7) clean-system-cruft ;;
    8) clean-docker ;;
    9) clean-git-repos ;;
    10) archive-compare ;;
    11) archive-dedupe-smart ;;

  esac
}

# ------------------------------------------------------------
# NEW ENHANCED FUNCTIONS
# ------------------------------------------------------------

# GDU Popup Scan (for tmux integration)
disk-scan() {
    local target="${1:-$PWD}"
    if [[ -n "$TMUX" ]]; then
        tmux popup -E -w 90% -h 90% -T " Disk Usage: $target " gdu "$target"
    else
        gdu "$target"
    fi
}

# Quick disk usage overview with multiple tools
disk-overview() {
    echo "=== Disk Overview ==="
    echo ""
    echo "--- Filesystem Usage ---"
    if command -v duf >/dev/null 2>&1; then
        duf --only local
    else
        df -h
    fi
    echo ""
    echo "--- Top 10 directories in current path ---"
    if command -v dust >/dev/null 2>&1; then
        dust -d 1 -n 10 .
    else
        du -h --max-depth=1 . 2>/dev/null | sort -hr | head -10
    fi
    echo ""
    echo "--- Largest files (>100MB) ---"
    fd --type f --size +100M . 2>/dev/null | head -10 || find . -type f -size +100M 2>/dev/null | head -10
}

# Find files by size threshold with actions
find-by-size() {
    local threshold="${1:-100M}"

    fd --type f --size "+${threshold}" . | \
        fzf --multi \
            --prompt="Files > ${threshold} > " \
            --preview='echo "Size: $(du -h {} | cut -f1)"; echo "Modified: $(stat -c %y {} 2>/dev/null || stat -f %Sm {})"; echo "---"; bat --style=numbers --color=always --line-range :50 {} 2>/dev/null || file {}' \
            --preview-window=right:60%:wrap \
            --header="ENTER: view | CTRL-D: trash | CTRL-B: backup | CTRL-O: open dir" \
            --bind "ctrl-d:execute(trash-put {})+reload(fd --type f --size +${threshold} .)" \
            --bind "ctrl-b:execute(echo 'Backing up...' && rclone copy {} \$(rclone listremotes | head -1)backup/)+reload(fd --type f --size +${threshold} .)" \
            --bind "ctrl-o:execute(cd \$(dirname {}) && \$SHELL)" \
            --bind "enter:execute(bat {} 2>/dev/null || less {})"
}

# System cleanup wizard (interactive)
clean-wizard() {
    local total_before=$(df -h / | awk 'NR==2 {print $4}')
    echo "=== System Cleanup Wizard ==="
    echo "Free space before: $total_before"
    echo ""

    local options=$(cat <<'EOF'
1. Package cache (pacman/AUR)
2. Journal logs (older than 2 weeks)
3. Thumbnail cache
4. Browser caches
5. Docker unused resources
6. Empty directories
7. Git repository cleanup
8. Orphaned packages
9. Trash (empty trash)
A. Run ALL safe cleanup tasks
EOF
)

    local choices=$(echo "$options" | fzf --multi --prompt="Select cleanup tasks > " --header="Use TAB to select multiple")

    [[ -z "$choices" ]] && return 0

    echo "$choices" | while IFS= read -r line; do
        local num="${line%%.*}"
        case "$num" in
            1)
                echo ""
                echo "==> Cleaning package cache..."
                if command -v paccache >/dev/null 2>&1; then
                    paccache -d
                    read "?Remove all but 3 recent versions? [y/N] " response
                    [[ "$response" =~ ^[Yy]$ ]] && paccache -r
                fi
                ;;
            2)
                echo ""
                echo "==> Cleaning journal logs..."
                sudo journalctl --disk-usage
                sudo journalctl --vacuum-time=2weeks
                ;;
            3)
                echo ""
                echo "==> Cleaning thumbnail cache..."
                du -sh ~/.cache/thumbnails 2>/dev/null
                rm -rf ~/.cache/thumbnails/*
                echo "Thumbnail cache cleared."
                ;;
            4)
                echo ""
                echo "==> Cleaning browser caches..."
                local firefox_cache=~/.cache/mozilla/firefox/*/cache2
                local chromium_cache=~/.cache/chromium/*/Cache
                local chrome_cache=~/.cache/google-chrome/*/Cache
                du -sh $firefox_cache $chromium_cache $chrome_cache 2>/dev/null
                rm -rf $firefox_cache/* $chromium_cache/* $chrome_cache/* 2>/dev/null
                echo "Browser caches cleared."
                ;;
            5)
                echo ""
                echo "==> Cleaning Docker..."
                if command -v docker >/dev/null 2>&1; then
                    docker system df
                    read "?Prune unused resources? [y/N] " response
                    [[ "$response" =~ ^[Yy]$ ]] && docker system prune -af
                else
                    echo "Docker not installed."
                fi
                ;;
            6)
                echo ""
                echo "==> Finding empty directories..."
                clean-empty
                ;;
            7)
                echo ""
                echo "==> Cleaning git repositories..."
                clean-git-repos
                ;;
            8)
                echo ""
                echo "==> Removing orphaned packages..."
                local orphans=$(paru -Qtdq 2>/dev/null)
                if [[ -n "$orphans" ]]; then
                    echo "$orphans"
                    read "?Remove these orphaned packages? [y/N] " response
                    [[ "$response" =~ ^[Yy]$ ]] && paru -Rns $(paru -Qtdq)
                else
                    echo "No orphaned packages found."
                fi
                ;;
            9)
                echo ""
                echo "==> Emptying trash..."
                trash-empty
                ;;
            A)
                echo ""
                echo "==> Running all safe cleanup tasks..."
                command -v paccache >/dev/null 2>&1 && paccache -rk 2
                sudo journalctl --vacuum-time=2weeks
                rm -rf ~/.cache/thumbnails/*
                command -v docker >/dev/null 2>&1 && docker system prune -f
                fd --type empty --type d . ~ 2>/dev/null | xargs -r rmdir 2>/dev/null
                echo "Safe cleanup complete."
                ;;
        esac
    done

    echo ""
    local total_after=$(df -h / | awk 'NR==2 {print $4}')
    echo "Free space after: $total_after"
}

# Inode usage checker (for too many small files)
check-inodes() {
    echo "=== Inode Usage ==="
    df -i / /home 2>/dev/null | column -t
    echo ""
    echo "=== Top 20 directories by file count ==="
    local target="${1:-.}"
    fd --type f . "$target" 2>/dev/null | \
        awk -F/ '{path=""; for(i=1;i<NF;i++) path=path"/"$i; print path}' | \
        sort | uniq -c | sort -rn | head -20
}

# Archive content searcher using ripgrep-all
search-archives() {
    local pattern="$1"
    local target="${2:-$PWD}"

    if [[ -z "$pattern" ]]; then
        read "pattern?Search pattern: "
    fi

    [[ -z "$pattern" ]] && return 1

    echo "Searching for '$pattern' in archives under $target..."

    if command -v rga >/dev/null 2>&1; then
        rga --files-with-matches "$pattern" "$target" 2>/dev/null | \
            fzf --preview="rga --context 3 '$pattern' {} 2>/dev/null | bat --style=plain --color=always" \
                --preview-window=right:60%:wrap \
                --prompt="Archives matching '$pattern' > " \
                --header="ENTER to view full matches"
    else
        echo "ripgrep-all (rga) not installed. Install with: paru -S ripgrep-all"
    fi
}

# Storage trends (for monitoring over time)
storage-log() {
    local logfile="${HOME}/.local/state/disk-usage.log"
    mkdir -p "$(dirname "$logfile")"

    case "${1:-show}" in
        record)
            local usage=$(df -h / | awk 'NR==2 {print $3, $4, $5}')
            echo "$(date -Iseconds) $usage" >> "$logfile"
            echo "Recorded: $usage"
            ;;
        show)
            if [[ -f "$logfile" ]]; then
                echo "=== Storage Trends (last 30 entries) ==="
                echo "Date                      Used   Free   Use%"
                echo "----------------------------------------"
                tail -30 "$logfile" | while read -r line; do
                    printf "%s\n" "$line"
                done
            else
                echo "No log file found. Run 'storage-log record' to start tracking."
                echo "Tip: Add to crontab: 0 0 * * * /bin/zsh -c 'source ~/.zshrc && storage-log record'"
            fi
            ;;
        graph)
            if [[ -f "$logfile" ]]; then
                echo "=== Storage Usage Graph ==="
                tail -30 "$logfile" | awk '{print $NF}' | \
                    sed 's/%//' | \
                    while read pct; do
                        bar=$(printf '=%.0s' $(seq 1 $((pct/2))))
                        printf "%3d%% |%-50s|\n" "$pct" "$bar"
                    done
            fi
            ;;
        clear)
            rm -f "$logfile"
            echo "Storage log cleared."
            ;;
        *)
            echo "Usage: storage-log [record|show|graph|clear]"
            ;;
    esac
}

# Quick space recovery suggestions
space-suggestions() {
    echo "=== Space Recovery Suggestions ==="
    echo ""

    # Package cache
    local pkg_cache=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1)
    [[ -n "$pkg_cache" ]] && echo "1. Package cache: $pkg_cache (run: paccache -r)"

    # Journal logs
    local journal=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.?\d*[GMK]')
    [[ -n "$journal" ]] && echo "2. Journal logs: $journal (run: sudo journalctl --vacuum-time=2weeks)"

    # Thumbnail cache
    local thumbs=$(du -sh ~/.cache/thumbnails 2>/dev/null | cut -f1)
    [[ -n "$thumbs" ]] && echo "3. Thumbnails: $thumbs (run: rm -rf ~/.cache/thumbnails/*)"

    # Trash
    local trash=$(du -sh ~/.local/share/Trash 2>/dev/null | cut -f1)
    [[ -n "$trash" ]] && echo "4. Trash: $trash (run: trash-empty)"

    # Docker
    if command -v docker >/dev/null 2>&1; then
        local docker_size=$(docker system df --format '{{.Size}}' 2>/dev/null | head -1)
        [[ -n "$docker_size" ]] && echo "5. Docker: $docker_size (run: docker system prune -a)"
    fi

    # npm/yarn cache
    local npm_cache=$(du -sh ~/.npm 2>/dev/null | cut -f1)
    [[ -n "$npm_cache" ]] && echo "6. npm cache: $npm_cache (run: npm cache clean --force)"

    # Largest directories in home
    echo ""
    echo "=== Largest directories in ~/ ==="
    du -h --max-depth=2 ~ 2>/dev/null | sort -hr | head -10
}

# Enhanced disk menu with more options
disk-menu-enhanced() {
    local option=$(cat <<'EOF' | fzf --prompt="Disk Cleaning > " \
        --preview='echo {}' \
        --preview-window=up:3:wrap \
        --height=70% \
        --border=rounded \
        --header="Select disk cleaning operation"
 1. Disk Overview          - Quick usage summary
 2. Interactive Scan (GDU) - Full disk analyzer
 3. Find Duplicates        - Multi-tool duplicate finder
 4. Find Big Files (>100M) - With preview and actions
 5. Find Big Files (>500M) - Larger threshold
 6. Remove Empty Dirs      - Clean empty directories
 7. Archive Search         - Search inside archives (rga)
 8. Backup to Cloud        - Upload files to remote
 9. Browse Cloud           - Mount and browse remotes
10. Cleanup Wizard         - Interactive system cleanup
11. Space Suggestions      - Quick recovery tips
12. Storage Trends         - View usage over time
13. Inode Check            - File count analysis
14. Package Cache          - Clean pacman/AUR cache
15. Git Repos              - Clean git repositories
16. Docker Cleanup         - Prune Docker resources
EOF
)

    [[ -z "$option" ]] && return 0

    case ${option%%. *} in
         1) disk-overview ;;
         2) disk-scan ;;
         3) dedupe-interactive ;;
         4) find-by-size 100M ;;
         5) find-by-size 500M ;;
         6) clean-empty ;;
         7) search-archives ;;
         8) cloud-backup-large ;;
         9) cloud-browse ;;
        10) clean-wizard ;;
        11) space-suggestions ;;
        12) storage-log show ;;
        13) check-inodes ;;
        14) clean-pkg-cache ;;
        15) clean-git-repos ;;
        16) clean-docker ;;
    esac
}
