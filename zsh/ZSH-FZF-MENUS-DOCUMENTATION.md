# ZSH FZF Menu Systems - Complete Documentation

---

## OVERVIEW

This configuration contains **3 primary menu systems** with overlapping but distinct purposes:

1. **CORE MENU** (`core-menu`) - Comprehensive hierarchical command hub with 8 categories
2. **COMMAND PALETTE** (`widget::command-palette`) - Quick-access flat command launcher
3. **DOCUMENTATION MENU** (`doc-menu`) - Documentation browser and management system

**Total FZF Components:**
- 3 main menu systems
- 42 widget functions
- 28 helper functions
- 40+ keybindings
- ~3000+ lines of FZF code

---

## PRIMARY MENU SYSTEMS

---

### 1. CORE MENU (Main System)
- **Keybind:** `Ctrl+Space` (primary) or `Alt+M` (alternate)
- **Command:** `core-menu` (also aliased as `menu`, `m`)
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/main-menu.zsh`
- **Widget:** `_core_menu_widget`

**Description:**
The central command hub providing hierarchical access to all shell utilities, FZF customization, system tools, and documentation. Organized into 8 distinct categories with submenus.

**Category Access:**
```
core-menu              # Main menu launcher
core-menu fzf          # Direct to FZF customization
core-menu git          # Direct to Git operations
core-menu system       # Direct to System tools
core-menu tmux         # Direct to Tmux integration
core-menu shell        # Direct to Shell utilities
core-menu docs         # Direct to Documentation
core-menu dev          # Direct to Development tools
```

**Aliases:**
```bash
menu, m               → core-menu
mf                    → core-menu fzf
mg                    → core-menu git
ms                    → core-menu system
mt                    → core-menu tmux
msh                   → core-menu shell
md                    → core-menu docs
mdev                  → core-menu dev
```

**Main Menu List:**
```
1. FZF Customization
2. File Operations
3. Git Operations
4. System Tools
5. Tmux Integration
6. Shell Utilities
7. Documentation
8. Development
```

---

### 1.1 FZF Customization Submenu
- **Keybind:** `Ctrl+Alt+F` (direct access) or `Ctrl+Space` → select FZF Customization
- **Command:** `_core_menu_fzf`
- **Widget:** `_core_menu_fzf_widget`
- **Alias:** `mf`

**Description:**
Comprehensive FZF appearance and behavior customization center. Allows real-time theme and layout switching with live preview.

**Submenu Options:**
```
- Select Theme          → fzf-theme-select (10+ color themes)
- Select Layout         → fzf-layout-select (10+ layouts)
- Show Current Config   → fzf-show-current
- Preview All Themes    → fzf-theme-preview (cycle through all)
- Reset to Defaults     → Reset FZF settings
- Appearance Menu       → Combined theme/layout selector
```

**Available Themes:**
```
- Monokai Dark
- Dracula
- Tokyo Night
- Nord
- Gruvbox Dark
- Catppuccin
- Solarized Dark
- One Dark
- Material
- Nightfox
- (and more...)
```

**Available Layouts:**
```
- default
- reverse
- reverse-list
- horizontal
- vertical
- inline
- fullscreen
- preview-top
- preview-bottom
- preview-left
- preview-right
- (and more...)
```

---

### 1.2 File Operations Submenu
- **Keybind:** `Ctrl+Space` → File Operations
- **Command:** `_core_menu_files`

**Description:**
File and directory navigation and management tools.

**Submenu Options:**
```
- Find Files            → widget::fzf-file-selector (Ctrl+F)
- Find Directories      → widget::fzf-directory-selector (Alt+F)
- Yazi File Picker      → widget::yazi-picker (Alt+Y)
- Yazi Navigate & CD    → widget::yazi-cd
- Zoxide Smart Jump     → zi (zoxide interactive)
- Directory Bookmarks   → widget::jump-bookmark (Alt+J)
- Recent Files          → Recent file browser
- Directory Tree        → Tree view with navigation
```

---

### 1.3 Git Operations Submenu
- **Keybind:** `Ctrl+Space` → Git Operations or `mg`
- **Command:** `_core_menu_git`
- **Widget:** `_core_menu_git_widget`

**Description:**
Complete Git workflow management with fuzzy selection for all major operations.

**Submenu Options:**
```
- Git Status Files      → widget::fzf-git-status (Ctrl+G)
- Git Branches          → widget::fzf-git-branch (Alt+G)
- Git Commits           → widget::fzf-git-commits (Alt+C)
- Git Remotes           → widget::fzf-git-remotes (Alt+R)
- Git Add (Fuzzy)       → fzf-git-add
- Git Checkout/Restore  → fzf-git-checkout-file
- Git Diff Browser      → Browse diffs with preview
- Git Log Viewer        → Enhanced log with graph
- Git Stash Manager     → Manage stashes
```

**FZF Keybinds (in Git widgets):**
```
Ctrl+G    → Open git status widget
Alt+G     → Open git branch widget
Alt+C     → Open git commits widget
Alt+R     → Open git remotes widget
Enter     → Select item
Ctrl+A    → Select all
Ctrl+D    → Deselect all
Tab       → Toggle selection
```

---

### 1.4 System Tools Submenu
- **Keybind:** `Ctrl+Space` → System Tools or `ms`
- **Command:** `_core_menu_system`
- **Widget:** `_core_menu_system_widget`

**Description:**
Advanced system administration and monitoring tools with interactive management.

**Submenu Options:**
```
- Systemd Manager       → widget::systemd-unit-manager (Ctrl+Alt+S)
- Journal Browser       → widget::systemd-journal-browser (Ctrl+Alt+J)
- Docker Containers     → widget::docker-container-manager (Ctrl+Alt+D)
- Docker Images         → widget::docker-image-manager
- Docker Compose        → widget::docker-compose-manager
- Process Manager       → widget::process-manager
- Network Manager       → widget::network-manager
- Listening Ports       → View ports with lsof
- Disk Usage            → Interactive du/ncdu
- Memory Info           → Memory statistics
- Hardware Info         → System hardware details
```

**Systemd Unit Manager Actions:**
```
- status       → View unit status
- start        → Start unit
- stop         → Stop unit
- restart      → Restart unit
- reload       → Reload configuration
- enable       → Enable at boot
- disable      → Disable at boot
- edit         → Edit unit file
- logs         → View logs
- cat          → View unit file
- dependencies → Show dependencies
- failed       → Show failed units
- mask         → Mask unit
- unmask       → Unmask unit
```

**Docker Container Actions:**
```
- logs         → View container logs
- exec         → Execute command in container
- stop         → Stop container
- remove       → Remove container
- restart      → Restart container
- stats        → View container statistics
```

---

### 1.5 Tmux Integration Submenu
- **Keybind:** `Ctrl+Space` → Tmux Integration or `mt`
- **Command:** `_core_menu_tmux`

**Description:**
Complete Tmux session, window, and pane management.

**Submenu Options:**
```
- Switch Sessions       → widget::fzf-tmux-session (Ctrl+T)
- Switch Windows        → widget::fzf-tmux-window (Alt+T)
- Switch Panes          → widget::fzf-tmux-pane
- Apply Layout          → fzf-tmux-layouts
- Create New Session    → tmux new-session prompt
- Create New Window     → tmux new-window prompt
- Split Horizontal      → tmux split-window -h
- Split Vertical        → tmux split-window -v
- Rename Session        → Rename current session
- Rename Window         → Rename current window
- Kill Pane             → Kill current pane
- Kill Window           → Kill current window
- Kill Session          → Kill current session
```

**Tmux Layout Options:**
```
- even-horizontal
- even-vertical
- main-horizontal
- main-vertical
- tiled
- (custom layouts from config)
```

---

### 1.6 Shell Utilities Submenu
- **Keybind:** `Ctrl+Space` → Shell Utilities or `msh`
- **Command:** `_core_menu_shell`

**Description:**
Essential shell productivity tools and utilities.

**Submenu Options:**
```
- History Search        → widget::fzf-history-search (Ctrl+R)
- Clipboard History     → widget::clipboard-history-manager
- Directory Bookmarks   → widget::jump-bookmark (Alt+J)
- Quick Notes           → widget::quick-note (Alt+N)
- Environment Vars      → widget::fzf-env (Alt+E)
- Aliases Browser       → Browse all aliases with search
- Functions Browser     → Browse all functions with search
- Keybindings Reference → View all keybindings
- Command Palette       → widget::command-palette (Ctrl+P)
- Calculator            → widget::calculator (Alt+=)
```

---

### 1.7 Documentation Submenu
- **Keybind:** `Ctrl+Space` → Documentation or `md`
- **Command:** `_core_menu_docs`

**Description:**
Browse and manage documentation (lighter version of full doc-menu).

**Submenu Options:**
```
- Browse Docs           → doc-browse
- Search Docs           → doc-search (full-text with rg)
- Quick Reference       → doc-quick-ref
- Context Help          → doc-context
- Add Documents         → doc-add
- Edit Documents        → doc-edit
- Generate from Code    → doc-generate
- Documentation Index   → doc-index
- Man Pages Browser     → fzf-man
```

---

### 1.8 Development Submenu
- **Keybind:** `Ctrl+Space` → Development or `mdev`
- **Command:** `_core_menu_dev`

**Description:**
Development-focused tools and workflows.

**Submenu Options:**
```
- NPM Scripts Runner    → fzf-npm-scripts
- Package Install       → fzf-pacman-install (Arch)
- Environment Editor    → fzf-environment
- JSON Tools            → JSON manipulation utilities
- HTTP Client           → HTTP request tools
- SSH Hosts             → widget::fzf-ssh (Alt+S)
- Port Scanner          → Network port scanning
- Log Viewer            → Application log browser
- Config Editor         → Configuration file editor
- Workspace Launcher    → widget::workspace-launcher
```

---

---

### 2. COMMAND PALETTE (Quick Access)
- **Keybind:** `Ctrl+P`
- **Command:** `widget::command-palette`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`
- **Widget:** `widget::command-palette`

