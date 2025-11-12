#!/usr/bin/env bash
# Get WezTerm context mode and output formatted tmux status segment

# Decode the WEZTERM_CONTEXT user variable (base64 encoded)
context=$(tmux show-environment -g WEZTERM_CONTEXT 2>/dev/null | cut -d= -f2 | base64 -d 2>/dev/null)

# Default to wezterm if not set
context="${context:-wezterm}"

# Output the formatted segment with appropriate colors
if [ "$context" = "tmux" ]; then
    # Green background for tmux mode
    echo "#[bold,fg=#000000,bg=#69FF94] 󰙀 TMUX "
else
    # Purple background for wezterm mode
    echo "#[bold,fg=#000000,bg=#C792EA]  WEZTERM "
fi
