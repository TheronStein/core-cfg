# Yazi Configuration Profiles

This directory contains different yazi configuration profiles that inherit from the main yazi configuration while providing specific customizations.

## Structure

```
~/.core/cfg/yazi/
├── init.lua              # Main init - loads all plugins
├── keymap.toml           # Main keymaps
├── package.toml          # Plugin dependencies
├── theme.toml            # Main theme
├── yazi.toml             # Main config
├── plugins/              # All plugins (shared)
├── flavors/              # Themes (shared)
└── conf/                 # Configuration profiles
    ├── sidebar-left/     # Left navigation sidebar
    │   ├── init.lua      -> ../init.lua (symlink - inherits)
    │   ├── keymap.toml   # CUSTOM: Main + yazibar-sync
    │   └── yazi.toml     # CUSTOM: ratio = [0, 1, 0]
    ├── sidebar-right/    # Right preview sidebar
    │   ├── init.lua      # CUSTOM: Minimal plugins
    │   ├── keymap.toml   # CUSTOM: Your keymaps
    │   └── yazi.toml     # CUSTOM: ratio = [0, 0, 1]
    ├── nvim/             # Neovim integration profile
    ├── dev/              # Development profile
    └── work/             # Work profile
```

## Configuration Profiles

### sidebar-left
**Purpose**: Left navigation sidebar for yazibar dual-pane setup

**Inheritance**:
- ✓ `init.lua` - Symlinked to main (all plugins loaded)
- ✓ `plugins/` - Shared directory
- ✓ `flavors/` - Shared directory
- ✗ `keymap.toml` - **Generated** from main with yazibar-sync integration
- ✗ `yazi.toml` - Custom ratio `[0, 1, 0]` for navigation focus

**Special Features**:
- All navigation keys (i/k/j/L, arrows) append `plugin yazibar-sync`
- Publishes hovered file path to tmux for right sidebar sync
- Auto-generated from main keymap - run `~/.core/cfg/yazi/scripts/generate-sidebar-keymap.sh` to regenerate

**Used by**: `~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-left.sh`

### sidebar-right
**Purpose**: Right preview sidebar for yazibar dual-pane setup

**Inheritance**:
- ✗ `init.lua` - **Minimal** (only full-border, yatline, simple-status)
- ✓ `plugins/` - Shared directory (but only loads specific ones)
- ✓ `flavors/` - Shared directory
- ✗ `keymap.toml` - Your custom keymaps (fuse-archive, wallpaper-dir, nvim-image-paste)
- ✗ `yazi.toml` - Custom ratio `[0, 0, 1]` for preview-only mode

**Special Features**:
- Preview-only display (no parent/current columns)
- Synchronized with left sidebar via yazibar-sync-watcher
- Uses built-in preview system (no custom previewers)

**Used by**: `~/.core/cfg/tmux/modules/yazibar/scripts/yazibar-right.sh`

## How Yazibar Uses These Configs

When you toggle the sidebars with `Alt+f` and `Alt+Shift+F`:

1. **Left sidebar** (`Alt+f`):
   ```bash
   export YAZI_CONFIG_HOME="$HOME/.core/cfg/yazi/conf/sidebar-left"
   yazi
   ```
   - Uses navigation-focused layout (current column only)
   - Every navigation key publishes hovered file to tmux option `@yazibar-hovered-file`
   - Shares all plugins with main yazi

2. **Right sidebar** (`Alt+Shift+F`):
   ```bash
   export YAZI_CONFIG_HOME="$HOME/.core/cfg/yazi/conf/sidebar-right"
   yazi
   ```
   - Uses preview-only layout (preview column only)
   - Watches tmux option `@yazibar-hovered-file` and previews that file
   - Minimal plugin load for performance

## Maintaining Sidebar Configs

### When you update main keymap.toml

Regenerate sidebar-left keymap to pick up changes:

```bash
~/.core/cfg/yazi/scripts/generate-sidebar-keymap.sh
```

This ensures sidebar-left always has your latest keymaps + yazibar-sync integration.

### When you add new plugins

1. Add to `package.toml` (shared)
2. Run `ya pack -i` (installs to shared `plugins/`)
3. Both sidebars can use it (if loaded in their `init.lua`)

## Migration from Old Structure

**Old (deprecated)**:
```
~/.core/cfg/yazi-sidebar-left/     # Separate directory
~/.core/cfg/yazi-sidebar-right/    # Separate directory
```

**New (current)**:
```
~/.core/cfg/yazi/conf/sidebar-left/
~/.core/cfg/yazi/conf/sidebar-right/
```

**Benefits**:
- ✓ Plugins/flavors automatically shared
- ✓ Easier to maintain - inheritance clear
- ✓ Keymaps generated from main (no drift)
- ✓ All configs in one place

The old directories can be safely removed after verifying the new structure works.

## Yazibar-Sync Plugin

The `yazibar-sync.yazi` plugin should be moved to the development workflow:

```bash
# Move to dev directory
mv ~/.core/cfg/yazi/plugins/yazibar-sync.yazi ~/.core/cfg/yazi/dev/

# Set up as git repo (following dev/CUSTOM_PLUGIN_WORKFLOW.md)
cd ~/.core/cfg/yazi/dev/yazibar-sync.yazi
git init
git add .
git commit -m "Initial commit: Yazibar sync plugin"
gh repo create yazibar-sync.yazi --public --source=. --push
```

Then add to `package.toml`:
```toml
[[plugin.deps]]
use = "yourusername/yazibar-sync"
```

## See Also

- `/home/theron/.core/cfg/yazi/dev/CUSTOM_PLUGIN_WORKFLOW.md` - Plugin development
- `/home/theron/.core/cfg/tmux/modules/yazibar/README.md` - Yazibar documentation
- `/home/theron/.core/cfg/tmux/modules/yazibar/ARCHITECTURE.md` - Yazibar architecture