**FZF Options:**
```
--height=100%
--reverse
--border
--preview-window=right:50%
--bind=ctrl-a:select-all
--bind=ctrl-d:deselect-all
```

**Description:**
Fast, flat-list command launcher for the most frequently used utilities. Designed for quick access without hierarchical navigation. Uses full-height overlay with dynamic preview.

**Command List:**
```
1.  Files: Select & Insert        → widget::fzf-file-selector
2.  Directories: Navigate & CD    → widget::fzf-directory-selector
3.  History: Search & Execute     → widget::fzf-history-search
4.  Process: Kill Process         → widget::fzf-kill-process
5.  Git: Status Files             → widget::fzf-git-status
6.  Git: Branches                 → widget::fzf-git-branch
7.  Git: Commits                  → widget::fzf-git-commits
8.  Tmux: Switch Session          → widget::fzf-tmux-session
9.  Tmux: Switch Window           → widget::fzf-tmux-window
10. SSH: Connect to Host          → widget::fzf-ssh
11. Env: Browse Variables         → widget::fzf-env
12. Yazi: File Picker             → widget::yazi-picker
13. Yazi: Navigate with CD        → widget::yazi-cd
14. Bookmarks: Jump to Location   → widget::jump-bookmark
15. Notes: Quick Note             → widget::quick-note
16. Calculator: Evaluate Math     → widget::calculator
17. Clipboard: History Manager    → widget::clipboard-history-manager
```

