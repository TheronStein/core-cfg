#!/usr/bin/env bash
# Get WezTerm context mode and output label

# Decode the WEZTERM_CONTEXT user variable (base64 encoded)
context=$(tmux show-environment -g WEZTERM_CONTEXT 2>/dev/null | cut -d= -f2 | base64 -d 2>/dev/null)

# Default to wezterm if not set
context="${context:-wezterm}"

# Output the appropriate label based on context
if [ "$context" = "tmux" ]; then
    echo "󰙀 TMUX"
else
    echo " WEZTERM"
fi
