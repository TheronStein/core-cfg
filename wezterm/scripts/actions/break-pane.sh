#!/usr/bin/env bash
# WezTerm Actions - Break Pane Menu
# Allows breaking current pane to its own tab or into another existing tab

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Arguments from WezTerm (passed from Lua)
CALLBACK_FILE="${1:-}"
WORKSPACE_DATA="${2:-}"  # JSON data with tabs info

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

# Parse workspace data if provided
declare -a TAB_CHOICES=()

if [[ -n "$WORKSPACE_DATA" && "$WORKSPACE_DATA" != "null" ]]; then
    # Read tabs from JSON data
    while IFS= read -r line; do
        TAB_CHOICES+=("$line")
    done < <(echo "$WORKSPACE_DATA" | jq -r '.tabs[] | "\(.id)|\(.icon) \(.title) (\(.pane_count) panes) - \(.cwd)"')
fi

# Add "Break to own tab" option at the top
OPTIONS=("own_tab|🚀 Break to Own Tab")
OPTIONS+=("separator|─────────────────────────────")

# Add existing tabs
if [[ ${#TAB_CHOICES[@]} -gt 0 ]]; then
    OPTIONS+=("${TAB_CHOICES[@]}")
fi

# Preview function (create as temporary script)
create_preview_script() {
    cat > "/tmp/break-pane-preview-$$.sh" << 'PREVIEW_EOF'
#!/usr/bin/env bash
choice="$1"
if [[ "$choice" == "own_tab" ]]; then
    echo "Break pane to its own new tab"
    echo ""
    echo "This will:"
    echo "  • Create a new tab"
    echo "  • Move the current pane to it"
    echo "  • Preserve the working directory"
elif [[ "$choice" == "separator" ]]; then
    echo "Select a tab above"
else
    echo "Break pane into existing tab"
    echo ""
    echo "Target: $choice"
    echo ""
    echo "This will move the current pane"
    echo "into the selected tab as a split"
fi
PREVIEW_EOF
    chmod +x "/tmp/break-pane-preview-$$.sh"
    echo "/tmp/break-pane-preview-$$.sh"
}

PREVIEW_SCRIPT=$(create_preview_script)

# Show menu
selected=$(printf "%s\n" "${OPTIONS[@]}" \
    | fzf \
        --ansi \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --border-label="╣ Session Manager > Actions > Break Pane ╠" \
        --prompt="Select ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --delimiter='|' \
        --with-nth=2 \
        --header=$'Navigate: ↑↓ | Select: Enter | Quit: Esc\n─────────────────────────────────────────' \
        --preview="$PREVIEW_SCRIPT {1}" \
        --preview-window=right:60%:wrap:rounded \
        --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
        --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
        --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
        --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4")

# Cleanup
rm -f "$PREVIEW_SCRIPT"

if [[ -n "$selected" ]]; then
    action_id=$(echo "$selected" | cut -d'|' -f1)

    # Skip if separator was selected
    if [[ "$action_id" == "separator" ]]; then
        exit 1
    fi

    echo "$action_id" > "$CALLBACK_FILE"
else
    exit 1
fi
