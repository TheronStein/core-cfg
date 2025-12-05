# Workspace Isolation Architecture

## Overview

WezTerm now supports **true workspace isolation** where each workspace runs in a separate WezTerm client (window/process). This provides complete independence between workspaces and ensures no state loss when switching between them.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ WezTerm Workspace Layer (Isolation)                     │
│ - Each workspace = separate client/window               │
│ - Independent, stable containers                        │
│ - No state loss on detach                               │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ tmux Session Layer (Persistence)                        │
│ - Multiple tmux sessions per workspace                  │
│ - Sessions shared across workspaces (if desired)        │
│ - Deep session state management                         │
└─────────────────────────────────────────────────────────┘
```

## Key Features

### 1. True Multi-Client Isolation

- **Separate Processes**: Each workspace runs in its own WezTerm client
- **Independent State**: Closing one workspace doesn't affect others
- **No Switching Overhead**: Workspaces maintain full state when not active
- **Visual Indicators**: Running workspaces show 🟢 in menus

### 2. Intelligent Client Management

- **Automatic Detection**: System detects if workspace already has a running client
- **Focus vs Spawn**: Switches to existing client or spawns new one as needed
- **Clean Shutdown**: Proper cleanup when closing isolated workspaces

### 3. Session Persistence

- **tmux Integration**: Each pane can connect to persistent tmux sessions
- **Layout Restoration**: Tab and pane layouts saved and restored
- **Metadata Preservation**: Icons, colors, themes persist across sessions

## Configuration

### Enabling/Disabling Isolation

Edit `/home/theron/.core/.sys/cfg/wezterm/modules/sessions/workspace_manager.lua`:

```lua
-- Configuration: Enable/disable workspace isolation
-- When true: each workspace runs in separate WezTerm client
-- When false: workspaces share same client (legacy behavior)
M.ENABLE_ISOLATION = true  -- Change to false to disable
```

## Usage

### Creating a New Workspace

1. Press `LEADER + w` to open workspace manager menu
2. Select "Create Workspace"
3. Enter workspace name
4. Choose an icon

**What happens (Isolation Mode)**:
- New WezTerm client spawns in separate window
- Workspace is created in that client
- You continue working in your current workspace

**What happens (Legacy Mode)**:
- Current client switches to new workspace
- All tabs move to new workspace

### Switching Workspaces

1. Press `LEADER + SHIFT + W` or use workspace manager menu
2. Select target workspace

**What happens (Isolation Mode)**:
- If workspace has running client: Focus that window (raises it)
- If workspace not running: Spawn new client for it

**Visual Indicators**:
- 🟢 = Workspace has running client
- ▶ = Current workspace
- No indicator = Workspace exists but not running

### Loading Workspace Sessions

1. Press `LEADER + w` → "Load Session"
2. Select saved session

**What happens (Isolation Mode)**:
- Checks if workspace already running
- If running: Focus existing client (prevents duplication)
- If not running: Spawn new client and restore full session layout

### Closing Workspaces

1. Press `LEADER + w` → "Close Workspace"
2. Select workspace to close

**What happens (Isolation Mode)**:
- Kills all panes/tabs in that workspace's client
- Closes the WezTerm window for that workspace
- Other workspaces remain unaffected

**What happens (Legacy Mode)**:
- Closes all tabs in workspace
- Switches to different workspace in current client

## How It Works

### Client Tracking

The system uses `wezterm cli list --format json` to:
- Enumerate all running WezTerm clients
- Map workspaces to window IDs
- Determine which workspaces are active

### Spawning Clients

When a new workspace is created:
```bash
wezterm start --workspace "workspace_name" &
```

This spawns a completely independent WezTerm process.

### Focusing Clients

When switching to existing workspace:
```bash
wezterm cli activate-workspace "workspace_name"
```

This raises the window containing that workspace.

## Use Cases

### Example 1: Multiple Project Contexts

**Setup**:
- Workspace "Development": 3 tabs for coding project
- Workspace "Research": 2 tabs for documentation/testing
- Workspace "Operations": 2 tabs for server monitoring

**Workflow**:
- Each workspace in separate window
- Switch between them with `LEADER + SHIFT + W`
- All workspaces stay active (no state loss)
- Close any workspace without affecting others

### Example 2: tmux Integration

**Setup**:
- Workspace "Frontend": Tabs connect to tmux sessions for different frontend services
- Workspace "Backend": Tabs connect to tmux sessions for backend services
- Shared tmux session "logs" accessible from both workspaces

**Workflow**:
- WezTerm provides UI isolation (separate windows)
- tmux provides session persistence
- Can access same tmux session from multiple workspaces
- Closing WezTerm workspace doesn't kill tmux sessions

## Keybindings

| Key | Action |
|-----|--------|
| `LEADER + w` | Open workspace manager menu |
| `LEADER + SHIFT + W` | Quick switch workspace |
| `LEADER + SHIFT + R` | Rename current workspace |
| `LEADER + SHIFT + S` | Save workspace as template |
| `LEADER + SHIFT + L` | Load workspace template |
| `LEADER + F1` | Main session/workspace menu |

## Files and Directories

### Session Storage
- **Location**: `~/.core/.sys/cfg/wezterm/.data/workspace-sessions/`
- **Format**: JSON files containing tab/pane layouts, metadata
- **Naming**: `{workspace_name}.json`

### Template Storage
- **Location**: `~/.core/.sys/cfg/wezterm/.data/workspace-templates/`
- **Format**: JSON files with reusable workspace layouts
- **Naming**: `{template_name}.json`

### Metadata
- **Location**: `~/.core/.sys/cfg/wezterm/.data/workspace-metadata.json`
- **Contents**: Icons, colors, themes for each workspace

## Module Organization

### Core Modules

1. **workspace_isolation.lua** (`modules/sessions/`)
   - Client tracking and detection
   - Spawning/focusing isolated clients
   - Workspace lifecycle management

2. **workspace_manager.lua** (`modules/sessions/`)
   - High-level workspace operations
   - Session save/load
   - Template management
   - Integration point for isolation mode

3. **workspace_metadata.lua** (`modules/sessions/`)
   - Icon/color/theme persistence
   - Metadata synchronization

4. **workspace-lifecycle.lua** (`events/`)
   - Event handlers for workspace changes
   - Auto-save functionality
   - tmux integration hooks

## Comparison: Isolation vs Legacy Mode

| Feature | Isolation Mode | Legacy Mode |
|---------|---------------|-------------|
| Workspace Independence | ✅ Complete | ❌ Shared client state |
| State Persistence | ✅ Always maintained | ⚠️  Only in active workspace |
| Window Management | Each workspace = separate window | All workspaces in one window |
| Resource Usage | Higher (multiple clients) | Lower (single client) |
| Switching Speed | Window focus (instant) | Workspace switch (slight delay) |
| Closing Impact | Only affects that workspace | Can affect all workspaces |
| tmux Integration | ✅ Full support | ✅ Full support |

## Troubleshooting

### Workspaces not spawning

**Check**: Is `wezterm cli` working?
```bash
wezterm cli list
```

If this fails, isolation mode won't work.

### Can't find workspace client

**Issue**: Workspace shows in list but can't focus it
**Solution**: May have been closed externally. Create new instance.

### Duplicate workspaces

**Issue**: Same workspace name in multiple clients
**Cause**: Workspace created before isolation was enabled
**Solution**: Close older instances manually

## Migration from Legacy Mode

If you have existing workspaces in legacy mode:

1. **Save Important Sessions**:
   - `LEADER + w` → "Save Current Session"
   - Do this for each workspace you want to preserve

2. **Enable Isolation Mode**:
   - Set `M.ENABLE_ISOLATION = true` in workspace_manager.lua
   - Reload config: `LEADER + r`

3. **Restore Sessions**:
   - `LEADER + w` → "Load Session"
   - Each session will spawn in isolated client

4. **Clean Up**:
   - Close old workspace clients if needed

## Advanced Configuration

### Customizing Spawn Behavior

Edit `workspace_isolation.lua`:

```lua
function M.spawn_workspace_client(workspace_name, cwd)
    -- Customize spawn command
    local spawn_cmd = string.format('wezterm start --workspace "%s"', workspace_name)

    -- Add custom arguments
    -- spawn_cmd = spawn_cmd .. ' --position 100,100'
    -- spawn_cmd = spawn_cmd .. ' --width 1920 --height 1080'

    if cwd then
        spawn_cmd = spawn_cmd .. string.format(' --cwd "%s"', cwd)
    end

    -- Execute
    spawn_cmd = spawn_cmd .. " &"
    return os.execute(spawn_cmd)
