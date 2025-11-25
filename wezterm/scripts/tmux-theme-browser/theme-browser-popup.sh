#!/usr/bin/env bash
# WezTerm Theme Browser - Tmux Popup with Split Layout
# Creates popup with fzf on left, live preview pane on right

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in tmux
if [[ -z "${TMUX:-}" ]]; then
    echo "Error: This script must be run from within tmux" >&2
    exit 1
fi

# Create the popup with a split layout using a wrapper script
tmux display-popup -E -w 95% -h 90% \
    "$SCRIPT_DIR/theme-browser-session.sh"
