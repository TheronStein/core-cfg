# ============================================================================
# Cleaning Functions Help Menu
# ============================================================================

# Main help menu for all cleaning functions
clean-help() {
    local choice

    choice=$(cat <<'EOF' | fzf --prompt="Cleaning Help > " \
        --header="Select a category or function to learn more" \
        --preview='echo {}' \
        --preview-window=up:3:wrap \
        --height=80% \
        --border=rounded
━━━ MAIN MENUS ━━━
disk-menu-enhanced (dc-menu) - Interactive disk cleaning menu (16 options)
clean-wizard - Interactive step-by-step cleanup wizard

━━━ ANALYSIS & DISCOVERY ━━━
disk-overview - Quick disk usage overview
disk-scan - Interactive disk scanner (GDU in tmux popup)
disk-inspect - Interactive disk usage analyzer (DUA)
bigfiles - Find big files with interactive deletion
find-by-size - Find files by size threshold with actions
space-suggestions - Show quick space recovery suggestions
storage-log - Track and visualize disk usage over time
check-inodes - Check inode usage and file counts

━━━ CLEANING FUNCTIONS ━━━
clean-pkg-cache - Clean pacman/AUR package caches
clean-system-cruft - Clean logs, thumbnails, browser caches
clean-docker - Clean Docker containers and images
clean-git-repos - Clean git repositories interactively
clean-empty - Remove empty directories
clear-zsh-cache - Clear all ZSH caches
cleanup-zwc-files - Remove orphaned compiled ZSH files
trash - Safe delete files to trash

━━━ DEDUPLICATION ━━━
dedupe-dirs - Multi-directory deduplication
dedupe-interactive - Enhanced interactive duplicate finder
archive-compare - Compare contents of archive files
archive-dedupe-smart - Smart archive deduplication
search-archives - Search inside archives with ripgrep-all

━━━ CLOUD BACKUP ━━━
cloud-backup-large - Backup large files to cloud storage
cloud-browse - Mount and browse cloud remotes
cloud-restore - Restore files from cloud storage

━━━ PIPELINES ━━━
clean-big-files-pipeline - Find → Backup → Delete pipeline
dedupe-compress-upload - Dedupe → Compress → Upload pipeline

━━━ UTILITIES ━━━
Show all cleaning commands - List all available commands
Quick start guide - How to get started
EOF
)

    case "$choice" in
        "disk-menu-enhanced"*)
            clean-help-detail "disk-menu-enhanced" \
                "Interactive disk cleaning menu with 16 options" \
                "dc-menu OR disk-menu-enhanced" \
                "Comprehensive fzf menu providing access to all disk cleaning operations including:
- Disk overview and analysis
- Duplicate file detection
- Big file finder (100M and 500M thresholds)
- Empty directory removal
- Archive searching
- Cloud backup/restore
- System cleanup wizard
- Storage trend tracking
- Package cache cleaning
- Git repository maintenance
- Docker cleanup

Navigate with arrow keys, search by typing, press Enter to select."
            ;;
        "clean-wizard"*)
            clean-help-detail "clean-wizard" \
                "Interactive step-by-step system cleanup wizard" \
                "clean-wizard" \
                "Multi-selection wizard for cleaning common system waste:

Options available:
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

Shows space freed before and after cleanup.
Use TAB to select multiple tasks, Enter to confirm."
            ;;
        "disk-overview"*)
            clean-help-detail "disk-overview" \
                "Quick disk usage overview" \
                "disk-overview" \
                "Displays:
- Filesystem usage (using duf if available, otherwise df)
- Top 10 directories in current path
- Largest files over 100MB

Quick way to assess disk usage without interactive tools."
            ;;
        "disk-scan"*)
            clean-help-detail "disk-scan" \
                "Interactive disk scanner using GDU" \
                "disk-scan [directory]" \
                "Opens gdu (Go Disk Usage) interactive analyzer.

If running in tmux, opens in a popup window (90% width/height).
Navigate with arrow keys, 'd' to delete, 'e' to empty.

Default: scans current directory
Example: disk-scan /var/log"
            ;;
        "disk-inspect"*)
            clean-help-detail "disk-inspect" \
                "Interactive disk usage analyzer using DUA" \
                "disk-inspect" \
                "Opens dua (Disk Usage Analyzer) in interactive mode.
Scans home directory, /mnt, and /media.

