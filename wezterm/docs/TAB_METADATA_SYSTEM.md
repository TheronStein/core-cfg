# Tab Metadata Auto-Capture System

## Overview

Automatic tab metadata persistence system that captures and stores tab information (title, icon, color, CWD) whenever changes occur. Includes an FZF-based browser to view all captured data.

## What Gets Captured

When you modify a tab, the system automatically saves:
- **Title**: Custom tab title
- **Icon**: Nerd Font icon
- **Color**: Tab color
- **CWD**: Working directory (from first pane)
- **Workspace**: Which workspace the tab belongs to
- **Pane Count**: Number of panes in the tab
- **Timestamp**: When last updated

## How It Works

### Auto-Capture Hooks

Hooks are installed that listen for tab changes:
- `tab-title-changed` - When you rename a tab
- `tab-color-changed` - When you set a tab color
- `tab-icon-changed` - When you change the tab icon
- `mux-tab-closed` - Removes metadata when tab closes

These hooks automatically call `capture_tab_state()` which saves all current metadata.

### Storage

All metadata is stored in: `.data/tabs/metadata.json`

Format:
```json
{
  "123": {
    "title": "My Project",
    "icon": "📁",
    "color": "#74c7ec",
    "cwd": "/home/user/project",
    "workspace": "CORE",
    "pane_count": 3,
    "updated_at": "2025-12-04 21:30:15"
  }
}
```

## Usage

### Keybindings

| Key | Action |
|-----|--------|
| `LEADER + SHIFT + M` | Show tab metadata browser (FZF) |
| `LEADER + SHIFT + CTRL + C` | Manually capture all tabs |

### Tab Metadata Browser

Press `LEADER + SHIFT + M` to launch the FZF browser showing:
- All tabs with saved metadata
- Tab ID, icon, title, color, workspace
- Pane count and CWD
- Live preview of metadata and directory contents

**Browser Features:**
- ↑↓ to navigate
- → to show/hide preview
- Ctrl-A to refresh and capture all tabs
- Esc to quit

### Preview

The right panel shows:
```
╭─────────────────────────────────────────╮
│           TAB METADATA                  │
╰─────────────────────────────────────────╯

🆔  Tab ID:       123
📝  Title:        📁 My Project
🎨  Color:        #74c7ec
📁  CWD:          /home/user/project
🌐  Workspace:    CORE
📊  Pane Count:   3
🕒  Updated:      2025-12-04 21:30:15

╭─────────────────────────────────────────╮
│       CWD CONTENTS (ls -la)             │
╰─────────────────────────────────────────╯

[directory listing]
```

## Integration Points

### Tab Rename Module
When you rename a tab via the tab rename system, it automatically emits `tab-title-changed` and `tab-icon-changed` events.

### Tab Color Picker
When you set a tab color, it emits `tab-color-changed` event.

### Event Handlers
Hooks are installed in `events/tab-lifecycle.lua` during startup.

## Files

| File | Purpose |
|------|---------|
| `modules/tabs/tab_metadata_persistence.lua` | Core metadata capture/storage system |
| `modules/tabs/tab_metadata_browser.lua` | WezTerm integration for browser |
| `modules/tabs/tab_color_picker.lua` | Modified to emit events |
| `modules/tabs/tab_rename.lua` | Modified to emit events |
| `scripts/tab-metadata-browser/browser.sh` | FZF browser script |
| `scripts/tab-metadata-browser/preview.sh` | Preview script for FZF |
| `events/tab-lifecycle.lua` | Installs hooks on startup |
| `keymaps/mods/leader.lua` | Keybinding definitions |

## Manual Capture

To capture metadata for all current tabs manually:

```
Press: LEADER + SHIFT + CTRL + C
```

Or programmatically:
```lua
local metadata = require("modules.tabs.tab_metadata_persistence")
metadata.capture_all_tabs(window)
```

## Troubleshooting

### No metadata showing in browser

1. Rename a tab to trigger capture: `LEADER + F2`
2. Manually capture all tabs: `LEADER + SHIFT + CTRL + C`
3. Check if file exists: `~/.core/.sys/cfg/wezterm/.data/tabs/metadata.json`

### Events not firing

Check that tab-lifecycle event handler is loaded in `wezterm.lua`:
```lua
require("events.tab-lifecycle").setup()
```

### Browser not launching

Check scripts are executable:
```bash
chmod +x ~/.core/.sys/cfg/wezterm/scripts/tab-metadata-browser/*.sh
```

## Future Enhancements

- [ ] Auto-restore tab metadata when loading workspace sessions
- [ ] Export metadata to workspace session files
- [ ] Search/filter tabs by workspace, color, or title
- [ ] Bulk operations (set color for all tabs in workspace)
- [ ] History tracking (see previous states)
- [ ] Integration with tmux session names

## Notes

- Tab IDs change when tabs are closed/recreated, so metadata is keyed by tab ID at capture time
- When restoring workspaces, new tab IDs are generated, so metadata needs to be re-associated
- This system complements (but doesn't replace) workspace session persistence
- CWD is captured from the first pane only (not all panes)
