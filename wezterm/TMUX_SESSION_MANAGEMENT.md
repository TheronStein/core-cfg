# Tmux Session ID Management - Documentation

## Overview

The WezTerm-tmux integration uses "view sessions" to allow multiple independent views of the same tmux session. Each WezTerm tab attached to a tmux session gets its own view session, enabling independent window/pane navigation while sharing the underlying session state.

## View Session Naming

View sessions follow the pattern: `<parent-session>-view-<timestamp>-<random>`

Example: `myproject-view-1735324800-5432`

## Lifecycle Management

### 1. View Session Creation

**Location**: `/home/theron/.core/.sys/cfg/wezterm/modules/tmux/sessions.lua`

When spawning a tab for a tmux session:
1. **Check for existing unattached view**: `find_existing_view()` searches for orphaned view sessions from the same parent
2. **Reuse if found**: Attach to the existing view instead of creating a new one
3. **Create if needed**: Generate a new unique view name and create a grouped session

**Key Functions**:
- `spawn_tab_with_session()` - Main entry point for creating tabs with tmux sessions
- `spawn_tab_with_custom_session()` - Alternative with custom tab name/icon
- `find_existing_view()` - **NEW** - Finds existing unattached views to reuse
- `generate_view_name()` - Creates unique view session names

### 2. View Session Tracking

**Storage**: `wezterm.GLOBAL.custom_tabs[tab_id]`

Each tab stores:
```lua
{
  title = "session name or custom title",
  icon_key = "icon character",
  tmux_session = "parent-session",
  tmux_view = "parent-session-view-123-456",  -- The view session ID
  tmux_workspace = "socket-name or nil"
}
```

### 3. View Session Cleanup

#### Automatic Cleanup (Multiple Layers)

**Layer 1: Tmux Detach Hook** (Immediate)
- **Location**: `/home/theron/.core/.sys/cfg/tmux/conf/hooks.conf`
- **Trigger**: `client-detached` hook
- **Action**: When a client detaches from a view session, immediately kill it if no other clients are attached
- **Prevents**: Orphaned sessions from accumulating between WezTerm tab closes

**Layer 2: WezTerm Tab Closed** (Event-driven)
- **Location**: `/home/theron/.core/.sys/cfg/wezterm/events/tab-lifecycle.lua`
- **Trigger**: `mux-tab-closed` event
- **Action**: Calls `cleanup_tab_view(tab_id)` to kill the view session and clean metadata

**Layer 3: WezTerm Window Closed** (Event-driven)
- **Location**: `/home/theron/.core/.sys/cfg/wezterm/events/tab-lifecycle.lua`
- **Trigger**: `mux-window-close` event
- **Action**: Calls `cleanup_orphaned_views()` to find and remove any orphaned views

**Layer 4: Periodic Cleanup** (Fallback)
- **Location**: `/home/theron/.core/.sys/cfg/wezterm/modules/tmux/clean-sessions.lua`
- **Trigger**: `update-status` event (every 60 seconds)
- **Action**: Scans all view sessions and removes those that are:
  - Unattached AND untracked by WezTerm
  - OR unattached AND older than 5 minutes (handles crashes)

**Layer 5: User Variable Trigger** (Event-driven from tmux)
- **Location**: `/home/theron/.core/.sys/cfg/wezterm/modules/tmux/clean-sessions.lua`
- **Trigger**: `user-var-changed` event with `TMUX_CLEANUP_TRIGGER`
- **Action**: Tmux sends cleanup signals when sessions detach/close

#### Manual Cleanup

**Script**: `/home/theron/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh`

Usage:
```bash
# Dry-run (show what would be deleted)
~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh --dry-run

# Verbose output
~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh --verbose

# Specific socket
~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh --socket my-workspace

# Actually cleanup
~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh
```

**WezTerm Keybinding**: `LEADER + CTRL + c`
- Manually trigger cleanup from within WezTerm
- Shows notification with count of cleaned sessions

## Fixed Issues

### Issue 1: Orphan ID Accumulation

**Problem**: View sessions were created but never deleted, accumulating over time.

**Root Causes**:
1. `detach-on-destroy` was set but didn't always trigger reliably
2. WezTerm cleanup only ran every 60 seconds (periodic)
3. No cleanup on tmux side when client detached

