# Tmux Shared Library (modules/lib/)

**Purpose:** Centralized utility functions for tmux option management, display operations, and pane/window/session queries.

**Created:** 2025-12-09
**Status:** Active

---

## Overview

This library provides shared functions used across multiple tmux modules, eliminating code duplication and ensuring consistent behavior. All functions are designed to be sourced by other scripts and exported for use in subshells.

---

## Library Files

### tmux-core.sh
Core tmux option management functions.

**Functions:**
- `get_tmux_option(option, default)` - Get global option with fallback
- `set_tmux_option(option, value)` - Set global option
- `clear_tmux_option(option)` - Unset global option
- `get_window_option(option, default)` - Get window-scoped option
- `set_window_option(option, value)` - Set window-scoped option
- `clear_window_option(option)` - Unset window-scoped option
- `get_current_window()` - Get current window ID

**Usage:**
```bash
source "$TMUX_CONF/modules/lib/tmux-core.sh"

# Get option with default
width=$(get_tmux_option "@my-width" "30")

# Set option
set_tmux_option "@my-enabled" "1"

# Clear option
clear_tmux_option "@my-temp"
```

### tmux-display.sh
Display and messaging functions.

**Functions:**
- `display_message(message, duration_ms)` - Show temporary message
- `display_error(message)` - Show error (5s, red)
- `display_info(message)` - Show info (2s, blue)
- `display_success(message)` - Show success (2s, green)
- `display_warning(message)` - Show warning (3s, yellow)

**Dependencies:** tmux-core.sh (auto-sourced)

**Usage:**
```bash
source "$TMUX_CONF/modules/lib/tmux-display.sh"

display_success "Operation completed"
display_error "Failed to execute command"
display_info "Loading configuration..."
```

### tmux-panes.sh
Pane query and manipulation functions.

**Functions:**
- `pane_exists(pane_id, [window_id])` - Check if pane exists in window
- `pane_exists_globally(pane_id)` - Check if pane exists anywhere
- `get_current_pane()` - Get current pane ID
- `get_current_pane_path()` - Get current pane working directory
- `get_current_dir()` - Alias for get_current_pane_path()
- `get_pane_width([pane_id])` - Get pane width (defaults to current)
- `get_pane_height([pane_id])` - Get pane height (defaults to current)
- `get_pane_tty([pane_id])` - Get pane TTY
- `get_pane_pid([pane_id])` - Get pane process PID
- `get_pane_index([pane_id])` - Get pane index
- `is_pane_zoomed([pane_id])` - Check if pane is zoomed
- `get_pane_info([pane_id])` - Get formatted pane info

**Dependencies:** tmux-core.sh (auto-sourced)

**Usage:**
```bash
source "$TMUX_CONF/modules/lib/tmux-panes.sh"

pane=$(get_current_pane)
if pane_exists "$pane"; then
    width=$(get_pane_width "$pane")
    echo "Pane width: $width"
fi
```

### tmux-windows.sh
Window query and manipulation functions.

**Functions:**
- `window_exists(window_id, [session])` - Check if window exists
- `get_window_name([window_id])` - Get window name
- `get_window_index([window_id])` - Get window index
- `get_window_id(window_index, [session])` - Get window ID from index
- `list_windows([session])` - List all windows
- `get_window_layout([window_id])` - Get window layout string

**Dependencies:** tmux-core.sh (auto-sourced)

**Usage:**
```bash
source "$TMUX_CONF/modules/lib/tmux-windows.sh"

window=$(get_current_window)
name=$(get_window_name "$window")
echo "Current window: $name"
```

### tmux-sessions.sh
Session query and manipulation functions.

**Functions:**
- `session_exists(session_name)` - Check if session exists
- `get_current_session()` - Get current session name
- `get_current_session_id()` - Get current session ID
- `list_sessions()` - List all sessions with details
- `get_session_path([session])` - Get session working directory
- `create_detached_session(name, [dir])` - Create detached session
- `kill_session(session_name)` - Kill specified session

**Usage:**
```bash
source "$TMUX_CONF/modules/lib/tmux-sessions.sh"

if ! session_exists "my-session"; then
    create_detached_session "my-session" "/path/to/dir"
fi
```

### tmux-server.sh
Server-level operations and queries.

**Functions:**
- `server_running()` - Check if tmux server is running
- `get_socket_path()` - Get tmux socket path
- `get_tmux_version()` - Get tmux version string
- `compare_version(version, target)` - Compare version numbers
- `validate_tmux_version(required)` - Validate minimum version

**Usage:**
```bash
source "$TMUX_CONF/modules/lib/tmux-server.sh"

if validate_tmux_version "3.0"; then
    echo "Tmux version is sufficient"
fi

if server_running; then
    echo "Server is active"
fi
```

