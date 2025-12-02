#!/usr/bin/env bash
# WezTerm Tmux Session Browser with FZF

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure dependencies
for cmd in fzf tmux; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done

# Browse available tmux sessions
browse_sessions() {
  # Format: name|windows|attached|created
  tmux list-sessions -F '#{session_name}|#{session_windows}|#{session_attached}|#{session_created}' 2>/dev/null | \
  while IFS='|' read -r name windows attached created; do
    local icon="○"
    local status="detached"

    if [[ "$attached" == "1" ]]; then
      icon="📌"
      status="attached"
    fi

    # Convert created timestamp to readable date
    local created_date=""
    if command -v date &>/dev/null && [[ -n "$created" ]]; then
      created_date=$(date -d "@$created" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "")
    fi

    # Format for FZF: NAME<TAB>icon name | windows (status) - created
    printf "%s\t%s %s | %d windows (%s) - %s\n" \
      "$name" "$icon" "$name" "$windows" "$status" "$created_date"
  done | \
    fzf \
      --ansi \
      --height=100% \
      --layout=reverse \
      --border=rounded \
      --border-label="╣ Tmux Sessions ╠" \
      --prompt="Session ▸ " \
      --pointer="▶" \
      --marker="✓" \
      --delimiter=$'\t' \
      --with-nth=2 \
      --header=$'Navigate: ↑↓ | Select: Enter | New: Ctrl-N | Delete: Ctrl-D | Quit: Esc\n─────────────────────────────────────────' \
      --preview="$SCRIPT_DIR/preview.sh {1}" \
      --preview-window=right:60%:wrap:rounded \
      --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
      --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
      --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
      --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
      --bind="ctrl-/:toggle-preview" \
      --bind="ctrl-n:execute(echo '__CREATE_NEW__')+abort" \
      --bind="ctrl-d:execute(tmux kill-session -t {1} 2>/dev/null && echo 'Killed session: {1}' || echo 'Failed to kill session')+reload(tmux list-sessions -F '#{session_name}|#{session_windows}|#{session_attached}|#{session_created}' 2>/dev/null | while IFS='|' read -r name windows attached created; do icon='○'; status='detached'; [[ \$attached == '1' ]] && icon='📌' && status='attached'; created_date=''; [[ -n \$created ]] && created_date=\$(date -d \"@\$created\" \"+%Y-%m-%d %H:%M\" 2>/dev/null || echo ''); printf \"%s\t%s %s | %d windows (%s) - %s\n\" \"\$name\" \"\$icon\" \"\$name\" \"\$windows\" \"\$status\" \"\$created_date\"; done)"
}

# Main
selected=$(browse_sessions)

if [[ -n "$selected" ]]; then
  # Check if creating new session
  if [[ "$selected" == "__CREATE_NEW__" ]]; then
    echo "__CREATE_NEW__"
    exit 0
  fi

  # Extract session name (first field before TAB)
  session_name=$(echo "$selected" | cut -f1)

  # Output selected session name
  echo "$session_name"
else
  exit 1
fi