**Internal FZF Keybinds:**
```
Ctrl+A    → Select all
Ctrl+D    → Deselect all
Enter     → Execute selected command
Esc       → Exit palette
Tab       → Toggle selection (multi-select)
```

---

---

### 3. DOCUMENTATION MENU (Full System)
- **Keybind:** `Ctrl+X ?` (in vi-mode)
- **Command:** `doc-menu`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/documentation.zsh`
- **Widget:** `doc-menu` (function, not ZLE widget)

**Description:**
Comprehensive documentation management system with browsing, searching, editing, and auto-generation capabilities. Distinct from the Documentation submenu in core-menu by providing full management features.

**Main Menu Options:**
```
1.  Browse Documentation         → doc-browse
2.  Search Documentation         → doc-search
3.  Quick Reference              → doc-quick-ref
4.  View Context Help            → doc-context
5.  Add New Documentation        → doc-add
6.  Edit Documentation           → doc-edit
7.  Generate from Code           → doc-generate
8.  Reorganize Documentation     → Manage doc structure
9.  View ZSH Config Docs         → doc-zsh-config
10. Open Documentation Index     → doc-index
```

**doc-browse Categories:**
```
- Functions
- Widgets
- Aliases
- Keybindings
- Integrations
- Modules
- Snippets
- Configuration
- Tutorials
- Reference
```

**doc-quick-ref Types:**
```
- Functions Reference
- Widgets Reference
- Keybindings Reference
- Aliases Reference
- Snippets Reference
- Integrations Reference
```

**doc-search Features:**
```
- Full-text search with ripgrep
- Category filtering
- Live preview
- Syntax highlighting
- Copy to clipboard
```

**Internal FZF Keybinds (in doc functions):**
```
Enter     → View/Select document
Ctrl+E    → Edit document
Ctrl+D    → Delete document
Ctrl+Y    → Copy to clipboard
Ctrl+O    → Open in editor
Tab       → Toggle preview
```

---

---

## INDIVIDUAL WIDGETS (42 Total)

These widgets can be called directly or accessed through the menu systems above.

---

### File & Directory Widgets

---

#### widget::fzf-file-selector
- **Keybind:** `Ctrl+F`
- **Command:** `widget::fzf-file-selector`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Insert selected file path(s) at cursor
Ctrl+A    → Select all files
Ctrl+D    → Deselect all
Tab       → Toggle selection
Esc       → Cancel
```

**Description:**
Interactive file selector with live preview. Uses `fd` for fast file discovery. Multi-select capable. Preview shows file contents with syntax highlighting via `bat`. Selected file paths are inserted into command line buffer.

**Preview Window:**
```
--preview='bat --color=always --style=numbers {}'
--preview-window=right:50%
```

---

