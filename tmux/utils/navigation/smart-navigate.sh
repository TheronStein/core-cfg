#!/bin/bash
# Smart navigation for tmux with multi-terminal support
# Navigates: Neovim splits <-> Tmux panes <-> Terminal panes
# Supports: WezTerm, Ghostty, Kitty (all use kitty keyboard protocol)
#
# Usage: smart-navigate.sh <direction> [--from-vim]
# direction: U, D, L, R (Up, Down, Left, Right)
# --from-vim: Skip vim detection (used when called from neovim)

direction="$1"
from_vim="${2:-}"

if [ -z "$direction" ]; then
  echo "Usage: $0 <direction> [--from-vim]"
  echo "direction: U, D, L, R"
  exit 1
fi

# Map direction to keys
case "$direction" in
  U) key="w"; arrow="Up" ;;
  D) key="s"; arrow="Down" ;;
  L) key="a"; arrow="Left" ;;
  R) key="d"; arrow="Right" ;;
  *) echo "Invalid direction: $direction"; exit 1 ;;
esac

# Check if we're running vim/neovim
is_vim() {
  tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)g?(view|n?vim?x?)(diff)?$'
}

# Check if we're at the specified edge
at_edge() {
  case "$1" in
    U) tmux display-message -p '#{pane_at_top}' ;;
    D) tmux display-message -p '#{pane_at_bottom}' ;;
    L) tmux display-message -p '#{pane_at_left}' ;;
    R) tmux display-message -p '#{pane_at_right}' ;;
  esac
}

# Get the outer terminal type using multiple detection methods
get_terminal() {
  local term_prog=""

  # Method 1: Try TERM_PROGRAM from tmux environment
  term_prog=$(tmux show-environment TERM_PROGRAM 2>/dev/null | grep -v "^-" | cut -d= -f2)
  if [ -n "$term_prog" ]; then
    echo "$term_prog"
    return
  fi

  # Method 2: Check for WezTerm-specific variables
  local wezterm_socket
  wezterm_socket=$(tmux show-environment WEZTERM_UNIX_SOCKET 2>/dev/null | grep -v "^-" | cut -d= -f2)
  if [ -n "$wezterm_socket" ]; then
    echo "WezTerm"
    return
  fi

  # Method 3: Check for Kitty-specific variables
  local kitty_listen
  kitty_listen=$(tmux show-environment KITTY_LISTEN_ON 2>/dev/null | grep -v "^-" | cut -d= -f2)
  if [ -n "$kitty_listen" ]; then
    echo "kitty"
    return
  fi

  # Method 4: Check TERM for terminal hints
  local term
  term=$(tmux show-environment TERM 2>/dev/null | grep -v "^-" | cut -d= -f2)
  case "$term" in
    *kitty*) echo "kitty"; return ;;
    *wezterm*) echo "WezTerm"; return ;;
    xterm-ghostty) echo "ghostty"; return ;;
  esac

  # Default: unknown (will use CSI fallback)
  echo ""
}

# Signal terminal to navigate its panes
signal_terminal() {
  local dir="$1"
  local terminal
  terminal=$(get_terminal)
  local pane_tty
  pane_tty=$(tmux display-message -p '#{pane_tty}')

  case "$terminal" in
    wezterm|WezTerm)
      # WezTerm: Use OSC 1337 SetUserVar
      local encoded_dir
      encoded_dir=$(echo -n "$dir" | base64)
      printf '\033]1337;SetUserVar=%s=%s\007' "navigate_wezterm" "$encoded_dir" >"$pane_tty"
      ;;
    ghostty)
      # Ghostty: Send CSI u sequence for Ctrl+Shift+Arrow
      # These map to goto_split in ghostty config
      case "$dir" in
        Up)    printf '\033[1;6A' >"$pane_tty" ;;  # CSI 1;6 A = Ctrl+Shift+Up
        Down)  printf '\033[1;6B' >"$pane_tty" ;;  # CSI 1;6 B = Ctrl+Shift+Down
        Left)  printf '\033[1;6D' >"$pane_tty" ;;  # CSI 1;6 D = Ctrl+Shift+Left
        Right) printf '\033[1;6C' >"$pane_tty" ;;  # CSI 1;6 C = Ctrl+Shift+Right
      esac
      ;;
    kitty)
      # Kitty: Use kitty @ remote control if available, else CSI arrows
      # Map direction names to kitty's expected format
      local kitty_dir
      case "$dir" in
        Up)    kitty_dir="top" ;;
        Down)  kitty_dir="bottom" ;;
        Left)  kitty_dir="left" ;;
        Right) kitty_dir="right" ;;
      esac

      if command -v kitty >/dev/null 2>&1 && [ -n "$KITTY_LISTEN_ON" ]; then
        kitty @ focus-window --match "neighbor:$kitty_dir" 2>/dev/null || \
          # Fallback to CSI arrows
          case "$dir" in
            Up)    printf '\033[1;6A' >"$pane_tty" ;;
            Down)  printf '\033[1;6B' >"$pane_tty" ;;
            Left)  printf '\033[1;6D' >"$pane_tty" ;;
            Right) printf '\033[1;6C' >"$pane_tty" ;;
          esac
      else
        # Fallback to CSI arrows like ghostty
        case "$dir" in
          Up)    printf '\033[1;6A' >"$pane_tty" ;;
          Down)  printf '\033[1;6B' >"$pane_tty" ;;
          Left)  printf '\033[1;6D' >"$pane_tty" ;;
          Right) printf '\033[1;6C' >"$pane_tty" ;;
        esac
      fi
      ;;
    *)
      # Unknown terminal - try CSI arrows as fallback
      case "$dir" in
        Up)    printf '\033[1;6A' >"$pane_tty" ;;
        Down)  printf '\033[1;6B' >"$pane_tty" ;;
        Left)  printf '\033[1;6D' >"$pane_tty" ;;
        Right) printf '\033[1;6C' >"$pane_tty" ;;
      esac
      ;;
  esac
}

# Main navigation logic
if [ "$from_vim" != "--from-vim" ] && is_vim; then
  # In vim/neovim: forward Ctrl+Shift+key to vim
  # Vim will handle its own edge detection and call back with --from-vim
  tmux send-keys "C-S-$key"
else
  # Either called from vim (--from-vim) or not in vim
  # Check if at tmux edge
  if [ "$(at_edge "$direction")" = "1" ]; then
    # At edge: signal terminal to navigate its panes
    signal_terminal "$arrow"
  else
    # Not at edge: navigate within tmux
    tmux select-pane "-$direction"
  fi
fi
