# WezTerm Keymap Browser

An interactive FZF-based browser for exploring all your WezTerm keybindings organized by modifier keys and key tables (modes).

## Features

- **Category View**: Browse keymaps organized by modifiers (CTRL, SUPER, LEADER, etc.) or key tables/modes
- **Detailed Preview**: See descriptions and context for each keybinding
- **Fuzzy Search**: Quickly find the keybinding you're looking for
- **Auto-Generated**: Automatically scans your active keymap configuration

## Usage

### Launch the Browser

Press `LEADER + F4` (default: `Super+Space` then `F4`)

Or run directly:
```bash
~/.core/cfg/wezterm/scripts/keymap-browser/keymap-browser.sh
```

### Navigation

**Category List:**
- `↑/↓` or `PageUp/PageDown` - Navigate categories
- `Enter` - View keybinds in selected category
- `Esc` - Exit browser
- `Ctrl-/` - Toggle preview panel
- Type to fuzzy search categories

**Keybind List:**
- `↑/↓` or `PageUp/PageDown` - Navigate keybinds
- `Esc` or `Alt+←` - Return to category list
- `Ctrl-/` - Toggle preview panel
- Type to fuzzy search keybinds

## Categories

The browser organizes keymaps into these types:

### Modifier Categories
- **Direct Keys** - Keys without modifiers (e.g., `F12`)
- **Shift Keys** - `Shift + Key` combinations
- **Control Keys** - `Ctrl + Key` combinations
- **Ctrl+Shift Keys** - `Ctrl + Shift + Key` combinations
- **Super Keys** - `Super/Win + Key` combinations
- **Super+Shift Keys** - `Super + Shift + Key` combinations
- **Leader Keys** - `Leader + Key` combinations
- **Leader+Ctrl Keys** - `Leader + Ctrl + Key` combinations

### Key Table/Mode Categories (⚡)
These are modal keymaps activated by a trigger:
- **Leader Mode** - Leader key modal bindings
- **Resize Mode** - Pane resizing mode
- **Nav Panes** - Pane navigation mode
- **Pane Selection Mode** - Visual pane selection
- **Super Mode** - Super key modal bindings
- **Tmux Mode** - Tmux-style bindings
- **Wez Mode** - WezTerm-specific mode

### Built-in WezTerm Modes

Some WezTerm modes like **copy_mode** are built-in and their keybindings are not part of your custom config. The browser will show which keys *activate* these modes (look for "Enter copy mode"), but the keybindings *within* those modes are WezTerm defaults and won't appear in the browser.

To see copy_mode keybindings, check the [official WezTerm docs](https://wezfurlong.org/wezterm/copymode.html).

## Data Generation

The browser reads from `data/keymaps.json`, which is auto-generated from your active keymap configuration.

### Regenerate Data

Data is automatically generated on first use. To manually regenerate:

```bash
~/.core/cfg/wezterm/scripts/keymap-browser/generate-data.sh
```

This will scan all active keymaps from the `keymaps/` directory:
- `keymaps/keys.lua` - Base keybindings
- `keymaps/mods/*.lua` - Modifier-based keymaps
- `keymaps/modes/*.lua` - Key table/mode definitions

## Requirements

- `fzf` - Fuzzy finder
- `jq` - JSON processor
- WezTerm terminal emulator

## Files

```
scripts/keymap-browser/
├── README.md                    # This file
├── keymap-browser.sh           # Main browser script
├── keymap-preview.sh           # Preview generator
├── generate-data.sh            # Data generation wrapper
├── generate-keymap-data.lua    # Lua data extractor
└── data/
    └── keymaps.json           # Generated keymap data
```

## Customization

### Colors

The browser uses Catppuccin Mocha colors by default. To customize, edit the `--color` flags in `keymap-browser.sh`:

```bash
--color="bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
--color="fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
```

### Preview Layout

Adjust preview window size in `keymap-browser.sh`:

```bash
--preview-window=right:60%:wrap:rounded  # Right side, 60% width
```

Change to:
```bash
--preview-window=down:40%:wrap:rounded   # Bottom, 40% height
```

## Troubleshooting

**No keybinds showing:**
- Run `generate-data.sh` manually to see any errors
- Check that `keymaps/init.lua` properly loads all your keymap modules

**Browser not launching:**
- Verify `fzf` and `jq` are installed
- Check that the script has execute permissions: `chmod +x keymap-browser.sh`

**Outdated keybinds:**
- Regenerate data after modifying keymaps: `./generate-data.sh`
- Consider adding a pre-commit hook to auto-regenerate

## Similar Tools

- `scripts/nerdfont-browser/` - Browse WezTerm nerd font icons
