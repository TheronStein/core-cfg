# Tab Color Picker

A visual, interactive color picker for WezTerm tabs with live preview in the style of your nerdfont and keymap browsers.

## Quick Start

1. **Open color picker**: `LEADER+F2`
2. **Browse colors** with arrow keys or fuzzy search
3. **See live preview** in the right pane showing:
   - Active tab appearance (full brightness)
   - Inactive tab appearance (dimmed)
   - Auto-adjusted text color for readability
4. **Press Enter** to apply the color
5. **Press Alt+C** to clear custom color and revert to default

## Features

### 🎨 Visual Browser Interface

Uses FZF with a curated Catppuccin color palette:
- 17 carefully selected colors
- Live preview pane showing exactly how tabs will look
- Color descriptions and hex codes
- Fuzzy search by color name

### 🔄 Smart Color Priority System

The system respects this priority order (highest to lowest):

1. **Tmux workspace color** ← ALWAYS wins
   - When attached to a tmux workspace with a defined color
   - The preview will warn you if tmux will override

2. **Custom tab color** ← Your choice from the picker
   - Set via `LEADER+F2`
   - Persists across WezTerm restarts
   - Stored in `.data/tabs/colors.json`

3. **Default mode color** ← Fallback
   - Changes based on WezTerm mode (normal, copy, search)
   - Used when no custom color is set

### 💾 Persistent Storage

Colors are automatically saved to:
```
~/.core/.sys/configs/wezterm/.data/tabs/colors.json
```

Format:
```json
{
  "42": "#a6e3a1",
  "43": "#89b4fa"
}
```

### ⚠️ Tmux Integration

**Important**: If a tab is attached to a tmux workspace, the workspace color will ALWAYS override the custom tab color. The browser will show a warning when this is the case.

To use custom colors with tmux:
- Detach from tmux, or
- Modify the tmux workspace color definition instead

## Color Palette

### Accent Colors (Vibrant)
| Color | Hex | Use Case |
|-------|-----|----------|
| Red | #f38ba8 | Alerts, errors, urgent tasks |
| Rose | #f5c2e7 | Soft, feminine projects |
| Maroon | #eba0ac | Deep red, serious work |
| Peach | #fab387 | Warm, creative projects |
| Yellow | #f9e2af | Highlights, warnings |
| Green | #a6e3a1 | Success, terminal, dev work |
| Teal | #94e2d5 | Cyan-green, databases |
| Sky | #89dceb | Light blue, documentation |
| Sapphire | #74c7ec | Bright blue, primary work |
| Blue | #89b4fa | Default blue, general use |
| Lavender | #b4befe | Purple-blue, creative |
| Mauve | #cba6f7 | Purple, design work |
| Pink | #f5c2e7 | Bright pink, fun projects |

### Neutrals (Subtle)
| Color | Hex | Use Case |
|-------|-----|----------|
| Flamingo | #f2cdcd | Light pink-gray, passive |
| Rosewater | #f5e0dc | Warm white, minimal |
| Surface2 | #585b70 | Dark gray, background work |
| Overlay2 | #9399b2 | Medium gray, utilities |

### Special
| Option | Effect |
|--------|--------|
| Default | Clears custom color, uses mode color |

## Keyboard Shortcuts

### In the Color Browser

- `↑/↓` or `j/k` - Navigate colors
- `PageUp/PageDown` - Fast scroll
- `Enter` - Apply selected color
- `Esc` - Cancel and exit
- `Alt+C` - Clear custom color (revert to default)
- `Ctrl+/` - Toggle preview pane
- Type to search - Fuzzy search by color name

## Examples

### Example 1: Color-code tabs by project type

```bash
# Development work - Green
Tab: "~/code/myapp" → LEADER+F2 → Select "Green"

# Documentation - Sky blue
Tab: "~/docs" → LEADER+F2 → Select "Sky"

# DevOps/Scripts - Peach
Tab: "~/scripts" → LEADER+F2 → Select "Peach"

# Monitoring/Logs - Yellow
Tab: "~/logs" → LEADER+F2 → Select "Yellow"
```

### Example 2: Clear a custom color

```bash
# Set a color
LEADER+F2 → Select "Mauve"

# Later, remove it
LEADER+F2 → Press Alt+C
# or
LEADER+F2 → Select "Default"
```

### Example 3: Understand priority with tmux

```bash
# 1. Set custom color
LEADER+F2 → Select "Green" (#a6e3a1)
# Tab shows green ✓

# 2. Attach to tmux workspace with Blue color
LEADER+a → Attach to workspace "development" (color: #89b4fa)
# Tab shows BLUE (workspace color overrides)

# 3. Detach from tmux
# Tab shows GREEN again (custom color restored)
```