#### widget::fzf-directory-selector
- **Keybind:** `Alt+F`
- **Command:** `widget::fzf-directory-selector`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Change directory to selection
Alt+Enter → Insert directory path at cursor
Ctrl+A    → Select all
Tab       → Toggle selection
```

**Description:**
Directory navigator with tree preview. Changes working directory to selected location or inserts path into buffer. Uses `tree` for directory structure preview.

**Preview Window:**
```
--preview='tree -C -L 2 {}'
--preview-window=right:50%
```

---

#### widget::yazi-picker
- **Keybind:** `Alt+Y`
- **Command:** `widget::yazi-picker`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Launch Yazi file manager for interactive file selection. Selected files are returned to command line buffer. Full Yazi functionality available (preview, selection, navigation).

---

#### widget::yazi-cd
- **Keybind:** Not directly bound (accessible via menus)
- **Command:** `widget::yazi-cd`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Launch Yazi for directory navigation. On exit, changes working directory to Yazi's final location. Enables visual directory browsing with automatic CD.

---

---

### Git Widgets

---

#### widget::fzf-git-status
- **Keybind:** `Ctrl+G`
- **Command:** `widget::fzf-git-status`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Insert file path
Ctrl+S    → Stage file
Ctrl+U    → Unstage file
Ctrl+D    → Show diff
Alt+Enter → Open in editor
```

**Description:**
Browse Git working tree changes with status indicators (modified, added, deleted, untracked). Preview shows git diff for each file. Actions available for staging/unstaging.

**Preview Window:**
```
--preview='git diff --color=always {}'
--preview-window=right:60%
```

---

#### widget::fzf-git-branch
- **Keybind:** `Alt+G`
- **Command:** `widget::fzf-git-branch`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Checkout branch
Ctrl+D    → Delete branch
Ctrl+M    → Merge branch
Ctrl+R    → Rebase onto branch
Ctrl+N    → Create new branch
```

**Description:**
Interactive Git branch switcher with commit preview. Shows local and remote branches with last commit info. Supports creation, deletion, merge, and rebase operations.

**Preview Window:**
```
--preview='git log --oneline --graph --color=always {}'
--preview-window=right:60%
```

---

#### widget::fzf-git-commits
- **Keybind:** `Alt+C`
- **Command:** `widget::fzf-git-commits`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Show commit details
Ctrl+Y    → Copy commit hash
Ctrl+D    → Show diff
Ctrl+R    → Reset to commit
Ctrl+P    → Cherry-pick commit
```

**Description:**
Browse Git commit history with graph visualization. Preview shows full commit details and diff. Supports cherry-pick, reset, and hash copying.

**Preview Window:**
```
--preview='git show --color=always {}'
--preview-window=right:60%
```

---

#### widget::fzf-git-remotes
- **Keybind:** `Alt+R`
- **Command:** `widget::fzf-git-remotes`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Show remote info
Ctrl+F    → Fetch from remote
Ctrl+P    → Pull from remote
Ctrl+U    → Push to remote
```

**Description:**
Git remote management with URL preview and fetch/pull/push shortcuts.

---

---

### History & Search Widgets

---

#### widget::fzf-history-search
- **Keybind:** `Ctrl+R`
- **Command:** `widget::fzf-history-search`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Execute command
Ctrl+Y    → Copy to clipboard
Ctrl+E    → Edit before executing
Ctrl+D    → Delete from history
Alt+Enter → Insert into buffer without executing
```

**Description:**
Enhanced history search with preview, deduplication, and timestamp display. Supports editing before execution, deletion, and clipboard copy. Context-aware preview shows command details.

**Preview Window:**
```
--preview='echo {}'
--preview-window=down:3:wrap
```

---

---

### System Management Widgets

---

#### widget::systemd-unit-manager
- **Keybind:** `Ctrl+Alt+S`
- **Command:** `widget::systemd-unit-manager`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets-advanced.zsh`

**FZF Keybinds:**
```
Enter     → Show detailed status
Ctrl+S    → Start unit
Ctrl+X    → Stop unit
Ctrl+R    → Restart unit
Ctrl+E    → Enable unit
Ctrl+D    → Disable unit
Ctrl+L    → View logs
Ctrl+F    → View unit file
```

**Description:**
Comprehensive systemd unit management interface. Lists all units with status indicators (active/inactive/failed). Preview shows full unit status. Supports all systemctl operations through keyboard shortcuts.

**Unit Types:**
```
- All units
- Services only
- Sockets only
- Timers only
- Targets only
- Mounts only
- Failed units only
```

**Preview Window:**
```
--preview='systemctl status {}'
--preview-window=right:60%
```

---

#### widget::systemd-journal-browser
- **Keybind:** `Ctrl+Alt+J`
- **Command:** `widget::systemd-journal-browser`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets-advanced.zsh`

**FZF Keybinds:**
```
Enter     → View full log
Ctrl+F    → Follow log (tail -f mode)
Ctrl+T    → Change time range
Ctrl+U    → Filter by unit
Ctrl+P    → Filter by priority
```

**Description:**
Interactive journalctl browser with filtering by time range, unit, and priority. Supports live tail mode. Preview shows log context.

**Time Range Options:**
```
- Last hour
- Last 24 hours
- Last 7 days
- Last 30 days
- Since boot
- Custom range
```

**Priority Levels:**
```
- Emergency (0)
- Alert (1)
- Critical (2)
- Error (3)
- Warning (4)
- Notice (5)
- Info (6)
- Debug (7)
```

---

