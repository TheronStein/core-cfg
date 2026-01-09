#!/usr/bin/env bash
# Buffer Picker - FZF-based tmux buffer selection
# Location: ~/.tmux/modules/fzf/pickers/buffer-picker.sh
# Usage: buffer-picker.sh [--action=paste|delete|save|copy|target]
#
# Actions:
#   paste   - Paste selected buffer (default)
#   delete  - Delete selected buffer
#   save    - Save selected buffer to file
#   copy    - Copy buffer content to system clipboard
#   target  - Output buffer name (for use in other commands)

set -euo pipefail

# Source libraries
source ~/.core/.cortex/lib/fzf-config.sh

# Parse arguments
ACTION="paste"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --action=*) ACTION="${1#*=}"; shift ;;
        -a) ACTION="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Build buffer list
# Format: buffer_name | size | first_line
get_buffers() {
    tmux list-buffers -F "#{buffer_name}|#{buffer_size}|#{buffer_sample}" 2>/dev/null | \
    while IFS='|' read -r name size sample; do
        # Truncate sample for display
        local short_sample="${sample:0:60}"
        [[ ${#sample} -gt 60 ]] && short_sample="${short_sample}..."
        # Escape special characters for display
        short_sample="${short_sample//$'\n'/↵}"
        printf "%-12s  %6s bytes  %s\n" "$name" "$size" "$short_sample"
    done
}

# Preview: show full buffer content
preview_buffer() {
    local line="$1"
    local buffer_name
    buffer_name=$(echo "$line" | awk '{print $1}')

    echo -e "\033[1;34m═══ Buffer: $buffer_name ═══\033[0m"
    echo ""

    # Buffer info
    local size
    size=$(tmux show-buffer -b "$buffer_name" 2>/dev/null | wc -c)
    echo -e "\033[1;33m Size:\033[0m $size bytes"
    echo ""

    # Buffer content
    echo -e "\033[1;33m Content:\033[0m"
    echo "─────────────────────────────────────"
    tmux show-buffer -b "$buffer_name" 2>/dev/null | head -40 || echo "(empty)"
    echo "─────────────────────────────────────"
}
export -f preview_buffer

# Check if any buffers exist
BUFFER_COUNT=$(tmux list-buffers 2>/dev/null | wc -l)
if [[ "$BUFFER_COUNT" -eq 0 ]]; then
    tmux display-message "No buffers available"
    exit 0
fi

# Header based on action
case "$ACTION" in
    paste)  HEADER="Select buffer to paste" ;;
    delete) HEADER="Select buffer to delete" ;;
    save)   HEADER="Select buffer to save" ;;
    copy)   HEADER="Select buffer to copy to clipboard" ;;
    target) HEADER="Select buffer" ;;
    *)      HEADER="Select buffer" ;;
esac

# Run FZF
SELECTED=$(get_buffers | fzf \
    --ansi \
    --height=70% \
    --layout=reverse \
    --border=rounded \
    --color="$(fzf::colors)" \
    --preview='bash -c "preview_buffer {}"' \
    --preview-window=right:60%:wrap \
    --header="$HEADER (ESC to cancel)" \
    --prompt="Buffer> " \
    --bind="esc:cancel" \
) || exit 0

# Extract buffer name
BUFFER_NAME=$(echo "$SELECTED" | awk '{print $1}')

[[ -z "$BUFFER_NAME" ]] && exit 0

# Execute action
case "$ACTION" in
    paste)
        tmux paste-buffer -b "$BUFFER_NAME"
        ;;
    delete)
        tmux delete-buffer -b "$BUFFER_NAME"
        tmux display-message "Deleted buffer: $BUFFER_NAME"
        ;;
    save)
        # Prompt for filename
        SAVE_PATH="${HOME}/tmux-buffer-${BUFFER_NAME}-$(date +%Y%m%d-%H%M%S).txt"
        tmux save-buffer -b "$BUFFER_NAME" "$SAVE_PATH"
        tmux display-message "Saved to: $SAVE_PATH"
        ;;
    copy)
        # Copy to system clipboard (wayland/X11)
        if command -v wl-copy &>/dev/null; then
            tmux show-buffer -b "$BUFFER_NAME" | wl-copy
        elif command -v xclip &>/dev/null; then
            tmux show-buffer -b "$BUFFER_NAME" | xclip -selection clipboard
        else
            tmux display-message "No clipboard tool found (wl-copy/xclip)"
            exit 1
        fi
        tmux display-message "Copied to system clipboard"
        ;;
    target)
        echo "$BUFFER_NAME"
        ;;
esac
