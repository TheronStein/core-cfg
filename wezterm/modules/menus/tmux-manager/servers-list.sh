#!/usr/bin/env bash
# WezTerm TMUX Manager - Servers List

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Arguments from WezTerm
CALLBACK_FILE="${1:-}"
SERVERS_DATA="${2:-}"  # JSON data with TMUX servers info

if [[ -z "$CALLBACK_FILE" ]]; then
    echo "Error: CALLBACK_FILE not provided" >&2
    exit 1
fi

# Ensure dependencies
for cmd in fzf jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

# Parse servers data if provided
declare -a SERVER_CHOICES=()

if [[ -n "$SERVERS_DATA" && "$SERVERS_DATA" != "null" ]]; then
    # Read servers from JSON data
    # Format: server_socket|icon server_name (X sessions)
    while IFS= read -r line; do
        SERVER_CHOICES+=("$line")
    done < <(echo "$SERVERS_DATA" | jq -r '.servers[] | "\(.socket)|\(.icon) \(.name) (\(.session_count) sessions)"')
fi

if [[ ${#SERVER_CHOICES[@]} -eq 0 ]]; then
    echo "error|No TMUX servers found" > "$CALLBACK_FILE"
    exit 0
fi

# Create preview script
create_preview_script() {
    cat > "/tmp/tmux-server-preview-$$.sh" << 'PREVIEW_EOF'
#!/usr/bin/env bash
server_socket="$1"

if [[ -S "$server_socket" ]]; then
    echo "TMUX Server"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Socket: $server_socket"
    echo ""
    echo "Sessions:"
    tmux -S "$server_socket" list-sessions 2>/dev/null | while IFS=: read -r session_name rest; do
        echo "  • $session_name"
    done
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Select to manage this server"
fi
PREVIEW_EOF
    chmod +x "/tmp/tmux-server-preview-$$.sh"
    echo "/tmp/tmux-server-preview-$$.sh"
}

PREVIEW_SCRIPT=$(create_preview_script)

# Show servers list
selected=$(printf "%s\n" "${SERVER_CHOICES[@]}" \
    | fzf \
        --ansi \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --border-label="╣ TMUX Manager > Servers ╠" \
        --prompt="Select ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --delimiter='|' \
        --with-nth=2 \
        --header=$'Enter: Manage Server | Ctrl+/: Toggle Preview | Esc: Cancel\n─────────────────────────────────────────' \
        --preview="$PREVIEW_SCRIPT {1}" \
        --preview-window=right:60%:wrap:rounded \
        --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
        --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
        --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
        --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
        --bind="ctrl-/:toggle-preview")

# Cleanup
rm -f "$PREVIEW_SCRIPT"

if [[ -n "$selected" ]]; then
    server_socket=$(echo "$selected" | cut -d'|' -f1)
    echo "$server_socket" > "$CALLBACK_FILE"
else
    exit 1
fi
