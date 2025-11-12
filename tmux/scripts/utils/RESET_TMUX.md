# Reset Tmux Command

## Overview
The "Reset Tmux Server" command provides a safe way to completely restart your tmux server while preserving your session state.

## Location
- **Menu:** Main Menu → "Reset Tmux Server" [X]
- **Script:** `~/.core/cfg/tmux/scripts/utils/reset-tmux.sh`

## What It Does

The reset command performs three operations in sequence:

1. **Save Session State** 💾
   - Uses tmux-resurrect to save current sessions
   - Preserves window layouts, pane arrangements, and working directories
   - Safe fallback if resurrect is unavailable

2. **Kill Tmux Server** 🛑
   - Cleanly stops all tmux processes
   - Clears any stuck states or configuration issues
   - Waits 1 second to ensure clean shutdown

3. **Relaunch Tmux** 🚀
   - Creates a new "main" session
   - Uses your tmux.conf configuration
   - Shows instructions for attaching or restoring

## Usage

### From Main Menu
1. Open main menu (your configured keybinding)
2. Select "Reset Tmux Server" [X]
3. Confirm the operation [y/n]
4. Wait for the popup to show completion
5. Attach to the new session: `tmux attach -t main`
6. (Optional) Restore previous state: `prefix + Ctrl-r`

### From Command Line
```bash
# Run the script directly
~/.core/cfg/tmux/scripts/utils/reset-tmux.sh

# Then attach
tmux attach -t main

# Restore previous session state
# Inside tmux: prefix + Ctrl-r
```

## When to Use

**Good times to reset:**
- After major configuration changes
- When tmux feels sluggish or unresponsive
- After plugin updates
- When experiencing weird layout issues
- Testing configuration changes

**Not needed for:**
- Simple config changes (use "Reload Config" instead)
- Switching between sessions
- Creating new windows/panes

## Safety Features

1. **Confirmation Required**
   - Prompts before executing to prevent accidental resets

2. **Automatic Save**
   - Always saves state first (if resurrect is available)
   - Your work is preserved

3. **Popup Display**
   - Shows progress and status messages
   - Clear indication when complete

4. **Error Handling**
   - Graceful fallbacks if components fail
   - Clear warning messages

## Output Example

```
🔄 Resetting tmux server...

💾 Saving current session state...
✓ Session state saved

🛑 Killing tmux server...
✓ Server killed

🚀 Relaunching tmux...
✓ New session 'main' created

📋 To attach: tmux attach -t main
   Or restore from resurrect: prefix + Ctrl-r

✅ Tmux reset complete!
```

## Technical Details

**Script Path:** `/home/theron/.core/cfg/tmux/scripts/utils/reset-tmux.sh`

**Dependencies:**
- tmux-resurrect plugin (optional, for save/restore)
- tmux.conf at `~/.core/cfg/tmux/tmux.conf`

**Session Created:**
- Name: `main`
- State: Detached
- Config: Uses your tmux.conf

## Comparison with Other Commands

| Command | Save State | Kill Server | Reload Config | Relaunch |
|---------|-----------|-------------|---------------|----------|
| Reload Config | ❌ | ❌ | ✅ | ❌ |
| Save State | ✅ | ❌ | ❌ | ❌ |
| Reset Tmux | ✅ | ✅ | ✅ | ✅ |

## Related Commands

- **Reload Config** - Reload configuration without killing server
- **Save State** - Save current session state only
- **Restore Session** - Restore previously saved state

## Version
- Implementation Date: 2025-10-30
- Compatible with tmux >= 2.0
