#!/usr/bin/env bash
# Generate complete tmux status-left with dynamic mode/context colors

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get current mode/context
mode_info=$(bash "$SCRIPT_DIR/get-tmux-mode.sh")
IFS=':' read -r _ mode_label mode_color <<< "$mode_info"

# Set mode colors based on current state
case "$mode_color" in
  red)    mode_bg="#f38ba8" ;;   # Red for LEADER/SYNC
  yellow) mode_bg="#f9e2af" ;;   # Yellow for copy mode
  orange) mode_bg="#fab387" ;;   # Orange for resize
  green)  mode_bg="#69FF94" ;;   # Green for TMUX context
  purple) mode_bg="#987afb" ;;   # Purple for WEZTERM context
  *)      mode_bg="#987afb" ;;   # Default purple
esac

# Get session name from argument (passed by tmux format expansion) or fallback
# Using argument ensures correct session context, not just the focused client
raw_session="${1:-#{session_name}}"
session_name=$(echo " $raw_session " | sed 's/-view-.*//')

# Build the status-left: Mode/Context → Session
# Two sections only: Context/Mode (A) → Session (B)
echo "#[bold,fg=#292D3E,bg=${mode_bg}]${mode_label} #[fg=${mode_bg},bg=#444267]#[bold,fg=${mode_bg},bg=#444267]${session_name^} #[fg=#444267,bg=#292D3E]"