---

## Integration Patterns

### Pattern 1: Source Single Library
```bash
#!/usr/bin/env bash
source "$TMUX_CONF/modules/lib/tmux-core.sh"

width=$(get_tmux_option "@my-width" "30")
```

### Pattern 2: Source Multiple Libraries
```bash
#!/usr/bin/env bash
source "$TMUX_CONF/modules/lib/tmux-core.sh"
source "$TMUX_CONF/modules/lib/tmux-panes.sh"
source "$TMUX_CONF/modules/lib/tmux-display.sh"

pane=$(get_current_pane)
width=$(get_pane_width "$pane")
display_info "Pane width: $width"
```

### Pattern 3: Module with Fallback
```bash
#!/usr/bin/env bash
# Try to source shared library, fall back to local implementation
if [ -f "$TMUX_CONF/modules/lib/tmux-core.sh" ]; then
    source "$TMUX_CONF/modules/lib/tmux-core.sh"
else
    # Local fallback implementation
    get_tmux_option() {
        local option="$1"
        local default="${2:-}"
        tmux show-option -gqv "$option" || echo "$default"
    }
fi
```

---

## Design Principles

### 1. Single Responsibility
Each library file focuses on one domain (core options, display, panes, etc.)

### 2. No External Dependencies
Library functions only depend on tmux itself and bash builtins.

### 3. Fail-Safe Design
All functions handle errors gracefully and provide sensible defaults.

### 4. Export for Subshells
Functions are exported so they work in `tmux run-shell` contexts.

### 5. Self-Documenting
Function names clearly indicate their purpose and return values.

---

## Migration Guide

### Migrating from utils/tmux.sh

**Old (utils/tmux.sh):**
```bash
source "$TMUX_CONF/utils/tmux.sh"
value=$(get_tmux_option "status" "on")
```

**New (modules/lib/tmux-core.sh):**
```bash
source "$TMUX_CONF/modules/lib/tmux-core.sh"
value=$(get_tmux_option "status" "on")
```

The API is identical, just update the source path.

### Migrating Module-Specific Helpers

If your module has duplicated utility functions:

1. **Remove local implementation** of core functions
2. **Source shared library** at the top of your script
3. **Keep module-specific** business logic in local helpers

**Example:**
```bash
# modules/mymodule/helpers.sh

# Source shared library for core operations
source "$TMUX_CONF/modules/lib/tmux-core.sh"
source "$TMUX_CONF/modules/lib/tmux-panes.sh"

# Remove local get_tmux_option, pane_exists, etc.
# Keep only module-specific functions:

mymodule_calculate_layout() {
    # Module-specific logic here
}

mymodule_get_config() {
    # Module-specific logic here
}
```

---

## Testing

### Test Library Functions
```bash
# Reload tmux configuration
tmux source-file ~/.tmux/tmux.conf

# Test core functions
tmux run-shell "source ~/.tmux/modules/lib/tmux-core.sh && get_tmux_option 'status' 'off'"

# Test pane functions
tmux run-shell "source ~/.tmux/modules/lib/tmux-panes.sh && echo \$(get_current_pane)"

# Test display functions
tmux run-shell "source ~/.tmux/modules/lib/tmux-display.sh && display_success 'Test message'"
```

---

## Maintenance

### Adding New Functions

1. Determine appropriate library file (or create new one)
2. Implement function with clear naming
3. Add export statement at bottom of file
4. Document in this README
5. Test thoroughly

### Deprecating Functions

1. Mark function as deprecated in comments
2. Update README with migration path
3. Keep function for 1-2 releases
4. Remove after transition period

---

## Troubleshooting

### Functions Not Found

**Symptom:** `command not found: get_tmux_option`

**Solution:** Ensure library is sourced before use:
```bash
source "$TMUX_CONF/modules/lib/tmux-core.sh"
```

### TMUX_CONF Not Set

**Symptom:** Library files not found

**Solution:** Ensure `conf/env.conf` is loaded first:
```tmux
# In tmux.conf, must be first:
source-file "~/.tmux/conf/env.conf"
```

### Export Not Working

**Symptom:** Functions work in parent script but not in `tmux run-shell`

**Solution:** Ensure functions are exported:
```bash
export -f function_name
```

---

## Version History

- **v1.0** (2025-12-09) - Initial implementation
  - Created tmux-core.sh, tmux-display.sh, tmux-panes.sh
  - Created tmux-windows.sh, tmux-sessions.sh, tmux-server.sh
  - Consolidated 15+ duplicate implementations

---

## References

- Architecture Plan: `.docs/architecture-plan.md`
- Migration Checklist: `.docs/migration-checklist.md`
- Analysis Report: `.docs/analysis-report.md`
