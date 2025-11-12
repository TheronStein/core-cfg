# Yazibar Module Architecture

## Overview

The Yazibar module provides a dual-sidebar system for tmux with real-time synchronization between yazi instances. Sidebars run in dedicated sessions on a separate tmux server for isolation and persistence.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│ Main Tmux Session (default server)                                  │
│ ┌─────────────┬──────────────────────────┬──────────────────────┐   │
│ │ Left        │ Main Work Area           │ Right                │   │
│ │ Sidebar     │                          │ Preview              │   │
│ │ (30%)       │   Editor / Terminal      │ (25%)                │   │
│ │             │                          │                      │   │
│ │ ┌─────────┐ │   ┌──────────────────┐   │   ┌──────────────┐   │   │
│ │ │ Window  │ │   │                  │   │   │ Window from  │   │   │
│ │ │ from    │ │   │  Active nvim     │   │   │ right-       │   │   │
│ │ │ left-   │ │   │  instance        │   │   │ sidebar      │   │   │
│ │ │ sidebar │ │   │                  │   │   │ session      │   │   │
│ │ │ session │ │   │  #{nvim_addr}    │   │   │              │   │   │
│ │ └─────────┘ │   │                  │   │   └──────────────┘   │   │
│ │             │   └──────────────────┘   │                      │   │
│ └─────────────┴──────────────────────────┴──────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
         │                                              │
         │ tmux attach -t                               │
         │ core-ide:left-sidebar                        │
         ├──────────────────┐              ┌────────────┤
         │                  │              │            │
         ▼                  ▼              ▼            ▼
┌─────────────────┐  ┌─────────────────────────────────────┐
│ core-ide server │  │ Input Sync: send-keys & hooks       │
│                 │  │ - Keypress on left → send to right  │
│ ├─ left-sidebar │  │ - Yazi DDS events → update CWD      │
│ │  ├─ window-0  │  │ - Hovered file → nvim address       │
│ │  └─ window-1  │  └─────────────────────────────────────┘
│ │                │
│ └─ right-sidebar│
│    ├─ window-0  │
│    └─ window-1  │
└─────────────────┘
```

## Core Components

### 1. Session Manager (`yazibar-session-manager.sh`)
- Creates/attaches to core-ide server
- Manages left-sidebar and right-sidebar sessions
- Handles session lifecycle (create, destroy, check)

### 2. Left Sidebar Manager (`yazibar-left.sh`)
- Creates left sidebar pane (30% width)
- Attaches window from core-ide:left-sidebar session
- Manages yazi instance with sidebar config
- Registers nvim addresses
- Updates CWD on navigation
- Locks width with layout-manager

### 3. Right Sidebar Manager (`yazibar-right.sh`)
- Creates right sidebar pane (25% width)
- Attaches window from core-ide:right-sidebar session
- Runs synchronized yazi instance
- Mirrors input from left sidebar
- Shows preview (child/parent directories)
- Active only when left sidebar is active

### 4. Width Persistence (`yazibar-width.sh`)
- Stores user-adjusted widths per directory
- Format: `directory<TAB>width<NEWLINE>`
- File: `~/.local/share/tmux/yazibar/widths.txt`
- Functions: get_width, set_width, restore_width

### 5. Nvim Address Registry (`yazibar-nvim.sh`)
- Detects active nvim instance in current pane/window
- Stores nvim socket address in tmux vars
- Updates yazi environment with `$NVIM_LISTEN_ADDRESS`
- Allows yazi to open files in active nvim

### 6. Input Synchronization (`yazibar-sync.sh`)
- Uses tmux hooks to capture input
- Sends keys from left sidebar to right sidebar
- Maintains synchronized state between yazi instances
- Hooks: `pane-focus-in`, `client-session-changed`

### 7. CWD Synchronization (`yazibar-cwd.sh`)
- Watches yazi DDS events for directory changes
- Updates shell CWD via escape sequences
- Format: `OSC 7` (Operating System Command 7)

### 8. Layout Manager Integration
- Locks sidebar widths to prevent layout disruption
- Restores dimensions after splits/resizes
- Per-sidebar lock tracking

## Session Architecture

### Server: `core-ide`
Dedicated tmux server for IDE components (sidebars, panels, etc.)

**Advantages**:
- Isolation from main tmux session
- Persistent across main session restarts
- Independent window/session management
- Can run multiple instances per workspace

### Session: `left-sidebar`
**Purpose**: File navigation with yazi

**Windows**:
- `window-0`: Default yazi instance
- `window-N`: Additional yazi instances per workspace/project

**Configuration**:
- Yazi config: `~/.core/cfg/yazi-sidebar/`
- Width: 30% (user-adjustable, persisted)
- Position: Full-height left split

### Session: `right-sidebar`
**Purpose**: Preview/parent directory display

**Windows**:
- `window-0`: Default preview instance
- `window-N`: Additional preview instances per workspace/project

**Configuration**:
- Yazi config: Same as left-sidebar (synchronized)
- Width: 25% (user-adjustable, persisted)
- Position: Full-height right split
- Input: Mirrored from left-sidebar

## Data Flow

### 1. Left Sidebar Activation
```
User: Alt+f
  └─> yazibar-left.sh toggle
        ├─> yazibar-session-manager.sh ensure left-sidebar
        │     └─> tmux new-session -s left-sidebar -d (if not exists)
        ├─> yazibar-width.sh get_width $(pwd)
        ├─> tmux split-window -fhb -l <width>
        ├─> tmux attach-pane -s core-ide:left-sidebar
        ├─> yazibar-nvim.sh register_current_nvim
        └─> layout-manager.sh lock-width <pane-id> <width>
