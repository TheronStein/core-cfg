# WezTerm Workspace Manager - FZF Menu System

## Overview

This is a comprehensive FZF-based menu system for WezTerm workspace management that replaces the native InputSelector menus with a more powerful, consistent, and feature-rich interface.

## Menu Hierarchy

```
Workspace Manager (LEADER+F1)
|
+-- Workspace Operations
|   +-- Create Workspace (with icon picker)
|   +-- Switch Workspace (live preview of tabs/panes)
|   +-- Rename Workspace (with icon picker)
|   +-- Close Workspace (with confirmation)
|   +-- Set Workspace Icon
|   +-- Set Workspace Color
|   +-- Set Workspace Theme
|
+-- Session Operations
|   +-- Save Current Session
|   +-- Load Session (preview of session contents)
|   +-- Delete Session
|   +-- Rename Session
|   +-- Auto-save Settings
|
+-- Template Operations
|   +-- Save as Template
|   +-- Load Template (preview of template)
|   +-- Delete Template
|   +-- Rename Template
|
+-- Pane Operations
|   +-- Move Pane to Own Tab
|   +-- Move Pane to Tab (select target)
|   +-- Grab Pane from Tab (select source)
|   +-- Swap Panes
|
+-- Tab Operations
|   +-- Move Tab to Workspace
|   +-- Grab Tab from Workspace
|   +-- Rename Tab (with icon picker)
|   +-- Set Tab Color
|
+-- TMUX Integration
    +-- Browse TMUX Servers
    +-- Attach to Session
    +-- Create Workspace from TMUX
```

## Architecture

### File Structure

```
modules/menus/workspace-manager/
+-- workspace-manager.sh          # Main entry point
+-- preview.sh                    # Preview handler for all items
+-- lib/
|   +-- theme.sh                  # Color scheme and styling
|   +-- utils.sh                  # Common utilities
|   +-- json.sh                   # JSON parsing helpers
+-- menus/
|   +-- workspaces.sh             # Workspace operations submenu
|   +-- sessions.sh               # Session operations submenu
|   +-- templates.sh              # Template operations submenu
|   +-- panes.sh                  # Pane operations submenu
|   +-- tabs.sh                   # Tab operations submenu
|   +-- tmux.sh                   # TMUX integration submenu
+-- previews/
|   +-- workspace-preview.sh      # Preview workspace details
|   +-- session-preview.sh        # Preview session contents
|   +-- template-preview.sh       # Preview template structure
|   +-- pane-preview.sh           # Preview pane info
+-- actions/
    +-- workspace-actions.sh      # Workspace action handlers
    +-- session-actions.sh        # Session action handlers
    +-- template-actions.sh       # Template action handlers
```

### Data Flow

```
WezTerm Lua                        Bash/FZF
    |                                  |
    |  1. SpawnCommandInNewTab         |
    +--------------------------------->|
    |     (pass callback_file,         |
    |      JSON data)                  |
    |                                  |
    |                            2. FZF Menu
    |                               (user selects)
    |                                  |
    |  3. Write action to callback     |
    |<---------------------------------+
    |                                  |
    | 4. Read callback, execute action |
    +--------------------------------->|
    |                                  |
    | 5. Close FZF tab                 |
    +----------------------------------+
```

## Theme Configuration

Uses ChaosCore color palette for consistency across all menus:

```bash
# From lib/theme.sh
BG="#1e1e2e"
FG="#cdd6f4"
ACCENT="#89b4fa"
HIGHLIGHT="#f38ba8"
SUCCESS="#a6e3a1"
WARNING="#f9e2af"
ERROR="#f38ba8"
MUTED="#6c7086"
```

## Key Bindings

### In FZF Menu
- `Enter` - Select/execute
- `Esc` - Cancel/back
- `Ctrl+/` - Toggle preview
- `Ctrl+p` - Preview up
- `Ctrl+n` - Preview down
- `Tab` - Multi-select (where applicable)
- `Alt+Enter` - Execute and stay in menu

### Custom Actions
- `Alt+c` - Clear selection/reset
- `Alt+d` - Delete selected item
- `Alt+r` - Rename selected item
- `Alt+e` - Edit selected item

## Integration with WezTerm Lua

### Callback Protocol

Actions are communicated via temporary files:

```
# Simple action
action_id

# Action with argument
action_id:argument

# Complex action (JSON)
{"action": "load", "target": "workspace-name", "options": {...}}
```

### Lua Handler Pattern

```lua
-- In workspace_manager.lua
function M.show_fzf_menu(window, pane)
    local callback_file = paths.WEZTERM_DATA .. "/workspace-manager-callback.tmp"

    -- Prepare data for bash script
    local menu_data = {
        current_workspace = window:active_workspace(),
        workspaces = get_workspaces_data(),
        sessions = get_sessions_data(),
        templates = get_templates_data(),
    }

    window:perform_action(
        wezterm.action.SpawnCommandInNewTab({
            args = {
                paths.WEZTERM_SCRIPTS .. "/workspace-manager/workspace-manager.sh",
                callback_file,
                wezterm.json_encode(menu_data),
            },
        }),
        pane
    )

    -- Watch for callback
    watch_callback(callback_file, function(action)
        handle_action(window, pane, action)
    end)
end
```

## Preview System

Each menu item type has a dedicated preview showing relevant information:

### Workspace Preview
- Current tabs and their titles
- Pane count per tab
- Working directories
- Icon and color
- Last modified time

### Session Preview
- Tab structure tree
- Pane layout per tab
- Working directories
- Metadata (saved time, workspace name)

### Template Preview
- Tab structure
- Expected pane layout
- Associated icon/color
- Creation/modification dates

## Migration Plan

### Phase 1: Parallel Implementation
1. Create new FZF menu system alongside existing InputSelector
2. Add feature flag to switch between systems
3. Test all functionality in FZF mode

### Phase 2: Feature Parity
1. Ensure all InputSelector features work in FZF
2. Add enhanced features (better previews, multi-select)
3. Performance optimization

### Phase 3: Deprecation
1. Make FZF menu the default
2. Mark InputSelector code as deprecated
3. Remove InputSelector code in future release

## Dependencies

- `fzf` (fuzzy finder)
- `jq` (JSON processing)
- `bat` (syntax highlighting in previews, optional)
- `eza` (enhanced file listing, optional)
