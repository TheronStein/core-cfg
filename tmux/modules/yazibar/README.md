# Yazibar - Dual Yazi Sidebar Module for Tmux

A sophisticated tmux module providing persistent, synchronized dual sidebars powered by [yazi](https://github.com/sxyazi/yazi) file manager.

## Features

- **Dual Sidebars**: Left sidebar for file navigation, right sidebar for preview
- **Session-Based Architecture**: Sidebars run in dedicated sessions on `core-ide` server
- **Layout Persistence**: Locked dimensions that resist layout changes
- **Width Memory**: User-adjusted widths saved per directory
- **Input Synchronization**: Right sidebar mirrors left sidebar navigation
- **Nvim Integration**: Open files in active nvim instance
- **CWD Tracking**: Shell working directory updates with yazi navigation

## Architecture

```
Main Session                    core-ide Server
┌──────────────────┐           ┌─────────────────┐
│ ┌──┬───────┬───┐ │           │ left-sidebar    │
│ │L │       │ R │ │◄─────────►│ right-sidebar   │
│ │  │ Work  │   │ │           └─────────────────┘
│ │30│ Area  │25%│ │
│ └──┴───────┴───┘ │           Layout Manager
└──────────────────┘           ┌─────────────────┐
                               │ Locks dimensions│
                               │ Restores layout │
                               └─────────────────┘
```

## Quick Start

### Installation

1. **Load the module** in your tmux config:

```tmux
# Add to ~/.core/cfg/tmux/tmux.conf
run-shell "~/.core/cfg/tmux/modules/yazibar/yazibar.tmux"
```

2. **Reload tmux config**:

```bash
tmux source-file ~/.core/cfg/tmux/tmux.conf
```

### Basic Usage

| Key | Action |
|-----|--------|
| `Alt+f` | Toggle left sidebar (yazi file browser) |
| `Alt+F` | Toggle right sidebar (preview) |
| `Alt+g` | Focus left sidebar |
| `Alt+G` | Focus right sidebar |
| `Alt+S` | Toggle input synchronization |
| `Alt+?` | Show yazibar status |

### First Run

1. **Open left sidebar**: Press `Alt+f`
   - Creates left sidebar at 30% width
   - Runs yazi file browser
   - Locks width with layout manager

2. **Open right sidebar**: Press `Alt+F` (Shift+Alt+f)
   - Requires left sidebar to be active
   - Creates right sidebar at 25% width
   - Synchronizes with left sidebar

3. **Navigate**: Use yazi keybindings in left sidebar
   - Right sidebar automatically follows
   - CWD updates as you navigate

## Configuration

### Tmux Options

Set these in your tmux config before loading yazibar:

```tmux
# Server and session names
set -g @yazibar-server "core-ide"
set -g @yazibar-left-session "left-sidebar"
set -g @yazibar-right-session "right-sidebar"

# Default widths
set -g @yazibar-left-width "30%"
set -g @yazibar-right-width "25%"

# Feature flags
set -g @yazibar-right-needs-left "1"  # Right requires left active
set -g @yazibar-debug "0"             # Enable debug logging
```

### Width Persistence

Sidebar widths are automatically saved per directory:

```bash
# Widths stored in:
~/.local/share/tmux/yazibar/widths.txt

# Format:
/home/user/projects    left     35
/home/user/documents   left     40
/home/user/projects    right    30
```

### Custom Keybindings

Override default keybindings in your tmux config:

```tmux
# Custom keybindings (add after loading yazibar)
bind -n C-f run-shell "$HOME/.core/cfg/tmux/modules/yazibar/scripts/yazibar-left.sh toggle"
bind -n C-p run-shell "$HOME/.core/cfg/tmux/modules/yazibar/scripts/yazibar-right.sh toggle"
```

## Advanced Usage

### Resize Sidebars

**Method 1: Keybindings**

- `Alt+Backspace` / `Alt+\` - Resize left sidebar
- `Alt+[` / `Alt+]` - Resize right sidebar

**Method 2: Direct commands**

```bash
# Resize left sidebar to 40 columns
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-left.sh resize 40

# Resize right sidebar to 30%
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-right.sh resize 30%
```

### Nvim Integration

```bash
# Register current nvim instance
Alt+n

# Check nvim status
Alt+N

# From yazi, files will open in registered nvim instance
# Set by environment variable: $NVIM_LISTEN_ADDRESS
```

### Session Management

```bash
# Show session status
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-session-manager.sh status

# Cleanup sessions (removes all yazibar sessions)
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-session-manager.sh cleanup
# Or: Alt+Ctrl+c
```

### Width Management

```bash
# List all saved widths
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-width.sh list

# Cleanup entries for deleted directories
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-width.sh cleanup
```

## Troubleshooting

### Left sidebar won't open

**Check**:
1. Yazi is installed: `which yazi`
2. Yazi sidebar config exists: `~/.core/cfg/yazi-sidebar/`
3. Layout manager exists: `~/.core/cfg/tmux/scripts/layout-manager.sh`

**Debug**:
```bash
# Enable debug logging
tmux set -g @yazibar-debug "1"

# Check debug log
tail -f ~/.local/share/tmux/yazibar/debug.log
```

### Right sidebar requires left sidebar

This is intentional! The right sidebar is a preview/sync sidebar that depends on the left.

**To allow independent right sidebar**:
```tmux
set -g @yazibar-right-needs-left "0"
```

### Sidebars not syncing

**Check sync status**:
```bash
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-sync.sh status
```

**Enable sync**:
```bash
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-sync.sh enable
# Or: Alt+S
```

### Widths not persisting

**Check width file**:
```bash
cat ~/.local/share/tmux/yazibar/widths.txt
```

**Manually save width**:
```bash
# Save current left sidebar width
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-width.sh save-current %5 left
```

### Nvim files not opening

**Check nvim address**:
```bash
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-nvim.sh status
```

**Register nvim**:
```bash
~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-nvim.sh register
# Or: Alt+n
```

## File Structure

```
yazibar/
├── ARCHITECTURE.md           # Detailed architecture documentation
├── README.md                 # This file
├── yazibar.tmux              # Main plugin loader
├── scripts/
│   ├── yazibar-utils.sh      # Shared utilities
│   ├── yazibar-session-manager.sh   # Session lifecycle
│   ├── yazibar-left.sh       # Left sidebar manager
│   ├── yazibar-right.sh      # Right sidebar manager
│   ├── yazibar-width.sh      # Width persistence
│   ├── yazibar-nvim.sh       # Nvim integration
│   ├── yazibar-sync.sh       # Input synchronization
│   ├── yazibar-sync-watcher.sh  # Sync background process
│   └── yazibar-run-yazi.sh   # Yazi runner with CWD sync
├── conf/
│   ├── keybindings.conf      # Default keybindings
│   └── hooks.conf            # Tmux hooks
└── docs/
    └── .archived/            # Previous implementation
```

## Dependencies

- **Required**:
  - tmux >= 3.0
  - [yazi](https://github.com/sxyazi/yazi) file manager
  - bash >= 4.0

- **Optional**:
  - nvim with RPC support (for file opening integration)
  - [layout-manager.sh](../../scripts/layout-manager.sh) (for dimension locking)

## Integration with Existing Setup

Yazibar is designed to work alongside your existing tmux configuration:

- Uses dedicated server (`core-ide`) to avoid conflicts
- Hooks are ordered to run after other operations
- Layout manager integration is optional but recommended
- Can coexist with other sidebar plugins

## Performance

- **Lazy initialization**: Sessions created on first use
- **Background sync**: Watcher runs as separate process
- **Cached widths**: File I/O only on changes
- **Minimal hooks**: Only essential events tracked

## Limitations

1. **Tmux version**: Requires tmux 3.0+
2. **Server dependency**: Sidebars need core-ide server running
3. **Sync delay**: ~100ms polling interval for sync watcher
4. **Width precision**: Percentages rounded to integer columns
5. **Single workspace**: Currently one sidebar per main session

## Future Enhancements

- [ ] Multiple workspace support (different sidebars per project)
- [ ] Yazi plugin for better DDS integration
- [ ] Real-time input mirroring (no polling delay)
- [ ] Preview mode toggle (child/parent/off)
- [ ] Sidebar themes and customization
- [ ] Integration with tmux-resurrect
- [ ] GUI for sidebar management

## See Also

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Detailed architecture documentation
- [Yazi documentation](https://yazi-rs.github.io/)
- [Layout Manager](../../scripts/layout-manager.sh) - Dimension locking system

## License

Part of the .core tmux configuration.

## Contributing

This is a personal configuration module. Adapt and modify as needed for your setup.

---

**Version**: 1.0.0-alpha
**Author**: theron + Claude Code
**Date**: 2025-11-01