**Fixes**:
1. **Added tmux-side cleanup**: `client-detached` hook now immediately kills view sessions with no attached clients
2. **Enhanced WezTerm cleanup**: Now also cleans up stale sessions (>5 min old) even if tracked
3. **Added view session reuse**: `find_existing_view()` prevents creating duplicate views

### Issue 2: Duplicate ID Creation on Attach

**Problem**: Attaching to the same tmux session multiple times created new view sessions each time instead of reusing existing ones.

**Root Cause**: No logic to detect and reuse existing unattached view sessions.

**Fix**: Added `find_existing_view()` function that:
1. Lists all sessions matching the parent session name
2. Filters for unattached views (attached == "0")
3. Verifies group membership matches parent
4. Reuses the first matching view instead of creating a new one

## Monitoring & Debugging

### Check for Orphaned View Sessions

```bash
# List all view sessions
tmux list-sessions | grep -E '\-view-[0-9]+-[0-9]+'

# Count orphaned view sessions (unattached)
tmux list-sessions -F '#{session_name}|#{session_attached}' | \
  grep -E '\-view-[0-9]+-[0-9]+\|0' | wc -l
```

### WezTerm Logs

View cleanup logs in WezTerm debug overlay or logs:
```
wezterm.log_info("Reusing existing view session: ...")
wezterm.log_info("Creating new view session: ...")
wezterm.log_info("Cleaned up N orphaned view session(s)")
```

### Tmux Hooks Status

```bash
# Show all hooks
tmux show-hooks -g

# Show specific hook
tmux show-hooks -g | grep client-detached
```

## State Files

### WezTerm State

- **custom_tabs**: In-memory global table (lost on restart)
  - Location: `wezterm.GLOBAL.custom_tabs`
  - Content: Maps tab IDs to tmux session metadata

### Tmux State

- **Sessions**: Managed by tmux server
  - List: `tmux list-sessions`
  - Per-session options: `tmux show-options -t session-name`

## Configuration Files Modified

1. **WezTerm**:
   - `/home/theron/.core/.sys/cfg/wezterm/modules/tmux/sessions.lua`
     - Added `find_existing_view()` function
     - Modified session spawning to reuse existing views

   - `/home/theron/.core/.sys/cfg/wezterm/modules/tmux/clean-sessions.lua`
     - Enhanced `cleanup_orphaned_views()` with age-based cleanup
     - Added stale session detection (>5 min)
     - Improved logging

2. **Tmux**:
   - `/home/theron/.core/.sys/cfg/tmux/conf/hooks.conf`
     - Enhanced `client-detached` hook with immediate cleanup
     - Added client count check before killing sessions

3. **Scripts**:
   - `/home/theron/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh` (NEW)
     - Manual cleanup utility with dry-run mode

## Best Practices

1. **Normal Operation**: The system should self-clean automatically through the multi-layer cleanup strategy

2. **After Crashes**: Run manual cleanup if WezTerm crashes without triggering cleanup hooks:
   ```bash
   ~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh --verbose
   ```

3. **Regular Monitoring**: Periodically check for orphaned sessions:
   ```bash
   tmux list-sessions | grep -E '\-view-[0-9]+-[0-9]+'
   ```

4. **Debugging**: Enable verbose logging in WezTerm config to track view session lifecycle

## Troubleshooting

### Sessions Still Accumulating

1. Check tmux hooks are loaded:
   ```bash
   tmux show-hooks -g | grep client-detached
   ```

2. Verify WezTerm cleanup is running:
   - Check logs for "Cleaned up N orphaned view session(s)"
   - Trigger manual cleanup: LEADER + CTRL + c

3. Reload tmux configuration:
   ```bash
   tmux source-file ~/.tmux.conf
   ```

### View Sessions Not Being Reused

1. Check logs for "Reusing existing view session" messages
2. Verify sessions are truly unattached:
   ```bash
   tmux list-sessions -F '#{session_name}|#{session_attached}|#{session_group}'
   ```

3. Check session group matches parent name

### Cleanup Script Not Working

1. Verify script is executable:
   ```bash
   ls -l ~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh
   ```

2. Run with --verbose to see detailed output:
   ```bash
   ~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh --verbose
   ```

## Future Improvements

Potential enhancements:
1. Add metrics/statistics tracking for view session lifecycle
2. Implement configurable age threshold for stale session cleanup
3. Add session resurrection for crashed WezTerm instances
4. Create systemd timer for periodic cleanup (belt-and-suspenders)
