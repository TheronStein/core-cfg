# Core-IDE Integration Fixes Applied

**Date:** 2025-12-06
**Status:** Ready for Testing

This document summarizes all fixes applied to get the Core-IDE environment into a working, testable state.

---

## ✅ Fixes Applied

### 1. **Fixed Syntax Error in yazibar-run-yazi.sh**

**File:** `/home/theron/.core/.sys/cfg/tmux/modules/yazibar/scripts/yazibar-run-yazi.sh`
**Line:** 80
**Issue:** Extra quote at end of `exec yazi` command
**Fix:** Removed trailing quote

```bash
# Before:
exec yazi "$START_DIR" --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose"

# After:
exec yazi "$START_DIR" --cwd-file=/tmp/yazi_cwd --chooser-file=/tmp/yazi_choose
```

---

### 2. **Verified Tmux Hook Fixes (Already Applied)**

**Files:**
- `/home/theron/.core/.sys/cfg/tmux/conf/hooks.conf`
- `/home/theron/.core/.sys/cfg/tmux/modules/yazibar/conf/hooks.conf`
- `/home/theron/.core/.sys/cfg/tmux/scripts/renumber-panes.sh`
- `/home/theron/.core/.sys/cfg/tmux/modules/yazibar/scripts/yazibar-left.sh`
- `/home/theron/.core/.sys/cfg/tmux/modules/yazibar/scripts/yazibar-right.sh`

**Root Causes Fixed by config-surgeon:**
1. Removed `window-resized` hook that created feedback loops
2. Added `@layout-restore-in-progress` guard flag to prevent recursive hook execution
3. Added guard flags during sidebar creation (lines 35-36 and 66-67 in yazibar-left.sh)
4. Updated `renumber-panes.sh` to skip locked (sidebar) panes
5. Standardized hook index allocation across all hook files
6. Disabled aggressive yazibar hooks that caused layout instability

---

### 3. **Created yazibar-sync.yazi Plugin**

**File:** `/home/theron/.core/.sys/cfg/yazi/plugins/yazibar-sync.yazi/init.lua`

**Purpose:** Publishes yazi hover and cd events to tmux options for sidebar synchronization

**Features:**
- Detects if running in left sidebar via `YAZIBAR_SIDE` environment variable
- Publishes hover events to `@yazibar-hovered`
- Publishes cd events to `@yazibar-current-dir`
- Properly escapes paths for shell execution
- Only runs in left sidebar (the publisher)

**Integration:** Already loaded by global init.lua at line 610

---

### 4. **Added DDS Support to yazibar-run-yazi.sh**

**File:** `/home/theron/.core/.sys/cfg/tmux/modules/yazibar/scripts/yazibar-run-yazi.sh`

**Changes:**
- Sets `YAZI_CONFIG_HOME` based on sidebar side (left vs right)
- Generates unique client ID for DDS: `yazibar-${SIDE}-$$`
- Left sidebar runs with `--local-events=hover,cd` for DDS event publishing
- Right sidebar runs in standard mode, receives commands via `ya emit-to`

---

### 5. **Created DDS Event Handler**

**File:** `/home/theron/.core/.sys/cfg/tmux/modules/yazibar/scripts/yazibar-dds-handler.sh`

**Purpose:** Reads yazi `--local-events` JSON output and syncs to right sidebar

**Features:**
- Parses JSON events (hover, cd)
- Publishes to tmux options for backwards compatibility
- Sends `:reveal` commands to right sidebar
- Logs events for debugging

**Note:** This is an enhanced alternative to the polling-based sync watcher. Both approaches will work.

---

### 6. **Added Socket-Awareness to Yazibar Module**

**File:** `/home/theron/.core/.sys/cfg/tmux/modules/yazibar/yazibar.tmux`
**Lines:** 45-51

**Changes:**
```bash
# Get Core-IDE context for socket isolation
CORE_IDE_CONTEXT="${CORE_IDE_CONTEXT:-default}"

# Use context-aware socket name for multi-workspace support
tmux set-option -gq @yazibar-server "core-ide-${CORE_IDE_CONTEXT}"
```

**Benefit:** Yazibar state is now isolated per Core-IDE workspace context

---

### 7. **Added Yazibar Status Indicators**

**File:** `/home/theron/.core/.sys/cfg/tmux/conf/status.conf`
**Lines:** 19-21, 58

**Changes:**
```bash
# Yazibar indicators: show when sidebars are active
tm_yazibar_left="#{?@yazibar-left-enabled-#{window_id},#[fg=#69FF94] ,}"
tm_yazibar_right="#{?@yazibar-right-enabled-#{window_id},#[fg=#01F9C6] ,}"
```

