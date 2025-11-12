# WezTerm Live Theme Browser

A powerful theme browser with real-time preview and workspace-specific theme persistence for WezTerm.

## Features

- **Live Preview**: See themes applied in real-time as you navigate through the list
- **Workspace-Specific Themes**: Each workspace can have its own persistent theme
- **Preserved Tabline**: Your custom tabline theme stays consistent regardless of workspace theme
- **Two Preview Modes**:
  - Template mode (ghostty-style preview with colors and sample code)
  - Split pane mode (live shell preview)
- **Filter Options**: Filter by light/dark, warm/cool/neutral temperature
- **1,113+ Built-in Themes**: All WezTerm color schemes available

## Quick Start

### Launch Theme Browser

Press `LEADER + F6` (Default: `Super+Space` then `F6`)

This will:
1. Start the theme watcher for live preview
2. Open the theme browser in a new tab
3. Preview themes in real-time in the current window

### Navigation

```
↑/↓         Navigate through themes
Enter       Apply theme to current workspace
Esc         Cancel and restore original theme
Ctrl+/      Toggle preview window
Ctrl+L      Filter light themes only
Ctrl+D      Filter dark themes only
Ctrl+W      Filter warm themes only
Ctrl+C      Filter cool themes only
Ctrl+R      Reset filters (show all)
```

## Preview Modes

### Template Mode (Default)

Shows a ghostty-style preview with:
- Color palette (16 ANSI colors)
- Sample code with syntax highlighting
- Sample text with formatting
- Table examples

### Split Pane Mode

To use split pane mode instead:

```bash
export THEME_BROWSER_PREVIEW_MODE=split
```

Then launch the browser. The preview will update in a separate pane.

## Workspace-Specific Themes

Themes are automatically saved per workspace:

1. Open theme browser (`LEADER + F6`)
2. Navigate to desired theme
3. Press `Enter` to apply to current workspace
4. Theme persists across sessions for that workspace

### Storage

Workspace themes are stored in:
```
~/.core/cfg/wezterm/.state/workspace-themes/themes.json
```

Format:
```json
{
  "workspace_name": {
    "theme": "Catppuccin Mocha",
    "updated_at": "2025-10-12T10:47:30Z"
  }
}
```

## Tabline Theme Protection

Your custom tabline theme is preserved in:
```
modules/tabline_theme_preserved.lua
```

