# Layout Manager Testing Guide

## Quick Test Procedure

### Setup

1. **Reload tmux config**:
   ```bash
   tmux source-file ~/.core/cfg/tmux/tmux.conf
   ```

2. **Verify scripts are executable**:
   ```bash
   ls -l ~/.core/cfg/tmux/scripts/layout-manager.sh
   ls -l ~/.core/cfg/tmux/scripts/yazi-sidebar-manager.sh
   ```

### Test 1: Basic Sidebar Locking

**Objective**: Verify sidebar maintains its width when creating new splits

```bash
# Step 1: Enable sidebar
Alt+f

# Step 2: Verify sidebar is created and locked
~/.core/cfg/tmux/scripts/layout-manager.sh list
# Should show: %X (yazi-sidebar): width = 30%

# Step 3: Create splits in main area
Prefix + |  # or your split-h binding
Prefix + -  # or your split-v binding

# Expected: Sidebar stays exactly 30% width

# Step 4: Create multiple splits
Prefix + | (repeat)
Prefix + - (repeat)

# Expected: Sidebar still 30% width regardless of number of splits
```

### Test 2: Sidebar Persistence Through Pane Kills

**Objective**: Verify sidebar width persists when killing other panes

```bash
# Step 1: Start with sidebar + 3 panes
Alt+f
Prefix + |
Prefix + -

# Step 2: Note sidebar width
tmux display-message -p "#{pane_width}" -t %0

# Step 3: Kill a pane
Prefix + x  # on non-sidebar pane
y           # confirm

# Expected: Sidebar width unchanged

# Step 4: Kill another pane
Prefix + x
y

# Expected: Sidebar still same width
```

### Test 3: Sidebar Through Layout Changes

**Objective**: Verify sidebar resists layout commands

```bash
# Step 1: Setup sidebar + multiple panes
Alt+f
Prefix + | (create 2-3 more panes)

# Step 2: Apply tiled layout
Prefix + Alt+1  # or: tmux select-layout tiled

# Expected: All panes except sidebar are tiled, sidebar stays 30%

# Step 3: Apply even-horizontal layout
Prefix + Alt+2  # or: tmux select-layout even-horizontal

# Expected: Sidebar still 30%

# Step 4: Apply main-vertical layout
Prefix + Alt+3  # or: tmux select-layout main-vertical

# Expected: Sidebar still 30%
```

### Test 4: Window Resize

**Objective**: Verify sidebar maintains width percentage on window resize

```bash
# Step 1: Enable sidebar and note actual width
Alt+f
tmux display-message -p "Window: #{window_width}, Sidebar: #{pane_width}"

# Step 2: Resize terminal window (make it wider/narrower)
# (Use terminal emulator's resize)

# Step 3: Check dimensions again
tmux display-message -p "Window: #{window_width}, Sidebar: #{pane_width}"

# Expected: Sidebar is still 30% of new window width
```

### Test 5: Manual Lock/Unlock

**Objective**: Test manual locking of arbitrary panes

```bash
# Step 1: Create 3 panes (no sidebar)
Prefix + |
Prefix + -

# Step 2: Lock middle pane width
# Focus middle pane, then:
Alt+L
# Or manually:
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %1

# Step 3: List locks
Alt+I
# Should show: %1: width = <current width>

# Step 4: Create new split
Prefix + |

# Expected: Locked pane maintains its width

# Step 5: Unlock
Alt+L (on the locked pane)

# Step 6: Create another split
Prefix + |

# Expected: Previously locked pane now resizes normally
```

### Test 6: Multiple Locked Panes

**Objective**: Test multiple independent locked panes

```bash
# Step 1: Create 4 panes
Prefix + | ; Prefix + | ; Prefix + -

# Step 2: Lock two panes with different dimensions
tmux select-pane -t 0
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 50

tmux select-pane -t 2
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %2 60

# Step 3: List locks
~/.core/cfg/tmux/scripts/layout-manager.sh list

# Step 4: Kill a non-locked pane
tmux select-pane -t 1
Prefix + x

# Expected: Both locked panes maintain their widths

# Step 5: Apply layout
tmux select-layout tiled

# Expected: Both locked panes maintain their widths
```

### Test 7: Sidebar with Preview Pane

**Objective**: Test sidebar when preview pane is also active

