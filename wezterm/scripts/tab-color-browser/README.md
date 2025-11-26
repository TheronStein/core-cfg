# Tab Color Browser

A visual color picker for WezTerm tabs with live preview, inspired by the nerdfont-browser and keymap-browser modules.

## Features

- **Interactive FZF browser** - Browse through a curated palette of colors
- **Live preview** - See exactly how the tab will look (active and inactive states)
- **TMUX-aware** - Warns when tmux workspace colors will override custom colors
- **Persistent storage** - Colors saved to `.data/tabs/colors.json`
- **Color priority system** - Respects tmux workspace colors over custom colors

## Usage

### Keybinding

Press `LEADER+F2` to open the tab color picker for the current tab.

### Color Priority

The tab color system follows this priority (highest to lowest):

1. **Tmux workspace color** (highest priority)
   - If the tab is attached to a tmux workspace with a defined color
   - This ALWAYS overrides custom tab colors

2. **Custom tab color** (medium priority)
   - Set via the color picker (`LEADER+F2`)
   - Stored per tab ID in `.data/tabs/colors.json`

3. **Default mode color** (lowest priority/fallback)
   - Uses WezTerm's current mode color (normal, copy, search, etc.)

### Example Workflow

```bash
# 1. Open a new tab
LEADER+c

# 2. Set a custom color
LEADER+F2
# Browse and select a color (e.g., "Catppuccin Green")

# 3. The tab now uses the custom color!

# 4. If you attach to a tmux workspace:
LEADER+a  # Attach to tmux
# The workspace color will override your custom color

# 5. Clear the custom color (revert to default):
LEADER+F2
# Select "Default" or press Alt-C
```

## Color Palette

The browser includes a curated selection of colors from the Catppuccin theme:

### Accent Colors
- **Red** (#f38ba8) - Alerts & errors
- **Rose** (#f5c2e7) - Soft pink
- **Peach** (#fab387) - Warm orange
- **Green** (#a6e3a1) - Success & terminal
- **Blue** (#89b4fa) - Primary blue
- **Mauve** (#cba6f7) - Purple accent

### Utility Colors
- **Sky** (#89dceb) - Light blue
- **Teal** (#94e2d5) - Cyan-green
- **Lavender** (#b4befe) - Purple-blue
- **Surface2** (#585b70) - Dark gray
- **Overlay2** (#9399b2) - Medium gray

## Preview Features

The live preview shows:

1. **Active tab appearance** - Full color brightness
2. **Inactive tab appearance** - Dimmed to 60% brightness
3. **Text color** - Auto-adjusted for readability (dark text on bright backgrounds)
4. **Tab content** - Shows your tab's icon and title
5. **TMUX override warning** - Alerts if in tmux workspace

## Files

```
scripts/tab-color-browser/
├── color-browser.sh    # Main FZF browser interface
├── color-preview.sh    # Live preview script
└── README.md          # This file

modules/
└── tab_color_picker.lua  # Lua module for color management

.data/tabs/
└── colors.json        # Persistent color storage (auto-created)
```

## Data Format

Colors are stored in `.data/tabs/colors.json`:

```json
{
  "42": "#a6e3a1",
  "43": "#89b4fa",
  "44": "#fab387"
}
```

Keys are tab IDs (as strings), values are hex color codes.

## Keyboard Shortcuts (in browser)

- `Enter` - Select color and apply
- `Esc` - Cancel without changes
- `Alt+C` - Clear custom color (revert to default)
- `Ctrl+/` - Toggle preview pane
- `↑/↓` - Navigate colors
- `PageUp/PageDown` - Fast scroll

## Integration

The color picker integrates seamlessly with existing WezTerm features:

- **Tab rename** - Custom colors work with custom tab titles/icons
- **Tmux workspaces** - Workspace colors automatically override
- **Mode switching** - Falls back to mode colors when no custom color set
- **Session management** - Colors persist across WezTerm restarts

## Technical Details

### Color Dimming Algorithm

Inactive tabs use a 60% brightness reduction:

```lua
local function dim_color(hex)
    local r = tonumber(hex:sub(2, 3), 16)
    local g = tonumber(hex:sub(4, 5), 16)
    local b = tonumber(hex:sub(6, 7), 16)
    r = math.floor(r * 0.6)
    g = math.floor(g * 0.6)
    b = math.floor(b * 0.6)
    return string.format("#%02x%02x%02x", r, g, b)
end
```

### Text Color Auto-Adjustment

Bright backgrounds get dark text, dark backgrounds get light text:

```lua
local function needs_dark_text(bg_color)
    local r = tonumber(bg_color:sub(2, 3), 16)
    local g = tonumber(bg_color:sub(4, 5), 16)
    local b = tonumber(bg_color:sub(6, 7), 16)
    local brightness = (r * 0.299 + g * 0.587 + b * 0.114)
    return brightness > 128
end
```

## Troubleshooting

### Colors not persisting

Check that `.data/tabs/colors.json` is writable:
```bash
ls -la ~/.core/.sys/configs/wezterm/.data/tabs/colors.json
```

### Preview not showing

Ensure the preview script is executable:
```bash
chmod +x ~/.core/.sys/configs/wezterm/scripts/tab-color-browser/color-preview.sh
```

### Tmux color always overrides

This is expected behavior! Tmux workspace colors have the highest priority. To use custom tab colors, detach from tmux or modify the workspace color definition.

## Future Enhancements

Possible future additions:
- [ ] Custom color input (hex color picker)
- [ ] Import/export color schemes
- [ ] Per-workspace color templates
- [ ] Gradient support for fancy effects
- [ ] Color themes (load preset palettes)
