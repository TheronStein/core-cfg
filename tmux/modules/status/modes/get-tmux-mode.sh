#!/usr/bin/env bash
# Detect current tmux mode/context and output label + color

# Check for custom mode first (RESIZE, COPY, etc.)
custom_mode=$(tmux show-option -gqv @custom_mode 2>/dev/null)
if [ -n "$custom_mode" ]; then
    echo "$custom_mode"
    exit 0
fi

# Check if prefix is pressed
client_prefix=$(tmux display-message -p '#{client_prefix}')
if [ "$client_prefix" = "1" ]; then
    echo "mode:LEADER:red"
    exit 0
fi

# Check for other built-in modes
pane_in_mode=$(tmux display-message -p '#{pane_in_mode}')
pane_synchronized=$(tmux display-message -p '#{pane_synchronized}')

if [ "$pane_in_mode" = "1" ]; then
    # Copy mode or other pane modes
    mode_name=$(tmux display-message -p '#{pane_mode}' 2>/dev/null || echo "copy")
    echo "mode:${mode_name^^}:yellow"
    exit 0
fi

if [ "$pane_synchronized" = "1" ]; then
    echo "mode:SYNC:red"
    exit 0
fi

# Default: show wezterm/tmux context
context=$(tmux show-environment -g WEZTERM_CONTEXT 2>/dev/null | cut -d= -f2 | base64 -d 2>/dev/null)
context="${context:-wezterm}"

if [ "$context" = "tmux" ]; then
    echo "mode:󰙀 TMUX:green"
else
    echo "mode: WEZTERM:purple"
fi
