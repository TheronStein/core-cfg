# Browser Name

Brief description of what this browser does and why it's useful.

## Purpose

Detailed explanation of the browser's purpose and use cases.

## Data Source

Explain where the data comes from and how it's generated:
- Static data (manually curated)
- Generated from system (fonts, configs, etc.)
- Scraped from tools (keymaps, themes, etc.)
- User-provided (bookmarks, snippets, etc.)

## Usage

### From Shell

```zsh
# Basic usage
browser::NAME

# Multi-select mode (if applicable)
browser::NAME::multi

# Update data
browser::NAME::update
```

### As Widget

```zsh
# In your .zshrc or keybindings file
bindkey '^X^N' widget::NAME  # Ctrl+X Ctrl+N (or your preferred binding)
```

Then use the keybinding in any command line.

### From Tmux

Add to your `tmux.conf`:

```tmux
# Popup browser
bind-key N display-popup -E -w 80% -h 80% "zsh -ic 'browser::NAME'"

# Or in a split
bind-key M-n split-window -h "zsh -ic 'browser::NAME'"
```

### From Wezterm

Add to your `wezterm.lua`:

```lua
{
  key = 'N',
  mods = 'CTRL|SHIFT',
  action = wezterm.action.SpawnCommand {
    args = { 'zsh', '-ic', 'browser::NAME' }
  }
}
```

### From Command Line

```bash
# Direct invocation
zsh -ic 'browser::NAME'

# In scripts
zsh -c 'source ~/.zshrc && browser::NAME'
```

## Data Structure

### Location
```
$BROWSER_DATA_DIR/NAME/
├── data.txt         # Main data file
├── metadata.json    # Optional metadata
└── cache/           # Optional cache directory
```

### Format

Describe the data file format:

**Text Format:**
```
item1    description1
item2    description2
```

**JSON Format:**
```json
{
  "items": [
    {
      "name": "item1",
      "value": "value1",
      "description": "Description 1"
    }
  ]
}
```

## Keybindings (in browser)

| Key | Action |
|-----|--------|
| `Enter` | Confirm selection |
| `Esc` | Cancel/Exit |
| `Ctrl+/` | Toggle preview |
| `Ctrl+R` | Reload data |
| `Ctrl+Y` | Copy to clipboard (if applicable) |
| `Tab` | Select and move down (multi-select) |
| `Shift+Tab` | Select and move up (multi-select) |
| `Ctrl+A` | Select all (multi-select) |
| `Ctrl+D` | Deselect all (multi-select) |

## Actions

What happens when you select an item:
- [ ] Copy to clipboard
- [ ] Insert into command line
- [ ] Execute as command
- [ ] Open in editor
- [ ] Custom action (describe)

## Data Generation

### Manual Update

```zsh
browser::NAME::update
```

Or directly:

```zsh
data::generate::NAME
```

### Automatic Update

Describe when/how data is automatically updated (if applicable):
- On first run
- When source files change
- On schedule
- Never (manual only)

## Dependencies

### Required
- `fzf` - Fuzzy finder
- `zsh` - Shell (obviously)

### Optional
- `jq` - JSON processing
- `bat` - Syntax highlighting in preview
- `wl-clipboard` - Clipboard operations (Wayland)
- `xclip` - Clipboard operations (X11)
- Other tool-specific dependencies

## Examples

### Example 1: Basic Selection

```zsh
$ browser::NAME
# Fuzzy search through items
# Select one
# Action performed
```

### Example 2: Multi-Select

```zsh
$ browser::NAME::multi
# Use Tab to select multiple items
# All selected items processed
```

### Example 3: Integration with Pipe

```zsh
# If browser outputs to stdout
browser::NAME | xargs -I {} command {}
```

## Customization

### Modifying Data

Edit the data file directly:

```zsh
$EDITOR $BROWSER_DATA_DIR/NAME/data.txt
```

Or regenerate:

```zsh
data::generate::NAME
```

### Adding Items

Describe how to add new items to the browser.

### Changing Behavior

Describe configuration options or how to modify behavior.

## Troubleshooting

### Data Not Found

```zsh
# Regenerate data
data::generate::NAME

# Or ensure directory exists
mkdir -p $BROWSER_DATA_DIR/NAME
```

### Preview Not Working

- Check if preview command is available
- Verify data file format
- Check file permissions

### No Results

- Verify data file has content
- Check data generation function
- Look for errors in data loader

## Advanced Usage

### Combining with Other Tools

```zsh
# Example: Pipe to other commands
browser::NAME | while read item; do
  # Process each item
done
```

### Custom Filters

```zsh
# Example: Pre-filter data
data::load::NAME | grep 'pattern' | fzf $(_fzf_base_opts)
```

### Integration in Scripts

```zsh
#!/usr/bin/env zsh
source ~/.zshrc  # Or source browsers.zsh directly

result=$(browser::NAME)
if [[ -n "$result" ]]; then
  # Use result
fi
```

## Related Browsers

- `browser::RELATED1` - Brief description
- `browser::RELATED2` - Brief description

## See Also

- Main documentation: `$ZDOTDIR/.data/README.md`
- Browser template: `$ZDOTDIR/templates/browser-template.zsh`
- Integration docs: `$ZDOTDIR/integrations/browsers.zsh`

## Changelog

### v1.0.0 - YYYY-MM-DD
- Initial implementation
- Basic functionality

### v1.1.0 - YYYY-MM-DD
- Added multi-select mode
- Improved preview
- Performance optimizations
