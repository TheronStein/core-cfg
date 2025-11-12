#!/usr/bin/env bash
# Rclone Browser - Left Sidebar Wrapper
# Runs browser without preview, sends selection to right sidebar

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELECTION_FILE="/tmp/rclone-browser-selection"

# Ensure dependencies
for cmd in fzf rclone; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done

# Cleanup on exit
trap "rm -f $SELECTION_FILE" EXIT

# Get initial list
initial_list=$(bash "$SCRIPT_DIR/browser.sh" --reload)

# Write first line to selection file for initial preview
echo "$initial_list" | head -1 > "$SELECTION_FILE"

# Main browser without preview
echo "$initial_list" | fzf \
  --ansi \
  --height=100% \
  --layout=reverse \
  --border=rounded \
  --border-label="╣ Rclone Mount Manager ╠" \
  --prompt="Remote ❯ " \
  --pointer="▶" \
  --marker="✓" \
  --delimiter=' | ' \
  --with-nth=1,2 \
  --header=$'Navigate: ↑↓ | Toggle Mount: Enter | Mount: Ctrl-M | Unmount: Ctrl-U | Open: Ctrl-O | Refresh: Ctrl-R | Panes: Alt+W/S/A/D\n───────────────────────────────────────────────────────────────────────────────────' \
  --preview-window=hidden \
  --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
  --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
  --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
  --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
  --bind="ctrl-r:reload(bash $SCRIPT_DIR/browser.sh --reload)+execute-silent(echo {} > $SELECTION_FILE)+refresh-preview" \
  --bind="load:execute-silent(echo {} > $SELECTION_FILE)" \
  --bind="enter:execute(remote=\$(echo {} | awk '{print \$2}'); status=\$(echo {} | awk '{print \$4}'); if [[ \"\$status\" == \"MOUNTED\" ]]; then bash $SCRIPT_DIR/browser.sh --unmount \"\$remote\" 2>&1; else bash $SCRIPT_DIR/browser.sh --mount \"\$remote\" 2>&1; fi; echo ''; read -p 'Press ENTER to continue...')+reload(bash $SCRIPT_DIR/browser.sh --reload)+refresh-preview" \
  --bind="ctrl-m:execute(remote=\$(echo {} | awk '{print \$2}'); bash $SCRIPT_DIR/browser.sh --mount \"\$remote\" 2>&1; echo ''; read -p 'Press ENTER to continue...')+reload(bash $SCRIPT_DIR/browser.sh --reload)+refresh-preview" \
  --bind="ctrl-u:execute(remote=\$(echo {} | awk '{print \$2}'); bash $SCRIPT_DIR/browser.sh --unmount \"\$remote\" 2>&1; echo ''; read -p 'Press ENTER to continue...')+reload(bash $SCRIPT_DIR/browser.sh --reload)+refresh-preview" \
  --bind="ctrl-o:execute-silent(remote=\$(echo {} | awk '{print \$2}'); mount_point=\$(bash $SCRIPT_DIR/browser.sh --get-mount-point \"\$remote\"); if mountpoint -q \"\$mount_point\" 2>/dev/null; then xdg-open \"\$mount_point\" || nautilus \"\$mount_point\" || thunar \"\$mount_point\" || echo 'No file manager found'; else echo 'Not mounted'; fi)" \
  --bind="change:execute-silent(echo {} > $SELECTION_FILE)" \
  --bind="up:up+execute-silent(echo {} > $SELECTION_FILE)" \
  --bind="down:down+execute-silent(echo {} > $SELECTION_FILE)" \
  --bind="page-up:page-up+execute-silent(echo {} > $SELECTION_FILE)" \
  --bind="page-down:page-down+execute-silent(echo {} > $SELECTION_FILE)" \
  --bind="alt-w:execute-silent(tmux select-pane -U)" \
  --bind="alt-s:execute-silent(tmux select-pane -D)" \
  --bind="alt-a:execute-silent(tmux select-pane -L)" \
  --bind="alt-d:execute-silent(tmux select-pane -R)"

# Cleanup
rm -f "$SELECTION_FILE"
