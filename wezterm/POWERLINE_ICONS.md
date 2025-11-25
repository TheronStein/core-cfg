# WezTerm Powerline Icons Reference

This document lists all available powerline separator icons from `wezterm.nerdfonts.*` that you can use for tabline/tab separators.

## Standard Powerline (pl_)

```lua
-- Hard dividers (solid arrows - full height)
wezterm.nerdfonts.pl_left_hard_divider         --
wezterm.nerdfonts.pl_right_hard_divider        --

-- Soft dividers (thin separators)
wezterm.nerdfonts.pl_left_soft_divider         -- ❮
wezterm.nerdfonts.pl_right_soft_divider        -- ❯

-- Branch symbol (often used for git)
wezterm.nerdfonts.pl_branch                    --
```

## Powerline Extra (ple_) - Uncommon/Unique Styles

### Half Circles (Rounded)
```lua
wezterm.nerdfonts.ple_left_half_circle_thick   --
wezterm.nerdfonts.ple_right_half_circle_thick  --
wezterm.nerdfonts.ple_left_half_circle_thin    --
wezterm.nerdfonts.ple_right_half_circle_thin   --
```

### Triangles (Flame/Angled)
```lua
-- Upper triangles (pointy top)
wezterm.nerdfonts.ple_upper_left_triangle      --
wezterm.nerdfonts.ple_upper_right_triangle     --

-- Lower triangles (pointy bottom)
wezterm.nerdfonts.ple_lower_left_triangle      --
wezterm.nerdfonts.ple_lower_right_triangle     --
```

### Diagonal/Slanted
```lua
wezterm.nerdfonts.ple_forwardslash_separator   --
wezterm.nerdfonts.ple_backslash_separator      --
```

### Honeycomb/Hexagon
```lua
wezterm.nerdfonts.ple_honeycomb                -- ⬡
```

### Ice Waveform (Pixelated/Stepped)
```lua
wezterm.nerdfonts.ple_ice_waveform             --
```

### Trapezoid
```lua
wezterm.nerdfonts.ple_trapezoid_top_bottom     --
```

### Flame (Sharp Points)
```lua
wezterm.nerdfonts.ple_flame_thick              --
wezterm.nerdfonts.ple_flame_thin               --
wezterm.nerdfonts.ple_flame_thick_mirrored     --
wezterm.nerdfonts.ple_flame_thin_mirrored      --
```

### Pixelated/Lego Style
```lua
wezterm.nerdfonts.ple_pixelated_squares        --
wezterm.nerdfonts.ple_lego_separator           --
wezterm.nerdfonts.ple_lego_separator_thin      --
```

### Additional Unique Shapes
```lua
wezterm.nerdfonts.ple_left_half_circle_thick_inverse   --
wezterm.nerdfonts.ple_right_half_circle_thick_inverse  --

wezterm.nerdfonts.ple_inner_left_half_circle_thick     --
wezterm.nerdfonts.ple_inner_right_half_circle_thick    --

wezterm.nerdfonts.ple_left_trapezoid                   --
wezterm.nerdfonts.ple_right_trapezoid                  --
```

## Current Configuration Locations

### Tabline Sections (modules/gui/tabline/config.lua)
```lua
section_separators = {
    left = wezterm.nerdfonts.pl_left_hard_divider,   -- Between A/B/C sections
    right = wezterm.nerdfonts.pl_right_hard_divider,
},
component_separators = {
    left = wezterm.nerdfonts.pl_left_soft_divider,   -- Within sections
    right = wezterm.nerdfonts.pl_right_soft_divider,
},
```

### Tabs (modules/gui/tabline/tabs.lua)
Currently using hardcoded Unicode:
- Line 244: `""` (left arrow)
- Line 252: `""` (right arrow)
- Line 264: `""` (left arrow)
- Line 272: `""` (right arrow)

**To customize:** Define variables at the top of the `tabs()` function:
```lua
local left_arrow = wezterm.nerdfonts.pl_left_hard_divider
local right_arrow = wezterm.nerdfonts.pl_right_hard_divider
```

Then replace the hardcoded `""` and `""` with `left_arrow` and `right_arrow`.

## Testing Different Combinations

Try these combinations for different aesthetics:

### Classic Powerline (Default)
```lua
section_separators: pl_left_hard_divider / pl_right_hard_divider
tabs: pl_left_hard_divider / pl_right_hard_divider
```

### Rounded Modern
```lua
section_separators: ple_left_half_circle_thick / ple_right_half_circle_thick
tabs: ple_left_half_circle_thick / ple_right_half_circle_thick
```

### Mixed (Sections hard, tabs soft)
```lua
section_separators: pl_left_hard_divider / pl_right_hard_divider
tabs: pl_left_soft_divider / pl_right_soft_divider
```

### Diagonal/Slanted
```lua
section_separators: ple_lower_left_triangle / ple_lower_right_triangle
tabs: ple_lower_left_triangle / ple_lower_right_triangle
```

## How to Apply

1. Edit `/home/theron/.core/cfg/wezterm/modules/gui/tabline/config.lua` for section/component separators
2. Edit `/home/theron/.core/cfg/wezterm/modules/gui/tabline/tabs.lua` for tab separators
3. Define variables instead of hardcoding, making it easy to swap styles
