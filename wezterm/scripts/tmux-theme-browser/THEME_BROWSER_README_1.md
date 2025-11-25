# WezTerm Theme Browser with Live Preview

A theme browser for WezTerm that runs in a tmux popup with a **split-pane layout** showing **live theme updates** as you navigate.

## How It Works

```
Press: prefix + T (in tmux)
           ↓
    ┌─────────────────────────────────────────────────────────────┐
    │                    Tmux Popup (95% x 90%)                   │
    │  ┌────────────────────────┬───────────────────────────────┐ │
    │  │  FZF Theme List (60%) │  Live Preview Pane (40%)      │ │
    │  │                        │                                │ │
    │  │  ☀  🔥 Catppuccin     │  ╔══════════════════════════╗ │ │
    │  │  🌙  ❄️  Tokyo Night   │  ║   THEME PREVIEW PANE     ║ │ │
    │  │ >☀  ⚪ Solarized Light │  ╚══════════════════════════╝ │ │
    │  │  🌙  🔥 Gruvbox Dark   │                                │ │
    │  │  ...                   │  Watch colors change here!    │ │
    │  │                        │                                │ │
    │  │  Navigate with ↑↓     │  $ ls -la --color=always      │ │
    │  │                        │  ■ Red ■ Green ■ Blue          │ │
    │  │                        │  ■ Yellow ■ Magenta ■ Cyan    │ │
    │  └────────────────────────┴───────────────────────────────┘ │
    └─────────────────────────────────────────────────────────────┘
                      ↓
         As you navigate themes in fzf:
                      ↓
         Theme name written to preview file
                      ↓
         WezTerm watches file and changes theme GLOBALLY
                      ↓
         Right pane automatically updates with new colors!
                      ↓
         You see the theme change in real-time!
```

## Architecture

This is beautifully simple:

### 1. **theme-browser-popup.sh** (Launcher)
- Checks you're in tmux
- Calls the session script inside a popup

### 2. **theme-browser-session.sh** (Split Setup)
- Runs inside the popup
- Splits into two panes (60% left, 40% right)
- Right pane: Shows shell with sample content (ls, colors, etc.)
- Left pane: Runs the fzf browser
- Saves/restores original theme

### 3. **theme-browser-simple.sh** (FZF Browser)
- Displays theme list in fzf
- On navigation: writes theme name to preview file
- On selection: keeps theme applied
- On cancel: restores original theme

### 4. **WezTerm Config** (Your Responsibility)
You need a file watcher in your WezTerm config:
```lua
-- Watch for theme changes
wezterm.add_to_config_reload_watch_list(
  os.getenv("XDG_RUNTIME_DIR") .. "/wezterm_theme_preview_default.txt"
)

-- In your config reload function:
local f = io.open(preview_file, "r")
if f then
  local theme = f:read("*line")
  f:close()
  if theme and theme ~= "INIT" and theme ~= "CANCEL" then
    config.color_scheme = theme
  end
end
```

## Key Features

- **Live Preview**: Right pane updates automatically as WezTerm recolors everything
- **No Capture Needed**: Tmux just shows a live pane, WezTerm handles the recoloring
- **Popup Interface**: Doesn't disrupt your workspace
- **Simple Architecture**: No complex capture/render logic
- **Workspace-Specific**: Each workspace can have different themes
- **Filter Options**: Light/dark, warm/cool theme filtering

## Installation

1. **Copy scripts to your WezTerm config:**
   ```bash
   mkdir -p ~/.config/wezterm/scripts
   cp theme-browser-popup.sh ~/.config/wezterm/scripts/
   cp theme-browser-session.sh ~/.config/wezterm/scripts/
   cp theme-browser-simple.sh ~/.config/wezterm/scripts/
   chmod +x ~/.config/wezterm/scripts/theme-browser-*.sh
   ```

2. **Add tmux keybinding:**
   ```bash
   # In your tmux.conf:
   bind-key T display-popup -E -w 95% -h 90% \
       "~/.config/wezterm/scripts/theme-browser-popup.sh"
   ```

3. **Ensure theme data exists:**
   ```bash
   # Generate themes.json with your theme data
   mkdir -p ~/.config/wezterm/scripts/data
   # Your WezTerm config should generate this file
   ```

