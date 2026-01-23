#!/usr/bin/env bash
# AI Session Window Picker
# Location: ~/.tmux/modules/popups/ai-picker.sh
#
# Shows fzf menu for all windows in the "ai" tmux session
# - If inside popup (ai session): switches to selected window
# - If outside popup: opens popup with selected window
#
# Keybind: Alt+` (works both inside and outside popups)

set -euo pipefail

AI_SESSION="ai"
POPUP_WIDTH="95"
POPUP_HEIGHT="95"

# Source fzf config if available
[[ -f ~/.core/.cortex/lib/fzf-config.sh ]] && source ~/.core/.cortex/lib/fzf-config.sh

# Get current session
CURRENT_SESSION=$(tmux display-message -p '#{session_name}' 2>/dev/null || echo "")

# Check if AI session exists
if ! tmux has-session -t "$AI_SESSION" 2>/dev/null; then
    # Create AI session with a default window
    tmux new-session -d -s "$AI_SESSION" -n "claude"
    tmux send-keys -t "${AI_SESSION}:claude" "claude" Enter
fi

# Get window list for AI session
get_ai_windows() {
    tmux list-windows -t "$AI_SESSION" -F "#{window_index}|#{window_name}|#{pane_current_path}|#{window_activity_flag}" 2>/dev/null | \
    while IFS='|' read -r index name path activity; do
        local marker=" "
        [[ "$activity" == "1" ]] && marker="*"

        # Shorten path
        local short_path="${path/#$HOME/~}"
        [[ ${#short_path} -gt 40 ]] && short_path="...${short_path: -37}"

        printf "%s %2s  %-20s  %s\n" "$marker" "$index" "$name" "$short_path"
    done
}

# Preview function for fzf
preview_ai_window() {
    local line="$1"
    local index
    index=$(echo "$line" | sed 's/^[* ] *//' | awk '{print $1}')

    echo -e "\033[1;34m═══ AI Window: $AI_SESSION:$index ═══\033[0m"
    echo ""

    local name
    name=$(tmux display-message -t "${AI_SESSION}:${index}" -p '#{window_name}' 2>/dev/null || echo "unknown")
    local path
    path=$(tmux display-message -t "${AI_SESSION}:${index}" -p '#{pane_current_path}' 2>/dev/null || echo "unknown")

    echo -e "\033[1;33m Window:\033[0m $name"
    echo -e "\033[1;33m Path:\033[0m $path"
    echo ""
    echo -e "\033[1;33m Content:\033[0m"
    tmux capture-pane -t "${AI_SESSION}:${index}" -p -S -20 2>/dev/null | tail -18 || echo "  (no preview)"
}
export -f preview_ai_window
export AI_SESSION

# Check if we have windows
WINDOW_COUNT=$(tmux list-windows -t "$AI_SESSION" 2>/dev/null | wc -l)

if [[ "$WINDOW_COUNT" -eq 0 ]]; then
    # No windows, create default and attach
    tmux new-window -t "$AI_SESSION" -n "claude"
    tmux send-keys -t "${AI_SESSION}:claude" "claude" Enter
    TARGET="claude"
elif [[ "$WINDOW_COUNT" -eq 1 ]]; then
    # Only one window, attach directly
    TARGET=$(tmux list-windows -t "$AI_SESSION" -F "#{window_name}" 2>/dev/null | head -1)
else
    # Multiple windows, show picker
    # Determine colors (use fzf-config.sh if available)
    FZF_COLORS="${FZF_DEFAULT_OPTS_COLORS:-bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4,hl:#f38ba8,hl+:#f38ba8,info:#cba6f7,marker:#f5e0dc,prompt:#cba6f7,spinner:#f5e0dc,pointer:#f5e0dc,header:#f38ba8,border:#6c7086,preview-bg:#1e1e2e}"

    SELECTED=$(get_ai_windows | fzf \
        --ansi \
        --height=100% \
        --layout=reverse \
        --border=rounded \
        --color="$FZF_COLORS" \
        --preview='bash -c "preview_ai_window {}"' \
        --preview-window=right:60%:wrap \
        --header="Select AI conversation window
^/ preview  Esc cancel  Enter select" \
        --prompt="󰚩 AI> " \
        --bind="ctrl-/:toggle-preview" \
        --bind="esc:cancel" \
    ) || exit 0

    # Extract window index
    TARGET=$(echo "$SELECTED" | sed 's/^[* ] *//' | awk '{print $1}')
fi

[[ -z "$TARGET" ]] && exit 0

# Attach to selected window
if [[ "$CURRENT_SESSION" == "$AI_SESSION" ]]; then
    # Already in AI session (inside popup), just switch windows
    tmux select-window -t "${AI_SESSION}:${TARGET}"
else
    # Not in AI session, open popup
    tmux display-popup -w "${POPUP_WIDTH}%" -h "${POPUP_HEIGHT}%" \
        -T " 󰚩 AI: $TARGET " -b rounded -S "fg=#89b4fa,bg=#1e1e2e" \
        "tmux attach-session -t '${AI_SESSION}:${TARGET}'"
fi
