# TMUX Menu System

Dynamic, hierarchical menu navigation system with automatic parent tracking.

## Features

- **Dynamic Navigation**: Menus automatically track their parent menu
- **Flexible Restructuring**: Move menus around without breaking navigation
- **Automatic Back Buttons**: Each submenu knows how to return to its caller
- **Centralized Theme**: All menus use the global theme from `conf/menu-theme.conf`

## Menu Structure

```
Main Menu (main-menu.sh)
├── Pane Management (mux/pane-menu.sh)
├── Window Management (mux/window-menu.sh)
├── Layout Management (mux/layout-menu.sh)
├── Config Management (config-management.sh)
│   ├── TMUX Config (config/tmux-config-menu.sh)
│   ├── WezTerm Config (config/wezterm-config-menu.sh)
│   ├── ZSH Config (config/zsh-config-menu.sh)
│   ├── ... (other configs)
│   └── Environment configs (env/*.sh)
└── App Management (app-management.sh)
    ├── Other Tools (other/*.sh)
    └── Media (media/*.sh)
```

## How It Works

### Navigation Tracking

The system uses `menu-nav.sh` to track parent-child relationships:

1. When a menu opens a submenu, it records the relationship
2. The submenu's "Back" button reads this relationship
3. Back button dynamically points to the correct parent

### Creating a New Menu

**Template for a parent menu (opens submenus):**

```bash
#!/bin/bash
# My Menu

MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="my-menu.sh"

# Helper to open submenu with parent tracking
om() {
  "$MENU_NAV" set "$(basename "$1")" "$CURRENT_MENU"
  echo "run-shell '\$TMUX_MENUS/$1'"
}

# Get dynamic back button (optional, for submenus)
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] My Menu " \
  "󰌑 Back" Tab "run-shell '\$TMUX_MENUS/$PARENT'" \
  "" \
  "Submenu 1" 1 "$(om path/to/submenu1.sh)" \
  "Submenu 2" 2 "$(om path/to/submenu2.sh)"
```

**Template for a leaf menu (no submenus):**

```bash
#!/bin/bash
MENU_NAV="$TMUX_MENUS/menu-nav.sh"
CURRENT_MENU="$(basename "$0")"
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")

MY_CFG="$HOME/.config/myapp"

tmux display-menu -x C -y C -T "#[fg=#e0af68,bold] My Config " \
  "󰌑 Back" Tab "run-shell '\$TMUX_MENUS/$PARENT'" \
  "󰈔 Explore Config" e "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MY_CFG\" yazi'" \
  "" \
  "Config File" 1 "run-shell 'tmux display-popup -E -w 90% -h 90% -d \"$MY_CFG\" \"\$EDITOR config.conf\"'"
```

## Key Components

### menu-nav.sh

Core navigation tracking system:

```bash
# Set parent for a menu
menu-nav.sh set CURRENT_MENU PARENT_MENU

# Get parent of a menu
menu-nav.sh get CURRENT_MENU [DEFAULT]

# Navigate back to parent
menu-nav.sh back CURRENT_MENU

# Clear navigation history
menu-nav.sh clear
```

### Navigation State

Stored in `~/.local/state/tmux/menu-nav/`
- Each menu's parent is stored as `{menu-name}.parent`
- Automatically created when navigating
- Can be cleared with `menu-nav.sh clear`

## Best Practices

### 1. Use the `om()` Helper

```bash
# Good - tracks navigation
"Submenu" 1 "$(om path/to/submenu.sh)"

# Bad - breaks navigation
"Submenu" 1 "run-shell '$TMUX_MENUS/path/to/submenu.sh'"
```

### 2. Use Dynamic Back Buttons

```bash
# Good - dynamic parent
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")
"󰌑 Back" Tab "run-shell '\$TMUX_MENUS/$PARENT'"

# Bad - hardcoded parent
"󰌑 Back" Tab "run-shell '$TMUX_MENUS/main-menu.sh'"
```

### 3. Consistent Menu Naming

```bash
# Use basename for CURRENT_MENU
CURRENT_MENU="my-menu.sh"  # Good
CURRENT_MENU="$(basename "$0")"  # Also good, auto-detects

# Don't use full paths
CURRENT_MENU="$TMUX_MENUS/my-menu.sh"  # Bad
```

### 4. Provide Default Parents

```bash
# Always provide a fallback
PARENT=$("$MENU_NAV" get "$CURRENT_MENU" "main-menu.sh")
```

## Reorganizing Menus

To move a menu to a different parent:

1. Move the menu file wherever you want
2. Update the parent menu to call it with `om()`
3. No changes needed in the child menu itself!

**Example:**

Moving `spotify-config-menu.sh` from main menu to app management:

```bash
# In app-management.sh
"󰓇 Spotify Config" S "$(om media/spotify-config-menu.sh)"
```

The menu automatically knows to return to app-management.sh instead of main-menu.sh!

## Troubleshooting

### Back Button Goes to Wrong Menu

```bash
# Clear navigation history
~/.core/.sys/cfg/tmux/modules/menus/menu-nav.sh clear

# Then navigate normally through menus to rebuild relationships
```

### Menu Not Found

Check symlinks:
```bash
ls -la ~/.core/.sys/cfg/tmux/modules/menus/mux/
ls -la ~/.core/.sys/cfg/tmux/modules/menus/tmux/
```

Required symlinks:
- `mux/pane-menu.sh` → `../pane-menu.sh`
- `mux/window-menu.sh` → `../window-menu.sh`
- `mux/layout-menu.sh` → `../layout-menu.sh`
- `mux/sidebar-menu.sh` → `../sidebar-menu.sh`
- `tmux/session-menu.sh` → `../session-menu.sh`
- `tmux/plugin-menu.sh` → `../plugin-menu.sh`
- `modes/pane-resize-select.sh` → `../mux/pane-resize-select.sh`

## Theme Customization

All menus use the global theme from `conf/menu-theme.conf`:

```bash
# Change theme
tmux source-file ~/.core/.sys/cfg/tmux/conf/themes/purple-haze.conf

# Or use the theme switcher (Alt+F12)
~/.core/.sys/cfg/tmux/modules/themes/theme-switcher.sh
```

See `conf/themes/README.md` for available themes.