#### widget::process-manager
- **Keybind:** Not directly bound (accessible via menus)
- **Command:** `widget::process-manager`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets-advanced.zsh`

**FZF Keybinds:**
```
Enter     → Show process details
Ctrl+K    → Kill process (SIGTERM)
Ctrl+9    → Kill process (SIGKILL)
Ctrl+R    → Renice process
Ctrl+L    → View process lsof
```

**Description:**
Process browser with resource usage preview (CPU, memory, command line). Supports killing processes with confirmation, renicing, and viewing open files.

**Preview Window:**
```
--preview='ps -fp {1}'
--preview-window=right:50%
```

---

#### widget::fzf-kill-process
- **Keybind:** `Ctrl+K`
- **Command:** `widget::fzf-kill-process`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Kill selected process(es) (SIGTERM)
Ctrl+9    → Force kill (SIGKILL)
Tab       → Toggle selection (multi-kill)
```

**Description:**
Quick process killer with multi-select. Shows process tree and resource usage in preview. Confirmation required for kill operations.

---

#### widget::network-manager
- **Keybind:** Not directly bound (accessible via menus)
- **Command:** `widget::network-manager`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets-advanced.zsh`

**FZF Keybinds:**
```
Enter     → Show connection details
Ctrl+U    → Bring connection up
Ctrl+D    → Bring connection down
Ctrl+R    → Restart connection
```

**Description:**
Network connection management interface. Lists all network interfaces with status. Preview shows interface details and statistics.

---

---

### Container Widgets

---

#### widget::docker-container-manager
- **Keybind:** `Ctrl+Alt+D`
- **Command:** `widget::docker-container-manager`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets-advanced.zsh`

**FZF Keybinds:**
```
Enter     → View container details
Ctrl+L    → View logs
Ctrl+E    → Execute shell in container
Ctrl+S    → Stop container
Ctrl+R    → Restart container
Ctrl+D    → Remove container
Ctrl+T    → View stats
```

**Description:**
Comprehensive Docker container management. Lists all containers (running and stopped) with status indicators. Preview shows `docker inspect` output. Actions available for all container operations.

**Preview Window:**
```
--preview='docker inspect {}'
--preview-window=right:60%
```

---

#### widget::docker-image-manager
- **Keybind:** Not directly bound (accessible via menus)
- **Command:** `widget::docker-image-manager`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets-advanced.zsh`

**FZF Keybinds:**
```
Enter     → View image details
Ctrl+R    → Run container from image
Ctrl+D    → Delete image
Ctrl+P    → Pull image
Ctrl+T    → Tag image
```

**Description:**
Docker image browser with details preview. Supports running containers, deleting images, pulling updates, and tagging.

---

#### widget::docker-compose-manager
- **Keybind:** Not directly bound (accessible via menus)
- **Command:** `widget::docker-compose-manager`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets-advanced.zsh`

**FZF Keybinds:**
```
Enter     → View service status
Ctrl+U    → Start services
Ctrl+D    → Stop services
Ctrl+R    → Restart services
Ctrl+L    → View logs
Ctrl+P    → Pull images
```

**Description:**
Docker Compose service management. Lists all services from docker-compose.yml with status. Supports all docker-compose operations.

---

---

### Tmux Widgets

---

#### widget::fzf-tmux-session
- **Keybind:** `Ctrl+T`
- **Command:** `widget::fzf-tmux-session`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Switch to session
Ctrl+D    → Delete session
Ctrl+R    → Rename session
Ctrl+N    → Create new session
```

**Description:**
Tmux session switcher with preview showing session windows and layout. Supports session creation, deletion, and renaming.

**Preview Window:**
```
--preview='tmux list-windows -t {}'
--preview-window=right:50%
```

---

#### widget::fzf-tmux-window
- **Keybind:** `Alt+T`
- **Command:** `widget::fzf-tmux-window`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Switch to window
Ctrl+D    → Delete window
Ctrl+R    → Rename window
Ctrl+N    → Create new window
Ctrl+M    → Move window to different session
```

**Description:**
Tmux window switcher with pane layout preview. Shows all windows across all sessions.

---

#### widget::fzf-tmux-pane
- **Keybind:** Not directly bound (accessible via menus)
- **Command:** `widget::fzf-tmux-pane`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Switch to pane
Ctrl+D    → Kill pane
Ctrl+Z    → Zoom/unzoom pane
Ctrl+B    → Break pane to new window
```

**Description:**
Tmux pane switcher with current command preview. Shows all panes in current window.

---

---

### Productivity Widgets

---

#### widget::clipboard-history-manager
- **Keybind:** Not directly bound (accessible via menus)
- **Command:** `widget::clipboard-history-manager`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets-advanced.zsh`

**FZF Keybinds:**
```
Enter     → Restore to clipboard
Ctrl+Y    → Copy to buffer
Ctrl+D    → Delete entry
Ctrl+C    → Clear history
```

**Description:**
Clipboard history browser with preview. Integrates with system clipboard manager (cliphist/clipman). Supports restoring old clipboard entries.

