# FZF Theme and Layout System

A comprehensive theming and layout management system for fzf with persistent preferences, robust error handling, and seamless fzf-tab integration.

## Features

- **Color Themes**: 8 built-in color themes (Catppuccin, Tokyo Night, Dracula, etc.)
- **Layouts**: 9 layout presets (Classic, Minimal, Centered, Fullscreen, etc.)
- **Persistence**: Theme and layout preferences survive shell restarts
- **Live Preview**: Interactive theme browser with preview
- **Error Handling**: Robust preview scripts that gracefully degrade
- **fzf-tab Integration**: Themes automatically apply to tab completions

## Quick Start

```zsh
# Interactive theme selector
fzf-themes

# Interactive layout selector
fzf-layouts

# Combined appearance menu
fzf-appearance

# Apply theme directly
fzf-theme-apply "catppuccin-mocha"

# Apply layout directly
fzf-layout-apply "centered"

# List all available themes
fzf-theme-list

# List all available layouts
fzf-layout-list

# Show current configuration
fzf-current
```

## Available Themes

| Theme | Category | Description |
|-------|----------|-------------|
| Catppuccin Mocha | dark | Soothing pastel dark theme |
| Catppuccin Macchiato | dark | Pastel dark with warm undertones |
| Tokyo Night | dark | Tokyo city lights inspired |
| Dracula | dark | Classic dark with vibrant colors |
| Gruvbox Dark | dark | Retro groove dark theme |
| Nord | dark | Arctic, north-bluish clean |
| Rose Pine | dark | Natural pine with soho vibes |
| One Dark | dark | Atom One Dark theme |
| Solarized Dark | dark | Precision colors (Ethan Schoonover) |

## Available Layouts

| Layout | Description |
|--------|-------------|
| Classic | Simple reverse layout with rounded border |
| Minimal | Clean design with no border |
| Centered | Floating centered window with margins |
| Fullscreen | Maximum screen real estate |
| Bottom Up | Traditional bottom-up list style |
| Preview Heavy | Large preview panel (70%) |
| Split Horizontal | Preview below the list |
| Sharp | Angular design with sharp corners |
| Fancy | Decorative style with unicode markers |

## Directory Structure

```
integrations/themes/fzf/
├── README.md                    # This file
├── catppuccin-mocha.zsh        # Color themes
├── catppuccin-macchiato.zsh
├── tokyo-night.zsh
├── dracula.zsh
├── gruvbox-dark.zsh
├── nord.zsh
├── rose-pine.zsh
├── one-dark.zsh
├── solarized-dark.zsh
└── layouts/                     # Layout presets
    ├── classic.zsh
    ├── minimal.zsh
    ├── centered.zsh
    ├── fullscreen.zsh
    ├── bottom-up.zsh
    ├── preview-heavy.zsh
    ├── split-horizontal.zsh
    ├── sharp.zsh
    └── fancy.zsh
```

## Creating Custom Themes

### Color Theme Template

Create a new file in `integrations/themes/fzf/` with `.zsh` extension:

```zsh
# FZF Theme: My Custom Theme
# Description of your theme

FZF_THEME_NAME="My Custom Theme"
FZF_THEME_CATEGORY="dark"  # or "light"

# Color definitions - all fzf color options
FZF_THEME_COLORS=(
    "bg:#282828"         # Background
    "bg+:#3c3836"        # Selection background
    "fg:#ebdbb2"         # Foreground
    "fg+:#fbf1c7"        # Selection foreground
    "hl:#fe8019"         # Highlight
    "hl+:#fe8019"        # Highlight in selection
    "info:#83a598"       # Info text
    "marker:#b8bb26"     # Multi-select marker
    "pointer:#fb4934"    # Pointer arrow
    "prompt:#fabd2f"     # Prompt
    "spinner:#d3869b"    # Loading spinner
    "header:#8ec07c"     # Header text
    "border:#504945"     # Border color
    "label:#fabd2f"      # Border label
    "query:#ebdbb2"      # Query text
    "gutter:#282828"     # Line numbers background
    "separator:#3c3836"  # Separator line
    "scrollbar:#d79921"  # Scrollbar color
    "preview-bg:#282828" # Preview background
    "preview-fg:#ebdbb2" # Preview foreground
    "preview-border:#3c3836"
)

# Optional: Override layout settings
FZF_THEME_LAYOUT=(
    "--height=80%"
    "--layout=reverse"
    "--border=rounded"
)

# Optional: Custom prompt characters
FZF_THEME_PROMPT='> '
FZF_THEME_POINTER='>'
FZF_THEME_MARKER='*'

# Optional: Header position
FZF_THEME_HEADER_FIRST=true
```