**Display:**
-  = Left sidebar active (green)
-  = Right sidebar active (cyan)

---

### 8. **Verified Menu System Scripts**

**Files:**
- `/home/theron/.core/.sys/cfg/tmux/events/vsplit.sh` ✓ Exists and executable
- `/home/theron/.core/.sys/cfg/tmux/events/hsplit.sh` ✓ Exists and executable

**Status:** All menu system dependencies verified

---

## 📋 What Was Already Working

The following were already properly configured (contrary to initial agent reports):

1. **Yazi Profiles** - Both `sidebar-left` and `sidebar-right` profiles exist with:
   - Proper ratio configurations (`[0,1,0]` and `[0,0,1]`)
   - Symlink inheritance from global config
   - Profile-specific `init.lua` for performance

2. **Tmux Hook System** - All hook fixes were already applied with proper comments

3. **Renumber Panes Script** - Already updated to skip locked panes

4. **WezTerm Integration** - Workspace isolation is functional

---

## 🧪 Testing Instructions

### 1. **Reload Tmux Configuration**

```bash
tmux source-file ~/.core/.sys/cfg/tmux/tmux.conf
```

### 2. **Test Sidebar Creation**

```bash
# Open left sidebar
Alt+f

# Open right sidebar
Alt+F
```

**Expected:**
- Left sidebar appears with yazi file list (ratio [0,1,0])
- Right sidebar appears with yazi preview (ratio [0,0,1])
- Status bar shows  and  indicators
- No automatic pane adjustments or bar offsets

### 3. **Test DDS Synchronization**

```bash
# With both sidebars open, navigate in left sidebar using i/k keys
```

**Expected:**
- Right sidebar preview updates automatically as you hover files
- No polling delay (or <100ms with polling approach)
- Tmux option `@yazibar-hovered` updates (check with: `tmux show-options -g | grep yazibar-hovered`)

### 4. **Test Socket Isolation**

```bash
# Set a different context
export CORE_IDE_CONTEXT="test-workspace"
tmux source-file ~/.core/.sys/cfg/tmux/modules/yazibar/yazibar.tmux

# Check socket name
tmux show-options -g | grep yazibar-server
```

**Expected:** Should show `@yazibar-server core-ide-test-workspace`

### 5. **Test Layout Stability**

```bash
# Create multiple panes
prefix + | (vertical split)
prefix + - (horizontal split)

# Toggle sidebars
Alt+f (left sidebar)
Alt+F (right sidebar)

# Kill a pane
prefix + x
```

**Expected:**
- No automatic layout adjustments
- Sidebars maintain their width
- Locked panes are not swapped during renumbering
- No feedback loops or infinite hook execution

### 6. **Check for Errors**

```bash
# Enable yazibar debug logging
tmux set-option -g @yazibar-debug 1

# Monitor debug log
tail -f ~/.local/share/tmux/yazibar/debug.log

# Check tmux hooks
tmux show-hooks -g
```

---

## 🐛 Debugging

If issues occur:

1. **Check Tmux Options:**
   ```bash
   tmux show-options -g | grep yazibar
   ```

2. **Verify Pane IDs:**
   ```bash
   # Should show left and right pane IDs
   tmux list-panes -F "#{pane_id} #{pane_title}"
   ```

3. **Test Yazi Profiles:**
   ```bash
   # Left sidebar profile
   YAZI_CONFIG_HOME=~/.core/.sys/cfg/yazi/profiles/sidebar-left yazi

   # Right sidebar profile
   YAZI_CONFIG_HOME=~/.core/.sys/cfg/yazi/profiles/sidebar-right yazi
   ```

4. **Check Hook Execution:**
   ```bash
   # Should not show recursive execution or errors
   tmux show-option -gv @layout-restore-in-progress
   ```

---

## 📚 Related Documentation

- **Yazi DDS Sync:** See `/home/theron/.core/.sys/cfg/tmux/modules/yazibar/yazi-notes.md`
- **Tmux Hook Architecture:** See `/home/theron/.core/.sys/cfg/tmux/conf/hooks.conf` header comments
- **Yazibar Module:** See `/home/theron/.core/.sys/cfg/tmux/modules/yazibar/README.md`
- **Integration Audit:** See agent reports from workflow-integration-planner, config-surgeon, and core-ide-architect

---

## ✨ Summary

All critical issues have been fixed and the Core-IDE environment is ready for testing. The integration between tmux, yazi, WezTerm, and other components should now work cohesively without:

- Automatic pane adjustments
- Bar offset issues
- Hook feedback loops
- Layout instability

The yazibar dual-sidebar system now has:
- Proper DDS event publishing
- Socket-aware state isolation
- Status bar indicators
- Clean hook management
