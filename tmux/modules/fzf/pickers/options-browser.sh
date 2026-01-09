#!/usr/bin/env bash
# Options Browser - FZF-based tmux options explorer
# Location: ~/.tmux/modules/fzf/pickers/options-browser.sh
# Usage: options-browser.sh [--scope=server|session|window|pane|all]

source ~/.core/.cortex/lib/fzf-config.sh

# Parse arguments
SCOPE="${1:-all}"
[[ "$SCOPE" == --scope=* ]] && SCOPE="${SCOPE#*=}"

# Get options by scope
get_options() {
    case "$1" in
        server)
            bash -c 'tmux show -s 2>/dev/null | grep -E "^[a-z@]" | sed "s/^/[server]  /"'
            ;;
        session)
            bash -c 'tmux show -g 2>/dev/null | grep -E "^[a-z@]" | grep -v "^status-format" | sed "s/^/[session] /"'
            ;;
        window)
            bash -c 'tmux show -wg 2>/dev/null | grep -E "^[a-z@]" | sed "s/^/[window]  /"'
            ;;
        pane)
            bash -c 'tmux show -pg 2>/dev/null | grep -E "^[a-z@]" | sed "s/^/[pane]    /"'
            ;;
        all)
            get_options server
            get_options session
            get_options window
            get_options pane
            ;;
    esac
}

# Header
case "$SCOPE" in
    server)  HEADER="Server Options" ;;
    session) HEADER="Session Options" ;;
    window)  HEADER="Window Options" ;;
    pane)    HEADER="Pane Options" ;;
    *)       HEADER="All Tmux Options" ;;
esac

# Run FZF
SELECTED=$(get_options "$SCOPE" | fzf \
    --ansi \
    --height=90% \
    --layout=reverse \
    --border=rounded \
    --color="$(fzf::colors)" \
    --preview='echo -e "\033[1;34m═══ Option ═══\033[0m\n"; echo "{}"' \
    --preview-window=right:50%:wrap \
    --header="$HEADER (ESC to cancel)" \
    --prompt="Option> " \
    --bind="esc:cancel" \
) || exit 0

# Extract option name
OPTION_NAME=$(echo "$SELECTED" | awk '{print $2}')
[[ -z "$OPTION_NAME" ]] && exit 0

echo -n "$OPTION_NAME" | tmux load-buffer -
tmux display-message "Copied: $OPTION_NAME"
