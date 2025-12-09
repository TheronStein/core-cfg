#!/usr/bin/env bash
# Disk Cleaning Workspace for Tmux
# Usage: tmux source-file ~/.core/.sys/cfg-disk-cleaning-tools/scripts/disk-cleaning-workspace.tmux
#    or: source this file to create the session

SESSION="disk"
MAIN_DIR="$HOME"

# Kill existing session if it exists
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Create new session with main window
tmux new-session -d -s "$SESSION" -n main -c "$MAIN_DIR"

# ============================================================
# Window 1: Main (Yazi + Tools)
# ============================================================
# Left pane: Yazi file browser
tmux send-keys -t "$SESSION:main" "yazi ~" C-m

# Right pane: Tools info and shell
tmux split-window -t "$SESSION:main" -h -l 45%
tmux send-keys -t "$SESSION:main.1" "cat << 'EOF'
========================================
      Disk Cleaning Tools Ready
========================================

Quick Commands:
  disk-menu          Interactive menu
  disk-overview      Quick summary
  disk-scan          GDU scan (popup)
  dedupe-interactive Find duplicates
  find-by-size 100M  Large files
  clean-wizard       System cleanup
  space-suggestions  Quick tips

Aliases:
  dc-dupes   Find duplicates
  dc-big     Big files
  dc-empty   Empty dirs
  dc-cloud   Cloud backup
  dc-all     All cleanup

Press any key to continue...
EOF
read -n1" C-m

# ============================================================
# Window 2: Disk Scanner (GDU)
# ============================================================
tmux new-window -t "$SESSION" -n scan -c "$MAIN_DIR"
tmux send-keys -t "$SESSION:scan" "gdu ~" C-m

# ============================================================
# Window 3: Duplicates
# ============================================================
tmux new-window -t "$SESSION" -n duplicates -c "$MAIN_DIR"
tmux send-keys -t "$SESSION:duplicates" "echo 'Duplicate Detection Tools'
echo '========================='
echo ''
echo 'Available tools:'
echo '  rmlint  - Safe scripts (recommended)'
echo '  fclones - Fast parallel (Rust)'
echo '  jdupes  - High performance'
echo ''
echo 'Run: dedupe-interactive'
echo 'Or:  dedupe-dirs (original)'
echo ''
echo 'Press Enter to start interactive mode...'
read
dedupe-interactive" C-m

# ============================================================
# Window 4: Cloud Remotes
# ============================================================
tmux new-window -t "$SESSION" -n cloud -c "$MAIN_DIR"
tmux send-keys -t "$SESSION:cloud" "echo 'Cloud Remotes'
echo '============='
echo ''
rclone listremotes
echo ''
echo 'Commands:'
echo '  cloud-backup-large  - Backup big files'
echo '  cloud-browse        - Mount and browse'
echo '  cloud-restore       - Restore files'
echo ''
echo 'Run: rclone about <remote>: for storage info'" C-m

# ============================================================
# Window 5: System Cleanup
# ============================================================
tmux new-window -t "$SESSION" -n cleanup -c "$MAIN_DIR"
tmux send-keys -t "$SESSION:cleanup" "echo 'System Cleanup'
echo '=============='
echo ''
echo 'Quick checks:'
echo ''
echo '--- Package Cache ---'
du -sh /var/cache/pacman/pkg 2>/dev/null || echo 'N/A'
echo ''
echo '--- Journal Logs ---'
journalctl --disk-usage 2>/dev/null || echo 'N/A'
echo ''
echo '--- Trash ---'
du -sh ~/.local/share/Trash 2>/dev/null || echo 'Empty'
echo ''
echo 'Run: clean-wizard for interactive cleanup'" C-m

# ============================================================
# Window 6: Monitoring
# ============================================================
tmux new-window -t "$SESSION" -n monitor -c "$MAIN_DIR"

# Left: df/duf output
tmux send-keys -t "$SESSION:monitor" "watch -n 60 'duf --only local 2>/dev/null || df -h'" C-m

# Right: dust for current dir
tmux split-window -t "$SESSION:monitor" -h -l 50%
tmux send-keys -t "$SESSION:monitor.1" "echo 'Directory Sizes (refreshes on Enter):'
while true; do
  dust -d 2 ~
  echo ''
  echo 'Press Enter to refresh...'
  read
  clear
done" C-m

# ============================================================
# Final setup
# ============================================================
# Return to main window
tmux select-window -t "$SESSION:main"
tmux select-pane -t "$SESSION:main.0

# Attach to session (if not already in tmux)
if [ -z "$TMUX" ]; then
    tmux attach-session -t "$SESSION"
else
    tmux switch-client -t "$SESSION"
fi
