# Tmux View Session ID Fixes - Summary

## Issues Fixed

### 1. Orphan ID Accumulation
**Problem**: View sessions (`*-view-<timestamp>-<random>`) were created but never deleted, causing them to accumulate over time.

**Solution**: Implemented multi-layer cleanup strategy:
- **Tmux-side**: Immediate cleanup on client detach (hooks.conf)
- **WezTerm-side**: Event-driven cleanup on tab/window close
- **Fallback**: Periodic cleanup every 60s + stale session detection (>5 min)

### 2. Duplicate ID Creation on Attach
**Problem**: Attaching to the same tmux session created a new view session each time instead of reusing existing unattached views.

**Solution**: Added `find_existing_view()` function that searches for and reuses unattached view sessions before creating new ones.

## Files Modified

### WezTerm Configuration
1. `/home/theron/.core/.sys/cfg/wezterm/modules/tmux/sessions.lua`
   - Added `find_existing_view()` function (lines 168-212)
   - Modified `spawn_tab_with_session()` to reuse views (lines 253-291)
   - Modified `spawn_tab_with_custom_session()` to reuse views (lines 387-425)

2. `/home/theron/.core/.sys/cfg/wezterm/modules/tmux/clean-sessions.lua`
   - Enhanced `cleanup_orphaned_views()` with age-based cleanup (lines 103-209)
   - Added stale session detection (>5 minutes)
   - Improved logging and metadata cleanup

### Tmux Configuration
3. `/home/theron/.core/.sys/cfg/tmux/conf/hooks.conf`
   - Enhanced `client-detached` hook (lines 43-61)
   - Added immediate view session cleanup on detach
   - Added client count check before killing

### New Files Created
4. `/home/theron/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh`
   - Manual cleanup script with dry-run mode
   - Usage: `cleanup-view-sessions.sh [--dry-run] [--verbose] [--socket NAME]`

5. `/home/theron/.core/.sys/cfg/wezterm/TMUX_SESSION_MANAGEMENT.md`
   - Comprehensive documentation of view session lifecycle
   - Troubleshooting guide
   - Monitoring instructions

## Quick Commands

### Check for Orphaned Sessions
```bash
# List all view sessions
tmux list-sessions | grep -E '\-view-[0-9]+-[0-9]+'

# Count orphaned (unattached) view sessions
tmux list-sessions -F '#{session_name}|#{session_attached}' | grep -E '\-view-[0-9]+-[0-9]+\|0' | wc -l
```

### Manual Cleanup
```bash
# Dry-run (see what would be deleted)
~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh --dry-run

# Actually cleanup
~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh

# With verbose output
~/.core/.sys/cfg/tmux/scripts/cleanup-view-sessions.sh --verbose
```

### Reload Configuration
```bash
# Reload tmux config (applies hook changes)
tmux source-file ~/.tmux.conf

# WezTerm auto-reloads on config changes
# Or manually: LEADER + CTRL + r
```

## How It Works Now

### View Session Creation (Fixed)
1. User spawns a tmux session tab in WezTerm
2. **NEW**: WezTerm checks for existing unattached view sessions
3. **NEW**: If found, reuses the existing view (no new ID created)
4. If not found, creates a new view with unique ID
5. Stores view ID in `wezterm.GLOBAL.custom_tabs[tab_id].tmux_view`

### View Session Cleanup (Fixed)
1. **Immediate**: When client detaches from view, tmux hook kills it if no other clients
2. **Event-driven**: When WezTerm tab closes, cleanup is triggered immediately
3. **Periodic**: Every 60s, scan for orphaned views (unattached + untracked)
4. **Stale detection**: Views unattached for >5 minutes are automatically cleaned up
5. **Manual**: User can run cleanup script or trigger from WezTerm (LEADER+CTRL+c)

## Testing the Fixes

### Test 1: View Reuse
1. Create a tmux session: `tmux new -s test`
2. Attach to it in WezTerm (spawns view-1)
3. Close the WezTerm tab (view-1 becomes unattached)
4. Attach again in WezTerm
5. **Expected**: Should reuse view-1, not create view-2
6. **Verify**: `tmux list-sessions | grep test-view` should show only one view

### Test 2: Immediate Cleanup
1. Create a tmux session: `tmux new -s cleanup-test`
2. Attach to it in WezTerm (spawns view session)
3. Note the view session name: `tmux list-sessions | grep cleanup-test-view`
4. Close the WezTerm tab
5. **Expected**: View session should be gone immediately
6. **Verify**: `tmux list-sessions | grep cleanup-test-view` should return nothing

### Test 3: Stale Session Cleanup
1. Create a view session manually: `tmux new -s parent-view-123-456`
2. Detach from it: `tmux detach`
3. Wait 6 minutes (or modify age threshold in clean-sessions.lua for testing)
4. **Expected**: WezTerm periodic cleanup should remove it
5. **Verify**: Check logs for "Cleaning up orphaned view session [stale]"

## Monitoring

### WezTerm Logs
Look for these messages:
- `"Reusing existing view session: ..."` - View reuse working
- `"Creating new view session: ..."` - New view created (when reuse not possible)
- `"Cleaned up N orphaned view session(s)"` - Cleanup successful
- `"Cleaning up orphaned view session [stale]"` - Stale session removed

### Tmux Session Count
```bash
# Should stay relatively stable, not grow indefinitely
watch -n 5 'tmux list-sessions | grep -E "\-view-[0-9]+-[0-9]+" | wc -l'
```

## Rollback (If Needed)

If issues occur, revert these commits:
```bash
cd ~/.core/.sys/cfg/wezterm
git diff HEAD~1 modules/tmux/sessions.lua
git diff HEAD~1 modules/tmux/clean-sessions.lua

cd ~/.core/.sys/cfg/tmux
git diff HEAD~1 conf/hooks.conf
```

To restore original behavior:
```bash
# WezTerm
cd ~/.core/.sys/cfg/wezterm
git checkout HEAD~1 -- modules/tmux/sessions.lua modules/tmux/clean-sessions.lua

# Tmux
cd ~/.core/.sys/cfg/tmux
git checkout HEAD~1 -- conf/hooks.conf

# Reload
tmux source-file ~/.tmux.conf
```

## Notes

- The fixes are backward compatible - existing view sessions will be cleaned up
- No manual intervention required for normal operation
- Cleanup script is a convenience tool for edge cases or debugging
- All changes preserve existing functionality while adding robustness