```

### 2. Right Sidebar Activation
```
User: Alt+F
  └─> yazibar-right.sh toggle
        ├─> Check if left-sidebar is active
        │     └─> If not: display message, exit
        ├─> yazibar-session-manager.sh ensure right-sidebar
        ├─> yazibar-width.sh get_width $(pwd)
        ├─> tmux split-window -fh -l <width>
        ├─> tmux attach-pane -s core-ide:right-sidebar
        ├─> yazibar-sync.sh enable
        └─> layout-manager.sh lock-width <pane-id> <width>
```

### 3. Input Synchronization
```
User input in left sidebar
  └─> tmux hook: after-select-pane
        └─> yazibar-sync.sh check_left_focused
              ├─> Is left sidebar pane?
              │     └─> Yes: Enable key mirroring
              └─> tmux hook: client-key-pressed (or similar)
                    └─> Send key to right sidebar pane
```

### 4. CWD Update
```
Yazi navigates to directory
  └─> Yazi DDS event: cd
        └─> yazibar-cwd.sh update
              ├─> Read new directory from DDS
              ├─> Send OSC 7 escape sequence
              └─> Update tmux pane_current_path
```

### 5. Nvim Integration
```
File selected in yazi
  └─> Yazi opens file
        ├─> Check $NVIM_LISTEN_ADDRESS
        │     └─> If set: Use nvim RPC
        │           └─> nvim --server $NVIM_LISTEN_ADDRESS --remote <file>
        └─> Else: Open in new nvim instance
```

## File Structure

```
~/.core/cfg/tmux/modules/yazibar/
├── ARCHITECTURE.md           # This file
├── README.md                 # User-facing documentation
├── yazibar.tmux              # Main plugin loader
├── scripts/
│   ├── yazibar-session-manager.sh   # Session lifecycle
│   ├── yazibar-left.sh              # Left sidebar manager
│   ├── yazibar-right.sh             # Right sidebar manager
│   ├── yazibar-width.sh             # Width persistence
│   ├── yazibar-nvim.sh              # Nvim address registry
│   ├── yazibar-sync.sh              # Input synchronization
│   ├── yazibar-cwd.sh               # CWD synchronization
│   └── yazibar-utils.sh             # Shared utilities
├── conf/
│   ├── keybindings.conf      # Default keybindings
│   └── hooks.conf            # Tmux hooks
└── docs/
    ├── QUICKSTART.md         # Getting started guide
    ├── CONFIGURATION.md      # Configuration options
    ├── TROUBLESHOOTING.md    # Common issues
    └── [archived docs]       # Previous implementation docs
```

## Configuration Variables

### Tmux Options (set via `tmux set-option -g`)

```bash
# Session configuration
@yazibar-server "core-ide"
@yazibar-left-session "left-sidebar"
@yazibar-right-session "right-sidebar"

# Width configuration
@yazibar-left-width "30%"
@yazibar-right-width "25%"
@yazibar-width-file "~/.local/share/tmux/yazibar/widths.txt"

# Feature flags
@yazibar-sync-enabled "1"           # Enable input sync
@yazibar-cwd-sync-enabled "1"       # Enable CWD sync
@yazibar-nvim-integration "1"       # Enable nvim integration
@yazibar-right-needs-left "1"       # Right requires left active

