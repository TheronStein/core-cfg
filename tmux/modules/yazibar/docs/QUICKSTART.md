# Yazibar Quickstart Guide

Get up and running with Yazibar in 5 minutes.

## Step 1: Prerequisites

```bash
# Check tmux version (needs 3.0+)
tmux -V

# Check yazi is installed
which yazi

# Check yazi sidebar config exists
ls ~/.core/cfg/yazi-sidebar/

# Check layout manager exists
ls ~/.core/cfg/tmux/scripts/layout-manager.sh
```

## Step 2: Load Yazibar

Add to your `~/.core/cfg/tmux/tmux.conf`:

```tmux
# Yazibar module
run-shell "~/.core/cfg/tmux/modules/yazibar/yazibar.tmux"
```

Reload tmux config:

```bash
tmux source-file ~/.core/cfg/tmux/tmux.conf
```

## Step 3: Test the Sidebars

### Open Left Sidebar

```
Press: Alt+f
```

You should see:
- New pane on the left (30% width)
- Yazi file browser running
- File list for current directory

### Open Right Sidebar

```
Press: Alt+F  (Shift+Alt+f)
```

You should see:
- New pane on the right (25% width)
- Another yazi instance
- Synchronized with left sidebar

### Navigate

```
In left sidebar:
  j/k     - Move down/up
  Enter   - Enter directory
  h       - Go to parent directory
```

The right sidebar should mirror your navigation.

## Step 4: Customize

### Change Default Widths

```tmux
# Add to tmux.conf BEFORE loading yazibar
set -g @yazibar-left-width "40%"
set -g @yazibar-right-width "30%"
```

### Resize on the Fly

```
Alt+Backspace  - Widen left sidebar
Alt+\          - Narrow left sidebar
Alt+]          - Widen right sidebar
Alt+[          - Narrow right sidebar
```

Widths are automatically saved for the current directory!

## Step 5: Integrate with Nvim

### Register Nvim

```
Press: Alt+n
```

This registers your current nvim instance. Now when you select files in yazi, they'll open in that nvim.

### Check Status

```
Press: Alt+?
```

Shows:
- Left/right sidebar status
- Session status
- Saved widths
- Much more

## Common Workflows

### Workflow 1: Project Browsing

```
1. Open project in nvim
2. Alt+n              - Register nvim
3. Alt+f              - Open left sidebar
4. Alt+F              - Open right sidebar
5. Navigate in yazi
6. Press 'o' in yazi  - Opens file in nvim
```

### Workflow 2: File Comparison

```
1. Alt+f              - Open left sidebar
2. Navigate to dir A
3. Alt+F              - Open right sidebar
4. Compare layouts side-by-side
```

### Workflow 3: Quick Browse

```
1. Alt+f              - Open sidebar
2. Browse files
3. Alt+f              - Close sidebar
```

## Troubleshooting

### Left sidebar won't open

```bash
# Enable debug mode
tmux set -g @yazibar-debug "1"

# Try opening again
# Alt+f

# Check debug log
tail ~/.local/share/tmux/yazibar/debug.log
```

### Right sidebar says "Left sidebar required"

This is expected! Right sidebar needs left sidebar active.

```
1. Alt+f    - Open left sidebar first
2. Alt+F    - Then open right sidebar
```

### Sidebars disappear after split

Check that hooks are loaded:

```bash
tmux show-hooks -g | grep yazibar
```

Should show multiple hooks. If not, reload config:

```bash
tmux source-file ~/.core/cfg/tmux/tmux.conf
```

### Width not saving

```bash
# Check width file
cat ~/.local/share/tmux/yazibar/widths.txt

# Manually save current width
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-width.sh save-current %5 left

# Replace %5 with your left sidebar pane ID (check with: tmux list-panes)
```

## Next Steps

- Read [README.md](../README.md) for full documentation
- Read [ARCHITECTURE.md](../ARCHITECTURE.md) for technical details
- Customize keybindings in `conf/keybindings.conf`
- Configure yazi in `~/.core/cfg/yazi-sidebar/`

## Key Cheat Sheet

```
┌─────────────────────────────────────────────────────┐
│                  YAZIBAR KEYS                       │
├─────────────────────────────────────────────────────┤
│ Sidebars:                                           │
│   Alt+f          Toggle left sidebar                │
│   Alt+F          Toggle right sidebar               │
│   Alt+g          Focus left sidebar                 │
│   Alt+G          Focus right sidebar                │
│                                                     │
│ Resize:                                             │
│   Alt+Backspace  Widen left sidebar                 │
│   Alt+\          Narrow left sidebar                │
│   Alt+]          Widen right sidebar                │
│   Alt+[          Narrow right sidebar               │
│                                                     │
│ Sync:                                               │
│   Alt+S          Toggle input synchronization       │
│                                                     │
│ Info:                                               │
│   Alt+?          Show status                        │
│   Alt+n          Register nvim                      │
│   Alt+N          Show nvim status                   │
│                                                     │
│ Cleanup:                                            │
│   Alt+Ctrl+c     Cleanup sessions                   │
└─────────────────────────────────────────────────────┘
```

Happy browsing! 🚀
