# Core-IDE: Integrated Workspace Environment Agent

### 1. Configuration Analysis & Discovery

**CRITICAL FIRST STEP**: Before making any changes, thoroughly analyze the existing Core-IDE (`~/.core`) structure:

1. **Map the complete directory structure:**

```bash
   tree -L 3 ~/.core
```

Document the actual organization, naming conventions, and file locations.

2. **Understand the current organization philosophy:**
   - How are configs grouped? (by tool, by function, by category?)
   - What naming conventions are used?
   - Are there any README or documentation files explaining the structure?
   - What's the relationship between `~/.core` and standard XDG paths?

3. **Identify all configuration files:**
   - Tmux: Find actual location of tmux.conf and related files
   - WezTerm: Find wezterm.lua location
   - Yazi: Find yazi config directory
   - Neovim: Find nvim config directory
   - Zsh: Find .zshrc and related files
   - Any other integrated tools

4. **Respect the existing structure:**
   - DO NOT reorganize without explicit permission
   - Work within the established patterns
   - Preserve any existing organizational logic
   - New integration files should follow existing conventions

5. **Document findings before proceeding:**
   - Create a map of current structure
   - Note any apparent organizational principles
   - Identify where integration scripts should live
   - Ask for clarification if structure is ambiguous

## Project Overview

Analyze and integrate tmux, WezTerm, yazi, and Neovim configurations to create **Core-IDE** - a seamless, persistent workspace environment with yazi sidebars as permanent tmux panes. Uses multiple tmux server sockets for workspace isolation and specialized integrations. This targets an advanced Arch Linux user with Hyprland who maintains dotfiles under `~/.core/` structure.

## Core-IDE Architecture

### Multi-Socket Design Philosophy

Core-IDE uses separate tmux server sockets to provide clean isolation between different workspace contexts:

**Primary Server Sockets:**

- **core-ide-main**: Default workspace for general development (socket: `/tmp/tmux-core-ide-main`)
- **core-ide-work**: Professional/work-specific projects (socket: `/tmp/tmux-core-ide-work`)
- **core-ide-personal**: Personal projects and experiments (socket: `/tmp/tmux-core-ide-personal`)
- **core-ide-research**: Research, documentation, learning (socket: `/tmp/tmux-core-ide-research`)

**Integration Server Sockets:**

- **core-ide-system**: System administration and monitoring (socket: `/tmp/tmux-core-ide-system`)
- **core-ide-remote**: Remote SSH sessions and infrastructure (socket: `/tmp/tmux-core-ide-remote`)
- **core-ide-build**: Long-running builds and compilation tasks (socket: `/tmp/tmux-core-ide-build`)
- **core-ide-debug**: Debugging sessions with isolated state (socket: `/tmp/tmux-core-ide-debug`)

**Benefits of Socket Isolation:**

- Complete session independence (keybindings, options, state)
- No cross-contamination between workspace contexts
- Parallel operation without interference
- Easier context switching and mental model separation
- Granular control over resource allocation per workspace
- Clean shutdown/restart of individual contexts
- Simplified backup and state management per socket

## Primary Objectives

### 1. Configuration Analysis & Discovery

Analyze existing configurations to understand:

- **Tmux**: Current layouts, keybindings, hooks, session management, plugin usage (TPM), existing socket usage
- **WezTerm**: Multiplexer integration, SSH domains, pane management, keybindings, socket connection handling
- **Yazi**: Keybindings, plugins, opener configurations, preview settings, theme
- **Neovim**: File explorer usage, window management, terminal integration, keybindings, remote control capabilities
- Identify configuration locations, loading order, and interdependencies
- Document current workflow patterns and pain points
- Map existing keybinding conflicts across all tools
- Audit existing tmux server usage and socket paths

### 2. Server Socket Architecture Implementation

**Socket Management System:**
Create centralized socket management infrastructure:

```bash
# Socket directory structure
~/.local/state/core-ide/sockets/
  ├── active/          # Currently running sockets
  ├── registry         # Socket registry with metadata
  └── locks/           # Socket lock files
```

**Socket Configuration:**

- Unique socket path per workspace context
- Socket naming convention: `tmux-core-ide-{context}`
- Socket ownership and permission management
- Automatic socket cleanup on exit
- Socket health monitoring and recovery

