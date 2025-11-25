# Tmux View Session Cleanup

## Problem

When attaching to tmux sessions from WezTerm tabs, temporary "view" sessions accumulate in the background. These view sessions are created using tmux's session grouping feature to provide independent views of the same session, but they don't get automatically cleaned up when WezTerm tabs are closed.

## Solution

A multi-layered cleanup system that detects and removes orphaned view sessions:

### 1. Automatic Event-Driven Cleanup

**Tmux Hooks** (`~/.core/cfg/tmux/conf/hooks.conf`)
- `client-detached` - Triggers when a client detaches from a view session
- `session-closed` - Triggers when a view session closes

These hooks send cleanup signals to WezTerm via OSC escape sequences:
```bash
set-hook -g client-detached 'run-shell "if echo #{session_name} | grep -q -- \"-view-\"; then printf \"\\033]1337;SetUserVar=TMUX_CLEANUP_TRIGGER=$(echo -n detach:#{session_name}:#{client_session} | base64)\\007\" > #{pane_tty}; fi"'
```

**WezTerm Event Handler** (`events/tab-cleanup.lua`)
- Listens for `TMUX_CLEANUP_TRIGGER` user-var changes
- Immediately calls `cleanup_orphaned_views()` when triggered
- Also handles `mux-tab-closed`, `mux-window-close`, and `gui-shutdown` events

### 2. Periodic Cleanup (Fallback)

- Periodic check every 60 seconds for dead tmux sessions (reduced from 2 seconds)
- Safety cleanup every 5 minutes (reduced from 30 seconds)
- Less aggressive now that event-driven cleanup is in place

### 3. Manual Cleanup

**Keybinding**: `LEADER + Shift + C`
- Manually trigger cleanup of all orphaned view sessions
- Shows toast notification with count of cleaned sessions

**Command-line Script**: `~/.core/cfg/wezterm/scripts/cleanup-orphaned-tmux-views.sh`
- Can be run from terminal to clean up orphaned sessions
- Useful for debugging or when WezTerm is not running

## How It Works

### View Session Pattern
View sessions follow this naming pattern:
```
<prefix>-view-<timestamp>-<random>
```

Examples:
- `tmux-17-view-1763312073-1449`
- `floating-view-1763323651-4474`
- `yazi-view-1763295383-1656`
- `wezterm-view-1763305218-1851`

### Cleanup Criteria
A view session is cleaned up if ALL of these are true:
1. **Pattern match**: Session name matches `*-view-<timestamp>-<random>`
2. **Not tracked**: Not found in WezTerm's `custom_tabs` metadata
3. **Not attached**: No active tmux clients attached to it

### Multi-Workspace Support
The cleanup function now checks ALL tmux sockets/workspaces:
- Default tmux socket
- All workspace-specific sockets defined in `tmux_workspaces` module

## Files Modified

1. **`modules/tmux_sessions.lua`**
   - Enhanced `cleanup_orphaned_views()` to check all workspaces
   - Improved pattern matching to catch all view session types
   - Better logging and error handling

2. **`keymaps/mods/leader.lua`**
   - Added `LEADER+Shift+C` keybinding for manual cleanup
   - Shows toast notifications with cleanup results

3. **`scripts/cleanup-orphaned-tmux-views.sh`** (NEW)
   - Standalone shell script for command-line cleanup
   - Checks all tmux sockets
   - Colored output for better visibility

## Usage

### Automatic (Default)
The system automatically cleans up orphaned sessions when:
- A WezTerm tab with a tmux view is closed
- A WezTerm window is closed
- WezTerm shuts down
- A tmux client detaches from a view session

### Manual Cleanup

**From WezTerm:**
1. Press `LEADER` (default: `Super+Space`)
2. Press `Shift+C`
3. Toast notification shows how many sessions were cleaned

**From Command Line:**
```bash
~/.core/cfg/wezterm/scripts/cleanup-orphaned-tmux-views.sh
```

### Verify Cleanup
Check for remaining view sessions:
```bash
tmux list-sessions | grep -E "view"
```

## Troubleshooting

### View sessions still accumulating
1. Check WezTerm logs for cleanup events:
   ```bash
   tail -f ~/.local/share/wezterm/wezterm.log
   ```

2. Manually trigger cleanup:
   - Use `LEADER+Shift+C` keybinding
   - Or run the shell script

3. Verify tmux hooks are working:
   ```bash
   tmux show-hooks -g | grep -E "client-detached|session-closed"
   ```

### Sessions not being cleaned
Check if sessions are actually orphaned:
```bash
tmux list-sessions -F '#{session_name}|#{session_attached}|#{session_group}'
```

Sessions with `attached=1` will NOT be cleaned (they're in use).

## Future Improvements

1. Add configuration option to control cleanup frequency
2. Add option to preserve certain view sessions (whitelist)
3. Add metrics/logging for cleanup activity
4. Consider adding cleanup on workspace switch
