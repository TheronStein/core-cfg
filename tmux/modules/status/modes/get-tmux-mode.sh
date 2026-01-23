#!/usr/bin/env bash
# Detect current tmux context AND mode, output both as separate segments
# Output format: CONTEXT_ICON CONTEXT_LABEL:context_color|MODE_LABEL:mode_color
# Mode portion is empty when no tmux mode is active

# ── Get Context (always present) ──────────────────────────────────────────────
# State is set by pane-focus-in hook based on @pane-is-vim detection
# Manual override flag indicates user explicitly set context (won't auto-update)
context=$(tmux show-option -gqv @tmux-context-mode)
context="${context:-TMUX}"
manual=$(tmux show-option -gqv @tmux-context-manual)

# Add lock icon when manual override is active
if [ "$manual" = "1" ]; then
  manual_indicator=" 󰌾"
else
  manual_indicator=""
fi

if [ "$context" = "NEOVIM" ]; then
  context_out="  NEOVIM${manual_indicator}:neovim"
else
  context_out="󰙀  TMUX${manual_indicator}:tmux"
fi

# ── Get Mode (only when active) ───────────────────────────────────────────────
mode_out=""

# Check for custom mode first (RESIZE, etc.)
custom_mode=$(tmux show-option -gqv @custom_mode 2>/dev/null)
if [ -n "$custom_mode" ]; then
  # Custom mode format is already "mode:LABEL:color", extract the mode part
  mode_out="${custom_mode#mode:}"
else
  # Check if prefix is pressed
  client_prefix=$(tmux display-message -p '#{client_prefix}')
  if [ "$client_prefix" = "1" ]; then
    mode_out="LEADER:red"
  else
    # Check for other built-in modes
    pane_in_mode=$(tmux display-message -p '#{pane_in_mode}')
    pane_synchronized=$(tmux display-message -p '#{pane_synchronized}')

    if [ "$pane_in_mode" = "1" ]; then
      mode_name=$(tmux display-message -p '#{pane_mode}' 2>/dev/null || echo "copy")
      mode_out="${mode_name^^}:yellow"
    elif [ "$pane_synchronized" = "1" ]; then
      mode_out="SYNC:red"
    fi
  fi
fi

# ── Output both: context|mode ─────────────────────────────────────────────────
echo "${context_out}|${mode_out}"

# ARCHIVED: WezTerm context detection (preserved for potential future use)
# context=$(tmux show-environment -g WEZTERM_CONTEXT 2>/dev/null | cut -d= -f2 | base64 -d 2>/dev/null)
# context="${context:-wezterm}"
# if [ "$context" = "tmux" ]; then
#     echo "mode:󰙀 TMUX:green"
# else
#     echo "mode: WEZTERM:purple"
# fi
