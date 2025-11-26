# TMUX Menu Themes

This directory contains theme configurations for TMUX menus.

## Available Themes

### Your Custom Themes (Based on Your Color Palette)

1. **chaoscore** (Default) - Your current theme with cyan/teal accents
2. **neon-nights** - Electric neon colors on deep black
3. **purple-haze** - Purple/violet theme with soft accents
4. **ocean-deep** - Deep blue/teal theme with aqua accents
5. **forest-glade** - Green/lime theme with natural tones
6. **sunset-amber** - Warm orange/amber/gold theme
7. **sakura-pink** - Soft pink/coral theme
8. **nord-ice** - Cool icy theme inspired by Nord

### Popular Community Themes

9. **dracula** - Classic Dracula theme
10. **gruvbox-dark** - Warm retro Gruvbox
11. **tokyo-night** - Popular Tokyo Night theme
12. **catppuccin-mocha** - Soft pastel Catppuccin
13. **one-dark** - Atom One Dark theme
14. **monokai** - Classic Monokai/Sublime
15. **solarized-dark** - Professional Solarized
16. **material** - Google Material Design

## Usage

### Using the Theme Switcher

```bash
# Show interactive theme menu
~/.core/.sys/cfg/tmux/modules/themes/theme-switcher.sh

# Or use keybinding (if configured):
# <prefix> + T
```

### Command Line Usage

```bash
# List all themes
~/.core/.sys/cfg/tmux/modules/themes/theme-switcher.sh list

# Get current theme
~/.core/.sys/cfg/tmux/modules/themes/theme-switcher.sh current

# Set a specific theme
~/.core/.sys/cfg/tmux/modules/themes/theme-switcher.sh set neon-nights

# Preview theme colors
~/.core/.sys/cfg/tmux/modules/themes/theme-switcher.sh preview ocean-deep
```

### Manual Theme Loading

```bash
# From within tmux
:source-file ~/.core/.sys/cfg/tmux/conf/themes/purple-haze.conf
```

## Theme Structure

Each theme file defines these settings:

```conf
set -g menu-style "fg=<color>,bg=<color>"                # Normal menu items
set -g menu-selected-style "fg=<color>,bg=<color>,bold"  # Selected items
set -g menu-border-style "fg=<color>"                    # Border color
set -g menu-border-lines "rounded"                       # Border style
```

Plus inline colors for:
- Title: Used in menu titles (inline with `#[fg=<color>,bold]`)
- Section separators: Used for menu dividers

## Creating Your Own Theme

1. Copy an existing theme file:
   ```bash
   cp chaoscore.conf my-theme.conf
   ```

2. Edit the colors to your preference

3. Test it:
   ```bash
   tmux source-file ~/.core/.sys/cfg/tmux/conf/themes/my-theme.conf
   ```

4. Set it permanently:
   ```bash
   ~/.core/.sys/cfg/tmux/modules/themes/theme-switcher.sh set my-theme
   ```

## Color Reference

Your color palette is defined in `~/.core/.sys/cfg/themes/colors.zsh` with these categories:

- **Neon/Blazing** (S:100% L:50%) - Pure, maximum intensity
- **Base/Radiant** (S:95% L:60%) - Brilliant and glowing
- **Electric** (S:85% L:55%) - Sharp and energetic
- **Hot/Lucid** (S:90% L:70%) - Clear and luminous
- **Jewel/Crisp** (S:70% L:50%) - Clean and defined
- **Dusk/Subtle** (S:45% L:50%) - Understated elegance
- **Ice Variants** - Subtle, desaturated tones
- **Light Variants** - Soft, pale tones
- **Deep/Dark Variants** - Deep, muted tones

## Theme Persistence

The current theme is saved in `~/.local/state/tmux/current-menu-theme` and automatically loaded when tmux starts.
