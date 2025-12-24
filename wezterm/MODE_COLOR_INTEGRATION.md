# Mode Color Integration - Implementation Summary

## Overview

Implemented a clean, unified mode color system where **tabline mode indicators and pane borders ALWAYS use the EXACT SAME color, applied at the EXACT SAME moment**.

## Problem (Before)

1. **Leader mode didn't change border color** - relied on polling via update-status
2. **Context switching showed wrong colors** - timing issues between border and tabline updates
3. **Code was scattered** - colors defined in 2 places, mode detection in 2 places, multiple sync mechanisms
4. **Polling-based sync** - update-status constantly polling instead of direct application

## Solution (After)

Created a **SINGLE SOURCE OF TRUTH** architecture:

### 1. Unified Mode Color Constants (`modules/utils/mode_colors.lua`)

**Purpose**: Define mode colors ONCE, used by both tabline and borders

**Key Features**:
- Maps mode names to ansi palette indices (e.g., leader_mode → ansi[2] red)
- Resolves actual hex colors from current color scheme
- Single mode detection function used everywhere
- Color cache with theme change detection

**Color Map**:
```lua
wezterm_mode        → ansi[5] (blue/lavender)
tmux_mode           → ansi[7] (cyan/teal)
leader_mode         → ansi[2] (red)
pane_mode           → ansi[3] (green)
resize_mode         → ansi[4] (yellow/peach)
copy_mode           → ansi[4] (yellow/peach)
search_mode         → ansi[3] (green)
pane_selection_mode → ansi[5] (blue)
```

### 2. Mode Application (`keymaps/mode-colors.lua`)

**Purpose**: Apply colors to BOTH border AND tabline at transition points

**Key Function**: `set_mode(window, mode_name)`
1. Gets color from constants
2. Sets pane border color via config override
3. Sets GLOBAL state that tabline reads
4. Emits update-status to refresh tabline immediately

**No more polling** - direct application when entering/exiting modes.

### 3. Tabline Integration (`tabline/config.lua`)

**Changed**: `get_colors()` now builds mode themes from the SAME constant map
- Imports `MODE_COLOR_MAP` from constants
- Generates mode themes using same ansi indices
- Guarantees border and tabline use identical colors

### 4. Tabline Mode Component (`tabline/components/window/mode.lua`)

**Changed**: Uses GLOBAL state instead of re-detecting mode
- Reads `wezterm.GLOBAL.current_mode` (set by mode-colors.lua)
- Fallback to unified detection if GLOBAL not set
- No more duplicate mode detection logic

### 5. Direct Leader Activation (`events/navigation.lua`)

**Critical Change**: Leader colors set IMMEDIATELY on key-event
```lua
if window:leader_is_active() then
  mode_colors.enter_mode(window, "leader_mode")  -- INSTANT color change
end
```

**No more polling** - leader border+tabline turn red the moment you press the leader key.

### 6. Context Switching (`modules/utils/context_manager.lua`)

**Changed**: Uses mode-colors.set_context() which internally calls set_mode()
- Tmux/wezterm toggle sets BOTH colors immediately
- Removed redundant update-status emit

### 7. Fallback Sync (`events/update-status.lua`)

**Changed**: sync_mode_border is now rate-limited fallback only
- Only runs once per second (was every update-status)
- Catches any missed transitions (safety net)
- 99% of transitions handled by direct setting

### 8. Mode Entry Points

**Updated all mode activations** to use direct color setting:
- `LEADER+p` → pane_mode (already had enter_mode)
- `LEADER+\`` → copy_mode (already had enter_mode)
- `LEADER+/` → search_mode (**FIXED** - was using sync, now enter_mode)
- `LEADER+SHIFT+P` → pane_selection_mode (**ADDED** - was missing color handling)
- Pane/resize mode transitions in modes/panes.lua and modes/resize.lua (already correct)

## Architecture Flow

### Mode Transition Example: Leader Key Press