**Socket Manager Commands:**
Create wrapper scripts/functions:

- `core-ide-launch <context>`: Start specific Core-IDE workspace
- `core-ide-switch <context>`: Switch between active workspaces
- `core-ide-list`: Show all active Core-IDE sockets
- `core-ide-status`: Display status of all workspaces
- `core-ide-kill <context>`: Cleanly shutdown workspace
- `core-ide-killall`: Shutdown all Core-IDE instances

**WezTerm Integration:**

- WezTerm workspace switcher connects to appropriate socket
- Tab/window spawning targets correct socket context
- Visual indicators showing which Core-IDE context is active
- Keybindings to switch between Core-IDE contexts
- WezTerm mux domains mapped to Core-IDE sockets

**Cross-Socket Communication:**
When necessary, implement:

- IPC mechanism for cross-workspace operations
- Shared clipboard buffer between sockets
- Centralized notification system
- Resource sharing (build caches, temporary files)
- Unified session registry

### 3. Yazi Sidebar Integration Architecture

Design and implement persistent yazi sidebars within tmux (per-socket):

**Layout Structure (Per Socket):**

- Left sidebar: Primary yazi instance (20-25% width, adjustable)
- Center workspace: Main editing/terminal area (flexible width)
- Right sidebar: Secondary yazi instance or context viewer (20-25% width, adjustable)
- Sidebars persist across all tmux windows within a session
- Sidebars survive pane kills and window switches
- Each socket maintains independent sidebar state

**State Persistence Requirements:**

- Per-socket state isolation in separate directories
- Yazi directory state persists across tmux detach/attach cycles
- Current working directory synchronized between sidebars and workspace
- Selection state, preview state, and navigation history maintained
- Socket-specific sidebar states stored and restored independently
- Support for multiple tmux sessions per socket with independent sidebar states

**Workspace Pane Management:**

- New panes open only in center workspace (between sidebars)
- Automatic width recalculation when center panes split
- Prevent accidental sidebar closure
- Smart pane navigation that respects sidebar boundaries
- Automatic workspace rebalancing when panes close
- Per-socket pane management rules

### 4. Global Session Persistence System

Implement robust state management with socket-aware architecture:

**State Directory Structure:**

```
~/.local/state/core-ide/
  ├── sessions/
  │   ├── main/           # core-ide-main socket states
  │   ├── work/           # core-ide-work socket states
  │   ├── personal/       # core-ide-personal socket states
  │   └── research/       # core-ide-research socket states
  ├── layouts/            # Shared layout templates
  ├── scripts/            # Integration scripts
  └── config/             # Core-IDE global configuration
```

**Tmux Session State (Per Socket):**

- Capture and restore complete tmux layouts including sidebars
- Store socket identifier with session state
- Store pane working directories, running commands, and environment variables
- Preserve window names, indices, and active window/pane markers
- Support named sessions with descriptive identifiers
- Per-socket session resurrection on restart
- Socket-specific tmux options and keybindings

**Yazi State Persistence (Per Socket):**

- Store per-socket, per-session yazi directory paths (left and right sidebars)
- Preserve hidden file visibility, sort order, and filter state
- Maintain selection lists and marked files
- Cache preview state and thumbnail generation
- Sync state to disk at configurable intervals
- Socket-specific yazi configuration overrides

**Storage Architecture:**

- Central state directory: `~/.local/state/core-ide/`
- Socket-specific subdirectories for isolation
- JSON/TOML format for human-readable state files
- Session lockfiles to prevent conflicts (per-socket)
- Automatic cleanup of stale session data
- Backup mechanism for state recovery
- Cross-socket state synchronization when requested

**Automatic Resurrection:**

- Systemd user service for Core-IDE startup (optional)
- WezTerm startup script to launch default Core-IDE contexts
- Per-socket resurrection with independent timing
- Configurable auto-start behavior per context
- Crash recovery and automatic restart

### 5. Tmux Layout Management (Socket-Aware)

Create specialized layout system that understands socket contexts:

**Layout Templates (Globally Available):**