## Preview Features

The live preview pane shows:

1. **Full tab preview** with your tab's icon and title
2. **Active state** - Full color brightness
3. **Inactive state** - Dimmed to 60% brightness
4. **Text color** - Automatically adjusted (dark on light, light on dark)
5. **Color information** - Hex codes for active and dimmed colors
6. **Priority explanation** - Shows which color source will win
7. **Tmux override warning** - Alerts if in tmux workspace

Example preview output:
```
╔════════════════════════════════════════╗
║           TAB COLOR PREVIEW            ║
╚════════════════════════════════════════╝

Color: #a6e3a1
Dimmed: #63885e

ACTIVE TAB PREVIEW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   code/myapp

INACTIVE TAB PREVIEW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   code/myapp

HOW IT WORKS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Active tabs: Full color brightness
• Inactive tabs: 60% dimmed
• Text color: Auto-adjusted for readability
```

## Files & Architecture

```
modules/
└── tab_color_picker.lua     # Lua module for color management
    ├── load_colors()        # Load from JSON
    ├── save_colors()        # Save to JSON
    ├── get_tab_color()      # Get color for tab
    ├── set_tab_color()      # Set color for tab
    └── show_color_picker()  # Launch browser

scripts/tab-color-browser/
├── color-browser.sh         # Main FZF interface
├── color-preview.sh         # Preview generation script
└── README.md               # Detailed documentation

modules/gui/tabline/tabs.lua # Integration point
└── Line 93-111: Color priority logic

keymaps/mods/leader.lua      # Keybinding
└── Line 194-205: LEADER+F2 binding

.data/tabs/
└── colors.json             # Persistent storage (auto-created)
```

## Integration with Other Features

The color picker works seamlessly with:

- ✅ **Tab rename** - Custom colors + custom titles/icons
- ✅ **Tmux workspaces** - Workspace colors override (by design)
- ✅ **Mode switching** - Falls back to mode colors
- ✅ **Session management** - Colors persist across restarts
- ✅ **Workspace templates** - Colors can be part of workspace saves

## Troubleshooting

### Q: Color not showing up?

**A**: Check the priority:
1. Is the tab in a tmux workspace? → Workspace color wins
2. Is there a custom color set? → Check `.data/tabs/colors.json`
3. Falls back to mode color

### Q: Can't save colors?

**A**: Check permissions:
```bash
mkdir -p ~/.core/.sys/configs/wezterm/.data/tabs
chmod 700 ~/.core/.sys/configs/wezterm/.data/tabs
```

### Q: Preview not working?

**A**: Ensure scripts are executable:
```bash
chmod +x ~/.core/.sys/configs/wezterm/scripts/tab-color-browser/*.sh
```

### Q: Want to override tmux workspace color?

**A**: You can't override it per-tab (by design), but you can:
- Modify the workspace color definition in `tmux_workspaces.lua`
- Detach from tmux to use custom tab colors

## Tips & Best Practices

1. **Use consistent colors for similar tasks**
   - Green for development
   - Blue for reading/browsing
   - Yellow for monitoring
   - Red for critical/production

2. **Leverage the preview**
   - The preview shows exactly what you'll get
   - Check both active and inactive states
   - Verify text remains readable

3. **Remember priority**
   - Tmux colors always win (this prevents confusion)
   - Custom colors work great for non-tmux tabs

4. **Color organization**
   - The palette is curated for maximum distinction
   - All colors meet readability standards
   - Dimmed inactive tabs remain identifiable

## Advanced Usage

### Adding Custom Colors

Edit `scripts/tab-color-browser/color-browser.sh` and add to the `COLORS` array:

```bash
declare -a COLORS=(
    # ... existing colors ...
    "CustomName|#HEXCODE|Description"
)
```

### Scripting

You can programmatically set colors via the Lua module:

```lua
local color_picker = require("modules.tab_color_picker")

-- Set a color
color_picker.set_tab_color(tab_id, "#a6e3a1")

-- Get a color
local color = color_picker.get_tab_color(tab_id)

-- Clear a color
color_picker.clear_tab_color(tab_id)
```

## Related Features

- `LEADER+F2` - **Tab rename** (set title and icon)
- `LEADER+F3` - Nerd Fonts icon browser
- `LEADER+F4` - Keybinding browser
- `LEADER+F5` - Theme browser
- `LEADER+w` - Workspace manager

---

**Keybinding**: `LEADER+F2`
**Module**: `modules/tab_color_picker.lua`
**Scripts**: `scripts/tab-color-browser/`
**Storage**: `.data/tabs/colors.json`
