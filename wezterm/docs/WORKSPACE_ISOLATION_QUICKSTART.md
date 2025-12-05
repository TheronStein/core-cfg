# Workspace Isolation Quick Start Guide

## What Changed?

Your WezTerm now supports **workspace isolation** - each workspace can run in a separate window/client!

## Quick Test

### 1. Create a New Isolated Workspace

```
LEADER + w → Create Workspace → Name it "TEST" → Choose an icon
```

**Expected**: A new WezTerm window opens with workspace "TEST"

### 2. Switch Back to Default

```
LEADER + SHIFT + W → Select "default"
```

**Expected**: Focus shifts to your original window

### 3. Check Both Are Running

```
wezterm cli list
```

**Expected**: You should see entries for both "default" and "TEST" workspaces

## Visual Indicators

When you press `LEADER + SHIFT + W` to switch workspaces:
- 🟢 = Workspace has a running client window
- ▶ = Your current workspace
- No indicator = Workspace exists in history but not currently running

## How to Use

### Basic Workflow

1. **Create workspaces for different contexts**:
   - "Development" for your coding project
   - "Research" for documentation/browser
   - "Admin" for system tasks

2. **Each workspace gets its own window**:
   - They run independently
   - Closing one doesn't affect others
   - All stay active even when not focused

3. **Switch between them**:
   - `LEADER + SHIFT + W` → Quick switch
   - `LEADER + w` → Full workspace menu

### Saving Workspace Layouts

```
LEADER + SHIFT + S
```

Saves current workspace's:
- All tabs and their titles
- Pane layouts
- Working directories
- Icons and colors

### Loading Saved Workspaces

```
LEADER + SHIFT + L
```

Restores a saved workspace in a new isolated window.

## Enable/Disable Isolation

### Check Current Mode

Open workspace manager:
```
LEADER + w
```

Look for "(Isolated Mode)" in the menu title.

### Disable If Needed

Edit `/home/theron/.core/.sys/cfg/wezterm/modules/sessions/workspace_manager.lua`:

```lua
M.ENABLE_ISOLATION = false  -- Change to false
```

Then reload: `LEADER + r`

## Troubleshooting

### "Workspace already running" message

**Cause**: You tried to load a session for a workspace that's already open

**Solution**:
- Use `LEADER + SHIFT + W` to switch to it, OR
- Close the existing workspace first, then load

### Can't spawn new workspace

**Check 1**: Is `wezterm cli` working?
```bash
wezterm cli list
```

**Check 2**: Look at WezTerm output for errors
(WezTerm prints to the terminal it was launched from)

### Too many windows open

You can close workspaces with:
```
LEADER + w → Close Workspace → Select workspace
```

## Integration with tmux

Workspace isolation and tmux work together:

- **WezTerm workspaces** = UI organization (separate windows)
- **tmux sessions** = Persistent shell sessions

You can:
- Have multiple tmux sessions in one WezTerm workspace
- Access the same tmux session from different WezTerm workspaces
- Close WezTerm workspace without killing tmux sessions

Example:
```
Workspace "Dev" → Tab 1: tmux attach -t backend
                → Tab 2: tmux attach -t frontend
                → Tab 3: tmux attach -t logs

Workspace "Ops" → Tab 1: tmux attach -t logs (same session!)
                → Tab 2: tmux attach -t monitoring
```

## Keyboard Shortcuts Reference

| Key | Action |
|-----|--------|
| `LEADER + w` | Open workspace menu |
| `LEADER + SHIFT + W` | Quick switch workspace |
| `LEADER + SHIFT + R` | Rename current workspace |
| `LEADER + SHIFT + S` | Save workspace layout |
| `LEADER + SHIFT + L` | Load workspace layout |

(LEADER = `SUPER + Space` by default)

## File Locations

- Workspace sessions: `~/.core/.sys/cfg/wezterm/.data/workspace-sessions/`
- Workspace templates: `~/.core/.sys/cfg/wezterm/.data/workspace-templates/`
- Workspace metadata: `~/.core/.sys/cfg/wezterm/.data/workspace-metadata.json`

## Next Steps

1. **Try creating 2-3 workspaces** for different tasks
2. **Experiment with switching** between them
3. **Save a workspace layout** you like
4. **Load it later** to see session restoration in action

For detailed documentation, see: `WORKSPACE_ISOLATION.md`

## Questions?

- Check logs: WezTerm outputs to stderr
- Enable debug: Look for `wezterm.log_info` in the code
- Test isolation: Run `wezterm cli list` to see all clients

---

**Isolation Mode**: Enabled by default
**To disable**: Set `M.ENABLE_ISOLATION = false` in `workspace_manager.lua`