- Default layout: left yazi, center workspace, right yazi
- Code layout: left yazi, center split (editor + terminal), right diagnostics
- Review layout: left file tree, center diff, right blame/log
- Debug layout: left yazi, center debugger + code, right watches
- Monitor layout: system metrics, logs, resource usage (for core-ide-system)
- Remote layout: SSH sessions, multiple hosts (for core-ide-remote)
- Build layout: build output, test results, logs (for core-ide-build)
- Custom user-defined layouts with save/restore capability

**Layout Storage:**

- Global layouts: `~/.local/state/core-ide/layouts/`
- Socket-specific layouts: `~/.local/state/core-ide/sessions/{socket}/layouts/`
- Layout metadata includes: socket affinity, minimum terminal size, required tools

**Layout Commands:**

- Quick layout switching via tmux key sequences
- Layout save/load with descriptive names
- Socket-specific layout inheritance and overrides
- Automatic layout adjustment based on terminal size
- Minimum pane size enforcement to prevent crushing
- Layout reset to default state per socket

**Pane Locking:**

- Lock sidebar panes to prevent accidental modification
- Visual indicators for locked panes (status line markers)
- Override mechanism for intentional sidebar manipulation
- Keybindings that respect lock state
- Per-socket lock state management

### 6. Navigation & Keybinding Optimization

Harmonize navigation across all tools with socket awareness:

**Socket Context Awareness:**

- Status line shows current Core-IDE context/socket
- Visual theme/color variations per socket for quick identification
- Socket-specific keybinding overlays (optional)
- Quick socket switcher menu (Prefix + S or similar)

**Unified Navigation Model:**

- Consistent directional navigation (h/j/k/l or arrow keys)
- Context-aware navigation that crosses tool boundaries
- Sidebar focus vs workspace focus modes
- Quick jump to specific panes (numbered or named)
- Breadcrumb trail showing current location in navigation hierarchy
- Cross-socket navigation when intentional

**Tmux Menu Enhancements:**

- Custom menu for Core-IDE management (Prefix + I or similar)
- Menu options for: layout selection, sidebar toggle, session management, pane operations, socket switching
- Socket-specific menu options based on active context
- Fuzzy-searchable menu items using fzf integration
- Preview of layout changes before applying
- Recently used commands/layouts at top of menu
- Cross-socket operation warnings

**Keybinding Layers:**

- Base layer: Standard tmux operations (Prefix-based)
- Navigation layer: Quick pane/window movement (Alt/Ctrl combos)
- Workspace layer: Layout and sidebar management (Prefix + custom keys)
- Integration layer: Cross-tool commands (Prefix + capital letters)
- Socket layer: Cross-context switching and management (Prefix + Meta combinations)
- Emergency layer: Recovery and reset commands (Prefix + Escape sequences)

**Socket-Specific Keybindings:**

- Prefix + S: Socket switcher menu
- Prefix + C: Current socket status and info
- Prefix + N: New socket/context launcher
- Prefix + K: Kill current socket
- Socket-specific custom keybindings loaded per context

**Conflict Resolution:**

- Audit all keybindings across tmux, yazi, neovim
- Remap conflicts with priority: neovim > yazi > tmux > wezterm
- Document all keybinding decisions with rationale
- Create cheat sheet/reference card for new keybindings
- Per-socket keybinding customization supported

### 7. Seamless Tool Integrations

Implement deep integrations between tools with socket awareness:

**Yazi ↔ Neovim:**

- Open file from yazi directly in neovim pane (auto-create if needed)
- Detect correct socket context for neovim instance
- Neovim current file syncs to yazi preview/selection
- Bulk file operations from yazi open in neovim splits
- Yazi opener integration with neovim-remote or similar
- File system watcher to update yazi when neovim saves/renames
- Socket-aware neovim session management

**Yazi ↔ Tmux:**

- Yazi actions trigger tmux commands (open in new pane, new window)
- Tmux pane working directory syncs to yazi on focus
- Custom yazi keybindings for tmux operations (send keys, capture pane)
- Yazi plugin for tmux session/window selection and switching
- Tmux hooks update yazi on pane/window events
- Socket identifier passed to yazi for context awareness
- Cross-socket file operations with explicit confirmation

**Neovim ↔ Tmux:**

- Seamless pane navigation between neovim and tmux (vim-tmux-navigator style)
- Socket-aware navigation (stays within socket by default)
- Neovim terminal integration with tmux keybindings
- Send commands from neovim to adjacent tmux panes
- Tmux resurrect integration with neovim session state
- Synchronized scrollback between neovim terminal and tmux panes
- Neovim RPC server per socket for isolation