```
User presses LEADER key
    ↓
key-event fires (events/navigation.lua)
    ↓
handle_key_event() detects leader_is_active()
    ↓
mode_colors.enter_mode(window, "leader_mode")  [keymaps/mode-colors.lua]
    ↓
mode_colors.set_mode(window, "leader_mode")
    ↓
┌─────────────────────────────┐
│ BOTH HAPPEN AT SAME MOMENT: │
├─────────────────────────────┤
│ 1. Set border color (red)   │
│ 2. Set GLOBAL.current_mode  │
│ 3. Emit update-status       │
└─────────────────────────────┘
    ↓
Tabline reads GLOBAL.current_mode → uses red theme
    ↓
BOTH border AND tabline are RED instantly
```

### Context Switch Example: Toggle tmux/wezterm

```
User presses LEADER+t
    ↓
context_manager.toggle_context()
    ↓
mode_colors.set_context(window, "tmux")
    ↓
mode_colors.set_mode(window, "tmux_mode")
    ↓
┌─────────────────────────────┐
│ BOTH HAPPEN AT SAME MOMENT: │
├─────────────────────────────┤
│ 1. Border → cyan (ansi[7])  │
│ 2. Tabline → cyan (ansi[7]) │
└─────────────────────────────┘
```

## Files Modified

### Created:
- `modules/utils/mode_colors.lua` - Unified color constants and mode detection

### Modified:
- `keymaps/mode-colors.lua` - Rewritten to use constants, set both border+tabline
- `tabline/config.lua` - get_colors() uses constant map
- `tabline/components/window/mode.lua` - Uses GLOBAL state instead of re-detecting
- `events/navigation.lua` - Direct leader color setting on key-event
- `events/update-status.lua` - sync_mode_border now rate-limited fallback only
- `modules/utils/context_manager.lua` - Removed redundant update-status emit
- `keymaps/mods/leader.lua` - Fixed search mode, added pane_selection_mode colors

### Not Modified (already correct):
- `keymaps/modes/panes.lua` - Already uses enter_mode/exit_mode
- `keymaps/modes/resize.lua` - Already uses enter_mode/exit_mode

## Testing Checklist

Test all mode transitions to verify BOTH border and tabline change color together:

- [ ] Leader key press → BOTH turn red immediately
- [ ] Leader key release → BOTH return to context color (blue/cyan)
- [ ] Enter copy mode (LEADER+\`) → BOTH turn yellow/peach
- [ ] Exit copy mode (Escape) → BOTH return to context color
- [ ] Enter search mode (LEADER+/) → BOTH turn green
- [ ] Exit search mode (Escape) → BOTH return to context color
- [ ] Enter pane mode (LEADER+p) → BOTH turn green
- [ ] Exit pane mode (Escape/q) → BOTH return to context color
- [ ] Enter resize mode (Tab in pane mode) → BOTH turn yellow/peach
- [ ] Exit resize mode (Escape/q) → BOTH return to context color
- [ ] Pane selection (LEADER+SHIFT+P) → BOTH turn blue
- [ ] Context toggle (LEADER+t) → BOTH change between blue (wezterm) / cyan (tmux)
- [ ] Verify no delay - colors change instantly on keypress
- [ ] Verify colors ALWAYS match between border and tabline

## Benefits

1. **Single source of truth** - colors defined once, used everywhere
2. **Instant updates** - direct setting at transition time, no polling delay
3. **Always synchronized** - border and tabline use EXACT same color constants
4. **Simpler code** - removed duplicate detection, duplicate color definitions, complex sync
5. **Better performance** - rate-limited fallback sync vs constant polling
6. **Maintainable** - change a color once in MODE_COLOR_MAP, affects both border and tabline

## Maintenance

### To change a mode's color:
Edit `modules/utils/mode_colors.lua`:
```lua
local MODE_COLOR_MAP = {
  leader_mode = 6,  -- Change from 2 (red) to 6 (pink)
  -- ...
}
```
Both border and tabline will automatically use the new color.

### To add a new mode:
1. Add to `MODE_COLOR_MAP` in `modules/utils/mode_colors.lua`
2. Call `mode_colors.enter_mode(window, "new_mode")` when entering the mode
3. Done - both border and tabline will work automatically

### To debug:
Enable debug mode in config/debug.lua:
```lua
debug_mode_borders = true
```
Check logs for mode transitions.
