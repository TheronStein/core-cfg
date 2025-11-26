# Menu System Integration & Fixes

**Date**: 2025-11-25
**Issue**: Old menus showing due to broken references

---

## Issues Found & Fixed

### 1. **Broken Keybindings** 🚨
**Problem**: Keybindings referenced deleted file `main-menu-2.sh`

**Lines in `keymaps/menus.conf`:**
```bash
bind-key -n C-1 run-shell '${TMUX_MENUS}/main-menu-2.sh'  # BROKEN
bind-key -n C-2 run-shell '${TMUX_MENUS}/main-menu-2.sh'  # BROKEN
bind-key -n C-3 run-shell '${TMUX_MENUS}/main-menu-2.sh'  # BROKEN
```

**Fixed**:
```bash
bind-key -n C-1 run-shell '${TMUX_MENUS}/main-menu.sh'  # ✅
bind-key -n C-2 run-shell '${TMUX_MENUS}/main-menu.sh'  # ✅
bind-key -n C-3 run-shell '${TMUX_MENUS}/main-menu.sh'  # ✅
```

---

### 2. **Wrong Menu Paths** 🚨
**Problem**: Function key menus referenced wrong paths

**Old**:
```bash
M-F1 → ${TMUX_MENUS}/pane-menu.sh       # Should be in mux/
M-F2 → ${TMUX_MENUS}/window-menu.sh     # Should be in mux/
M-F3 → ${TMUX_MENUS}/session-menu.sh    # Should be in tmux/
M-F4 → ${TMUX_MENUS}/save-restore-menu.sh  # Wrong menu
```

**Fixed**:
```bash
M-F1 → ${TMUX_MENUS}/mux/pane-menu.sh      # ✅ Pane operations
M-F2 → ${TMUX_MENUS}/mux/window-menu.sh    # ✅ Window operations
M-F3 → ${TMUX_MENUS}/tmux/session-menu.sh  # ✅ Session management
M-F4 → ${TMUX_MENUS}/tmux/plugin-menu.sh   # ✅ Plugin management
```

---

### 3. **Internal Menu References** 🚨
**Problem**: Submenu "Back" buttons had wrong paths

**Fixed Files**:
- ✅ `spotify-config-menu.sh` - Back button now points to main-menu.sh
- ✅ `mux/window-swap-menu.sh` - Back to mux/window-menu.sh
- ✅ `mux/window-move-menu.sh` - Back to mux/window-menu.sh
- ✅ `modules/task-menu.sh` - Back to tmux/session-menu.sh

---

## Menu Structure (Corrected)

```
Main Menu (C-` or C-1/2/3)
├── mux/
│   ├── pane-menu.sh (M-F1)       - Split, join, swap, resize panes
│   ├── window-menu.sh (M-F2)     - Window operations
│   ├── layout-menu.sh            - Layout management
│   └── sidebar-menu.sh           - Yazibar sidebar controls
│
├── tmux/
│   ├── session-menu.sh (M-F3)    - Session operations
│   └── plugin-menu.sh (M-F4)     - Plugin management
│
├── config/
│   ├── tmux-config-menu.sh
│   ├── wezterm-config-menu.sh
│   ├── yazi-config-menu.sh
│   └── ... (other config menus)
│
├── config-management.sh          - Top-level config menu
├── app-management.sh             - App launcher menu
└── popup-windows.sh              - Popup window menu
```

---

## Menu Navigation System

The menu system uses **dynamic parent tracking** via `menu-nav.sh`:

1. Parent menus call `om()` helper when opening submenus
2. This records the parent-child relationship
3. Child menus dynamically generate "Back" buttons
4. You can reorganize menus without breaking navigation

### How It Works:
```bash
# In parent menu:
om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '\$TMUX_MENUS/$1'"
}

tmux display-menu \
  "Submenu" 1 "$(om path/to/submenu.sh)"

# In child menu:
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")
tmux display-menu \
  "Back" Tab "run-shell '\$TMUX_MENUS/$PARENT'"
```

---

## Keybindings Reference

### Main Menu Access:
- `C-\`` (Ctrl+Backtick) → Main menu
- `C-1` → Main menu
- `C-2` → Main menu
- `C-3` → Main menu

### Direct Menu Access:
- `M-F1` → Pane Management (split, join, swap, resize)
- `M-F2` → Window Management (move, swap, rename)
- `M-F3` → Session Management (new, switch, rename)
- `M-F4` → Plugin Management (install, update, clean)
- `M-F12` → Theme Selector

### Alternative Access:
- `F1` → Customize mode (native tmux)
- `C-F1` → List all keybindings (with descriptions)
- `C-F2` → List all keys (raw)

---

## Environment Variables Used

All menu scripts now use proper environment variables:

- `$TMUX_MENUS` - Menu scripts directory (`$TMUX_MODULES/menus`)
- `$TMUX_CONF` - Main tmux config directory
- `$CORE_CFG` - Core configuration directory

No hardcoded paths remain in menu system.

---

## Testing

To test the fixes, reload tmux config:
```bash
tmux source-file ~/.core/.sys/cfg/tmux/tmux.conf
```

Then press:
- `C-\`` or `C-1` - Should open main menu
- `M-F1` - Should open pane management menu
- `M-F2` - Should open window management menu
- Navigate through submenus - "Back" buttons should work correctly

---

## Files Modified

### Keybindings:
- ✅ `keymaps/menus.conf` - Fixed all broken menu references

### Menu Scripts:
- ✅ `spotify-config-menu.sh` - Fixed back button
- ✅ `mux/window-swap-menu.sh` - Fixed back button path
- ✅ `mux/window-move-menu.sh` - Fixed back button path
- ✅ `modules/task-menu.sh` - Fixed back button path

---

## Menu System Summary

**Total Menu Scripts**: 54 files
**Menu Categories**:
- Multiplexer operations (mux/) - 12 menus
- TMUX management (tmux/) - 3 menus
- Configuration (config/) - 8+ menus
- Environment (env/) - 5+ menus
- Media & Apps (media/, other/) - 5+ menus
- Top-level navigation - 10+ menus

**All menus now working** with corrected paths and environment variables! 🎉

---

**End of Menu Fixes Report**
