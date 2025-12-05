# Unified Workspace-Session Manager Refactor

**Date**: 2025-12-05
**Status**: ✅ COMPLETE - Ready for Testing

---

## What Changed

### Core Architecture Redesign

**Previously**: Two separate modules doing similar things:
- `session_manager.lua` - Basic workspace/session handling
- `workspace_manager.lua` - Advanced workspace features with isolation

**Now**: One unified module:
- `unified_workspace.lua` - Single source of truth for all workspace operations

### Key Principle

**Workspace = Session** (they are ONE concept, not two)

---

## Core Features

### 1. Strict One-Client-Per-Workspace Model

Each WezTerm client is bound to **exactly ONE workspace**:

- ✅ Creating a workspace → Spawns NEW client
- ✅ Switching workspaces → Focuses DIFFERENT client
- ✅ One workspace cannot be loaded in multiple clients
- ✅ Default workspace gets RENAMED (not replaced) when creating first workspace

### 2. Default Workspace Handling

**When you're in "default" workspace and create a new workspace:**
- System **renames** default → your new workspace name
- All tabs move to the new workspace
- Icon and metadata are applied
- **No new client spawned** (you stay in your current client)

**When you're in a named workspace and create another:**
- System **spawns a new isolated client** with the new workspace
- Your current client stays in its workspace
- Each workspace runs independently

### 3. Smart Workspace Menu

The menu shows:
- ▶ Current workspace (where you are)
- 🟢 Running workspaces (have active clients)
- Other workspaces (can be loaded)

**Key difference from before**: Menu is context-aware and shows isolation status.

---

## Keybinding Changes

### Main Keybindings (No Changes)

| Keybinding | Action |
|------------|--------|
| `LEADER+F1` or `LEADER+w` | Open workspace manager menu |
| `LEADER+SHIFT+W` | Quick workspace switcher |
| `LEADER+SHIFT+R` | Rename current workspace |
| `LEADER+SHIFT+S` | Save current session |
| `LEADER+SHIFT+L` | Load session |
| `LEADER+SHIFT+T` | Move pane to own tab |
| `LEADER+m` | Move pane to another tab |
| `LEADER+g` | Grab pane from another tab |

### Changed Keybindings

**Before**: `LEADER+SHIFT+W` was mapped TWICE (conflict!)
- Once for workspace switcher
- Once for tmux workspace browser

**Now**:
- `LEADER+SHIFT+W` → WezTerm workspace switcher (isolation mode)
- `LEADER+SHIFT+A` → tmux workspace browser

---

## Workflow Examples

### Example 1: Starting Fresh

1. Open WezTerm → You're in "default" workspace
2. Press `LEADER+w` → Open menu
3. Select "Create Workspace"
4. Enter name: "Development"
5. Choose icon: 💻
6. **Result**: Your "default" workspace is RENAMED to "💻 Development"

### Example 2: Creating Second Workspace

1. You're in "💻 Development" workspace
2. Press `LEADER+w` → Open menu
3. Select "Create Workspace"
4. Enter name: "Research"
5. Choose icon: 📚
6. **Result**: A NEW WezTerm client spawns with "📚 Research" workspace

### Example 3: Switching Between Workspaces

1. Press `LEADER+SHIFT+W`
2. See list:
   - ▶ 💻 Development 🟢 (current, running)
   - 📚 Research 🟢 (running)
   - 🎮 Gaming (not running)
3. Select "📚 Research"
4. **Result**: WezTerm focuses the Research client window

### Example 4: Loading a Session

