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
