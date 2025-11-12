#!/bin/bash
# Smart navigation for tmux that passes to WezTerm when at edge
# Usage: smart-navigate.sh <direction> <key>
# direction: U, D, L, R (tmux directions)
# key: w, s, a, d (original keys)

direction="$1"
key="$2"

# Check if we're running vim
is_vim="$(tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)g?(view|n?vim?x?)(diff)?$' && echo true || echo false)"

if [ "$is_vim" = "true" ]; then
    # Forward to vim
    tmux send-keys "M-$key"
else
    # Check if we're at the edge
    case "$direction" in
        U) at_edge="$(tmux display-message -p '#{pane_at_top}')" ;;
        D) at_edge="$(tmux display-message -p '#{pane_at_bottom}')" ;;
        L) at_edge="$(tmux display-message -p '#{pane_at_left}')" ;;
        R) at_edge="$(tmux display-message -p '#{pane_at_right}')" ;;
    esac

    if [ "$at_edge" = "1" ]; then
        # At edge - tell WezTerm to navigate by setting user var
        # Map direction to WezTerm direction
        case "$direction" in
            U) wez_dir="Up" ;;
            D) wez_dir="Down" ;;
            L) wez_dir="Left" ;;
            R) wez_dir="Right" ;;
        esac
        # Encode direction in base64
        encoded_dir="$(echo -n "$wez_dir" | base64)"
        # Get the current pane's TTY and write directly to it
        pane_tty="$(tmux display-message -p '#{pane_tty}')"
        # Send OSC escape directly to TTY, bypassing tmux filtering
        printf '\033]1337;SetUserVar=%s=%s\007' "navigate_wezterm" "$encoded_dir" > "$pane_tty"
    else
        # Not at edge - navigate within tmux
        tmux select-pane "-$direction"
    fi
fi