1. Press `LEADER+SHIFT+L`
2. See saved sessions (only those WITHOUT running clients)
3. Select session
4. **Result**:
   - If workspace exists and running → Focus it (don't duplicate)
   - If workspace not running → Spawn new client with full session restored

---

## What's Been Fixed

### 1. ✅ Duplicate Module Functions

**Before**: Both `session_manager` and `workspace_manager` had:
- `switch_workspace()`
- `rename_workspace()`
- `save_session()` / `load_template()`

**Now**: Single unified implementation in `unified_workspace.lua`

### 2. ✅ Duplicate Keybindings

**Before**: `LEADER+SHIFT+W` was bound twice, causing conflicts

**Now**: Clean keybinding hierarchy:
- `LEADER+SHIFT+W` → WezTerm workspaces
- `LEADER+SHIFT+A` → tmux workspaces (moved)

### 3. ✅ Default Workspace Behavior

**Before**: Creating a workspace left "default" empty and created a new one

**Now**: Creating first workspace RENAMES "default" to your chosen name

### 4. ✅ Menu Showing All Workspaces

**Before**: Menu showed all workspaces, even those with running clients

**Now**: Menu context-aware:
- Shows running status with 🟢 indicator
- Prevents loading already-running workspaces
- Offers to focus existing client instead of duplicating

### 5. ✅ Isolation Mode Not Always Used

**Before**: `session_manager.switch_workspace()` used old `act.SwitchToWorkspace()` which switches within client

**Now**: Always uses isolation mode via `isolation.switch_to_workspace()` which spawns/focuses separate clients

---

## Module Architecture

```
unified_workspace.lua (NEW - single source of truth)
    ├── create_workspace() - Renames default or spawns new client
    ├── switch_workspace() - Spawns/focuses different client
    ├── rename_workspace() - Renames current workspace
    ├── close_workspace() - Closes isolated client
    ├── save_session() - Saves current state
    ├── load_session() - Loads session (checks for running clients)
    ├── move_pane_to_tab() - Pane management
    ├── grab_pane_from_tab() - Pane management
    ├── move_pane_to_own_tab() - Pane management
    └── show_menu() - Unified menu interface

workspace_isolation.lua (UNCHANGED - provides isolation primitives)
    ├── get_running_clients() - List all WezTerm clients
    ├── find_client_for_workspace() - Find client for workspace
    ├── spawn_workspace_client() - Spawn new isolated client
    ├── focus_workspace_client() - Focus existing client
    ├── switch_to_workspace() - Spawn or focus
    └── close_workspace_client() - Close client

keymaps/mods/leader.lua (UPDATED)
    ├── Uses unified_workspace instead of session_manager + workspace_manager
    └── Fixed duplicate LEADER+SHIFT+W binding
```

---

## Testing Checklist

### Basic Operations

- [ ] Create first workspace from default (should rename)
- [ ] Create second workspace (should spawn new client)
- [ ] Switch between workspaces (should focus different clients)
- [ ] Rename workspace (should update all tabs)
- [ ] Close workspace (should kill client)

### Session Operations

- [ ] Save session with multiple tabs/panes
- [ ] Load session (should spawn new client)
- [ ] Try loading already-running session (should focus, not duplicate)
- [ ] Session restores tab titles, icons, colors

### Pane Operations

- [ ] Move pane to another tab
- [ ] Grab pane from another tab
- [ ] Move pane to its own tab

### Menu Behavior

- [ ] Menu shows current workspace with ▶
- [ ] Menu shows running workspaces with 🟢
- [ ] Menu shows workspace icons
- [ ] Can switch to any workspace from menu

---

## Next Steps (Future Enhancements)

### 1. tmux Resurrect Integration

Add hooks to save/restore tmux session state when workspace sessions are saved/loaded.

**Implementation points**:
- `unified_workspace.save_session()` → Call `tmux-resurrect save`
- `unified_workspace.load_session()` → Call `tmux-resurrect restore`

### 2. Neovim Auto-Session Integration

Add hooks to save/restore Neovim session state per workspace.

**Implementation points**:
- Before `save_session()` → Emit event to save Neovim sessions
- After `load_session()` → Emit event to restore Neovim sessions
- Use workspace name as session identifier

### 3. Startup Script

Create custom WezTerm startup script that:
- Checks for saved sessions
- Offers to restore last session
- Provides quick workspace launcher

---

## Files Modified

### Created
- `modules/sessions/unified_workspace.lua` (NEW)
- `docs/UNIFIED_WORKSPACE_REFACTOR.md` (this file)

### Modified
- `keymaps/mods/leader.lua`
  - Replaced session_manager/workspace_manager with unified_workspace
  - Fixed duplicate LEADER+SHIFT+W binding
  - Moved tmux workspace browser to LEADER+SHIFT+A

### Deprecated (Not Deleted Yet)
- `modules/sessions/manager.lua` (old session_manager)
- `modules/sessions/workspace_manager.lua` (old workspace_manager)

**Note**: Old modules can be safely deleted after testing confirms unified module works.

---

## Troubleshooting

### "Failed to load unified_workspace"

Check WezTerm logs:
```bash
tail -f ~/.local/share/wezterm/wezterm.log
```

Look for:
- Module loading errors
- Lua syntax errors
- Missing dependencies

### Workspace Not Spawning

Check if `wezterm cli` is working:
```bash
wezterm cli list
```

If not working:
- Ensure WezTerm is running
- Check socket permissions in `$XDG_RUNTIME_DIR`

### Session Not Restoring Properly

Check session file:
```bash
cat ~/.local/share/wezterm/data/sessions/<name>.json | jq .
```

Verify:
- tabs array exists and has content
- panes have valid cwd paths
- Metadata (icon, color, theme) is present

---

## Summary

The unified workspace-session manager implements your exact requirements:

1. ✅ **Workspace = Session** (single concept)
2. ✅ **One workspace per client** (strict isolation)
3. ✅ **Rename default instead of create** (proper initialization)
4. ✅ **Smart menu** (shows running status, prevents duplicates)
5. ✅ **Clean keybindings** (no conflicts)
6. ✅ **Proper state handling** (saves/restores full workspace state)

Ready for integration with tmux resurrect and neovim auto-session once you test and approve the base functionality.

---

**Test the workflow** and let me know if anything doesn't behave as expected!
