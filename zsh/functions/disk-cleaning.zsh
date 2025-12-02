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