---

#### widget::workspace-launcher
- **Keybind:** Not directly bound (accessible via menus)
- **Command:** `widget::workspace-launcher`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets-advanced.zsh`

**FZF Keybinds:**
```
Enter     → Launch workspace
Ctrl+E    → Edit workspace config
Ctrl+D    → Delete workspace
Ctrl+N    → Create new workspace
```

**Description:**
Launch predefined workspace configurations (tmux sessions, editor layouts, directory contexts). Preview shows workspace composition.

---

#### widget::jump-bookmark
- **Keybind:** `Alt+J`
- **Command:** `widget::jump-bookmark`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Jump to bookmark
Ctrl+D    → Delete bookmark
Ctrl+E    → Edit bookmark
Ctrl+A    → Add current directory
```

**Description:**
Directory bookmark manager. Quick navigation to frequently used directories. Persistent across sessions.

---

#### widget::quick-note
- **Keybind:** `Alt+N`
- **Command:** `widget::quick-note`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → View note
Ctrl+E    → Edit note
Ctrl+D    → Delete note
Ctrl+N    → Create new note
Ctrl+Y    → Copy note content
```

**Description:**
Quick note-taking system with preview and search. Notes stored in plain text with timestamps.

---

#### widget::calculator
- **Keybind:** `Alt+=`
- **Command:** `widget::calculator`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Interactive calculator with history. Evaluates mathematical expressions and inserts result into buffer. Supports bc syntax.

---

---

### SSH & Network Widgets

---

#### widget::fzf-ssh
- **Keybind:** `Alt+S`
- **Command:** `widget::fzf-ssh`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Connect to host
Ctrl+E    → Edit SSH config
Ctrl+C    → Copy SSH command
Ctrl+K    → View host keys
```

**Description:**
SSH host selector from ~/.ssh/config with connection preview. Shows host details, port, user, and connection info.

**Preview Window:**
```
--preview='grep -A 10 "Host {}" ~/.ssh/config'
--preview-window=right:50%
```

---

---

### Environment & Shell Widgets

---

#### widget::fzf-env
- **Keybind:** `Alt+E`
- **Command:** `widget::fzf-env`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**FZF Keybinds:**
```
Enter     → Insert variable value
Ctrl+Y    → Copy value to clipboard
Ctrl+E    → Edit variable (export)
Ctrl+U    → Unset variable
```

**Description:**
Environment variable browser with value preview. Shows all environment variables with syntax highlighting. Supports editing and unsetting.

---

#### widget::copy-buffer
- **Keybind:** `Alt+W`
- **Command:** `widget::copy-buffer`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Copy current command line buffer to system clipboard. No FZF interface, direct action.

---

#### widget::paste-clipboard
- **Keybind:** `Alt+V`
- **Command:** `widget::paste-clipboard`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Paste from system clipboard into command line buffer. No FZF interface, direct action.

---

#### widget::edit-command
- **Keybind:** `Ctrl+X Ctrl+E`
- **Command:** `widget::edit-command`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Open current command line buffer in $EDITOR for complex editing. On save, command is inserted back into buffer.

---

#### widget::clear-scrollback
- **Keybind:** `Ctrl+L`
- **Command:** `widget::clear-scrollback`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Clear screen and scrollback buffer. Enhanced version of standard clear.

---

#### widget::insert-last-output
- **Keybind:** `Alt+.`
- **Command:** `widget::insert-last-output`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Insert the output of the last command into current buffer. Useful for command chaining.

---

#### widget::toggle-sudo
- **Keybind:** `Esc Esc` (double Escape)
- **Command:** `widget::toggle-sudo`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Toggle `sudo` prefix on current command. Adds if missing, removes if present.

---

#### widget::insert-timestamp
- **Keybind:** `Alt+T`
- **Command:** `widget::insert-timestamp`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Insert current timestamp at cursor position. Format: `YYYY-MM-DD HH:MM:SS`

---

#### widget::insert-date
- **Keybind:** `Alt+D`
- **Command:** `widget::insert-date`
- **File:** `/home/theron/.core/.sys/cfg/zsh/modules/widgets.zsh`

**Description:**
Insert current date at cursor position. Format: `YYYY-MM-DD`

---

---

## FZF HELPER FUNCTIONS (28 Total)

These are utility functions that can be called directly or through menus. They are not ZLE widgets.

**File:** `/home/theron/.core/.sys/cfg/zsh/integrations/fzf.zsh`

---

### Git Helpers

#### fzf-git-add
**Command:** `fzf-git-add`

**Description:** Fuzzy file selector for `git add`. Shows modified/untracked files with diff preview. Multi-select capable.

---

#### fzf-git-checkout-file
**Command:** `fzf-git-checkout-file`

**Description:** Fuzzy file selector for `git checkout`/`git restore`. Discards changes with confirmation.

---

---

### System Helpers

#### fzf-systemctl
**Command:** `fzf-systemctl`

