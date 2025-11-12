#!/bin/bash
# File: tmux-resurrect-browser.sh
# Function: Simple tmux resurrect file browser for popup usage

RESURRECT_DIR="$HOME/.core/cfg/tmux/resurrect"
LAST_LINK="$RESURRECT_DIR/last"
PREVIEW_SCRIPT="/tmp/tmux_preview_$$"

# Exit if directory doesn't exist
[[ ! -d "$RESURRECT_DIR" ]] && {
    echo "Resurrect directory not found: $RESURRECT_DIR"
    exit 1
}

# Create temporary preview script
cat >"$PREVIEW_SCRIPT" <<'EOF'
#!/bin/bash
file="$1"
LAST_LINK="$2"

echo "File: $(basename "$file")"
echo "Modified: $(date -r "$file" '+%Y-%m-%d %H:%M' 2>/dev/null || stat -c '%y' "$file" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)"
echo "Size: $(du -h "$file" 2>/dev/null | cut -f1)"

if [[ -L "$LAST_LINK" ]] && [[ "$(readlink "$LAST_LINK")" == "$(basename "$file")" ]]; then
    echo "Status: ★ CURRENT RESTORE FILE"
else
    echo "Status: Available"
fi

sessions=$(grep -c "^session" "$file" 2>/dev/null || echo "0")
windows=$(grep -c "^window" "$file" 2>/dev/null || echo "0") 
panes=$(grep -c "^pane" "$file" 2>/dev/null || echo "0")
echo "Content: $sessions sessions, $windows windows, $panes panes"
echo ""
echo "--- Sessions ---"
grep "^session" "$file" 2>/dev/null | head -3
echo ""
echo "--- Recent Windows ---"
grep "^window" "$file" 2>/dev/null | head -8
echo ""
echo "--- Recent Panes ---"
grep "^pane" "$file" 2>/dev/null | head -8
EOF

chmod +x "$PREVIEW_SCRIPT"

# Cleanup function
cleanup() {
    rm -f "$PREVIEW_SCRIPT"
}
trap cleanup EXIT

# Main action: browse and select file
selected_file=$(find "$RESURRECT_DIR" -name "tmux_resurrect_*.txt" -type f | sort -r |
    fzf --preview "$PREVIEW_SCRIPT {} $LAST_LINK" \
        --preview-window=right:60%:wrap \
        --height=100% \
        --header='Select resurrect file (ENTER=restore & link, CTRL+L=link only)' \
        --bind 'enter:accept' \
        --bind 'ctrl-l:execute-silent(echo "LINK_ONLY:{}" > /tmp/fzf_action)+accept' \
        --ansi --border)

if [[ -n "$selected_file" ]]; then
    # Check if link-only action was triggered
    if [[ -f "/tmp/fzf_action" ]]; then
        action_content=$(cat "/tmp/fzf_action")
        rm -f "/tmp/fzf_action"

        if [[ "$action_content" =~ ^LINK_ONLY: ]]; then
            selected_file="${action_content#LINK_ONLY:}"
            basename_file=$(basename "$selected_file")
            # Just update symlink
            [[ -L "$LAST_LINK" ]] && rm "$LAST_LINK"
            ln -s "$basename_file" "$LAST_LINK"
            echo "Updated 'last' link to: $basename_file"
            exit 0
        fi
    fi

    # Normal restore path
    basename_file=$(basename "$selected_file")
    # Update symlink and restore
    [[ -L "$LAST_LINK" ]] && rm "$LAST_LINK"
    ln -s "$basename_file" "$LAST_LINK"
    echo "Restoring: $basename_file"

    # Trigger restore
    if [[ -n "$TMUX" ]]; then
        tmux run-shell "$CORE/cfg/tmux/plugins/tmux-resurrect/scripts/restore.sh"
    else
        echo "Start tmux and use Prefix+Ctrl+r to restore"
    fi
else
    echo "No file selected"
fi
