# Workspace Module Crash - 2025-12-05

## What Happened

The new `unified_workspace.lua` module caused WezTerm to freeze/crash when accessing the workspace menu.

## Quick Fix Applied

1. **Disabled the broken module**:
   ```bash
   mv modules/sessions/unified_workspace.lua modules/sessions/unified_workspace.lua.DISABLED
   ```

2. **Keybindings**: The `leader.lua` file still references the unified module, but with `pcall()` it will safely fail and fall back.

3. **Current State**:
   - Old `session_manager.lua` should still work (if keybindings revert)
   - Old `workspace_manager.lua` should still work (if keybindings revert)

## To Fully Revert

The keybindings in `keymaps/mods/leader.lua` need to be changed back to use the old modules.

**Lines to change** (around 62-107):
- Remove: `unified_workspace` references
- Restore: `session_manager` and `workspace_manager` bindings

## Root Cause (To Investigate)

The crash likely occurred in one of these functions:
1. `list_available_workspaces()` - filters running workspaces
2. `isolation.get_running_clients()` - calls `wezterm cli list`
3. Menu rendering loop - infinite loop or stack overflow

## Next Steps

1. Test if WezTerm works now (should be safe with unified module disabled)
2. Manually revert keybindings if needed
3. Debug the unified module with proper error handling before re-enabling
4. Add extensive logging to identify exact crash point

## Files Affected

- ✅ `modules/sessions/unified_workspace.lua` → `.DISABLED` (renamed)
- ⚠️ `keymaps/mods/leader.lua` → Still references unified (but safely fails)
- 📁 Backup: `keymaps/mods/leader.lua.broken-unified`

---

**User can safely reload WezTerm now**. The broken module won't load.