end
```

### Integration with Window Managers

For Hyprland/i3/sway users, you can enhance the experience:

**Hyprland Example** (add to hyprland.conf):
```
# Assign WezTerm workspaces to specific Hyprland workspaces
windowrulev2 = workspace name:dev, class:org.wezfurlong.wezterm, title:.*Development.*
windowrulev2 = workspace name:research, class:org.wezfurlong.wezterm, title:.*Research.*
```

## Performance Considerations

### Memory Usage
- Each WezTerm client: ~50-100MB base
- Plus pane/tab content
- For 5 workspaces: expect ~500MB total

### Recommended Limits
- **Light Use**: 3-5 isolated workspaces
- **Heavy Use**: Up to 10 workspaces
- **Enterprise**: Consider tmux-only for >10 contexts

## Future Enhancements

Planned features:
- [ ] Auto-save workspace layouts on interval
- [ ] Workspace groups (spawn multiple related workspaces)
- [ ] Remote workspace sync (share workspaces across machines)
- [ ] Workspace snapshots (save point-in-time state)
- [ ] Integration with project management tools
- [ ] Workspace-specific environment variables

## Contributing

Found a bug? Have an idea?

1. Check logs: `wezterm` outputs to stderr
2. Enable debug mode: Set `wezterm.log_info` calls to `wezterm.log_error`
3. Submit issue with:
   - WezTerm version: `wezterm --version`
   - Your config: Relevant sections from workspace_manager.lua
   - Steps to reproduce

## Credits

- **Architecture Design**: Based on user requirements for true workspace isolation
- **Implementation**: Config Surgeon (Claude Code)
- **WezTerm**: Wez Furlong (@wez) - for the excellent terminal emulator
- **tmux Integration**: Building on existing tmux session patterns

---

**Last Updated**: 2025-12-04
**Version**: 1.0.0
**Isolation Mode**: Enabled by default
