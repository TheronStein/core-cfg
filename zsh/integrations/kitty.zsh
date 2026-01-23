# ~/.core/.sys/cfg/zsh/integrations/kitty.zsh
# Kitty Terminal Integration - Utilities and socket detection
#
# Navigation keybindings are handled by navigation.zsh which provides
# cross-terminal support (WezTerm, Kitty, Ghostty) with tmux edge detection.
# This file provides Kitty-specific utilities and socket detection helpers.

#=============================================================================
# CHECK FOR KITTY
# Check multiple indicators since env vars aren't always reliable
#=============================================================================
_kitty_detected=0

# Method 1: KITTY_PID set
[[ -n "$KITTY_PID" ]] && _kitty_detected=1

# Method 2: KITTY_LISTEN_ON set
[[ -n "$KITTY_LISTEN_ON" ]] && _kitty_detected=1

# Method 3: TERM is xterm-kitty
[[ "$TERM" == "xterm-kitty" ]] && _kitty_detected=1

# Method 4: Kitty socket exists (configured path or dynamic)
[[ -S "/tmp/kitty" ]] && _kitty_detected=1
[[ $_kitty_detected -eq 0 ]] && [[ -n "$(find /tmp -maxdepth 1 -name 'kitty-*' -type s 2>/dev/null | head -1)" ]] && _kitty_detected=1

# Exit if not in Kitty
[[ $_kitty_detected -eq 0 ]] && return 0

#=============================================================================
# SOCKET DETECTION
# Find the Kitty remote control socket (used by terminal-nav and utilities)
#=============================================================================
_get_kitty_socket() {
  # Method 1: KITTY_LISTEN_ON env var
  if [[ -n "$KITTY_LISTEN_ON" ]]; then
    echo "$KITTY_LISTEN_ON"
    return
  fi

  # Method 2: Configured socket path (from kitty.conf: listen_on unix:/tmp/kitty)
  if [[ -S "/tmp/kitty" ]]; then
    echo "unix:/tmp/kitty"
    return
  fi

  # Method 3: Dynamic socket (kitty creates /tmp/kitty-{PID})
  local found
  found=$(find /tmp -maxdepth 1 -name "kitty-*" -type s 2>/dev/null | head -1)
  if [[ -n "$found" ]]; then
    echo "unix:$found"
    return
  fi

  # Fallback
  echo "unix:/tmp/kitty"
}

#=============================================================================
# UTILITY FUNCTIONS
#=============================================================================

# List all kitty windows
kitty-windows() {
  local socket
  socket=$(_get_kitty_socket)
  kitty @ --to "$socket" ls 2>/dev/null | jq -r '.[].tabs[].windows[] | "\(.id): \(.title)"'
}

# Focus specific kitty window by ID
kitty-focus() {
  local id="$1"
  local socket
  socket=$(_get_kitty_socket)
  kitty @ --to "$socket" focus-window --match "id:$id"
}

# Debug function for troubleshooting navigation
kitty-nav-debug() {
  echo "=== Kitty Navigation Debug ==="
  echo "KITTY_PID: ${KITTY_PID:-unset}"
  echo "KITTY_LISTEN_ON: ${KITTY_LISTEN_ON:-unset}"
  echo "TERM: $TERM"
  echo "TMUX: ${TMUX:-unset}"
  echo "Socket: $(_get_kitty_socket)"
  echo ""
  echo "Navigation keybindings (from navigation.zsh):"
  bindkey | grep -E '__nav_'
  echo ""
  echo "Test socket connection:"
  local socket
  socket=$(_get_kitty_socket)
  kitty @ --to "$socket" ls 2>&1 | head -3
}
