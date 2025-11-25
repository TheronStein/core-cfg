# Tmux Workspaces Integration

This document describes the tmux workspace system that allows you to manage multiple tmux server sockets with dedicated configurations in WezTerm.

## Overview

The tmux workspace system provides:
- **Workspace Browser** - Visual selector for launching/attaching to tmux workspaces
- **Visual Indicators** - Color-coded workspace icons in the tabline
- **Socket Management** - Each workspace runs on its own tmux server socket
- **Workspace Metadata** - Each workspace has a unique icon, color, and description

## Architecture

### Files

1. **`modules/tmux_workspaces.lua`** - Main workspace manager
   - Defines workspace metadata (icons, colors, descriptions)
   - Manages workspace launching and socket detection
   - Provides workspace browser UI

2. **`modules/tmux_sessions.lua`** - Enhanced session management
   - Now supports socket-specific spawning via `-L` flag
   - Updated functions: `spawn_tab_with_session()`, `create_session()`, `session_exists()`

3. **`modules/gui/tabline/components/window/tmux_server.lua`** - Visual indicators
   - Shows workspace icon and name with color coding
   - Detects current tmux server from TMUX environment variable

4. **`~/.core/cfg/tmux/workspaces/*.tmux`** - Workspace config files
   - Each workspace has a dedicated tmux configuration file
   - Configs source the base `tmux.conf` and add workspace-specific settings

## Workspace Definitions

| Workspace | Icon | Color | Description |
|-----------|------|-------|-------------|
| configuration | 󰒓 (cog) | Blue (#89b4fa) | System configuration and dotfiles |
| development | 󰅩 (code) | Green (#a6e3a1) | Software development projects |
| documentation | 󰂺 (book) | Yellow (#f9e2af) | Documentation and knowledge base |
| environment | 󰀻 (app-cog) | Peach (#fab387) | Environment setup and management |
| objective | 󰛕 (target) | Red (#f38ba8) | Goal tracking and task management |
| personal | 󰀄 (account) | Mauve (#cba6f7) | Personal projects and files |
| system | 󰍹 (monitor) | Teal (#94e2d5) | System administration and monitoring |
| testing | 󰻉 (flask) | Pink (#f5c2e7) | Testing and experimentation |

## Usage

### Launching Workspaces

**Keybinding:** `LEADER+Shift+W` (default: `SUPER+Space` then `Shift+W`)

This opens the workspace browser showing:
- ● Active workspaces (server socket is running)
- ○ Inactive workspaces (not yet started)
- ⚠ Missing config (workspace config file not found)

**Behavior:**
- If workspace is **inactive**: Launches tmux using the workspace config file
  ```bash
  tmux -f ~/.core/cfg/tmux/workspaces/{workspace}.tmux -L {workspace} new-session
  ```
- If workspace is **active**: Attaches to the existing tmux server
  ```bash
  tmux -L {workspace} attach-session
  ```

### Visual Indicators

When you're in a tmux workspace, the tabline shows:
- **Workspace icon** in the workspace's color
- **Workspace display name** in the workspace's color

Example: If you're in the "development" workspace, you'll see:
```
󰅩 Development  (in green)
```

### Session Management

The existing tmux session commands now support workspace-specific sessions:

**`LEADER+a`** - Attach to tmux session (default server)

All tmux sessions created within a workspace automatically use that workspace's server socket.

## Workspace Configuration Files

Each workspace config file (`~/.core/cfg/tmux/workspaces/{name}.tmux`) follows this pattern:

```tmux
# Source the base tmux configuration
source-file "~/.core/cfg/tmux/tmux.conf"

# Set custom environment variable for this server's default CWD
set-environment -g TMUX_SESSION_CWD "$HOME/.core/dev"

# Server identification
set-environment -g TMUX_SERVER_NAME "development"

# Set custom resurrect directory for this server
set -g @resurrect-dir "~/.tmux/resurrect/development"

# Optional: Capture additional state
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-nvim 'session'
```

## Technical Details

### Socket Detection

The system detects active tmux sockets by checking for socket files in `/tmp/tmux-{UID}/`:
```lua
local socket_path = "/tmp/tmux-" .. uid .. "/" .. workspace_name
```

### Workspace Metadata Storage

Metadata is stored in `modules/tmux_workspaces.lua`:
```lua
M.workspaces = {
  workspace_name = {
    name = "workspace_name",
    display_name = "Display Name",
    icon = wezterm.nerdfonts.md_icon,
    color = "#hexcolor",
    description = "Description text",
    default_cwd = "$HOME/path",
  }
}
```

### Tabline Integration

The tmux_server component extracts the server name from the `TMUX` environment variable:
```
TMUX=/tmp/tmux-1000/workspace_name,session_id,window_id
                    ^^^^^^^^^^^^^^
                    server socket name
```

## Future Enhancements

Potential additions:
- [ ] Rofi integration for system-wide workspace launcher
- [ ] Quick workspace switching (without spawning new tabs)
- [ ] Workspace-specific color schemes
- [ ] Per-workspace WezTerm configuration overrides
- [ ] Workspace session templates (auto-create specific tmux sessions on launch)

## Troubleshooting

**Workspace shows "no config" warning:**
- Ensure the config file exists at `~/.core/cfg/tmux/workspaces/{workspace}.tmux`
- Check file permissions are readable

**Visual indicators not showing:**
- Verify the shell integration script is sourced in your `.bashrc` or `.zshrc`
- Source: `~/.core/cfg/wezterm/scripts/shell-integration/export-tmux-server.sh`
- The script exports the tmux server name via OSC 1337 sequences

**Can't attach to workspace:**
- Check if tmux is installed: `which tmux`
- Verify socket permissions in `/tmp/tmux-{UID}/`
- Try manually: `tmux -L workspace_name attach`
