With these patterns, you can treat your left pane as a permanent sidebar (explorer, symbols, tags) and your right pane as a context/scratch area (terminal, help, previews), while keeping your main editing focus in the middle — all without ever losing your place.

its for a yazi left sidebar navigation and right sidebar preview plugin, both instances of yazi only use their singular preview, so \[0,10,0\] on the left, \[0,0,10\] on the right

Yes, this is a perfect and very popular Yazi setup: run **three instances** of Yazi side-by-side in a terminal multiplexer (tmux or WezTerm), where

- Left pane (15% width): Yazi instance dedicated to navigation only → \[0,10,0\] (hide parent, current, and preview; show only children)
- Middle pane (~50%): your main Yazi instance (normal behavior)
- Right pane (35% width): Yazi instance dedicated to preview only → \[0,0,10\] (hide parent and current; show only preview, maximized)

Here’s exactly how to set it up cleanly and reliably.

### 1\. The layout ratios you want

Yazi uses the --layout argument (since v24.6+):

Bash

```
# Left sidebar – navigation only (children only, 10 lines high)
yazi --layout='[0,10,0]'

# Right sidebar – preview only (preview only, 10 lines high)
yazi --layout='[0,0,10]'
```

The array means \[parent, current, preview\] in lines. 10 is more than enough because Yazi will expand the chosen section to fill the available height anyway.

### 2\. Recommended full setup (tmux example)

Add this to your shell (or bind to a key):

Bash

```
# Create the three-pane layout with exact widths
tmux new-session -d -s yazi-triple

# Left: 15% navigation sidebar
tmux split-window -h -l 15% "yazi --layout='[0,10,0]' --chooser-file=/tmp/yazi_left"

# Right: 35% preview sidebar
tmux split-window -h -l 35% "yazi --layout='[0,0,10]' --chooser-file=/tmp/yazi_right"

# Middle stays the main interactive instance
tmux send-keys "yazi" C-m

# Optional: enforce fixed widths on resize
tmux set-option -w -g pane-border-status off
tmux set-hook -g client-resized 'split-window -h -l 15% -t 0 "yazi --layout='[0,10,0]' --chooser-file=/tmp/yazi_left" \; \
                                 split-window -h -l 35% -t 2 "yazi --layout='[0,0,10]' --chooser-file=/tmp/yazi_right"'

tmux attach-session -t yazi-triple
```

### 3\. WezTerm version (if you prefer WezTerm panes)

In your WezTerm config or a launch script:

Lua

```
local wezterm = require 'wezterm'
local act = wezterm.action

wezterm.on('launch-yazi-triple', function(window, pane)
  local tab, left, _ = window:spawn_tab {}
  left:split {
    direction = 'Right',
    size = 0.15,
    args = { 'yazi', '--layout=[0,10,0]', '--chooser-file=/tmp/yazi_left' },
  }
  local right = pane:split {
    direction = 'Right',
    size = 0.35,
    args = { 'yazi', '--layout=[0,0,10]', '--chooser-file=/tmp/yazi_right' },
  }
  -- middle pane stays normal yazi
  pane:send_text 'yazi\n'
end)
```

### 4\. Sync navigation between panes (optional but magical)

Use Yazi’s --chooser-file and --cwd-file options so all three instances stay in sync:

Bash

```
# In all three instances add:
--cwd-file=/tmp/yazi_cwd          # shared current directory
--chooser-file=/tmp/yazi_choose   # shared selection
```

Or even better, put this in a small wrapper script ~/bin/yazi-left, ~/bin/yazi-right, ~/bin/yazi-main that all share the same temp files.

### 5\. One-liner you can alias right now (quick test)

Bash

```
tmux new-session -d -s y3 \
  "yazi --layout='[0,10,0]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" \; \
  split-window -h -l 15% \; \
  split-window -h -l 35% "yazi --layout='[0,0,10]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" \; \
  send c-m "yazi --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" \; \
  attach
```

Now you have exactly what you wanted:

- Left 15%: pure folder tree / navigation
- Middle: full interactive Yazi
- Right 35%: full-height preview of whatever is selected

Many power users run this exact layout daily — it feels like a proper IDE file manager once the cwd/selection syncing is in place. Enjoy!

╭─░▒▓    ~tmux-cfg/modules    master !91 ?450 ▓▒░─────────────────────────────────────────────────────────────────────────────────────░▒▓ ✔  local   01:10:15 AM  ▓▒░─╮ ╰─ ./tmux-test.sh unknown command: send c-m

The error happens because of a typo in my previous tmux one-liner: there’s an invisible non-breaking space (or similar character) between send and c-m. tmux sees it as send c-m instead of the correct send-keys (or its short form send), so it complains with “unknown command: send c-m”.

Here’s the **corrected, clean version** of the one-liner (copy-paste this exactly):

Bash

```
tmux new-session -d -s y3 \
  "yazi --layout='[0,10,0]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" \; \
  split-window -h -l 15% \; \
  split-window -h -l 35% "yazi --layout='[0,0,10]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" \; \
  send-keys "yazi --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" C-m \; \
  attach-session -t y3
```

### Or, written more readably as a proper script (~/bin/yazi-triple or wherever you like):

Bash

```
#!/usr/bin/env bash

SESSION="yazi-triple"

tmux new-session -d -s "$SESSION" \
  "yazi --layout='[0,10,0]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose"

tmux split-window -h -l 15% -t "$SESSION" \
  "yazi --layout='[0,10,0]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose"

tmux split-window -h -l 35% -t "$SESSION" \
  "yazi --layout='[0,0,10]' --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose"

# Start the main interactive yazi instance in the middle pane
tmux send-keys -t "$SESSION":0.1 \
  "yazi --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose" C-m

tmux attach-session -t "$SESSION"
```

Make it executable (chmod +x ~/bin/yazi-triple) and run it. This will give you exactly:

- Left pane (15%): navigation-only Yazi (\[0,10,0\])
- Middle pane (~50%): full normal Yazi
- Right pane (35%): preview-only Yazi (\[0,0,10\])
- All three panes stay perfectly in sync because they share the same --cwd-file and --chooser-file

No more “unknown command” error, and the layout works immediately. Enjoy the triple-yazi goodness!
