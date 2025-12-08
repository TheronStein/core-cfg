#!/usr/bin/env bash
# ~/bin/yazi-sidebars  →  FIXED for numeric client-ids

SESSION="${1:-$(tmux display-message -p '#S')}" # use current session if not given

# Generate unique numeric IDs (timestamp + random = always unique, all digits)
LEFT_ID=$(date +%s)$RANDOM
PREV_ID=$(date +%s)$RANDOM

# 1. Start the hidden Yazi server once per session (no client-id for server)
if ! tmux has-session -t "=yazi-server-$SESSION" 2>/dev/null; then
  tmux new-window -d -t "$SESSION" -n "yazi-server-$SESSION" \
    "yazi --server --chooser-file /tmp/yazi_chooser_$SESSION"
  sleep 0.2
fi

# 2. Create the three-pane layout in the current window
tmux select-layout tiled 2>/dev/null

# Left = main navigation (30% width)
tmux split-window -h -t "$SESSION" -p 10 # 30% left, 70% right for middle+preview
tmux split-window -h -t "$SESSION" -p 30 # split right 30% → 30% preview + 60% middle

# Now panes are:  0=left (30%) | 1=middle (35%) | 2=right (35%)

# Left sidebar → ONLY the file list (single column, numeric ID)
tmux send-keys -t "$SESSION:.0" \
  "yazi --client-id $LEFT_ID --clear-layout [1]" C-m

# Right sidebar → pure preview (numeric ID)
tmux send-keys -t "$SESSION:.2" \
  "yazi --client-id $PREV_ID --preview-only" C-m

# Make them pretty and obvious
tmux select-pane -t "$SESSION:.0" -T " Yazi │ List "
tmux select-pane -t "$SESSION:.2" -T " Yazi │ Preview "
tmux select-pane -t "$SESSION:.1" -T " Workspace "

# Focus the real workspace (middle)
tmux select-pane -t "$SESSION:.1"

echo "Yazi synchronized sidebars injected! (IDs: left=$LEFT_ID, prev=$PREV_ID)"
