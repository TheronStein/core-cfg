# WezTerm Theme Browser

Live theme preview browser with workspace-specific persistence.

## Quick Start

```bash
# Launch from WezTerm
LEADER + F6

# Or run directly
./theme-browser.sh
```

## Files

- **theme-browser.sh** - Main browser (fzf-based UI)
- **generate-themes-data.lua** - Extract theme metadata from WezTerm
- **theme-preview-template.sh** - Ghostty-style preview template
- **data/themes.json** - Cached theme metadata (1,113 themes)

## Preview Modes

### Template (Default)
Shows color palette, sample code, and formatted text

### Split Pane
Live preview in separate WezTerm pane

Set mode via:
```bash
export THEME_BROWSER_PREVIEW_MODE=split  # or "template"
```

## Controls

```
↑/↓         Navigate
Enter       Apply to workspace
Esc         Cancel
Ctrl+L/D    Filter light/dark
Ctrl+W/C    Filter warm/cool
Ctrl+R      Reset filters
Ctrl+/      Toggle preview
```

## How It Works

1. Browser writes theme name to `/run/user/1000/wezterm_theme_preview_<workspace>.txt`
2. Theme watcher (in WezTerm) polls file every 50ms
3. On change, applies theme via `window:set_config_overrides()`
4. On Enter, saves theme to workspace JSON
5. On cancel, restores original theme

## Generate Theme Data

```bash
cd ~/.core/cfg/wezterm
wezterm --config-file scripts/theme-browser/generate-themes-data.lua
```

## Architecture

```
theme-browser.sh
    ├─> generate-themes-data.lua → data/themes.json
    ├─> theme-preview-template.sh → fzf preview window
    └─> writes to: preview file

modules/theme_watcher.lua
    ├─> polls: preview file
    ├─> applies: window:set_config_overrides()
    └─> integrates with: workspace_themes.lua

modules/workspace_themes.lua
    ├─> stores: .state/workspace-themes/themes.json
    ├─> loads: on workspace switch
    └─> persists: across sessions
```

## See Full Documentation

[Complete Theme Browser Guide](../../docs/THEME_BROWSER_GUIDE.md)
