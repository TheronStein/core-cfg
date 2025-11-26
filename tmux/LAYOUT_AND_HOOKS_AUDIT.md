# Tmux Layout & Hooks Audit Report

**Date**: 2025-11-25
**Audited By**: Claude Code
**Focus**: Layout handling, hook conflicts, sidebar dependencies, input sync

---

## 1. Layout Control Mechanism ✅

### Layout Manager (`scripts/layout-manager.sh`)
- **Purpose**: Preserves fixed-dimension panes during layout operations
- **Storage**: Uses tmux session variable `@locked-panes` (format: `pane_id:dimension:value`)
- **Operations**:
  - `lock-width/height` - Lock pane dimensions
  - `restore` - Restore all locked dimensions (triggered by hooks)
  - `cleanup` - Remove non-existent panes from lock list
  - `unlock` - Remove pane from lock list

### How It Works:
1. Sidebar scripts call `layout-manager.sh lock-width %5 30%`
2. Dimension stored in `@locked-panes` variable
3. Hooks trigger `restore` after any layout-affecting operation
4. Layout manager resizes locked panes back to saved dimensions

**Status**: ✅ Working correctly, well-designed system

---

## 2. Hook Execution Order ✅

Hooks use bracketed indices `[N]` to control execution order (lower runs first):

```
[0]  - Pane renumbering, layout cleanup
[2]  - Layout restoration after kill
[5]  - Yazibar window-scoped cleanup
[10] - Yazi sidebar cleanup (old system)
[12] - Right sidebar dependency check
[20] - GPG agent TTY refresh
```

**Hooks Defined** (43 total):
- **Layout Manager**: after-split-window, after-kill-pane[2], window-resized, after-select-layout, pane-exited
- **WezTerm Integration**: client-detached, session-closed, after-new-session, client-session-changed
- **Yazibar**: after-split-window[0], after-kill-pane[2,12], pane-exited[0,5]
- **Old Yazi Sidebar**: pane-exited[10] (disabled but still defined)
- **GPG Agent**: after-split-window[20], after-new-window[20]

**Status**: ✅ Proper ordering, but see conflicts below

---

## 3. 🚨 CRITICAL ISSUE: Duplicate Hook Definitions

### Problem:
**Hooks are defined in TWO places:**

1. **`conf/hooks.conf`** (loaded first from tmux.conf)
   - Layout manager hooks
   - Old yazi-sidebar hooks (disabled)
   - WezTerm integration hooks

2. **`modules/yazibar/conf/hooks.conf`** (loaded second via yazibar.tmux)
   - Layout manager hooks (DUPLICATE!)
   - Yazibar-specific hooks

### Duplicate Hooks:
```bash
# Both files define:
after-split-window[0]  → layout-manager.sh restore
after-kill-pane[2]     → layout-manager.sh restore
pane-exited[0]         → layout-manager.sh cleanup
window-resized[0]      → layout-manager.sh restore
```

### Impact:
- **Layout manager runs TWICE** per event (inefficient, potential race conditions)
- **Hook indices may conflict** (both use [0], [2], etc.)
- **Maintenance burden** (must update hooks in two places)

### Recommendation:
**CONSOLIDATE HOOKS** - Remove layout manager hooks from yazibar/conf/hooks.conf, keep only yazibar-specific hooks there.

---

## 4. Sidebar Dependency Handling ✅⚠️

### Right Sidebar Dependency on Left:
Controlled by `@yazibar-right-needs-left` option (default: "1")

**When Left Sidebar is Disabled/Killed:**
1. `yazibar-left.sh disable` checks if right is enabled
2. If `@yazibar-right-needs-left == 1`, calls `yazibar-right.sh disable`
3. Right sidebar pane is killed, layout restored

**When Right Sidebar Checks Dependency:**
- Hook: `after-kill-pane[12]` runs `yazibar-right.sh check-dependency`
- Checks if left sidebar still exists
- If not, disables right sidebar

**Per-Window Scoping:**
- Each window tracks its own sidebar state
- Uses `@yazibar-{left|right}-enabled-${window_id}`
- Different windows can have different sidebar configurations

**Status**: ✅ Properly handles dependency, ⚠️ but see layout behavior below

---

## 5. Layout Behavior When Closing One Sidebar ⚠️

### Current Behavior:

**Scenario 1: Close Left Sidebar (Right is Open)**
```
Before: [Left 30%] [Main 45%] [Right 25%]
Action: Close left (Alt+f or kill pane)
After:  [Main 75%] [Right 25%]  ← Right survives if right-needs-left=0
After:  [Main 100%]             ← Right also closes if right-needs-left=1 (default)
```

**Scenario 2: Close Right Sidebar (Left is Open)**
```
Before: [Left 30%] [Main 45%] [Right 25%]
Action: Close right (Alt+F or kill pane)
After:  [Left 30%] [Main 70%]  ← Left survives, dimensions locked
```

