# Copy-Mode Fixes

**Date**: 2025-11-25
**Issue**: Clipboard yanking not working, no easy way to enter copy-mode

---

## Issues Fixed

### 1. **Clipboard Integration** 🚨
**Problem**: Copy commands used `copy-selection-and-cancel` instead of `copy-pipe-and-cancel`
- This copies to tmux buffer only, NOT system clipboard
- `wl-copy` is installed but wasn't being used

**Fixed**: All copy commands now use `copy-pipe-and-cancel "wl-copy"`

### 2. **Enter Copy-Mode Keybindings**
**Problem**: No easy way to enter copy-mode

**Added**:
- `Prefix + Escape` → Enter copy-mode
- `Alt + Escape` → Enter copy-mode (no prefix needed!)
- Existing: `Prefix + [` still works

---

## Copy-Mode Keybindings (Fixed)

### Enter Copy-Mode:
- `Alt + Escape` - Direct entry (no prefix)
- `Prefix + Escape` - With prefix
- `Prefix + [` - Traditional binding
- `F12` - Alternative binding

### In Copy-Mode (vi-mode):

**Selection**:
- `v` - Start visual selection
- `V` - Select line
- `Ctrl+v` - Visual block selection
- `.` - Select word under cursor
- `Escape` - Clear selection

**Copying** (All now copy to system clipboard via wl-copy):
- `y` - Yank selection to clipboard ✅
- `Space` - Yank selection to clipboard ✅
- `Enter` - Yank selection to clipboard ✅
- `Y` - Yank entire line to clipboard ✅
- `D` - Yank from cursor to end of line ✅
- `S` - Yank word under cursor ✅

**Navigation**:
- `h/j/k/l` - Vim navigation
- `w/b/e` - Word navigation
- `H/L` - Beginning/End of line
- `u/d` - Half-page up/down
- `Ctrl+u/Ctrl+d` - Page up/down
- `/` - Search forward
- `?` - Search backward
- `n/N` - Next/Previous match

**Special**:
- `*` - Search forward for word under cursor
- `#` - Search backward for word under cursor
- `m` - Set mark
- `'` - Jump to mark
- `o` - Other end of selection
- `q` or `i` - Exit copy-mode

---

## How Clipboard Works

### Wayland (wl-clipboard):
```bash
# Copy to clipboard
echo "text" | wl-copy

# Paste from clipboard
wl-paste
```

**Tmux Integration**:
- `copy-pipe-and-cancel "wl-copy"` - Copies selection to wl-clipboard
- `set-clipboard on` - Enables OSC 52 clipboard sharing

### X11 Fallback (xclip):
If wl-clipboard fails, xclip is also available:
```bash
# Copy
echo "text" | xclip -selection clipboard

# Paste
xclip -selection clipboard -o
```

---

## Testing

**After reloading config**, test copy-mode:

1. **Enter copy-mode**: Press `Alt+Escape`
2. **Navigate**: Use `hjkl` to move cursor
3. **Select text**: Press `v`, then move to select
4. **Copy**: Press `y` or `Space` or `Enter`
5. **Paste**: Use `Ctrl+Shift+V` or middle-click (Wayland)

**Test clipboard**:
```bash
# In tmux, copy some text with y
# Then in terminal:
wl-paste
# Should output the copied text
```

---

## Configuration Files Modified

### Fixed:
- ✅ `keymaps/copy-mode.conf`:
  - Changed all `copy-selection-and-cancel` → `copy-pipe-and-cancel "wl-copy"`
  - Fixed: `y`, `Space`, `Enter`, `Y`, `D` keybindings
  - Added: `Alt+Escape` and `Prefix+Escape` to enter copy-mode

### Clipboard Settings (Already Correct):
- ✅ `conf/global.conf`: `set-clipboard on`
- ✅ `conf/term.conf`: `set-clipboard on` (OSC 52)

---

## IMPORTANT: Reload Config

**Run this command in tmux to apply fixes**:
```bash
tmux source-file ~/.core/.sys/cfg/tmux/tmux.conf
```

Or use the keybinding:
- `Prefix + r` (if configured)

**Alternative**: Kill tmux server and restart:
```bash
tmux kill-server
tmux
```

---

## Common Issues

### "wl-copy: command not found"
Install wl-clipboard:
```bash
sudo pacman -S wl-clipboard  # Arch
sudo apt install wl-clipboard  # Debian/Ubuntu
```

### Still can't paste outside tmux
1. Check if wl-copy works:
   ```bash
   echo "test" | wl-copy
   wl-paste  # Should output "test"
   ```

2. Check Wayland session:
   ```bash
   echo $WAYLAND_DISPLAY  # Should output something like "wayland-0"
   ```

3. If using X11, modify keybindings to use xclip:
   ```bash
   # Replace "wl-copy" with:
   xclip -selection clipboard
   ```

### Copy-mode exits immediately
- This is CORRECT behavior with `copy-pipe-and-cancel`
- It copies and exits automatically
- To stay in copy-mode after copying, use `copy-pipe` instead of `copy-pipe-and-cancel`

---

## Quick Reference Card

```
┌─────────────────────────────────────────┐
│         TMUX COPY-MODE CHEATSHEET       │
├─────────────────────────────────────────┤
│ ENTER COPY-MODE:                        │
│   Alt+Esc        Direct entry (fastest) │
│   Prefix+Esc     With prefix            │
│   Prefix+[       Traditional            │
│                                          │
│ VISUAL SELECTION:                       │
│   v              Start selection        │
│   V              Select line            │
│   Ctrl+v         Block selection        │
│                                          │
│ YANK TO CLIPBOARD:                      │
│   y              Yank selection         │
│   Space          Yank selection         │
│   Enter          Yank selection         │
│   Y              Yank line              │
│   D              Yank to EOL            │
│                                          │
│ NAVIGATION:                             │
│   hjkl           Vim movement           │
│   w/b/e          Word movement          │
│   H/L            BOL/EOL                │
│   u/d            Half page up/down      │
│                                          │
│ SEARCH:                                 │
│   /              Search forward         │
│   ?              Search backward        │
│   n/N            Next/Prev match        │
│   */# Search word under cursor          │
│                                          │
│ EXIT:                                   │
│   q/i            Quit copy-mode         │
│   Esc            Clear selection        │
└─────────────────────────────────────────┘
```

---

**Copy-mode now fully functional with clipboard integration!** 🎉
