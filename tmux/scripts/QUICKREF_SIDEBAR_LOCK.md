# Quick Reference: Static Sidebar Dimensions

## TL;DR

Your sidebar now maintains static dimensions. Create splits, kill panes, resize - sidebar stays put.

## Quick Start

```bash
# Enable sidebar (auto-locks to 30% width)
Alt+f

# Create splits - sidebar stays 30%
<prefix> | <prefix> -

# That's it! Everything else is automatic.
```

## Keybindings

| Key | Action |
|-----|--------|
| `Alt+f` | Toggle sidebar (auto-locks) |
| `Alt+L` | Lock current pane dimensions |
| `Alt+I` | List all locked panes |
| `Alt+R` | Restore locked dimensions |

## CLI Commands

```bash
# Lock commands
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 50
~/.core/cfg/tmux/scripts/layout-manager.sh lock-height %1 20
~/.core/cfg/tmux/scripts/layout-manager.sh unlock %0

# Info commands
~/.core/cfg/tmux/scripts/layout-manager.sh list
~/.core/cfg/tmux/scripts/layout-manager.sh is-locked %0
~/.core/cfg/tmux/scripts/layout-manager.sh restore
```

## Common Tasks

### Change Sidebar Width

**Temporarily** (resets on disable/enable):
```bash
# 1. Unlock sidebar
~/.core/cfg/tmux/scripts/layout-manager.sh unlock $(tmux show-option -qv @yazi-sidebar-pane-id)

# 2. Resize it
tmux resize-pane -t $(tmux show-option -qv @yazi-sidebar-pane-id) -x 40

# 3. Lock new width
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width $(tmux show-option -qv @yazi-sidebar-pane-id) 40
```

**Permanently** (default width):
```bash
# Edit ~/.core/cfg/tmux/scripts/yazi-sidebar-manager.sh
# Change: SIDEBAR_WIDTH="30%" to SIDEBAR_WIDTH="40%"
```

### Lock Multiple Panes

```bash
# Lock left sidebar
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %0 50

# Lock right sidebar
~/.core/cfg/tmux/scripts/layout-manager.sh lock-width %2 40

# Lock bottom panel
~/.core/cfg/tmux/scripts/layout-manager.sh lock-height %3 15
```

### Debug Issues

```bash
# Test system
~/.core/cfg/tmux/scripts/test-sidebar-lock.sh

# Check hooks
tmux show-hooks -g | grep "layout-manager\|yazi-sidebar"

# List locks
~/.core/cfg/tmux/scripts/layout-manager.sh list

# Manually restore
~/.core/cfg/tmux/scripts/layout-manager.sh restore
```

## What's Locked Automatically

- ✅ Yazi sidebar width when enabled via `Alt+f`

## What Operations Preserve Locks

- ✅ Creating new splits (`split-window`)
- ✅ Killing panes
- ✅ Resizing other panes
- ✅ Applying layouts (tiled, even-horizontal, etc.)
- ✅ Window resize events
- ✅ Switching windows

## Documentation

- Full docs: `~/.core/cfg/tmux/scripts/LAYOUT_MANAGER.md`
- Test guide: `~/.core/cfg/tmux/scripts/LAYOUT_TEST_GUIDE.md`
- Summary: `~/.core/cfg/tmux/scripts/SIDEBAR_LOCK_SUMMARY.md`

## Files

```
~/.core/cfg/tmux/scripts/
├── layout-manager.sh           # Core locking system
├── yazi-sidebar-manager.sh     # Sidebar manager (uses locks)
├── test-sidebar-lock.sh        # Quick test
├── LAYOUT_MANAGER.md           # Full documentation
├── LAYOUT_TEST_GUIDE.md        # Testing procedures
├── SIDEBAR_LOCK_SUMMARY.md     # Implementation summary
└── QUICKREF_SIDEBAR_LOCK.md    # This file
```

## Status Check

```bash
# Is sidebar enabled?
tmux show-option -qv @yazi-sidebar-enabled

# Which pane is sidebar?
tmux show-option -qv @yazi-sidebar-pane-id

# What's locked?
tmux show-option -qv @locked-panes
```

## Pro Tips

1. **Multiple sessions** - Each session has independent locks
2. **Manual adjustment** - You can still resize locked panes, just update the lock
3. **Unlock to resize freely** - `Alt+L` toggles lock on/off
4. **Percentages vs absolute** - Use `30%` for responsive, `80` for fixed columns
5. **Cleanup regularly** - Old pane locks accumulate, run cleanup occasionally

## Troubleshooting One-Liner

```bash
tmux source-file ~/.core/cfg/tmux/tmux.conf && \
  tmux display-message "Config reloaded" && \
  ~/.core/cfg/tmux/scripts/test-sidebar-lock.sh
```

## That's It!

Your sidebar now has static dimensions. Create layouts freely without worrying about the sidebar moving or resizing.

**Enable sidebar**: `Alt+f`
**Create splits**: `<prefix> |` or `<prefix> -`
**Sidebar stays put**: ✅
