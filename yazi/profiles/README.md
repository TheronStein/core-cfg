# Yazi Profiles

This directory contains profile-specific configurations for yazi that override the main configuration for specific use cases.

## Structure

```
yazi/
├── yazi.toml          # Main config (ratio [1,5,3]: parent + current + preview)
├── keymap.toml        # Main keymaps
├── init.lua           # Main initialization
├── plugins/           # All plugins
├── flavors/           # All themes
├── theme.toml         # Current theme
├── package.toml       # Plugin dependencies
└── profiles/          # Profile-specific overrides
    ├── sidebar-left/  # Left sidebar profile (navigation only)
    │   ├── yazi.toml  # Ratio [0,1,0]: current column only
    │   └── * → ../../ # All other configs symlinked to main
    └── sidebar-right/ # Right sidebar profile (preview only)
        ├── yazi.toml  # Ratio [0,0,1]: preview column only
        ├── init.lua   # Minimal init (just borders/status)
        └── * → ../../ # All other configs symlinked to main
```

## Usage

Profiles are activated by setting `YAZI_CONFIG_HOME`:

```bash
# Main yazi (full 3-column layout)
YAZI_CONFIG_HOME="$CORE_CFG/yazi" yazi

# Left sidebar (navigation only)
YAZI_CONFIG_HOME="$CORE_CFG/yazi/profiles/sidebar-left" yazi

# Right sidebar (preview only)
YAZI_CONFIG_HOME="$CORE_CFG/yazi/profiles/sidebar-right" yazi
```

## Automatic Usage

The yazibar tmux module automatically uses these profiles:

- **Left sidebar** (`Alt+f`): Uses `profiles/sidebar-left` for file navigation
- **Right sidebar** (`Alt+F`): Uses `profiles/sidebar-right` for previews

## Profile Characteristics

### sidebar-left
- **Ratio**: `[0, 1, 0]` - Shows only current directory listing
- **Purpose**: File navigation in narrow tmux pane (~30% width)
- **Plugins**: Full plugin support (symlinked from main)
- **Keymaps**: Full keymap support (symlinked from main)

### sidebar-right
- **Ratio**: `[0, 0, 1]` - Shows only preview column
- **Purpose**: File/directory previews in narrow tmux pane (~25% width)
- **Plugins**: Full plugin support (symlinked from main)
- **Init**: Custom minimal init.lua (borders and status only)
- **Keymaps**: Full keymap support (symlinked from main)

## Environment Variables

All paths use environment variables for portability:

- `$YAZI_CONFIG_HOME` - Main yazi config directory (defaults to `$CORE_CFG/yazi`)
- `$CORE_CFG` - Core configuration directory (`~/.core/.sys/cfg`)

This ensures the configuration remains portable across environment changes.

## Adding New Profiles

To create a new profile:

1. Create directory: `mkdir -p $CORE_CFG/yazi/profiles/my-profile`
2. Create custom `yazi.toml` with desired `ratio`
3. Symlink shared configs:
   ```bash
   cd $CORE_CFG/yazi/profiles/my-profile
   ln -sf ../../plugins plugins
   ln -sf ../../flavors flavors
   ln -sf ../../theme.toml theme.toml
   ln -sf ../../keymap.toml keymap.toml
   ln -sf ../../init.lua init.lua
   ln -sf ../../package.toml package.toml
   ```
4. Optional: Create custom `init.lua` if needed

## Benefits

- **No redundant directories** - Single `yazi/` directory, profiles nested inside
- **Shared configuration** - Plugins, keymaps, themes all in one place
- **Environment-portable** - Uses `$CORE_CFG` instead of hardcoded paths
- **Easy to maintain** - Update main config, all profiles inherit changes
- **Clean organization** - No clutter in main config directory
