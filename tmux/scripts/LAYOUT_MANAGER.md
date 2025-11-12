# Layout Manager - Fixed Dimension Pane System

## Overview

The Layout Manager provides a powerful system for creating **panes with static dimensions** that resist layout changes from other pane operations. This solves the problem of sidebars and utility panes being resized when you split, resize, or rearrange other panes.

## Problem Statement

By default, tmux dynamically adjusts all pane dimensions when:
- Creating new splits
- Killing panes
- Resizing panes
- Applying layouts (tiled, even-horizontal, etc.)
- Window resize events

This makes it difficult to maintain static sidebars or utility panes with fixed dimensions.

## Solution

The Layout Manager implements a **dimension locking system** that:

1. **Tracks locked panes** - Stores which panes have locked dimensions
2. **Monitors layout events** - Hooks into tmux events that affect layout
3. **Restores dimensions** - Automatically restores locked pane dimensions after any layout change
4. **Provides smart operations** - Offers wrapper commands for split/resize that respect locks

## Architecture

### Core Components

1. **layout-manager.sh** - Main script providing locking/restoration functionality
2. **tmux hooks** - Automatically restore dimensions after layout changes
3. **Session variables** - Store locked pane information per session

### How It Works

```
┌─────────────────────────────────────────────────────┐
│ User Action (split, resize, layout change)         │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│ tmux performs operation (dimensions may change)     │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│ Hook triggers: "layout-manager.sh restore"          │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│ Locked pane dimensions restored                     │
└─────────────────────────────────────────────────────┘
```

## Usage

### Automatic (Yazi Sidebar)

The Yazi sidebar automatically locks its width when enabled:

```bash
# Enable sidebar (automatically locks width)
Alt+f

# Sidebar width now stays constant regardless of:
# - New splits
# - Pane kills
# - Resizes
# - Layout changes
```

### Manual Locking

Lock any pane's dimensions manually:

```bash
# Lock current pane width (in tmux)
Alt+L

# Lock specific pane width
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %5 50

# Lock pane height
~/.core/cfg/tmux/scripts/layout-manager.sh lock-height %3 20

# Lock both dimensions
~/.core/cfg/tmux/scripts/layout-manager.sh lock-full %2 60 30

# Unlock pane
~/.core/cfg/tmux/scripts/layout-manager.sh unlock %5
```

### Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `Alt+L` | Toggle lock | Toggle dimension lock on current pane |
| `Alt+I` | List locks | Show all locked panes |
| `Alt+R` | Restore | Manually restore all locked dimensions |

### CLI Commands

```bash
# Get script path
LAYOUT_MGR="~/.core/cfg/tmux/scripts/layout-manager.sh"

# Locking commands
$LAYOUT_MGR lock-width [pane-id] [width]    # Lock pane width
$LAYOUT_MGR lock-height [pane-id] [height]  # Lock pane height
$LAYOUT_MGR lock-full [pane-id] [w] [h]     # Lock both dimensions
$LAYOUT_MGR unlock [pane-id]                # Unlock pane
$LAYOUT_MGR toggle-lock                     # Toggle lock on current pane

# Smart operations (preserve locked dimensions)
$LAYOUT_MGR split-h [size] [target]         # Horizontal split
$LAYOUT_MGR split-v [size] [target]         # Vertical split
$LAYOUT_MGR layout <type>                   # Apply layout
$LAYOUT_MGR resize <pane> <dir> <amount>    # Resize pane

# Maintenance
$LAYOUT_MGR restore                         # Restore all locked dimensions
$LAYOUT_MGR cleanup                         # Remove non-existent panes
$LAYOUT_MGR list                            # List locked panes
$LAYOUT_MGR is-locked [pane-id]             # Check if pane is locked
```

## Examples

### Example 1: Fixed Sidebar

```bash
# Create a left sidebar
tmux split-window -fhb -l 30%

# Lock the sidebar width
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 30%

# Now create splits in the main area - sidebar stays 30%
tmux split-window -v
tmux split-window -h

# Apply any layout - sidebar still 30%
tmux select-layout tiled
```

### Example 2: Fixed Bottom Panel

```bash
# Create bottom panel
tmux split-window -v -l 15

# Lock its height
~/.core/cfg/tmux/scripts/layout-manager.sh lock-height %1 15

# Split the top area multiple ways - bottom stays 15 lines
tmux select-pane -t 0
tmux split-window -h
```

### Example 3: Multiple Fixed Panes

```bash
# Left sidebar (30% width)
tmux split-window -fhb -l 30%
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 30%

# Right sidebar (25% width)
tmux split-window -fh -l 25%
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %2 25%

# Bottom panel in center (10 lines)
tmux select-pane -t 1
tmux split-window -v -l 10
~/.core/cfg/tmux/scripts/layout-manager.sh lock-height %3 10

# All three panes now have fixed dimensions
# Center area is fully flexible
```

### Example 4: Adjusting Fixed Dimensions

