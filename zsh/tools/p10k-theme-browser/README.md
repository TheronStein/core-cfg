# Powerlevel10k Theme Browser

Interactive theme browser for Powerlevel10k prompts, inspired by WezTerm's theme browser.

## Features

- 🎨 **20+ pre-configured themes** including popular color schemes
- 👁️ **Live preview** of how themes will look in your prompt
- 📁 **Category filtering** (dark, light, vibrant, minimal, etc.)
- 💾 **Automatic backups** before applying changes
- 🔍 **FZF integration** for smooth browsing experience

## Usage

### Quick Start

```bash
# Launch the theme browser
p10k-themes

# Or use the full path
~/.core/.sys/dev/zsh/tools/p10k-theme-browser/browser.sh
```

### Keyboard Navigation

- **↑/↓** - Navigate through themes
- **Enter** - Select and apply theme
- **Tab** - Toggle category filter
- **Ctrl-/** - Toggle preview panel
- **Ctrl-C / Esc** - Cancel and exit

### Available Themes

#### Dark Themes
- **Monokai Dark** - Dark theme with orange accents
- **Dracula** - Popular Dracula theme colors
- **Nord** - Arctic-inspired colors
- **Tokyo Night** - Japanese night theme
- **Catppuccin Mocha** - Warm, cozy colors
- **Gruvbox Dark** - Retro groove colors
- **One Dark** - Atom's One Dark
- **Solarized Dark** - Classic Solarized

#### Light Themes
- **Gruvbox Light** - Light variant of Gruvbox
- **Solarized Light** - Bright Solarized

#### Vibrant Themes
- **Cyan Wave** - Cyan and teal
- **Purple Dream** - Purple and magenta
- **Material** - Material design colors

#### And more categories: Nature, Cool, Minimal, Classic

## File Structure

```
p10k-theme-browser/
├── browser.sh           # Main browser script
├── preview.sh           # Theme preview generator
├── data/
│   └── themes.json      # Theme definitions
└── README.md           # This file
```

## Adding Custom Themes

Edit `data/themes.json` to add your own themes:

```json
{
  "name": "My Custom Theme",
  "description": "Description of the theme",
  "category": "custom",
  "colors": {
    "dir_background": 4,
    "dir_foreground": 254,
    "vcs_clean_background": 2,
    "vcs_modified_background": 3,
    "vcs_untracked_background": 2,
    "prompt_char_ok": 76,
    "prompt_char_error": 196
  }
}
```

### Color Code Reference

Use 256-color terminal codes (0-255). See the color chart:

```bash
for i in {0..255}; do printf "\x1b[48;5;${i}m %3d \x1b[0m" $i; (( (i+1) % 16 == 0 )) && echo; done
```

Popular colors:
- 0-7: Basic colors (black, red, green, yellow, blue, magenta, cyan, white)
- 8-15: Bright variants
- 16-231: 216 RGB colors
- 232-255: 24 grayscale shades

## Backup and Restore

The browser automatically creates backups before applying themes:

```bash
# Backups are saved as:
~/.p10k.zsh.backup.YYYYMMDD_HHMMSS

# To restore a backup:
cp ~/.p10k.zsh.backup.YYYYMMDD_HHMMSS ~/.p10k.zsh
exec zsh
```

## Dependencies

- `fzf` - Fuzzy finder for browsing
- `jq` - JSON processor for theme data

## Integration with ZSH Config

The theme browser is automatically available via the `p10k-themes` function/alias.

To use it:
```bash
p10k-themes
```

## Credits

Inspired by the WezTerm theme browser system.