### Layout Template

Create a new file in `integrations/themes/fzf/layouts/` with `.zsh` extension:

```zsh
# FZF Layout: My Custom Layout
# Short description

FZF_LAYOUT_NAME="My Custom Layout"
FZF_LAYOUT_DESC="Description shown in layout list"

FZF_LAYOUT_OPTS=(
    "--height=60%"
    "--layout=reverse"
    "--border=rounded"
    "--info=inline"
    "--margin=2,4"
    "--padding=1"
    "--preview-window=right:50%:wrap"
)

FZF_LAYOUT_PROMPT='> '
FZF_LAYOUT_POINTER='>'
FZF_LAYOUT_MARKER='*'
```

## Configuration Files

Theme preferences are stored in:
- `$XDG_STATE_HOME/fzf/current-theme` - Current color theme
- `$XDG_STATE_HOME/fzf/current-layout` - Current layout

To reset to defaults:
```zsh
rm -f ~/.local/state/fzf/current-*
fzf-theme-init
```

## Integration with fzf-tab

The theme system automatically configures fzf-tab with matching colors. No additional configuration required.

## Preview System

### File Preview Script

Located at: `$CORE_CFG/zsh/tools/fzf-preview`

Features:
- Automatic file type detection
- Syntax highlighting with bat/batcat
- Image preview with chafa/kitty
- Archive listing
- PDF text extraction
- Media file info
- Binary file detection
- Graceful fallbacks when tools unavailable

### fzf-tab Completions

Located at: `$CORE_CFG/zsh/functions/widgets/fzf-preview`

Provides context-aware previews for:
- Files and directories
- Git operations (diff, log, checkout, stash)
- Process management (kill, pkill)
- System services (systemctl, journalctl)
- Package management (pacman, yay, paru)
- Docker operations
- SSH hosts
- Environment variables
- And more...

All previews include:
- Empty input handling
- Tool availability checks
- Fallback chains
- Error suppression

## Keybindings

Default fzf keybindings (configured by theme system):

| Key | Action |
|-----|--------|
| Ctrl-/ | Toggle preview |
| Ctrl-A | Select all |
| Ctrl-D | Deselect all |
| Ctrl-Y | Copy selection to clipboard |
| Ctrl-U | Preview page up |
| Ctrl-N | Preview page down |
| Alt-J | Preview down |
| Alt-K | Preview up |
| Ctrl-F | Page down |
| Ctrl-B | Page up |
| Tab | Move down |
| Shift-Tab | Move up |
| Enter | Accept selection |

## Troubleshooting

### Theme not applying
```zsh
# Reinitialize theme system
fzf-theme-init

# Check current settings
fzf-current

# Force rebuild FZF_DEFAULT_OPTS
_fzf_rebuild_opts
```

### Preview not working
```zsh
# Test preview script directly
$CORE_CFG/zsh/tools/fzf-preview /path/to/file

# Check if required tools are installed
which bat eza chafa
```

### fzf-tab not using theme colors
```zsh
# The theme is applied when fzf-tab loads
# Try reloading your shell or:
source $CORE_CFG/zsh/functions/fzf-theme
fzf-theme-init
```

## Functions Reference

| Function | Description |
|----------|-------------|
| `fzf-theme-select` | Interactive color theme selector |
| `fzf-layout-select` | Interactive layout selector |
| `fzf-appearance` | Combined theme/layout menu |
| `fzf-theme-apply <name>` | Apply a specific theme |
| `fzf-layout-apply <name>` | Apply a specific layout |
| `fzf-theme-list` | List available themes |
| `fzf-layout-list` | List available layouts |
| `fzf-theme-init` | Initialize/reload saved preferences |
| `fzf-show-current` | Show current configuration |
| `fzf-theme-preview` | Live cycle through themes |

## Aliases

| Alias | Command |
|-------|---------|
| `fzf-themes` | `fzf-theme-select` |
| `fzf-layouts` | `fzf-layout-select` |
| `fzf-colors` | `fzf-theme-select` |
| `fzf-style` | `fzf-appearance` |
| `fzf-current` | `fzf-show-current` |
