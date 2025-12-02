#!/usr/bin/env bash
# WezTerm Actions - Grab Pane Menu
# Allows grabbing a pane from another tab into the current tab

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Arguments from WezTerm (passed from Lua)
CALLBACK_FILE="${1:-}"
PANES_DATA="${2:-}"  # JSON data with panes from other tabs

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

# Parse panes data if provided
declare -a PANE_CHOICES=()

if [[ -n "$PANES_DATA" && "$PANES_DATA" != "null" ]]; then
    # Read panes from JSON data (grouped by tab)
    # Format: pane_id|[Tab Name] Pane X: process (cwd) [only pane - will close tab]
    while IFS= read -r line; do
        PANE_CHOICES+=("$line")
    done < <(echo "$PANES_DATA" | jq -r '.panes[] | "\(.pane_id)|\(.display)"')
fi

if [[ ${#PANE_CHOICES[@]} -eq 0 ]]; then
    echo "no_panes|No panes available to grab" > "$CALLBACK_FILE"
    exit 0
fi

# Preview function
create_preview_script() {
    cat > "/tmp/grab-pane-preview-$$.sh" << 'PREVIEW_EOF'
#!/usr/bin/env bash
pane_data="$1"
echo "Grab pane into current tab"
echo ""
echo "Selected pane: $pane_data"
echo ""
echo "This will:"
echo "  • Create a split in the current tab"
echo "  • Move the selected pane into it"
echo "  • Preserve the working directory"
echo "  • Close the source tab if it's the only pane"
PREVIEW_EOF
    chmod +x "/tmp/grab-pane-preview-$$.sh"
    echo "/tmp/grab-pane-preview-$$.sh"
}

PREVIEW_SCRIPT=$(create_preview_script)

# Show menu
selected=$(printf "%s\n" "${PANE_CHOICES[@]}" \
    | fzf \
        --ansi \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --border-label="╣ Session Manager > Actions > Grab Pane ╠" \
        --prompt="Select ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --delimiter='|' \
        --with-nth=2 \
        --header=$'Navigate: ↑↓ | Select: Enter | Quit: Esc\n─────────────────────────────────────────' \
        --preview="$PREVIEW_SCRIPT {2}" \
        --preview-window=right:60%:wrap:rounded \
        --color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8" \
        --color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc" \
        --color="marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" \
        --color="border:#89b4fa,label:#89b4fa,query:#cdd6f4")

# Cleanup
rm -f "$PREVIEW_SCRIPT"

if [[ -n "$selected" ]]; then
    pane_id=$(echo "$selected" | cut -d'|' -f1)
    echo "$pane_id" > "$CALLBACK_FILE"
else
    exit 1
fi
