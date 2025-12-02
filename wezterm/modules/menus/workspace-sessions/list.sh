#!/usr/bin/env bash
# WezTerm Workspace Sessions - List View with Actions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSIONS_DIR="$HOME/.core/.sys/cfg/wezterm/.data/workspace-sessions"

# Arguments from WezTerm
CALLBACK_FILE="${1:-}"

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

# Check if sessions directory exists
if [[ ! -d "$SESSIONS_DIR" ]]; then
    echo "error|No sessions directory found" > "$CALLBACK_FILE"
    exit 0
fi

# Load sessions and create choices
declare -a SESSION_CHOICES=()

for session_file in "$SESSIONS_DIR"/*.json; do
    if [[ -f "$session_file" ]]; then
        session_name=$(basename "$session_file" .json)

        # Parse session metadata
        icon=$(jq -r '.icon // ""' "$session_file")
        workspace_name=$(jq -r '.workspace_name // .name' "$session_file")
        tab_count=$(jq -r '.tab_count // (.tabs | length)' "$session_file")
        saved_at=$(jq -r '.saved_at // "unknown"' "$session_file")

        icon_prefix=""
        if [[ -n "$icon" && "$icon" != "null" ]]; then
            icon_prefix="$icon "
        fi

        display="${icon_prefix}${session_name} (${workspace_name}) - ${tab_count} tabs - ${saved_at}"
        SESSION_CHOICES+=("${session_name}|${display}")
    fi
done

if [[ ${#SESSION_CHOICES[@]} -eq 0 ]]; then
    echo "error|No sessions saved" > "$CALLBACK_FILE"
    exit 0
fi

# Create preview script
create_preview_script() {
    cat > "/tmp/session-preview-$$.sh" << 'PREVIEW_EOF'
#!/usr/bin/env bash
session_name="$1"
sessions_dir="$HOME/.core/.sys/cfg/wezterm/.data/workspace-sessions"
session_file="$sessions_dir/$session_name.json"

if [[ -f "$session_file" ]]; then
    session_data=$(cat "$session_file")

    name=$(echo "$session_data" | jq -r '.name // "N/A"')
    workspace=$(echo "$session_data" | jq -r '.workspace_name // "N/A"')
    icon=$(echo "$session_data" | jq -r '.icon // "N/A"')
    color=$(echo "$session_data" | jq -r '.color // "N/A"')
    theme=$(echo "$session_data" | jq -r '.theme // "N/A"')
    tab_count=$(echo "$session_data" | jq -r '.tab_count // (.tabs | length)')
    saved_at=$(echo "$session_data" | jq -r '.saved_at // "N/A"')
    modified_at=$(echo "$session_data" | jq -r '.modified_at // "N/A"')
    auto_save=$(echo "$session_data" | jq -r '.auto_save // false')

    echo "Session: $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Workspace: $workspace"
    echo "Icon:      $icon"
    echo "Color:     $color"
    echo "Theme:     $theme"
    echo "Tabs:      $tab_count"
    echo "Auto-save: $auto_save"
    echo ""
    echo "Saved:     $saved_at"
    echo "Modified:  $modified_at"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Tabs in session:"
    echo "$session_data" | jq -r '.tabs[] | "  \(.icon // "•") \(.title)"'
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Actions:"
    echo "  Enter    - Load session"
    echo "  Alt+D    - Delete session"
    echo "  Alt+R    - Rename session"
    echo "  Ctrl+/   - Toggle preview"
fi
PREVIEW_EOF
    chmod +x "/tmp/session-preview-$$.sh"
    echo "/tmp/session-preview-$$.sh"
}

PREVIEW_SCRIPT=$(create_preview_script)

# Show sessions list with keybinds
selected=$(printf "%s\n" "${SESSION_CHOICES[@]}" \
    | fzf \
        --ansi \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --border-label="╣ Workspace Sessions - List View ╠" \
        --prompt="Select ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --delimiter='|' \
        --with-nth=2 \
        --header=$'Enter: Load | Alt+S: Save Current | Alt+N: New | Alt+D: Delete | Alt+R: Rename | Ctrl+/: Preview\n─────────────────────────────────────────' \
        --preview="$PREVIEW_SCRIPT {1}" \
        --preview-window=right:60%:wrap:rounded \
        --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
        --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
        --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
        --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4" \
        --bind="ctrl-/:toggle-preview" \
        --bind="alt-s:execute(echo 'save:current' > '$CALLBACK_FILE')+abort" \
        --bind="alt-n:execute(echo 'create:new' > '$CALLBACK_FILE')+abort" \
        --bind="alt-d:execute(echo 'delete:{1}' > '$CALLBACK_FILE')+abort" \
        --bind="alt-r:execute(echo 'rename:{1}' > '$CALLBACK_FILE')+abort")

# Cleanup
rm -f "$PREVIEW_SCRIPT"

if [[ -n "$selected" ]]; then
    session_name=$(echo "$selected" | cut -d'|' -f1)
    # Load action
    echo "load:$session_name" > "$CALLBACK_FILE"
else
    exit 1
fi
