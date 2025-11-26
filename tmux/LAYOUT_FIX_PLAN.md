# Tmux Layout & Hook Fixes - Action Plan

**Date**: 2025-11-25
**Priority**: High - Duplicate hooks causing inefficiency and potential conflicts

---

## Issues Identified

### 1. 🚨 CRITICAL: Duplicate Hook Definitions
**Problem**: Layout manager hooks defined in BOTH:
- `/conf/hooks.conf` (loaded first)
- `/modules/yazibar/conf/hooks.conf` (loaded second)

**Impact**:
- Layout manager runs TWICE per event (2x inefficiency)
- Race conditions possible
- Maintenance burden

### 2. ⚠️ Missing Hook Coverage
**Operations NOT covered by layout restoration hooks:**
- `join-pane` - Merges pane from another window
- `break-pane` - Breaks pane into new window
- `swap-pane` - Swaps two panes
These operations can affect layout but don't trigger `restore`

### 3. ⚠️ Layout-Affecting Options
**Found**:
- `aggressive-resize on` (windows.conf:21) - Affects window resize behavior
- `window-style` and `window-active-style` (panes.conf) - Cosmetic only
- `pane-border-status top` (panes.conf:10) - Takes vertical space

**Impact**: `aggressive-resize on` may cause unexpected resizes with multiple clients

### 4. ⚠️ Old Scripts Present
**Old yazi-sidebar implementation still in scripts/**:
- `toggle-yazi-sidebar.sh` - Replaced by yazibar
- `yazi-sidebar-manager.sh` - Replaced by yazibar
- `yazi-sidebar-persistent.sh` - Replaced by yazibar
- `toggle-yazi-preview.sh` - Replaced by yazibar
These may confuse users and maintainers

---

## Fix Plan

### Fix 1: Remove Duplicate Hooks from Yazibar

**File**: `modules/yazibar/conf/hooks.conf`

**Remove these duplicate hooks** (already in conf/hooks.conf):
```bash
set-hook -g after-split-window[0] "..."  # DUPLICATE - remove
set-hook -g after-kill-pane[2] "..."     # DUPLICATE - remove
set-hook -g pane-exited[0] "..."         # DUPLICATE - remove
set-hook -g window-resized[0] "..."      # DUPLICATE - remove
```

**Keep yazibar-specific hooks**:
```bash
set-hook -g after-kill-pane[12] "..."    # Yazibar dependency check - keep
set-hook -g pane-exited[5] "..."         # Yazibar window cleanup - keep
```

**Result**: Layout manager runs once per event, yazibar hooks coexist peacefully

---

### Fix 2: Add Missing Layout Restoration Hooks

**File**: `conf/hooks.conf`

**Add these hooks after existing layout manager hooks**:
```bash
# Restore locked dimensions after join/break/swap operations
set-hook -g after-join-pane 'run-shell "$TMUX_CONF/scripts/layout-manager.sh restore"'
set-hook -g after-break-pane 'run-shell "$TMUX_CONF/scripts/layout-manager.sh restore"'
set-hook -g after-swap-pane 'run-shell "$TMUX_CONF/scripts/layout-manager.sh restore"'
```

**Result**: Locked pane dimensions survive join/break/swap operations

---

### Fix 3: Document Aggressive-Resize Impact

**File**: `conf/windows.conf`

**Add comment**:
```bash
# aggressive-resize: When multiple clients attached, resize window to smallest
# Impact: May cause unexpected resizes when different clients view same session
# Note: Works with layout-manager locked panes (restore hook fires on resize)
set -wg aggressive-resize on
```

**Alternative**: Consider setting to `off` if multi-client resize issues occur

---

### Fix 4: Archive Old Yazi Scripts

**Create archive directory**:
```bash
mkdir -p $TMUX_CONF/scripts/.archv/yazi-old/
```

**Move old scripts**:
```bash
mv scripts/toggle-yazi-sidebar.sh scripts/.archv/yazi-old/
mv scripts/yazi-sidebar-manager.sh scripts/.archv/yazi-old/
mv scripts/yazi-sidebar-persistent.sh scripts/.archv/yazi-old/
mv scripts/toggle-yazi-preview.sh scripts/.archv/yazi-old/
mv scripts/yazi-preview-*.sh scripts/.archv/yazi-old/  # Keep for reference
```

**Update hooks.conf**: Comment out or remove references to old scripts

**Result**: Clean scripts/ directory, old code preserved for reference

---

## Implementation Order

1. ✅ **Create audit report** (DONE)
2. ✅ **Create fix plan** (DONE)
3. ⏳ **Remove duplicate hooks from yazibar/conf/hooks.conf**
4. ⏳ **Add missing hooks to conf/hooks.conf**
5. ⏳ **Document aggressive-resize in windows.conf**
6. ⏳ **Archive old yazi scripts**
7. ⏳ **Test all scenarios**
8. ⏳ **Update documentation**

---

## Testing Checklist

After implementing fixes, test these scenarios:

### Basic Sidebar Operations
- [ ] Toggle left sidebar (Alt+f) - verify locked width
- [ ] Toggle right sidebar (Alt+F) - verify locked width + dependency
- [ ] Close left first - verify right closes (if needs-left=1)
- [ ] Close right first - verify left stays with locked width

### Layout Operations (verify sidebars survive)
- [ ] Split pane (horizontal/vertical)
- [ ] Kill pane
- [ ] Resize window
- [ ] Change layout (tiled/even-horizontal/etc)
- [ ] Join pane from another window
- [ ] Break pane to new window
- [ ] Swap panes

### Multi-Client (aggressive-resize testing)
- [ ] Attach second client with different terminal size
- [ ] Verify sidebars maintain locked dimensions
- [ ] Switch between clients, verify no layout corruption

### Edge Cases
- [ ] Open/close sidebars in multiple windows
- [ ] Test with tmux-resurrect save/restore
- [ ] Test with right-needs-left=0
- [ ] Kill all panes except sidebar (should unlock and expand)

---

## Expected Outcomes

### Performance
- ✅ Layout manager runs **once** per event (not twice)
- ✅ Faster hook execution
- ✅ No race conditions from duplicate hooks

### Reliability
- ✅ Locked dimensions survive **all** layout operations
- ✅ Sidebars work correctly with aggressive-resize
- ✅ No conflicts between old and new yazi implementations

### Maintainability
- ✅ Clear separation: global hooks vs yazibar hooks
- ✅ Easy to find and modify layout hooks (single location)
- ✅ Old code archived, not mixed with new

---

## Rollback Plan

If issues occur:
1. Restore yazibar/conf/hooks.conf from backup
2. Remove new hooks from conf/hooks.conf
3. Restore old scripts from .archv/
4. Report issues in `LAYOUT_AND_HOOKS_AUDIT.md`

---

**End of Fix Plan**