**Description:** Systemd unit selector for systemctl operations. Simpler version of full systemd widget.

---

#### fzf-docker-logs
**Command:** `fzf-docker-logs`

**Description:** Select container and view logs with tail -f support.

---

#### fzf-docker-exec
**Command:** `fzf-docker-exec`

**Description:** Select container and execute shell command interactively.

---

#### fzf-man
**Command:** `fzf-man`

**Description:** Man page browser with fuzzy search. Preview shows man page summary.

---

#### fzf-pacman-install
**Command:** `fzf-pacman-install`

**Description:** Arch Linux package installer with fuzzy search. Shows package info in preview.

---

#### fzf-kill-port
**Command:** `fzf-kill-port <port>`

**Description:** Kill process listening on specified port. Auto-detects process and kills with confirmation.

---

#### fzf-npm-scripts
**Command:** `fzf-npm-scripts`

**Description:** NPM package.json scripts runner. Lists all scripts with preview of script command.

---

#### fzf-environment
**Command:** `fzf-environment`

**Description:** Environment variable viewer/editor with export functionality.

---

#### fzf-wifi
**Command:** `fzf-wifi`

**Description:** WiFi network selector with nmcli integration. Connect to networks interactively.

---

#### fzf-cliphist
**Command:** `fzf-cliphist`

**Description:** Clipboard history browser (cliphist backend). Select and restore old clipboard entries.

---

#### fzf-tmux-layouts
**Command:** `fzf-tmux-layouts`

**Description:** Tmux layout selector with visual preview. Apply predefined or custom layouts to current window.

---

---

### FZF Theme System

**File:** `/home/theron/.core/.sys/cfg/zsh/functions/fzf-theme`

---

#### fzf-theme-select
**Command:** `fzf-theme-select`
**Alias:** `fzf-themes`

**Description:** Interactive theme selector with live color preview. Applies theme immediately on selection.

**Available Themes:** 10+ color schemes (Monokai, Dracula, Tokyo Night, Nord, Gruvbox, etc.)

---

#### fzf-theme-apply
**Command:** `fzf-theme-apply <theme-name>`

**Description:** Apply specific theme by name. Updates FZF_DEFAULT_OPTS with theme colors.

---

#### fzf-theme-preview
**Command:** `fzf-theme-preview`
**Alias:** `fzf-preview-themes`

**Description:** Cycle through all themes with live preview in FZF. Press Enter to select, Esc to cancel.

---

#### fzf-layout-select
**Command:** `fzf-layout-select`
**Alias:** `fzf-layouts`

**Description:** Interactive layout selector with preview. Choose from 10+ layout configurations.

**Available Layouts:** default, reverse, horizontal, vertical, fullscreen, preview-top/bottom/left/right, etc.

---

#### fzf-layout-apply
**Command:** `fzf-layout-apply <layout-name>`

**Description:** Apply specific layout by name. Updates FZF_DEFAULT_OPTS with layout settings.

---

#### fzf-appearance
**Command:** `fzf-appearance`

**Description:** Combined theme + layout selector. Two-step process: select theme, then select layout.

---

#### fzf-show-current
**Command:** `fzf-show-current`
**Alias:** `fzf-current`

**Description:** Display currently active FZF theme and layout configuration with color preview.

---

---

## KEYBINDING REFERENCE

### Primary Menu Launchers
```
Ctrl+Space       → core-menu (Main menu)
Alt+M            → core-menu (Alternate)
Ctrl+P           → Command Palette
Ctrl+X ?         → Documentation Menu
Ctrl+Alt+F       → FZF Customization (direct)
```

### File & Directory
```
Ctrl+F           → File selector
Alt+F            → Directory selector
Alt+Y            → Yazi file picker
Alt+J            → Directory bookmarks
```

### Git Operations
```
Ctrl+G           → Git status files
Alt+G            → Git branches
Alt+C            → Git commits
Alt+R            → Git remotes
```

### System Management
```
Ctrl+Alt+S       → Systemd manager
Ctrl+Alt+J       → Journal browser
Ctrl+Alt+D       → Docker containers
Ctrl+K           → Kill process
```

### Tmux Integration
```
Ctrl+T           → Tmux sessions
Alt+T            → Tmux windows
```

### Shell Utilities
```
Ctrl+R           → History search
Alt+E            → Environment variables
Alt+N            → Quick notes
Alt+=            → Calculator
Alt+S            → SSH hosts
```

### Buffer Operations
```
Alt+W            → Copy buffer to clipboard
Alt+V            → Paste from clipboard
Ctrl+X Ctrl+E    → Edit command in $EDITOR
Alt+.            → Insert last output
Esc Esc          → Toggle sudo
```

### Misc
```
Ctrl+L           → Clear with scrollback
Alt+T            → Insert timestamp
Alt+D            → Insert date
```

---

## MENU COMPARISON MATRIX

