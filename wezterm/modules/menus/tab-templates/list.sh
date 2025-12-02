#!/usr/bin/env bash
# WezTerm Tab Templates - List View with Actions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEZTERM_CONFIG_DIR="${WEZTERM_CONFIG_DIR:-$HOME/.config/wezterm}"
TEMPLATES_FILE="$HOME/.core/.sys/cfg/wezterm/.data/tabs/templates.json"

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

# Check if templates file exists
if [[ ! -f "$TEMPLATES_FILE" ]]; then
    echo "error|No templates file found" > "$CALLBACK_FILE"
    exit 0
fi

# Load templates and create choices
declare -a TEMPLATE_CHOICES=()

while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        TEMPLATE_CHOICES+=("$line")
    fi
done < <(jq -r 'to_entries[] | "\(.key)|\(.value.icon // "") \(.value.title) - \(.value.name) (created: \(.value.created_at // "unknown"))"' "$TEMPLATES_FILE")

if [[ ${#TEMPLATE_CHOICES[@]} -eq 0 ]]; then
    echo "error|No templates saved" > "$CALLBACK_FILE"
    exit 0
fi

# Create preview script
create_preview_script() {
    cat > "/tmp/template-preview-$$.sh" << 'PREVIEW_EOF'
#!/usr/bin/env bash
template_name="$1"
templates_file="$HOME/.core/.sys/cfg/wezterm/.data/tabs/templates.json"

if [[ -f "$templates_file" ]]; then
    template_data=$(jq -r --arg name "$template_name" '.[$name]' "$templates_file")
    if [[ "$template_data" != "null" ]]; then
        title=$(echo "$template_data" | jq -r '.title // "N/A"')
        icon=$(echo "$template_data" | jq -r '.icon // "N/A"')
        color=$(echo "$template_data" | jq -r '.color // "N/A"')
        cwd=$(echo "$template_data" | jq -r '.cwd // "N/A"')
        created=$(echo "$template_data" | jq -r '.created_at // "N/A"')

        echo "Template: $template_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Title:   $title"
        echo "Icon:    $icon"
        echo "Color:   $color"
        echo "CWD:     $cwd"
        echo "Created: $created"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Actions:"
        echo "  Enter    - Load template"
        echo "  Alt+D    - Delete template"
        echo "  Alt+R    - Rename template"
        echo "  Ctrl+/   - Toggle preview"
    fi
fi
PREVIEW_EOF
    chmod +x "/tmp/template-preview-$$.sh"
    echo "/tmp/template-preview-$$.sh"
}

PREVIEW_SCRIPT=$(create_preview_script)

# Show templates list with keybinds
selected=$(printf "%s\n" "${TEMPLATE_CHOICES[@]}" \
    | fzf \
        --ansi \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --border-label="╣ Tab Templates - List View ╠" \
        --prompt="Select ❯ " \
        --pointer="▶" \
        --marker="✓" \
        --delimiter='|' \
        --with-nth=2 \
        --header=$'Enter: Load | Alt+D: Delete | Alt+R: Rename | Ctrl+/: Toggle Preview | Esc: Cancel\n─────────────────────────────────────────' \
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
    template_name=$(echo "$selected" | cut -d'|' -f1)
    # Load action
    echo "load:$template_name" > "$CALLBACK_FILE"
else
    exit 1
fi