4. **Add file watcher to WezTerm config:**
   ```lua
   -- Add to your wezterm.lua
   local preview_file = os.getenv("XDG_RUNTIME_DIR") .. 
     "/wezterm_theme_preview_default.txt"
   
   wezterm.add_to_config_reload_watch_list(preview_file)
   
   -- In config reload:
   local f = io.open(preview_file, "r")
   if f then
     local theme = f:read("*line")
     f:close()
     if theme and theme ~= "INIT" and theme ~= "CANCEL" then
       config.color_scheme = theme
     end
   end
   ```

## Keybindings

**In FZF:**
- `↑↓` / `PageUp/PageDown` - Navigate themes (right pane updates automatically!)
- `Enter` - Apply theme to workspace permanently
- `Esc` - Cancel and restore original theme
- `Ctrl+L` - Filter light themes
- `Ctrl+D` - Filter dark themes
- `Ctrl+W` - Filter warm themes
- `Ctrl+C` - Filter cool themes
- `Ctrl+R` - Reset filters

**In Tmux:**
- `prefix + T` - Launch theme browser

## File Structure

```
~/.config/wezterm/scripts/
├── theme-browser-popup.sh      # Popup launcher
├── theme-browser-session.sh    # Split layout setup
├── theme-browser-simple.sh     # FZF browser
├── data/
│   └── themes.json            # Generated theme database
└── THEME_BROWSER_README.md    # This file

~/.config/tmux/
└── tmux.conf                   # Your keybinding

/tmp/ (or $XDG_RUNTIME_DIR)
├── wezterm_theme_preview_default.txt        # Theme selection file
└── wezterm_original_theme_default.txt       # Original theme backup
```

## Dependencies

- `fzf` - Fuzzy finder
- `jq` - JSON processing
- `tmux` - Terminal multiplexer (for popup and splits)
- `wezterm` - Terminal emulator with theme support
- `bash` - Shell (4.0+)

## Environment Variables

- `WEZTERM_WORKSPACE` - Current workspace name (default: "default")
- `XDG_RUNTIME_DIR` - Runtime directory (default: "/tmp")

## How The Magic Works

The beauty is in the simplicity:

1. **Popup splits into two panes** (tmux does this)
2. **Left pane runs fzf** with theme list
3. **Right pane shows a shell** with sample content
4. **As you navigate fzf**, it calls `apply_preview` function
5. **apply_preview writes** theme name to preview file
6. **WezTerm watches** that file (via config reload watch)
7. **WezTerm changes theme** globally when file changes
8. **Right pane automatically shows** new colors (no capture needed!)
9. **You see instant feedback** as you navigate

No complex capture logic, no text extraction - just a live pane that WezTerm recolors!

## Troubleshooting

### Right pane doesn't update colors
- Ensure your WezTerm config has the file watcher set up
- Check that the preview file is being written (`ls /tmp/wezterm_theme_preview_*`)
- Verify WezTerm config reload is working

### Popup not appearing
- Confirm you're running from within tmux
- Check tmux version (>= 3.2 recommended for popups)
- Verify popup size doesn't exceed terminal size

### Theme not applying permanently
- Check that the theme name in themes.json matches WezTerm's theme names
- Verify workspace name is correct
- Look for errors in WezTerm debug log

### Split layout looks wrong
- Adjust percentages in theme-browser-session.sh
- Try different terminal sizes
- Check tmux pane minimum size settings

## Advanced Customization

### Change Split Layout

Edit `theme-browser-session.sh`:
```bash
# Change from 60/40 to 70/30:
tmux split-window -h -p 30
```

### Customize Preview Pane Content

Edit `theme-browser-session.sh`:
```bash
# Add your own commands:
tmux send-keys -t "{right}" "cat ~/.zshrc | head -20" Enter
tmux send-keys -t "{right}" "echo 'Your custom content here'" Enter
```

### Different Popup Size

Edit `theme-browser-popup.sh`:
```bash
# Change from 95/90 to 80/80:
tmux display-popup -E -w 80% -h 80% \
    "$SCRIPT_DIR/theme-browser-session.sh"
```

## Why This Works Better

Compared to capturing pane output:
- **Simpler**: No capture/render logic needed
- **Faster**: Direct rendering by tmux
- **Real-time**: Instant updates as theme changes
- **Native**: Uses tmux's built-in split system
- **Flexible**: Easy to customize pane content

The right pane is just a **live window into your terminal** that happens to update when WezTerm changes themes. It's like tmux's choose-tree preview, but for themes!

## License

Your license here.