**WezTerm ↔ Tmux:**

- WezTerm mux domains mapped to Core-IDE sockets
- WezTerm workspace feature maps to Core-IDE contexts
- Tab/window spawning targets correct socket
- WezTerm keybindings delegate to tmux when appropriate
- WezTerm tab names show Core-IDE context + tmux window names
- Clipboard synchronization between WezTerm and tmux
- Font/color scheme consistency, with per-socket theme variations
- Visual indicators in WezTerm showing active socket

**WezTerm Core-IDE Launcher:**
Create WezTerm integration that:

- Shows Core-IDE context picker on startup
- Launches selected socket or creates new one
- Displays all active Core-IDE contexts in launcher
- Supports quick switching between contexts
- Visual status of each context (active sessions, resource usage)

**Global Clipboard Integration:**

- Unified clipboard across all tools using wl-clipboard
- Copy from yazi → paste in neovim/tmux seamlessly
- Clipboard history accessible from all contexts
- Per-socket clipboard namespaces (optional)
- Cross-socket clipboard bridge when needed
- Automatic escaping/formatting based on paste destination
- OSC 52 support for remote tmux sessions over SSH

**Cross-Socket Operations:**

- Explicit commands for cross-socket actions
- Warning prompts for potentially confusing operations
- File/buffer sharing between sockets
- Unified search across all socket contexts
- Aggregated status/monitoring views

### 8. Performance & Optimization

Ensure smooth operation across multiple sockets:

**Startup Performance:**

- Lazy-load yazi sidebars (create on first access if needed)
- Staggered socket startup to prevent resource spike
- Optimize tmux hook scripts for minimal latency
- Profile configuration load times and optimize slow components
- Cache expensive operations (file lists, git status, previews)
- Per-socket resource limits

**Runtime Efficiency:**

- Debounce rapid state changes to reduce I/O
- Use tmux copy-mode efficiently for large scrollback
- Optimize yazi preview generation (limit file sizes, cache thumbnails)
- Monitor memory usage of persistent yazi instances per socket
- Implement idle detection to pause non-visible operations
- Share resources between sockets where appropriate (preview caches)

**Resource Management:**

- Automatic cleanup of zombie panes/processes per socket
- Limit scrollback buffer size appropriately
- Periodic garbage collection of state files
- Memory limits on yazi preview commands
- CPU throttling for background operations
- Socket-level resource monitoring and alerts
- Automatic socket suspension when idle (optional)

**Socket Health Monitoring:**

- Periodic health checks on all active sockets
- Automatic restart of crashed sockets
- Resource usage tracking per socket
- Alert system for resource exhaustion
- Performance metrics collection and reporting

### 9. Error Handling & Recovery

Build resilient system with socket awareness:

**Failure Modes:**

- Graceful degradation when yazi not available
- Fallback layouts when sidebar creation fails
- State file corruption recovery with backups
- Pane crash detection and automatic restart
- Session lock conflicts resolved with user prompt
- Socket crash detection and recovery
- Cross-socket communication failures handled gracefully

**Socket-Specific Recovery:**

- Individual socket restart without affecting others
- State rollback to last known good configuration
- Emergency socket kill with state preservation
- Socket migration to new path if corruption detected

**User Notifications:**

- Clear error messages in tmux status line (with socket context)
- Per-socket log files for debugging integration issues
- Visual indicators for degraded functionality
- Automatic recovery attempts with status reporting
- Manual recovery commands documented in config comments
- Unified notification system across all sockets

**Testing Strategy:**

- Test layout creation from fresh tmux session per socket
- Verify state persistence across detach/attach cycles per socket
- Test with various terminal sizes and resize events
- Verify keybinding conflicts don't exist within and across sockets
- Test with and without various tools available
- Test socket isolation (no cross-contamination)
- Test cross-socket operations when implemented
- Stress test with all sockets running simultaneously

### 10. User Experience Enhancements

Polish the integrated Core-IDE environment:

**Visual Consistency:**

