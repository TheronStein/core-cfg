#!/usr/bin/env bash
# WezTerm TMUX Manager - Sessions List for a Server

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Arguments from WezTerm
CALLBACK_FILE="${1:-}"
SERVER_SOCKET="${2:-}"
SERVER_NAME="${3:-TMUX Server}"

if [[ -z "$CALLBACK_FILE" ]]; then
    echo "Error: CALLBACK_FILE not provided" >&2
    exit 1
fi

if [[ -z "$SERVER_SOCKET" ]]; then
    echo "Error: SERVER_SOCKET not provided" >&2
    exit 1
fi

# Ensure dependencies
for cmd in fzf tmux; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

# Check if server socket exists
if [[ ! -S "$SERVER_SOCKET" ]]; then
    echo "error|TMUX server socket not found" > "$CALLBACK_FILE"
    exit 0
fi

# Get sessions from TMUX server
declare -a SESSION_CHOICES=()

while IFS=: read -r session_name rest; do
    # Get session info
    window_count=$(tmux -S "$SERVER_SOCKET" list-windows -t "$session_name" 2>/dev/null | wc -l)
    attached=$(tmux -S "$SERVER_SOCKET" list-sessions -F '#{session_name}:#{session_attached}' 2>/dev/null | grep "^${session_name}:" | cut -d: -f2)

    attached_indicator=""
    if [[ "$attached" == "1" ]]; then
        attached_indicator="[attached] "
    fi

    display="${attached_indicator}${session_name} (${window_count} windows)"
    SESSION_CHOICES+=("${session_name}|${display}")
done < <(tmux -S "$SERVER_SOCKET" list-sessions -F '#{session_name}' 2>/dev/null)

if [[ ${#SESSION_CHOICES[@]} -eq 0 ]]; then
    echo "error|No sessions in this server" > "$CALLBACK_FILE"
    exit 0
fi

# Create preview script
create_preview_script() {
    cat > "/tmp/tmux-session-preview-$$.sh" << PREVIEW_EOF
#!/usr/bin/env bash
session_name="\$1"
server_socket="$SERVER_SOCKET"

if tmux -S "\$server_socket" has-session -t "\$session_name" 2>/dev/null; then
    echo "TMUX Session: \$session_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Get session info
    attached=\$(tmux -S "\$server_socket" display-message -t "\$session_name" -p '#{session_attached}')
    created=\$(tmux -S "\$server_socket" display-message -t "\$session_name" -p '#{session_created}')

    echo "Attached: \$([[ \"\$attached\" == "1" ]] && echo "Yes" || echo "No")"
    echo "Created:  \$(date -d @\$created '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo 'N/A')"
    echo ""
    echo "Windows:"
    tmux -S "\$server_socket" list-windows -t "\$session_name" -F '  #{window_index}: #{window_name} (#{window_panes} panes)' 2>/dev/null
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Actions:"
    echo "  Enter    - Attach to session"
    echo "  Alt+D    - Delete session"
    echo "  Alt+R    - Rename session"
    echo "  Ctrl+/   - Toggle preview"
fi
PREVIEW_EOF
    chmod +x "/tmp/tmux-session-preview-$$.sh"
    echo "/tmp/tmux-session-preview-$$.sh"
}

PREVIEW_SCRIPT=$(create_preview_script)

# Show sessions list with keybinds
selected=$(printf "%s\n" "${SESSION_CHOICES[@]}" \
    | fzf \
        --ansi \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --border-label="╣ TMUX Manager > $SERVER_NAME > Sessions ╠" \
        --prompt="Select ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --delimiter='|' \
        --with-nth=2 \
        --header=$'Enter: Attach | Alt+D: Delete | Alt+R: Rename | Ctrl+/: Toggle Preview | Esc: Cancel\n─────────────────────────────────────────' \
        --preview="$PREVIEW_SCRIPT {1}" \
        --preview-window=right:60%:wrap:rounded \
        --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
        --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
        --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
        --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
        --bind="ctrl-/:toggle-preview" \
        --bind="alt-d:execute(echo 'delete:{1}' > '$CALLBACK_FILE')+abort" \
        --bind="alt-r:execute(echo 'rename:{1}' > '$CALLBACK_FILE')+abort")

# Cleanup
rm -f "$PREVIEW_SCRIPT"

if [[ -n "$selected" ]]; then
    session_name=$(echo "$selected" | cut -d'|' -f1)
    # Attach action
    echo "attach:$session_name" > "$CALLBACK_FILE"
else
    exit 1
fi
