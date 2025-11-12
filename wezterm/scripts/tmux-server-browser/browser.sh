#!/usr/bin/env bash
# WezTerm Tmux Server Browser with FZF

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure dependencies
for cmd in fzf tmux; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done

# Find tmux socket directory
get_tmux_tmpdir() {
  if [[ -n "${TMUX_TMPDIR:-}" ]]; then
    echo "$TMUX_TMPDIR"
  else
    echo "/tmp/tmux-$(id -u)"
  fi
}

# Browse available tmux servers
browse_servers() {
  local tmux_dir=$(get_tmux_tmpdir)

  if [[ ! -d "$tmux_dir" ]]; then
    echo "No tmux servers found in $tmux_dir" >&2
    exit 1
  fi

  # Find all socket files (tmux servers)
  find "$tmux_dir" -type s 2>/dev/null | \
  while IFS= read -r socket; do
    local socket_name=$(basename "$socket")
    local session_count=0
    local attached_count=0

    # Get session count and attached count for this server
    if tmux -L "$socket_name" list-sessions &>/dev/null; then
      session_count=$(tmux -L "$socket_name" list-sessions 2>/dev/null | wc -l)
      attached_count=$(tmux -L "$socket_name" list-sessions -F '#{session_attached}' 2>/dev/null | grep -c '^1$' || echo 0)
    fi

    local icon="🖥️ "
    local status="active"

    if [[ $attached_count -gt 0 ]]; then
      icon="📌"
      status="$attached_count attached"
    fi

    # Format for FZF: SOCKET_NAME<TAB>icon name | sessions (status)
    printf "%s\t%s %s | %d sessions (%s)\n" \
      "$socket_name" "$icon" "$socket_name" "$session_count" "$status"
  done | \
    fzf \
      --ansi \
      --height=100% \
      --layout=reverse \
      --border=rounded \
      --border-label="╣ Tmux Servers ╠" \
      --prompt="Server ▸ " \
      --pointer="▶" \
      --marker="✓" \
      --delimiter=$'\t' \
      --with-nth=2 \
      --header=$'Navigate: ↑↓ | Select: Enter | Kill Server: Ctrl-D | Quit: Esc\n─────────────────────────────────────────' \
      --preview="$SCRIPT_DIR/preview.sh {1}" \
      --preview-window=right:60%:wrap:rounded \
      --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
      --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
      --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
      --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
      --bind="ctrl-/:toggle-preview" \
      --bind="ctrl-d:execute(tmux -L {1} kill-server 2>/dev/null && echo 'Killed server: {1}' || echo 'Failed to kill server')+reload(find $(echo '$tmux_dir') -type s 2>/dev/null | while read socket; do name=\$(basename \"\$socket\"); count=0; attached=0; tmux -L \"\$name\" list-sessions &>/dev/null && count=\$(tmux -L \"\$name\" list-sessions 2>/dev/null | wc -l) && attached=\$(tmux -L \"\$name\" list-sessions -F '#{session_attached}' 2>/dev/null | grep -c '^1\$' || echo 0); icon='🖥️ '; status='active'; [[ \$attached -gt 0 ]] && icon='📌' && status=\"\$attached attached\"; printf \"%s\t%s %s | %d sessions (%s)\n\" \"\$name\" \"\$icon\" \"\$name\" \"\$count\" \"\$status\"; done)"
}

# Main
selected=$(browse_servers)

if [[ -n "$selected" ]]; then
  # Extract server name (first field before TAB)
  server_name=$(echo "$selected" | cut -f1)

  # Output selected server name
  echo "$server_name"
else
  exit 1
fi