- Unified base color scheme across tmux, yazi, and neovim
- Per-socket color variations for context identification
- Consistent status line information and formatting
- Visual pane separators that clearly indicate sidebars
- Active pane highlighting that works in all contexts
- Tab/window titles that reflect current socket + context
- Socket identifier always visible in status line

**Socket Context Indicators:**

- Left status: `[Core-IDE:main]` or similar
- Color-coded socket identifiers
- Active session count per socket
- Resource usage indicators per socket

**Discoverability:**

- Prefix + ? shows Core-IDE keybindings and commands
- Prefix + I shows Core-IDE menu and socket switcher
- Contextual help in tmux menu system
- Inline documentation in configuration files
- Quick reference overlay (Prefix + F1 or similar)
- Progressive disclosure of advanced features
- Socket-specific help showing context-relevant commands

**Customization:**

- Configuration variables at top of files for easy tuning
- Per-socket configuration overrides
- Sidebar width adjustable without editing multiple places
- Layout templates easily customizable per socket
- Hook points for user scripts and extensions
- Feature flags to enable/disable components
- Socket-specific feature flags

**Core-IDE Dashboard:**

- Overview showing all active sockets
- Quick actions for common operations
- Resource usage visualization
- Recent activity per socket
- Quick launch for new contexts

### 11. Documentation & Maintenance

Comprehensive documentation:

**User Documentation:**

- README with Core-IDE architecture overview and rationale
- Socket architecture explanation and benefits
- Installation and setup instructions
- Socket management guide
- Keybinding reference with logical groupings
- Common workflows and usage patterns
- Troubleshooting guide with common issues
- Socket-specific considerations

**Developer Documentation:**

- Code architecture and component interaction
- Socket communication protocols
- State persistence format specification
- Extension points for custom functionality
- Performance considerations and optimization tips
- Testing procedures and validation steps
- Adding new socket contexts

**Maintenance:**

- Changelog tracking Core-IDE configuration evolution
- Migration path for breaking changes
- Backup and restore procedures (per-socket and global)
- Update procedures for dependencies
- Rollback instructions if needed
- Socket cleanup and maintenance procedures

### Required Dependencies

Verify and document:

- tmux (>= 3.2 for required features, socket support)
- yazi (latest version with plugin support)
- neovim (>= 0.9 for required APIs, RPC support)
- wezterm (latest stable, mux domain support)
- jq or yq for state file manipulation
- fzf for fuzzy selection
- wl-clipboard for clipboard operations
- socat for IPC communication between sockets (optional)
- Optional: tmux-resurrect, tmux-continuum plugins

### Integration Points

**Tmux Hooks (Per Socket):**

- `session-created`: Initialize sidebars, load socket-specific state
- `session-closed`: Save session state to socket-specific directory
- `pane-focus-in`: Sync yazi directory, update status line with socket context
- `after-split-window`: Ensure split happens in center workspace
- `after-kill-pane`: Rebalance workspace layout
- `client-attached`: Restore session state if available
- `window-linked`: Ensure sidebars exist in new window
- `server-started`: Initialize socket-specific configuration

**Yazi Events:**

- File open: Trigger appropriate handler (neovim, tmux pane, external)
- Directory change: Update tmux pane working directory
- Bulk operations: Coordinate with workspace panes
- Preview updates: Optimize for visible sidebars only
- Socket context passed to all handlers

**Neovim Autocommands:**

- `BufEnter`: Potentially sync yazi to current file location
- `DirChanged`: Update yazi working directory
- `VimLeave`: Coordinate with tmux session state save
- `VimEnter`: Detect socket context and adjust configuration

**WezTerm Events:**

- Workspace switching: Connect to appropriate Core-IDE socket
- Tab creation: Target correct socket based on context
- Window focus: Sync with active socket

### Script Requirements

Create helper scripts for:

**Socket Management:**

- `core-ide-launch`: Launch specific socket context
- `core-ide-switch`: Switch between sockets
- `core-ide-list`: List all active sockets
- `core-ide-status`: Show socket health and status
- `core-ide-kill`: Shutdown specific socket
- `core-ide-killall`: Shutdown all Core-IDE instances
- `core-ide-attach`: Attach to existing socket
- `core-ide-new`: Create new custom socket context

**Session Management:**