# State tracking (internal)
@yazibar-left-enabled "0"           # Left sidebar enabled
@yazibar-right-enabled "0"          # Right sidebar enabled
@yazibar-left-pane-id ""            # Left sidebar pane ID
@yazibar-right-pane-id ""           # Right sidebar pane ID
@yazibar-current-nvim-addr ""       # Current nvim socket
```

## Implementation Phases

### Phase 1: Core Infrastructure ✓
- [x] Module structure
- [ ] Session manager
- [ ] Width persistence
- [ ] Basic left sidebar
- [ ] Basic right sidebar
- [ ] Layout manager integration

### Phase 2: Synchronization
- [ ] Input mirroring (send-keys)
- [ ] CWD tracking via DDS
- [ ] Yazi config sharing

### Phase 3: Nvim Integration
- [ ] Nvim address detection
- [ ] Socket registration
- [ ] File opening via RPC

### Phase 4: Polish
- [ ] Error handling
- [ ] Documentation
- [ ] Keybinding customization
- [ ] Testing & debugging

## Technical Considerations

### 1. Tmux Server Attachment
```bash
# Attach window from different server to current session
tmux split-window "tmux -L core-ide attach -t left-sidebar"
```

**Issue**: This creates a nested tmux session (tmux inside tmux)

**Solution**: Use `join-pane` or `link-window` instead
```bash
# Create window in core-ide server
tmux -L core-ide new-window -t left-sidebar:0 -d "yazi"

# Link window to current session (better approach)
# Note: This shares the window, not copies it
tmux link-window -s core-ide:left-sidebar:0 -t $(tmux display-message -p '#{session_name}'):99

# Or use named pipes / socket-based communication
```

**Best Approach**: Use `tmux respawn-pane` to run commands connected to remote session

### 2. Input Synchronization Methods

**Option A: tmux hooks + send-keys**
```bash
# Hook into pane-focus-in
tmux set-hook -g pane-focus-in 'run-shell "yazibar-sync.sh on_focus"'

# In yazibar-sync.sh
if is_left_sidebar_pane "$PANE_ID"; then
    # Every key pressed gets sent to right pane
    # Issue: No native hook for key presses
fi
```

**Option B: tmux pipe-pane**
```bash
# Mirror output from left to right (doesn't work for input)
tmux pipe-pane -t $LEFT_PANE "tee >(tmux send-keys -t $RIGHT_PANE)"
```

**Option C: Yazi DDS Events** (Recommended)
```bash
# Yazi publishes events via DDS (Data Distribution Service)
# Subscribe to events and mirror state

# In left sidebar yazi config:
[plugin]
prepend_fetchers = [
  { name = "sync-to-preview", run = "sync-preview" }
]

# sync-preview.yazi plugin sends DDS events
# Right sidebar yazi subscribes and mirrors state
```

### 3. Yazi Preview Synchronization

**Approach**: Use Yazi's DDS system to sync state

**Left Sidebar** (`~/.core/cfg/yazi-sidebar/init.lua`):
```lua
-- Publish hover events
local function publish_hover(url)
    local cmd = string.format(
        'tmux set-option -g @yazibar-hovered-file "%s"',
        url
    )
    os.execute(cmd)
end

return {
    setup = function(state)
        -- Hook into hover events
        state:subscribe("hover", publish_hover)
    end
}
```

**Right Sidebar** (watches `@yazibar-hovered-file`):
```bash
# Watcher script
while true; do
    file=$(tmux show-option -gv @yazibar-hovered-file)
    if [ "$file" != "$last_file" ]; then
        # Send command to right yazi to preview $file
        tmux send-keys -t $RIGHT_PANE ":preview $file" Enter
        last_file="$file"
    fi
    sleep 0.1
done
```

### 4. Width Persistence Format

**File**: `~/.local/share/tmux/yazibar/widths.txt`

```
/home/user/projects/foo    35
/home/user/documents       40
/tmp                       25
```

**Functions**:
```bash
get_width() {
    local dir="$1"
    local default="$2"
    grep "^${dir}[[:space:]]" "$WIDTH_FILE" | awk '{print $2}' || echo "$default"
}

set_width() {
    local dir="$1"
    local width="$2"
    # Update or append
    sed -i "/^${dir}[[:space:]]/d" "$WIDTH_FILE"
    echo "$dir    $width" >> "$WIDTH_FILE"
}
```

## Integration with Existing Code

### Migrate from `~/.core/cfg/tmux/scripts/`

**Current files to migrate**:
- `yazi-sidebar-manager.sh` → `yazibar-left.sh`
- `toggle-yazi-preview.sh` → `yazibar-right.sh`
- `yazi-sidebar-persistent.sh` → Integrate into `yazibar-left.sh`
- Keep: `layout-manager.sh` (stays in main scripts, used by module)

### Preserve `layout-manager.sh`
- Keep in `~/.core/cfg/tmux/scripts/`
- Used by yazibar and potentially other modules
- Yazibar calls it via absolute path

## Next Steps

1. Create module directory structure
2. Implement session manager
3. Implement left sidebar manager
4. Implement right sidebar manager
5. Add width persistence
6. Implement input synchronization
7. Add nvim integration
8. Write documentation
9. Test and debug
10. Update keybindings

---

**Version**: 1.0.0-alpha
**Author**: Claude Code + theron
**Date**: 2025-11-01