**Hooks Triggered:**
1. `pane-exited[0]` → `layout-manager.sh cleanup` (removes dead pane from lock list)
2. `after-kill-pane[2]` → `layout-manager.sh restore` (restores remaining locked panes)
3. `after-kill-pane[12]` → `yazibar-right.sh check-dependency` (if right killed)
4. `pane-exited[5]` → Yazibar window cleanup (clears tracking variables)

**Potential Issues:**
- ⚠️ **No automatic resize** of remaining panes to fill space optimally
- ✅ **Locked dimensions preserved** correctly
- ⚠️ **Main pane may be too narrow** if both sidebars were open

**Status**: ⚠️ Works but may not resize optimally

---

## 6. Input Synchronization Between Sidebars ✅

### Mechanism:
- **Script**: `yazibar-sync.sh` (enable/disable/toggle)
- **Watcher**: `yazibar-sync-watcher.sh` (background process)
- **State**: Window-scoped (`@yazibar-sync-active-${window_id}`)

### How Sync Works:
1. Left sidebar hovered file published to `@yazibar-hovered`
2. Watcher polls this value every 0.1s
3. When changed, sends `:reveal 'path'` to right sidebar
4. Right sidebar (ratio [0,0,1]) shows preview of revealed file

### Lifecycle:
- **Enable**: Background watcher started, PID stored in `@yazibar-sync-watcher-pid-${window_id}`
- **Disable**: Watcher process killed
- **Auto-Stop**: Watcher exits if either pane disappears or sync disabled

**Status**: ✅ Properly implemented, window-scoped

---

## 7. Broken Links & Unused Files

### Broken Symlinks Found:
```
/home/theron/.core/.sys/cfg/tmux/plugins/tmux-resurrect/run_tests
/home/theron/.core/.sys/cfg/tmux/plugins/tmux-resurrect/tests/helpers/helpers.sh
/home/theron/.core/.sys/cfg/tmux/plugins/tmux-resurrect/tests/run_tests_in_isolation
```
**Impact**: None (test files only)

### Potentially Unused Files:
- `conf/new-hooks.conf` - Not sourced anywhere
- `scripts/toggle-yazi-sidebar.sh` - Old implementation, yazibar replaces this
- `scripts/yazi-sidebar-manager.sh` - Old implementation, yazibar replaces this
- `scripts/yazi-sidebar-persistent.sh` - Old implementation
- `scripts/toggle-yazi-preview.sh` - Old implementation

**Status**: ⚠️ Old yazi scripts should be archived/removed to avoid confusion

---

## 8. Other Integration Points

### Plugins That May Affect Layout:
- **tmux-resurrect**: Saves/restores sessions (may conflict with locked panes?)
- **tmux-continuum**: Auto-saves sessions
- **tmux-sidebar** (if present): Would conflict with yazibar

### Layout Triggering Operations:
✅ **Covered by hooks:**
- Split pane (after-split-window)
- Kill pane (after-kill-pane, pane-exited)
- Resize window (window-resized)
- Select layout (after-select-layout)

❓ **NOT explicitly covered:**
- `join-pane` - May affect layout without triggering restore
- `break-pane` - May affect layout without triggering restore
- `swap-pane` - Doesn't change dimensions but changes positions
- `resize-pane` - User manual resize (intentional, shouldn't restore)

---

## Summary & Recommendations

### ✅ Working Well:
1. Layout manager system is solid
2. Hook execution order is well-designed
3. Sidebar dependency handling works correctly
4. Input sync is properly implemented
5. Window-scoped state management

### 🚨 Critical Issues:
1. **Duplicate hook definitions** - Must consolidate to avoid double execution

### ⚠️ Improvements Needed:
1. **Hook coverage gaps** - Add hooks for join-pane, break-pane if needed
2. **Layout optimization** - Sidebar closure doesn't optimally resize remaining panes
3. **Old script cleanup** - Archive/remove old yazi-sidebar scripts
4. **Documentation** - Add inline comments explaining hook indices

### 🔧 Recommended Actions:
1. **Remove duplicate layout manager hooks from yazibar/conf/hooks.conf**
2. **Add hooks for join-pane and break-pane** if layout locking needs to survive these
3. **Archive old yazi scripts** to `scripts/.archv/yazi-old/`
4. **Test tmux-resurrect compatibility** with locked panes
5. **Document hook execution order** in hooks.conf header

---

## Testing Checklist

- [ ] Open left sidebar → verify locked width
- [ ] Open right sidebar → verify locked width + sync enabled
- [ ] Kill left sidebar → verify right closes (if needs-left=1)
- [ ] Kill right sidebar → verify left survives with locked width
- [ ] Split new pane → verify sidebars maintain locked dimensions
- [ ] Resize window → verify sidebars restore to locked dimensions
- [ ] Change layout → verify sidebars restore to locked dimensions
- [ ] Close all sidebars → verify main pane fills window
- [ ] Test with right-needs-left=0 → verify right survives left closure
- [ ] Test input sync → verify right mirrors left navigation
- [ ] Test tmux-resurrect → verify session restore with locked panes

---

**End of Audit Report**