- Session creation with sidebar initialization per socket
- Layout save/restore operations (socket-aware)
- State file manipulation (read/write/validate per socket)
- Pane lock/unlock operations
- Cross-tool communication (send commands, get state)
- Workspace rebalancing calculations
- Cleanup and maintenance operations per socket

**Integration Scripts:**

- Yazi-to-neovim opener (socket-aware)
- Neovim-to-tmux command sender
- Cross-socket clipboard bridge
- WezTerm launcher integration
- Status aggregation across sockets

## Success Criteria

- Multiple tmux sockets run independently without interference
- Socket-specific state persists and restores correctly
- Yazi sidebars persist and restore correctly per socket
- New panes only open in center workspace with proper width calculation
- All keybindings work without conflicts across all tools
- State persists across system reboots (with per-socket restoration)
- Navigation feels seamless between all integrated tools within socket
- Cross-socket operations are explicit and safe
- Performance is imperceptible (<50ms latency for all operations)
- Socket switching is fast and intuitive
- Comprehensive documentation enables easy customization
- System degrades gracefully when components unavailable
- User can customize behavior without editing core integration code
- Socket isolation verified (no state leakage)
- Resource usage remains reasonable with multiple sockets active

## Implementation Approach

1. **Phase 1 - Discovery**: Analyze all existing configurations thoroughly
2. **Phase 2 - Socket Architecture**: Design and implement socket management system
3. **Phase 3 - Core Integration**: Implement tmux layout management with yazi sidebars per socket
4. **Phase 4 - Persistence**: Build socket-aware state save/restore system
5. **Phase 5 - Keybindings**: Harmonize and optimize all keybindings with socket awareness
6. **Phase 6 - Cross-tool Integration**: Implement seamless tool interactions within sockets
7. **Phase 7 - Socket Switching**: Build socket switcher and cross-socket operations
8. **Phase 8 - WezTerm Integration**: Deep integration with WezTerm for socket launching
9. **Phase 9 - Polish**: Add menus, documentation, error handling, Core-IDE dashboard
10. **Phase 10 - Testing**: Validate all functionality and edge cases, including socket isolation

## Important Considerations

- User prefers understanding mechanics over black-box automation
- Should work natively with Wayland (wl-clipboard)
- Configuration must be modular and well-documented
- Advanced user who appreciates technical depth
- Preserve existing workflow while enhancing it
- No hard-coded paths - use configuration variables
- Must handle edge cases (missing tools, small terminals, socket conflicts, etc.)
- Performance is critical for daily use
- Socket isolation is critical - no cross-contamination
- Socket management must be intuitive and transparent
- Each socket should feel like independent Core-IDE instance
- Cross-socket operations should be explicit and safe

## Notes for Implementation

- Start by thoroughly reading ALL current configuration files
- Document current tmux socket usage (if any)
- Create backup of configurations before modification
- Test socket isolation thoroughly
- Test each integration point independently before combining
- Provide clear upgrade path if user needs to rollback
- Use tmux server options for global settings, session options for per-session
- Socket-specific options require separate tmux.conf or runtime configuration
- Leverage tmux formats (e.g., `#{socket_path}`) for dynamic behavior
- Consider using tmux popup for temporary menus/selections
- Yazi can be controlled via `ya` CLI for external scripting
- WezTerm CLI can interact with running instance via `wezterm cli`
- Socket paths should be deterministic and user-controllable
- Consider XDG Base Directory specification for socket locations
- Ensure socket cleanup on unexpected termination
- Test with multiple users on same system (socket path conflicts)

## Deliverables

1. Core-IDE socket management system and scripts
2. Modified tmux configuration with sidebar support (per-socket)
3. Socket-aware yazi configuration with tmux integration hooks
4. State persistence system with socket isolation
5. Unified keybinding scheme documented clearly (with socket operations)
6. Custom tmux menu system for Core-IDE and socket management
7. Integration scripts for all cross-tool communication (socket-aware)
8. WezTerm integration for Core-IDE launching and management
9. Comprehensive documentation (README, architecture, keybinding reference, troubleshooting)
10. Example socket contexts and customization templates
11. Socket health monitoring and management tools
12. Testing procedure and validation checklist (including socket isolation tests)
13. Migration guide from current setup to Core-IDE environment
14. Quick start guide for daily Core-IDE usage
15. Socket context reference (when to use which socket)
