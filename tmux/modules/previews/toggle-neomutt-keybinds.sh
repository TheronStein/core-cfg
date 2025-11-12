#!/usr/bin/env bash

# Toggle neomutt keybindings sidebar

PANE_VAR="@neomutt-keybindings-pane"
ENABLED_VAR="@neomutt-keybindings-enabled"

enable_keybindings() {
  local current_pane=$(tmux display-message -p "#{pane_id}")
  local current_dir=$(tmux display-message -p "#{pane_current_path}")

  # Create left sidebar with keybindings
  local left_pane=$(tmux split-window -fhb -l 35% -c "$current_dir" -P -F "#{pane_id}" \
    "~/.core/cfg/tmux/modules/previews/neomutt-keybindings.sh")

  tmux set-option -g "$PANE_VAR" "$left_pane"
  tmux set-option -g "$ENABLED_VAR" "1"

  # Focus back to main pane
  tmux select-pane -t "$current_pane"
}

disable_keybindings() {
  local pane=$(tmux show-option -gv "$PANE_VAR" 2>/dev/null)

  if [ -n "$pane" ] && tmux list-panes -F "#{pane_id}" | grep -q "^${pane}$"; then
    tmux kill-pane -t "$pane"
  fi

  tmux set-option -gu "$PANE_VAR"
  tmux set-option -gu "$ENABLED_VAR"
}

toggle_keybindings() {
  local enabled=$(tmux show-option -gv "$ENABLED_VAR" 2>/dev/null)

  if [ "$enabled" = "1" ]; then
    disable_keybindings
  else
    enable_keybindings
  fi
}

case "${1:-toggle}" in
  enable)
    enable_keybindings
    ;;
  disable)
    disable_keybindings
    ;;
  toggle)
    toggle_keybindings
    ;;
  *)
    echo "Usage: $0 {enable|disable|toggle}"
    exit 1
    ;;
esac
