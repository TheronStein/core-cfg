# WezTerm Event Handlers

## Critical: Event Handler Override Behavior

**IMPORTANT**: WezTerm event handlers registered with `wezterm.on()` will **override** previous handlers for the same event. Only the **last registered handler** will execute.

### Problem

If you have multiple files doing this:
```lua
-- file1.lua
wezterm.on('update-status', function(window, pane)
  -- This will be overridden
end)

-- file2.lua
wezterm.on('update-status', function(window, pane)
  -- This will be overridden
end)

-- file3.lua
wezterm.on('update-status', function(window, pane)
  -- Only THIS ONE runs!
end)
```

Only the LAST handler (file3) will execute. The others are silently overridden.

### Solution

Use a **unified event handler** that calls all necessary components:

```lua
-- events/update-status-unified.lua
wezterm.on('update-status', function(window, pane)
  -- Call ALL components that need to run on update-status
  component1.update(window, pane)
  component2.update(window, pane)
  component3.update(window, pane)
end)
```

## Current Unified Handlers

### `update-status-unified.lua`

This is the **ONLY** `update-status` handler. It calls:
1. Tabline status bar components (`gui.tabline.component.set_status`)
2. Backdrop cycle status
3. Tab cleanup checks
4. Other status-dependent features

**Rules:**
- Must be loaded LAST in `wezterm.lua` to avoid being overridden
- All new `update-status` logic should be added to this file
- Do NOT create separate `wezterm.on('update-status', ...)` handlers

## Affected Events

The following events are susceptible to this override behavior:

- `update-status` - **UNIFIED** (see `update-status-unified.lua`)
- `format-tab-title` - Handled by tabline module
- `window-config-reloaded` - Check for conflicts
- `user-var-changed` - Check for conflicts

## Adding New Update-Status Logic

**DON'T DO THIS:**
```lua
-- events/my-new-feature.lua
wezterm.on('update-status', function(window, pane)
  -- This will override the unified handler!
end)
```

**DO THIS INSTEAD:**
```lua
-- events/my-new-feature.lua
local M = {}

function M.update(window, pane)
  -- Your logic here
end

return M

-- Then add to events/update-status-unified.lua:
local my_feature = require('events.my-new-feature')
my_feature.update(window, pane)
```

## Debugging Event Conflicts

If you suspect event handler conflicts:

1. Enable debug logging in `config/debug.lua`:
   ```lua
   debug_tabline_events = true
   ```

2. Check logs for event firing:
   ```
   [TABLINE:EVENT] update-status fired
   ```

3. If events aren't firing, check `wezterm.lua` load order
4. Ensure unified handler is loaded LAST

## Event Handler Files (Deprecated)

The following files contain OLD `update-status` handlers and are **DISABLED**:
- ~~`events/backdrop-cycle.lua`~~ (logic moved to unified handler)
- ~~`events/backdrop-opacity-watcher.lua`~~ (logic moved to unified handler)
- ~~`events/backdrop-refresh-watcher.lua`~~ (logic moved to unified handler)
- ~~`events/leader-activated.lua`~~ (logic moved to unified handler)
- ~~`events/tab-cleanup.lua`~~ (logic moved to unified handler)
- ~~`events/workspace_theme_handler.lua`~~ (passive - no changes needed)

These files may still exist but their `wezterm.on('update-status', ...)` calls are no longer used.