```bash
# Step 1: Enable sidebar
Alt+f

# Step 2: Enable preview pane
Alt+Shift+F (or your preview toggle binding)

# Expected: Preview appears, sidebar stays 30%

# Step 3: Create split in main area
Focus main area pane
Prefix + |

# Expected: Sidebar still 30%, preview unaffected

# Step 4: Toggle preview off
Alt+Shift+F

# Expected: Sidebar still 30%
```

### Test 8: Sidebar Across Window Switches

**Objective**: Verify sidebar state is session-scoped

```bash
# Step 1: Enable sidebar in window 1
Alt+f

# Step 2: Create new window
Prefix + c

# Expected: New window has sidebar (if enabled for session)

# Step 3: Switch back to window 1
Prefix + 1

# Expected: Sidebar still present and same width

# Step 4: Disable sidebar
Alt+f

# Step 5: Create new window
Prefix + c

# Expected: New window has no sidebar
```

### Test 9: Hook Verification

**Objective**: Verify hooks are properly installed

```bash
# Check layout manager hooks
tmux show-hooks -g | grep layout-manager

# Expected output:
# after-split-window: run-shell "~/.core/cfg/tmux/scripts/layout-manager.sh restore"
# after-kill-pane[2]: run-shell "~/.core/cfg/tmux/scripts/layout-manager.sh restore"
# window-resized: run-shell "~/.core/cfg/tmux/scripts/layout-manager.sh restore"
# pane-exited: run-shell "~/.core/cfg/tmux/scripts/layout-manager.sh cleanup"

# Check sidebar hooks
tmux show-hooks -g | grep yazi-sidebar-manager

# Expected: Various hooks for sidebar ensure
```

### Test 10: Stress Test

**Objective**: Verify system handles rapid operations

```bash
# Step 1: Enable sidebar
Alt+f

# Step 2: Rapidly create/kill panes
# Execute quickly in sequence:
Prefix + | ; Prefix + - ; Prefix + | ; Prefix + x ; y ; Prefix + | ; Prefix + x ; y

# Expected: Sidebar maintains width throughout all operations

# Step 3: Apply layouts rapidly
tmux select-layout tiled
tmux select-layout even-horizontal
tmux select-layout even-vertical
tmux select-layout tiled

# Expected: Sidebar still 30% width
```

## Common Issues and Solutions

### Issue: Sidebar doesn't maintain width

**Check**:
```bash
# Is sidebar locked?
~/.core/cfg/tmux/scripts/layout-manager.sh is-locked $(tmux show-option -qv @yazi-sidebar-pane-id)

# Are hooks installed?
tmux show-hooks -g | grep layout-manager
```

**Solution**:
```bash
# Reload config
tmux source-file ~/.core/cfg/tmux/tmux.conf

# Disable and re-enable sidebar
Alt+f ; Alt+f
```

### Issue: "Script not found" error

**Check**:
```bash
ls -l ~/.core/cfg/tmux/scripts/layout-manager.sh
```

**Solution**:
```bash
chmod +x ~/.core/cfg/tmux/scripts/layout-manager.sh
chmod +x ~/.core/cfg/tmux/scripts/yazi-sidebar-manager.sh
```

### Issue: Width keeps changing slightly

**Explanation**: When using percentages, tmux rounds to integer columns. This is expected behavior.

**Solution**: Use absolute widths if pixel-perfect accuracy is needed:
```bash
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 80
```

### Issue: Locks don't persist after tmux restart

**Explanation**: Locks are stored in session variables, not persistent storage.

**Solution**: This is expected. The sidebar automatically re-locks on enable. For manual locks, consider adding to your session startup script.

## Success Criteria

✅ All tests pass with expected results
✅ Sidebar maintains width through all operations
✅ Manual locks work on arbitrary panes
✅ Multiple locks can coexist
✅ Hooks execute without errors
✅ No performance degradation
✅ Layout changes don't break sidebar
✅ Window resize maintains percentage
✅ Session-scoped state works correctly

## Performance Metrics

Expected performance (on modern hardware):
- Hook execution: < 50ms per operation
- Dimension restoration: < 100ms for 10 locked panes
- No noticeable lag during normal operations

To measure:
```bash
# Time a split operation
time tmux split-window -h

# Should be < 200ms total
```

## Reporting Issues

If tests fail, report:
1. Which test failed
2. tmux version: `tmux -V`
3. Hook status: `tmux show-hooks -g | grep -E "(layout|yazi)"`
4. Lock status: `~/.core/cfg/tmux/scripts/layout-manager.sh list`
5. Error messages (if any)