The tabline always uses these hardcoded colors:
- **CORE mode**: Cyan (#01F9C6)
- **LEADER mode**: Red (#FF5370)
- **WEZTERM mode**: Purple (#C792EA)
- **TMUX mode**: Orange (#F78C6C)
- **SUPER mode**: Yellow (#FFCB6B)
- And 7 more custom mode themes

These colors remain consistent regardless of the workspace theme.

## Architecture

### Components

1. **modules/workspace_themes.lua**
   - Manages workspace-specific theme persistence
   - JSON storage and retrieval
   - Theme application logic

2. **modules/theme_watcher.lua**
   - Watches preview file for theme changes
   - Applies themes in real-time (50ms polling)
   - Handles cleanup and cancellation

3. **modules/tabline_theme_preserved.lua**
   - Hardcoded tabline theme colors
   - Prevents tabline from being affected by workspace themes

4. **events/workspace_theme_handler.lua**
   - Event handler for workspace theme management
   - Automatically applies themes on workspace switch
   - Integrates with theme watcher

5. **scripts/theme-browser/**
   - `theme-browser.sh`: Main browser script (fzf-based)
   - `generate-themes-data.lua`: Extracts theme metadata from WezTerm
   - `theme-preview-template.sh`: Generates preview display
   - `data/themes.json`: Theme metadata cache

### How Live Preview Works

1. Browser writes theme name to preview file:
   ```
   /run/user/1000/wezterm_theme_preview_<workspace>.txt
   ```

2. Theme watcher polls this file every 50ms

3. On change, watcher updates `window:set_config_overrides()`

4. WezTerm applies theme instantly without restart

## Regenerating Theme Data

If new themes are added to WezTerm or metadata needs updating:

```bash
cd ~/.core/cfg/wezterm
wezterm --config-file scripts/theme-browser/generate-themes-data.lua
```

This generates:
```
scripts/theme-browser/data/themes.json
```

With metadata for all 1,113+ themes including:
- Category (light/dark)
- Brightness (0-255)
- Temperature (warm/cool/neutral)
- Background/foreground colors
- ANSI color palette

## Customization

### Change Preview Mode Default

Edit `scripts/theme-browser/theme-browser.sh`:

```bash
# Line 16
PREVIEW_MODE="${THEME_BROWSER_PREVIEW_MODE:-split}"  # or "template"
```

### Add Custom Filters

Edit the fzf bindings in `theme-browser.sh`:

```bash
--bind="ctrl-h:reload(bash -c 'generate_list \"\" \"\" high-contrast')"
```

### Modify Preview Template

Edit `scripts/theme-browser/theme-preview-template.sh` to customize:
- Color palette display
- Sample code examples
- Text formatting samples

## Troubleshooting

### Theme preview not updating

1. Check if theme watcher is active:
   ```lua
   local theme_watcher = require("modules.theme_watcher")
   print(theme_watcher.is_active(window))
   ```

2. Check preview file exists:
   ```bash
   ls -la /run/user/1000/wezterm_theme_preview_*.txt
   ```

3. Manually start watcher:
   ```lua
   window:set_user_var("start_theme_watcher", workspace)
   ```

### Theme not persisting

1. Check workspace themes file exists:
   ```bash
   cat ~/.core/cfg/wezterm/.state/workspace-themes/themes.json
   ```

2. Verify event handler is loaded:
   ```bash
   grep "workspace_theme_handler" ~/.core/cfg/wezterm/wezterm.lua
   ```

3. Check logs for errors:
   ```bash
   # In WezTerm, press CTRL+SHIFT+L to open debug overlay
   ```

### Tabline affected by workspace theme

If tabline colors change with workspace theme:

1. Verify preserved theme is loaded:
   ```bash
   grep "tabline_theme_preserved" ~/.core/cfg/wezterm/modules/tabline_custom.lua
   ```

2. Check tabline config uses hardcoded theme:
   ```lua
   theme = "Catppuccin Mocha",  -- Should be hardcoded, not config.color_scheme
   ```

## Performance

- **Theme Data**: Cached in JSON, regenerates only when needed
- **Preview Updates**: 50ms polling (configurable in theme_watcher.lua)
- **Memory**: Minimal overhead, themes loaded on-demand
- **Startup**: No impact, event handlers lazy-load

## Integration with Existing Systems

### With Workspace Manager

Workspace-specific themes work seamlessly with the existing workspace manager:

```lua
-- In modules/workspace_manager.lua
-- Themes are automatically applied when switching workspaces
```

### With Session Manager

Sessions remember their workspace theme:

1. Save session with theme
2. Load session → workspace activates → theme applied automatically

### With Backdrop System

Themes and backdrops work independently:
- Backdrop changes don't affect theme
- Theme changes don't affect backdrop
- Both can be customized per workspace

## Future Enhancements

Potential improvements:

- [ ] Favorite themes system
- [ ] Theme categories/tags
- [ ] Color scheme editor
- [ ] Theme previews with actual terminal output
- [ ] Domain-specific themes (not just workspace)
- [ ] Theme gradients/transitions
- [ ] Export/import custom themes
- [ ] Theme suggestions based on time of day
- [ ] Integration with system theme (dark/light mode)

## Credits

Inspired by:
- Ghostty theme browser UI
- Original WezTerm theme_watcher.lua from refs
- fzf-based keymap browser template

## See Also

- [Keymap Browser](../scripts/keymap-browser/README.md)
- [Workspace Manager](WORKSPACE_MANAGER.md)
- [Backdrop System](../utils/backdrops.lua)
- [Tabline Customization](../modules/tabline_custom.lua)