```bash
# You can still manually adjust locked pane sizes
# Just resize and update the lock:

# Resize sidebar to new width
tmux resize-pane -t %0 -x 40

# Update the lock to new width
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 40

# Or unlock, resize, then re-lock
~/.core/cfg/tmux/scripts/layout-manager.sh unlock %0
tmux resize-pane -t %0 -x 40
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 40
```

## Technical Details

### Storage Format

Locked panes are stored in the session variable `@locked-panes`:

```
Format: pane_id:dimension:value,pane_id:dimension:value,...
Example: %0:width:50,%1:height:15,%2:width:30%
```

### Dimension Values

Dimensions can be specified as:
- **Absolute pixels**: `50`, `100`, `200`
- **Percentages**: `30%`, `25%`, `50%`

tmux automatically handles percentage calculations.

### Hook Order

Hooks are ordered to ensure proper execution:

```
after-split-window
  [0] - layout-manager restore
  [10] - yazi-sidebar ensure

after-kill-pane
  [0] - renumber-panes
  [2] - layout-manager restore
  [10] - yazi-sidebar ensure

window-resized
  [0] - layout-manager restore
  [10] - yazi-sidebar ensure

pane-exited
  [0] - layout-manager cleanup
  [10] - yazi-sidebar cleanup
```

This ensures:
1. Pane operations complete first
2. Layout restoration happens
3. Sidebar verification happens last

### Performance

The restoration process is fast:
- Only restores locked panes (not all panes)
- Only runs on actual layout-affecting events
- No polling or continuous monitoring

### Limitations

1. **Manual resizing**: If you manually resize a locked pane with `resize-pane`, you need to update the lock or it will snap back
2. **Percentage accuracy**: When using percentages, tmux rounds to integer columns/rows
3. **Nested sessions**: Locks are per-session, not global
4. **Window splits**: Locks don't transfer when breaking/joining panes between windows

## Integration with Yazi Sidebar

The Yazi sidebar automatically uses the Layout Manager:

1. When sidebar is enabled, its width is locked
2. All layout operations automatically preserve sidebar dimensions
3. When sidebar is disabled, the lock is removed
4. If sidebar is manually resized, the lock is automatically updated

## Troubleshooting

### Locked pane keeps snapping back

Check if the pane is actually locked:
```bash
~/.core/cfg/tmux/scripts/layout-manager.sh is-locked %0
```

If yes, unlock it to resize freely:
```bash
~/.core/cfg/tmux/scripts/layout-manager.sh unlock %0
```

### Locks not working after tmux restart

Locks are stored in session variables, which don't persist across tmux restarts. The Yazi sidebar automatically re-locks on enable, but manual locks need to be reapplied.

Future: Integration with tmux-resurrect to save/restore locks.

### Too many panes locked, hard to manage

List all locks:
```bash
~/.core/cfg/tmux/scripts/layout-manager.sh list
```

Remove old locks:
```bash
~/.core/cfg/tmux/scripts/layout-manager.sh cleanup
```

Unlock all by clearing the session variable:
```bash
tmux set-option -qu @locked-panes
```

### Hooks not firing

Check if hooks are installed:
```bash
tmux show-hooks -g | grep layout-manager
```

Reload config:
```bash
tmux source-file ~/.core/cfg/tmux/tmux.conf
```

### Performance issues

If you have many locked panes and notice slowness:
```bash
# Check number of locked panes
tmux show-option -qv @locked-panes | tr ',' '\n' | wc -l

# Cleanup non-existent panes
~/.core/cfg/tmux/scripts/layout-manager.sh cleanup
```

## Advanced Usage

### Custom Split Command

Replace your split keybindings to use smart splits:

```tmux
# Instead of:
bind v split-window -h

# Use:
bind v run-shell '~/.core/cfg/tmux/scripts/layout-manager.sh split-h'
```

### Conditional Locking

Lock panes based on conditions:

```bash
# Lock pane only if it's running yazi
if tmux display-message -p -t %0 '#{pane_current_command}' | grep -q yazi; then
    ~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 30%
fi
```

### Dynamic Width Adjustment

Adjust locked width based on window size:

```bash
# Get window width
window_width=$(tmux display-message -p '#{window_width}')

# Set sidebar to 20% of window width
sidebar_width=$((window_width / 5))
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 $sidebar_width
```

## Future Enhancements

- [ ] Integration with tmux-resurrect for persistent locks
- [ ] Per-window lock profiles
- [ ] GUI for managing locks (tmux menu)
- [ ] Auto-adjustment based on window size
- [ ] Lock groups (lock multiple panes as a unit)
- [ ] Minimum/maximum dimension constraints
- [ ] Lock transitions (animate dimension changes)

## See Also

- [YAZI_SIDEBAR_V2.md](./YAZI_SIDEBAR_V2.md) - Session-scoped sidebar documentation
- [layout-manager.sh](./layout-manager.sh) - Main script implementation
- [conf/hooks.conf](../conf/hooks.conf) - Hook configuration

## Version History

### v1.0 (Current)
- Initial implementation
- Width and height locking
- Automatic restoration via hooks
- Yazi sidebar integration
- Manual locking commands