Navigate directories, mark for deletion, aggregate results."
            ;;
        "bigfiles"*)
            clean-help-detail "bigfiles" \
                "Find big files with fzf preview and deletion" \
                "bigfiles [threshold]" \
                "Interactive big file finder with:
- fzf preview showing file size
- Press Enter to trash selected file
- Multi-select with TAB
- Auto-reload after deletion

Default threshold: 100M
Example: bigfiles 500M"
            ;;
        "find-by-size"*)
            clean-help-detail "find-by-size" \
                "Find files by size with multiple actions" \
                "find-by-size [threshold]" \
                "Advanced file finder with rich preview and keybindings:

Preview shows:
- File size
- Modification date
- File contents (first 50 lines)

Keybindings:
- ENTER: view full file
- CTRL-D: trash file
- CTRL-B: backup to cloud
- CTRL-O: open directory in shell

Default threshold: 100M
Example: find-by-size 500M"
            ;;
        "space-suggestions"*)
            clean-help-detail "space-suggestions" \
                "Quick space recovery suggestions" \
                "space-suggestions" \
                "Analyzes and reports potential space savings from:
1. Package cache
2. Journal logs
3. Thumbnail cache
4. Trash
5. Docker resources
6. npm/yarn cache
7. Largest directories in home

Shows size and command to clean each item."
            ;;
        "storage-log"*)
            clean-help-detail "storage-log" \
                "Track disk usage over time" \
                "storage-log [record|show|graph|clear]" \
                "Log and visualize disk usage trends.

Commands:
- storage-log record  : Record current usage to log
- storage-log show    : Display last 30 entries
- storage-log graph   : Show visual graph of usage
- storage-log clear   : Delete log file

Log location: ~/.local/state/disk-usage.log

Tip: Add to crontab for automatic tracking:
  0 0 * * * /bin/zsh -c 'source ~/.zshrc && storage-log record'"
            ;;
        "check-inodes"*)
            clean-help-detail "check-inodes" \
                "Check inode usage" \
                "check-inodes [directory]" \
                "Displays:
- Inode usage for / and /home filesystems
- Top 20 directories by file count

Useful when you have 'No space left on device' errors
but df shows available space (inode exhaustion).

Default: current directory
Example: check-inodes /var"
            ;;
        "clean-pkg-cache"*)
            clean-help-detail "clean-pkg-cache" \
                "Clean package manager caches" \
                "clean-pkg-cache" \
                "Cleans Arch Linux package caches:

1. Shows pacman cache with dry-run
2. Prompts to remove all but 3 recent versions
3. Cleans AUR cache if yay is installed

Safe: keeps recent versions for rollback capability."
            ;;
        "clean-system-cruft"*)
            clean-help-detail "clean-system-cruft" \
                "Clean system logs, thumbnails, caches" \
                "clean-system-cruft" \
                "Interactively cleans:
1. Journal logs (older than 2 weeks)
2. Thumbnail cache (~/.cache/thumbnails)
3. Browser caches (Firefox, Chromium)

Shows current size and asks for confirmation before cleaning."
            ;;
        "clean-docker"*)
            clean-help-detail "clean-docker" \
                "Clean Docker resources" \
                "clean-docker" \
                "Shows Docker disk usage breakdown:
- Images
- Containers
- Volumes
- Build cache

Offers to run 'docker system prune -a' to remove:
- All stopped containers
- All unused networks
- All unused images
- All build cache"
            ;;
        "clean-git-repos"*)
            clean-help-detail "clean-git-repos" \
                "Clean git repositories" \
                "clean-git-repos" \
                "Interactive fzf selection of git repositories.

For each selected repo, performs:
- git gc --aggressive --prune=now (garbage collection)
- git remote prune origin (remove stale remote refs)
- git worktree prune (clean worktree metadata)

Preview shows git status and repo size."
            ;;
        "clean-empty"*)
            clean-help-detail "clean-empty" \
                "Remove empty directories" \
                "clean-empty" \
                "Interactive fzf selection of empty directories.

- Multi-select with TAB
- Press Enter to delete selected directories
- Auto-reloads after deletion"
            ;;
        "clear-zsh-cache"*)
            clean-help-detail "clear-zsh-cache" \
                "Clear ZSH caches and rebuild" \
                "clear-zsh-cache" \
                "Clears all ZSH caches:
- Completion dump (.zcompdump)
- Cache-eval caches
- FZF history
- Command caches

Then rebuilds and compiles the completion dump.
Useful after installing new shell completions."
            ;;
        "cleanup-zwc-files"*)
            clean-help-detail "cleanup-zwc-files" \
                "Remove orphaned compiled ZSH files" \
                "cleanup-zwc-files" \
                "Finds and removes .zwc (compiled ZSH) files that no longer
