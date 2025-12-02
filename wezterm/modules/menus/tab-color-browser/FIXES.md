# Tab Color Picker - Fixes Applied

## Issue 1: Colors Not Applying After Selection

### Problem
The bash script was saving colors to the JSON file, but WezTerm wasn't seeing the changes because:
1. The Lua module had already loaded the colors at startup
2. No mechanism to trigger a tab refresh after color selection

### Solution: Callback File Mechanism

Implemented a callback file system for immediate communication:

1. **Lua side** (`modules/tab_color_picker.lua`):
   - Generates a unique callback file path when launching browser
   - Passes callback file path to bash script as 5th argument
   - Watches for the callback file to appear (polls every 0.5s, max 30s)
   - When detected, reads the color, saves it, and closes the browser tab
   - Auto-closing the browser tab triggers a natural redraw

2. **Bash side** (`scripts/tab-color-browser/color-browser.sh`):
   - Accepts `CALLBACK_FILE` as 5th parameter
   - Writes selected color (or "CLEAR") to callback file after saving to JSON
   - This signals WezTerm that a selection was made

**Result**: Colors now apply immediately when selected!

---

## Issue 2: Tabs Flashing on Config Reload

### Problem
When WezTerm config reloads, all tabs were flashing a specific color because:
1. Colors were loaded from JSON file on every tab render
2. The initial refresh mechanism used `force_reverse_video_cursor` toggle
3. This caused a visible flash across all tabs

### Solution: Global Color Cache + Natural Redraw

Implemented efficient caching and removed forced config changes:

1. **Global Color Cache**:
   ```lua
   -- Colors loaded once into wezterm.GLOBAL.tab_colors
   -- All subsequent calls use the cache
   -- Cache updated whenever colors are saved
   ```

2. **Removed Force Refresh**:
   - Removed the `force_reverse_video_cursor` toggle hack
   - Instead, auto-close the color picker tab after selection
   - Closing the tab causes a natural redraw (no flash!)

3. **Cache Initialization**:
   ```lua
   local function ensure_color_cache()
       if not wezterm.GLOBAL.tab_colors then
           wezterm.GLOBAL.tab_colors = M.load_colors_from_file()
       end
   end
   ```

4. **Cache Updates**:
   - `save_colors()` updates both file AND cache
   - `set_tab_color()` and `clear_tab_color()` update cache
   - `get_tab_color()` reads from cache (fast!)

**Result**: No more flashing on config reload! Colors load once and stay consistent.

---

## Technical Details

### Before (Problematic Flow)

```
User selects color
    ↓
Bash saves to JSON
    ↓
Lua doesn't know anything happened
    ↓
User sees no change ❌
```

### After (Fixed Flow)

```
User selects color
    ↓
Bash saves to JSON + writes callback file
    ↓
Lua detects callback file
    ↓
Lua reads color, updates cache, saves to storage
    ↓
Lua auto-closes browser tab
    ↓
Tab redraw shows new color ✓
```

### Performance Improvements

**Before**:
- File I/O on every tab render (slow)
- Config override toggles (causes flash)

**After**:
- File I/O only on startup and color changes (fast)
- Cache reads for all renders (instant)
- Natural tab redraws (smooth)

---

## Files Modified

### `modules/tab_color_picker.lua`
- Added `ensure_color_cache()` for lazy cache initialization
- Added `load_colors_from_file()` for internal file reading
- Modified `load_colors()` to use cache
- Modified `save_colors()` to update cache
- Modified `show_color_picker()` to pass callback file
- Added `watch_for_color_selection()` for callback polling
- Added auto-close browser tab logic
- Removed config override flash hack

### `scripts/tab-color-browser/color-browser.sh`
- Added `CALLBACK_FILE` parameter (5th argument)
- Added callback file writing after color selection
- Added validation for callback file parameter

---

## Testing

To verify the fixes work:

1. **Test color application**:
   ```
   LEADER+F2 → Select any color → Should apply immediately
   ```

2. **Test cache performance**:
   ```
   Set colors on several tabs
   LEADER+r (reload config)
   → Tabs should NOT flash
   → Colors should persist
   ```

3. **Test clear function**:
   ```
   LEADER+F2 → Alt+C (or select "Default")
   → Custom color removed immediately
   ```

4. **Test tmux override**:
   ```
   Set custom color → Attach to tmux workspace
   → Workspace color should take priority
   → Preview should warn about override
   ```

---

## Cache Invalidation

The cache is automatically managed:

- **Initialized**: First time `get_tab_color()` is called
- **Updated**: Every time `save_colors()` is called
- **Persistent**: Lives in `wezterm.GLOBAL` for the session
- **Reloaded**: Automatically on WezTerm restart

No manual cache clearing needed!

---

## Benefits

✅ **Immediate feedback** - Colors apply instantly after selection
✅ **No flashing** - Config reloads don't cause visual artifacts
✅ **Better performance** - Cache eliminates redundant file I/O
✅ **Smooth UX** - Browser auto-closes after selection
✅ **Reliable** - Colors persist across restarts
✅ **Clean code** - No hacks or workarounds

---

## Compatibility

These fixes maintain full compatibility with:
- Tab rename system (custom titles/icons)
- Tmux workspace color priority
- Session management
- Workspace templates
- All existing keybindings

No breaking changes!
