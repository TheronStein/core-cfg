# Snippets Directory

This directory contains local zsh scripts that are sourced directly.

## Usage

Snippets are loaded in `.zshrc` with:
```zsh
zt light-mode is-snippet for $ZDOTDIR/snippets/*.zsh
```

## Examples

- `git-helpers.zsh` - Git workflow shortcuts
- `docker-helpers.zsh` - Docker utility functions
- `project-shortcuts.zsh` - Project-specific aliases
- `color-theme.zsh` - Terminal color customizations

Snippets are best for:
- Quick helper functions
- Project-specific configurations
- Experimental code
- Local customizations that don't need a full plugin