have corresponding source files.

Useful after reorganizing ZSH configuration files."
            ;;
        "trash"*)
            clean-help-detail "trash" \
                "Safe delete to trash" \
                "trash <file1> [file2] ..." \
                "Moves files to trash instead of permanently deleting.

Location: ~/.local/share/Trash/files/

Can be restored or permanently deleted later with:
  trash-empty  # empty entire trash"
            ;;
        "dedupe-dirs"*)
            clean-help-detail "dedupe-dirs" \
                "Multi-directory deduplication" \
                "dedupe-dirs" \
                "Interactive duplicate finder with tool selection:

1. Select directories with fzf (multi-select)
2. Choose deduplication tool:
   - czkawka: Feature-rich with GUI
   - rmlint: Generates safe removal script
   - rdfind: Priority-based deletion
   - fdupes: Hash-based detection

Each tool has different features and safety levels."
            ;;
        "dedupe-interactive"*)
            clean-help-detail "dedupe-interactive" \
                "Enhanced interactive duplicate finder" \
                "dedupe-interactive [directory]" \
                "Advanced duplicate detection with detailed tool selection:

Tools available:
- rmlint: Generates safe script (recommended)
- fclones: Fast parallel Rust implementation
- jdupes: High-performance hash-based
- czkawka-cli: Feature-rich CLI
- rdfind: Priority-based with dry-run

Shows tool descriptions and guides you through the process.
Default: current directory"
            ;;
        "archive-compare"*)
            clean-help-detail "archive-compare" \
                "Compare archive contents" \
                "archive-compare" \
                "Finds and compares contents of archives:

Supported formats: .zip, .tar.gz, .tar.xz, .7z

1. Select multiple archives with fzf
2. Extracts to temp directory
3. Runs czkawka to find duplicates
4. Auto-cleanup temp files on exit

Useful for finding duplicate backups."
            ;;
        "archive-dedupe-smart"*)
            clean-help-detail "archive-dedupe-smart" \
                "Smart archive deduplication" \
                "archive-dedupe-smart" \
                "Intelligent archive deduplication:

1. Select multiple archives
2. Sorts by size (largest = master)
3. Keeps master archive intact
4. Removes duplicates from smaller archives
5. Re-compresses cleaned archives

Master archive preserved, others optimized."
            ;;
        "search-archives"*)
            clean-help-detail "search-archives" \
                "Search inside archives" \
                "search-archives [pattern] [directory]" \
                "Search for text patterns inside archives using ripgrep-all.

Supported formats: zip, tar, 7z, pdf, office docs, etc.

Interactive fzf preview shows matches with context.

Example: search-archives 'TODO' ~/backups"
            ;;
        "cloud-backup-large"*)
            clean-help-detail "cloud-backup-large" \
                "Backup large files to cloud" \
                "cloud-backup-large [threshold] [remote]" \
                "Interactive cloud backup workflow:

1. Select rclone remote with preview
2. Find files larger than threshold
3. Shows if already backed up
4. Multi-select files to upload
5. Upload with progress bar

Default threshold: 500M
Requires: rclone configured with remotes"
            ;;
        "cloud-browse"*)
            clean-help-detail "cloud-browse" \
                "Mount and browse cloud storage" \
                "cloud-browse" \
                "Interactive cloud storage browser:

1. Select rclone remote
2. Mounts to /tmp/rclone-<remote>
3. Opens yazi file manager
4. Auto-unmounts on exit

Requires: rclone, yazi"
            ;;
        "cloud-restore"*)
            clean-help-detail "cloud-restore" \
                "Restore files from cloud" \
                "cloud-restore" \
                "Interactive file restoration:

1. Select rclone remote
2. Browse remote files with preview
3. Select file to restore
4. Choose destination directory
5. Download with progress

Requires: rclone configured"
            ;;
        "clean-big-files-pipeline"*)
            clean-help-detail "clean-big-files-pipeline" \
                "Complete cleanup pipeline" \
                "clean-big-files-pipeline" \
                "Automated workflow: Find → Backup → Delete

1. Finds files larger than 500M
2. Optionally backs up to cloud
3. Interactively select files to delete
4. Moves to trash (not permanent delete)

Safe: always backs up first if requested."
            ;;
        "dedupe-compress-upload"*)
            clean-help-detail "dedupe-compress-upload" \
                "Dedupe → Compress → Upload pipeline" \
                "dedupe-compress-upload" \
                "Full archive workflow:

1. Runs dedupe-dirs
2. Select directories to compress
3. Creates .tar.gz archives
4. Uploads to cloud storage

Useful for backing up deduplicated directories."
            ;;
        "Show all cleaning commands"*)
            echo ""
            echo "━━━ ALL CLEANING COMMANDS ━━━"
            echo ""
            echo "Main Menus:"
            echo "  disk-menu-enhanced (dc-menu)"
            echo "  clean-wizard"
            echo ""
            echo "Analysis:"
            echo "  disk-overview, disk-scan, disk-inspect"
            echo "  bigfiles, find-by-size"
            echo "  space-suggestions, storage-log, check-inodes"
            echo ""
            echo "Cleaning:"
            echo "  clean-pkg-cache, clean-system-cruft"
            echo "  clean-docker, clean-git-repos, clean-empty"
            echo "  clear-zsh-cache, cleanup-zwc-files"
            echo "  trash"
            echo ""
            echo "Deduplication:"
            echo "  dedupe-dirs, dedupe-interactive"
            echo "  archive-compare, archive-dedupe-smart"
            echo "  search-archives"
            echo ""
            echo "Cloud Backup:"
            echo "  cloud-backup-large, cloud-browse, cloud-restore"
            echo ""
            echo "Pipelines:"
            echo "  clean-big-files-pipeline, dedupe-compress-upload"
            echo ""
            read -k "?Press any key to return to menu..."
            clean-help
            ;;
        "Quick start guide"*)
            clean-help-quickstart
            ;;
        *)
            [[ -n "$choice" ]] && echo "No help available for: $choice"
            ;;
    esac
}

# Helper function to display detailed help for a function
clean-help-detail() {
    local func="$1"
    local desc="$2"
    local usage="$3"
    local details="$4"

    clear
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $func"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "DESCRIPTION:"
    echo "  $desc"
    echo ""
    echo "USAGE:"
    echo "  $usage"
    echo ""
    echo "DETAILS:"
    echo "$details" | fold -s -w 70 | sed 's/^/  /'
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    local action
    read "action?[T]ry it now, [B]ack to menu, or [Q]uit? "

    case "$action" in
        [Tt])
            echo ""
            echo "Running: $func"
            echo ""
            eval "$func"
            ;;
        [Bb])
            clean-help
            ;;
        *)
            return 0
            ;;
    esac
}

# Quick start guide
clean-help-quickstart() {
    clear
    cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CLEANING FUNCTIONS - QUICK START GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RECOMMENDED STARTING POINTS:

1. First-time cleanup:
   $ clean-wizard
   → Interactive wizard, select multiple tasks with TAB
   → Option 'A' runs all safe cleanup tasks

2. Browse all cleaning options:
   $ dc-menu
   → Access to all 16 disk cleaning operations
   → Navigate with arrows, search by typing

3. Quick disk analysis:
   $ disk-overview
   → See what's using space immediately

4. Find what to clean:
   $ space-suggestions
   → Shows potential space savings with commands

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMMON WORKFLOWS:

Free up space quickly:
  $ clean-wizard
  → Select: Package cache, Journal logs, Thumbnails, Trash

Find and remove big files:
  $ bigfiles 500M
  → Interactive: TAB to select, Enter to trash

Find duplicate files:
  $ dedupe-interactive
  → Choose tool (rmlint recommended)

Clean specific system:
  $ clean-pkg-cache     # Package cache
  $ clean-docker        # Docker resources
  $ clean-git-repos     # Git repositories

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INTERACTIVE EXPLORATION:

Deep disk analysis:
  $ disk-scan          # GDU analyzer (tmux popup)
  $ disk-inspect       # DUA analyzer

Track usage over time:
  $ storage-log record    # Record current state
  $ storage-log show      # View history
  $ storage-log graph     # Visual graph

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SAFETY FEATURES:

- Most functions use 'trash' instead of 'rm' (recoverable)
- Dry-run options where available
- Confirmation prompts for destructive actions
- Preview before deletion with fzf

TIPS:

- Use TAB for multi-select in fzf menus
- All menus support search - just start typing
- Run 'clean-help' anytime to return to this help system
- Alias 'dc-menu' is faster than 'disk-menu-enhanced'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    echo ""
    read -k "?Press any key to return to help menu..."
    clean-help
}

# Alias for convenience
alias ch='clean-help'
