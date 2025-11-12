# Default: show wezterm/tmux context
context=$(tmux show-environment -g WEZTERM_CONTEXT 2>/dev/null | cut -d= -f2 | base64 -d 2>/dev/null)
context="${context:-wezterm}"

if [ "$context" = "tmux" ]; then
  echo "mode:󰙀 TMUX:green"
else
  echo "mode: WEZTERM:purple"
fi