| Feature | Core Menu | Command Palette | Doc Menu |
|---------|-----------|-----------------|----------|
| **Total Options** | 80+ (across 8 categories) | 17 quick commands | 10 doc operations |
| **Navigation Style** | Hierarchical (2 levels) | Flat list | Hierarchical |
| **Primary Keybind** | Ctrl+Space | Ctrl+P | Ctrl+X ? |
| **Access Speed** | 2 selections | 1 selection | 2 selections |
| **Best For** | Exploration, discovery | Quick known tasks | Documentation mgmt |
| **Preview Type** | Dynamic by category | Command description | Document content |
| **Multi-select** | Context-dependent | Yes (most options) | Limited |
| **Customization** | Via menu structure | Via widget code | Via doc templates |
| **Data Source** | Functions/commands | Static list | Markdown files |
| **Learning Curve** | Medium | Low | Medium |
| **Comprehensiveness** | Complete (all features) | Essentials only | Docs only |

---

## CONFIGURATION FILES

```
/home/theron/.core/.sys/cfg/zsh/
├── modules/
│   ├── main-menu.zsh              # Core menu system (8 categories)
│   ├── widgets.zsh                # Basic widgets (32 total)
│   ├── widgets-advanced.zsh       # Advanced widgets (10 specialized)
│   ├── documentation.zsh          # Doc menu system
│   └── widget-registry.zsh        # Auto-registration
│
├── integrations/
│   └── fzf.zsh                    # FZF helpers (28 functions)
│
├── functions/
│   └── fzf-theme                  # Theme/layout system
│
├── 03-widgets.zsh                 # Universal overlay widget
├── 04-keybindings.zsh             # Keybinding setup
└── 02-zinit.zsh                   # zvm_after_init bindings
```

---

## CONCEPTUAL ORGANIZATION

```
┌─────────────────────────────────────────────────────────┐
│              FZF MENU ECOSYSTEM LAYERS                  │
└─────────────────────────────────────────────────────────┘

LAYER 1: Entry Points (3 main menus)
   ├─ core-menu        → Comprehensive hierarchical hub
   ├─ command-palette  → Quick flat launcher
   └─ doc-menu         → Documentation system

LAYER 2: Category Submenus (8 core-menu categories)
   ├─ FZF Customization
   ├─ File Operations
   ├─ Git Operations
   ├─ System Tools
   ├─ Tmux Integration
   ├─ Shell Utilities
   ├─ Documentation
   └─ Development

LAYER 3: Widgets (42 total)
   ├─ Basic Widgets (32)      → General-purpose tools
   └─ Advanced Widgets (10)   → Specialized management

LAYER 4: Helpers (28 total)
   ├─ Git Helpers (2)
   ├─ System Helpers (11)
   └─ FZF Theme System (15)

LAYER 5: Integration
   ├─ FZF base configuration
   ├─ fzf-tab theme integration
   └─ keybinding management
```

---

## USAGE RECOMMENDATIONS

### When to use CORE MENU (Ctrl+Space)
- Exploring available features
- Accessing infrequently-used tools
- Need category-based organization
- Want to discover what's available
- Configuring FZF appearance
- Comprehensive system management

### When to use COMMAND PALETTE (Ctrl+P)
- Quick access to common tasks
- Know what you want to do
- Muscle memory for Ctrl+P
- Fast command execution
- Working with files/git/tmux frequently

### When to use DOC MENU (Ctrl+X ?)
- Need documentation
- Want to search docs
- Creating/editing documentation
- Learning about functions/widgets
- Browsing reference material

### When to use Direct Keybindings
- Extremely frequent operations
- Speed is critical
- Single-purpose actions
- Muscle memory established

Example workflow:
1. Start with core-menu to explore
2. Graduate to command-palette for common tasks
3. Learn direct keybinds for your top 10 operations
4. Use doc-menu when you forget syntax or need help

---

## STATISTICS SUMMARY

**Total Components:**
- 3 main menu systems
- 8 core-menu categories
- 42 ZLE widgets (32 basic + 10 advanced)
- 28 helper functions
- 40+ keybindings
- 10+ color themes
- 10+ layout configurations
- ~3000+ lines of FZF code

**Most Comprehensive:** core-menu (80+ options across 8 categories)
**Fastest Access:** command-palette (17 one-selection commands)
**Most Specialized:** doc-menu (documentation-focused)

**Code Distribution:**
- Main menu: ~400 lines
- Widgets: ~1200 lines
- Helpers: ~800 lines
- Theme system: ~600 lines

---

## NOTES

- All menus use consistent FZF theming (synchronized colors)
- Multi-select is available in most widgets (Ctrl+A/Ctrl+D/Tab)
- Preview windows are context-aware (file content, git diff, systemd status, etc.)
- Most actions have confirmation for destructive operations
- Widget registry auto-registers all widgets for introspection
- Documentation system can auto-generate docs from code comments
- Theme/layout changes apply instantly across all FZF interfaces

---

*Generated: 2026-01-03*
*Configuration: /home/theron/.core/.sys/cfg/zsh*
*Total FZF Components: 100+*
