# Yazi Profile System

This directory contains profile-specific configurations for different yazi use cases. Each profile inherits from the global configuration and only overrides specific settings.

## Profile Structure

Each profile uses **symlinks** to inherit from the global configuration:
- `init.lua` → `../../init.lua` (plugins and custom functions)
- `keymap.toml` → `../../keymap.toml` (keybindings)
- `theme.toml` → `../../theme.toml` (colors and appearance)
- `package.toml` → `../../package.toml` (plugin dependencies)
- `plugins` → `../../plugins/` (plugin code)
- `flavors` → `../../flavors/` (color schemes)

Only `yazi.toml` is profile-specific and contains **minimal overrides**.

## Available Profiles

### sidebar-left (Navigator)
**Purpose**: File list navigation pane for dual-pane mode
**Override**: `ratio = [0, 1, 0]` - Shows only current file list
**Title**: `Navigator: {cwd}`

**Usage**:
```bash
YAZI_CONFIG_HOME=~/.core/.sys/cfg/yazi/profiles/sidebar-left yazi
```

### sidebar-right (Preview)
**Purpose**: Preview pane for dual-pane mode (synchronized with left pane)
**Override**: `ratio = [0, 0, 1]` - Shows only preview column
**Title**: `Preview: {cwd}`

**Usage**:
```bash
YAZI_CONFIG_HOME=~/.core/.sys/cfg/yazi/profiles/sidebar-right yazi
```

### nvim
**Purpose**: Profile optimized for Neovim integration
**Usage**: Automatically used by yazi.nvim plugin

### dev
**Purpose**: Development profile for testing new configurations

## Inheritance Model

```
Global Config (../../)
├── yazi.toml       (manager, tasks, input, opener, etc.)
├── keymap.toml     (all keybindings)
├── theme.toml      (visual styling)
├── init.lua        (plugins, functions, DDS setup)
└── package.toml    (plugin dependencies)

Profile (e.g., sidebar-left/)
├── yazi.toml       (ONLY [mgr].ratio and title_format)
├── init.lua → ../../init.lua  (symlink)
├── keymap.toml → ../../keymap.toml  (symlink)
├── theme.toml → ../../theme.toml  (symlink)
├── package.toml → ../../package.toml  (symlink)
├── plugins → ../../plugins/  (symlink)
└── flavors → ../../flavors/  (symlink)
```

## Profile Configuration Guidelines

When creating a new profile:

1. **Create minimal `yazi.toml`**:
   - Only override what's necessary
   - Keep it under 20 lines
   - Document what you're changing and why

2. **Symlink everything else**:
   ```bash
   cd profiles/new-profile
   ln -s ../../init.lua init.lua
   ln -s ../../keymap.toml keymap.toml
   ln -s ../../theme.toml theme.toml
   ln -s ../../package.toml package.toml
   ln -s ../../plugins plugins
   ln -s ../../flavors flavors
   ```

3. **Test the profile**:
   ```bash
   YAZI_CONFIG_HOME=~/.core/.sys/cfg/yazi/profiles/new-profile yazi
   ```

## Dual-Pane Integration

The `sidebar-left` and `sidebar-right` profiles are designed to work together:

- **Left pane** (Navigator): User navigates files, hovers trigger DDS events
- **Right pane** (Preview): Receives DDS `reveal` commands to update preview
- **Sync**: Both panes share the same `cd` state and file operations

This is managed by the yazi.nvim dual-pane module (see: `~/.core/.proj/plugins/nvim/yazi.nvim/lua/yazi/dual_pane/`)

## Archived Configurations

Old duplicate configurations have been archived to `.ref/conf-backup-YYYYMMDD/`

These contained full copies of keymap.toml and yazi.toml which created maintenance issues when updating global settings.
