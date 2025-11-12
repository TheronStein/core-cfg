# Pivot Pane Module

A standalone WezTerm module for toggling the orientation of adjacent panes (horizontal ↔ vertical).

## Features

- **Smart Pane Detection**: Automatically finds adjacent panes to pivot
- **State Preservation**: Captures and restores process state, working directory, and scrollback
- **Priority-based Restoration**: Prioritizes shell processes for accurate state restoration
- **Configurable**: Customize scrollback capture and process priorities

## Installation

This is a standalone module that doesn't require external plugins. Simply place the `pivot` directory in your WezTerm modules folder.

## Usage

### Basic Setup

In your `wezterm.lua`:

```lua
local pivot = require("modules.pivot")

-- Use with defaults
local config = {}

-- Add keybinding
config.keys = {
  {
    key = "p",
    mods = "LEADER",
    action = wezterm.action_callback(pivot.toggle_orientation_callback),
  },
}

return config
```

### Custom Configuration

```lua
local pivot = require("modules.pivot").setup({
  -- Maximum scrollback lines to preserve (0 to disable)
  max_scrollback_lines = 2000,

  -- Process priority for state restoration
  priority_apps = {
    ["zsh"] = 10,      -- Shells have highest priority
    ["bash"] = 10,
    ["nvim"] = 3,      -- Editors have lower priority
    ["vim"] = 3,
  },

  -- Shell detection
  shell_detection = {
    "bash", "zsh", "fish", "sh"
  },

  -- Enable debug logging
  debug = false,
})
```

## How It Works

1. **Detection**: Identifies two adjacent panes (horizontally or vertically aligned)
2. **Capture**: Saves the state of both panes (process, directory, scrollback)
3. **Pivot**: Closes one pane and recreates it with the opposite orientation
4. **Restore**: Restores process state prioritizing shells for accurate restoration

### State Preservation

- **Shell Processes**: Directory and command history are preserved
- **Non-shell Processes**: Attempts to restart the same command
- **Scrollback**: Optionally captures terminal scrollback (configurable)

## API

### `setup(config)`

Initializes the module with custom configuration.

```lua
pivot.setup({
  max_scrollback_lines = 1000,
  debug = true,
})
```

### `toggle_orientation_callback(window, pane)`

Callback function for WezTerm keybindings.

```lua
config.keys = {
  {
    key = "p",
    mods = "LEADER",
    action = wezterm.action_callback(pivot.toggle_orientation_callback),
  },
}
```

### `toggle_orientation(tab_or_pane)`

Directly toggle pane orientation.

```lua
-- Toggle active pane with its adjacent neighbor
pivot.toggle_orientation()

-- Toggle specific pane
pivot.toggle_orientation(some_pane)
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `max_scrollback_lines` | number | 1000 | Maximum scrollback lines to preserve (0 = disabled) |
| `priority_apps` | table | See config.lua | Process priority mapping for restoration |
| `shell_detection` | string[] | Common shells | List of shell process names |
| `debug` | boolean | false | Enable debug logging |

## Limitations

- Currently supports pivoting exactly 2 adjacent panes
- Non-shell process state may not be fully restored
- Scrollback restoration is limited

## Architecture

The module is organized into:

- `init.lua` - Module entry point and public API
- `pivot.lua` - Core pivoting logic
- `config.lua` - Configuration management
- `utils.lua` - Helper utilities
- `types.lua` - Type definitions
- `lib/` - Standalone utility libraries
  - `logger.lua` - Logging functionality
  - `table.lua` - Table manipulation utilities
  - `wezterm_utils.lua` - WezTerm-specific utilities

## License

This module is standalone and has no external dependencies beyond WezTerm itself.
