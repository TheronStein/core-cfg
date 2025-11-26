# Tab Naming System

## Overview

The WezTerm tab naming system uses a **three-tier priority system** that determines how tabs are displayed in the tabline.

## Priority Levels

### 1. Default (Lowest Priority)
**When:** No tmux workspace, no custom name set
**Display:** Current working directory name or process name
**Icon:** Process-based icon (e.g., nvim icon for neovim)
**Color:** Default mode color

### 2. Tmux (Medium Priority)
**When:** Tab is attached to a tmux workspace
**Display:** `SHORTNAME/SESSION` (e.g., `CFG/wezterm` for configuration workspace)
**Icon:** Tmux workspace icon (e.g., ⚙️ for configuration)
**Color:** Tmux workspace color (e.g., blue #89b4fa for configuration)

### 3. Custom (Highest Priority)
**When:** User manually renames tab via `LEADER+F2` → Tab Manager → Rename Tab
**Display:** User-provided custom name
**Icon:** Custom icon if specified, **otherwise tmux workspace icon if in tmux**
**Color:** **Always preserves tmux workspace color if in tmux**

## Implementation Details

### Custom Tab Storage
Custom tab data is stored in `wezterm.GLOBAL.custom_tabs[tab_id]`:
```lua
{
  title = "My Custom Name",           -- User-provided title
  icon_key = "🚀",                    -- Optional custom icon
  tmux_workspace = "configuration",   -- Set if in tmux workspace
  tmux_workspace_color = "#89b4fa"   -- Tmux workspace color (preserved)
}
```

### Icon Priority
1. **Custom icon** - If `icon_key` is set during rename
2. **Tmux workspace icon** - If in tmux workspace and no custom icon
3. **Process icon** - Default fallback

### Color Handling
- Tmux workspace color is **always preserved** even with custom titles
- This is handled separately in the tab rendering logic (lines 93-96 in `tabs.lua`)
- Custom tabs in tmux workspaces will show custom title but keep workspace color

## Usage Examples

### Scenario 1: Default Tab
- **Context:** Regular tab, not in tmux
- **Result:** Shows CWD like "wezterm" with folder/process icon

### Scenario 2: Tmux Workspace Tab
- **Context:** Attached to "configuration" tmux workspace, session "nvim"
- **Result:** Shows "CFG/nvim" with ⚙️ icon in blue color

### Scenario 3: Custom Named Tmux Tab (No Custom Icon)
- **Context:** In "configuration" workspace, renamed to "My Config"
- **Result:** Shows "My Config" with ⚙️ icon (tmux icon preserved) in blue color

### Scenario 4: Custom Named Tmux Tab (With Custom Icon)
- **Context:** In "configuration" workspace, renamed to "Database" with 🗄️ icon
- **Result:** Shows "Database" with 🗄️ icon in blue color (workspace color preserved)

### Scenario 5: Custom Named Regular Tab
- **Context:** Not in tmux, renamed to "Downloads" with 📥 icon
- **Result:** Shows "Downloads" with 📥 icon in default mode color

## Key Benefits

✅ **Context Awareness** - Tabs show different information based on their context
✅ **Visual Consistency** - Tmux workspace colors provide visual grouping
✅ **User Control** - Can override any tab name while preserving context indicators
✅ **Icon Flexibility** - Can use custom icons or rely on automatic workspace/process icons

## Debugging

To enable debug logging for tab naming:

```lua
-- In config/debug.lua
debug_tabline_tabs = true  -- Shows tab rendering decisions
```

## Code Location

The tab naming logic is implemented in:
- **Main Logic:** `modules/gui/tabline/tabs.lua` (lines 182-227)
- **Custom Tab Storage:** `modules/tab_rename.lua` (stores to `wezterm.GLOBAL.custom_tabs`)
- **Tmux Metadata:** `modules/tmux_workspaces.lua` (workspace definitions and colors)
- **Color Preservation:** `modules/gui/tabline/tabs.lua` (lines 93-96)

## Related Keybindings

- `LEADER+F1` - Session/workspace menu
- `LEADER+F2` - Tab manager menu (rename tab)
- `LEADER+w` - Workspace manager menu
- `LEADER+W` (Shift) - Browse tmux workspaces
