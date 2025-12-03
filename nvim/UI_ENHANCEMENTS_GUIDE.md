# Neovim UI Enhancements Guide

## Overview
This guide details the comprehensive UI and notification system improvements added to your Neovim configuration.

## 1. Enhanced Notification System (`<leader>n*`)

### Features
A comprehensive notification management system with multiple views and filtering capabilities.

### Keybindings

| Key | Description | Function |
|-----|-------------|----------|
| `<leader>nn` | Notification History (Snacks) | Show notification history using Snacks plugin |
| `<leader>nh` | Notification History (Alt) | Alternative notification history view |
| `<leader>nr` | Recent Notifications (10) | Show last 10 notifications |
| `<leader>nR` | Recent Notifications (25) | Show last 25 notifications |
| `<leader>ne` | Error Notifications | Filter and show only error notifications |
| `<leader>nw` | Warning Notifications | Filter and show only warning notifications |
| `<leader>ni` | Info Notifications | Filter and show only info notifications |
| `<leader>nD` | Debug Notifications | Filter and show only debug notifications |
| `<leader>na` | All Notifications | Show all cached notifications |
| `<leader>nd` | Dismiss All | Dismiss all visible notifications |
| `<leader>nc` | Clear Cache | Clear notification history cache |
| `<leader>ns` | Search Notifications | Search through notification history |
| `<leader>nS` | Notification Statistics | Show statistics about notifications |
| `<leader>nf` | Filter with FZF | Interactive filtering using fzf-lua |
| `<leader>nl` | Last Message (Noice) | Show last message using Noice |
| `<leader>nH` | Full History (Noice) | Show complete history using Noice |
| `<leader>nE` | Errors (Noice) | Show errors using Noice |

### Features Explained

#### Notification Tracking
- Automatically tracks all notifications with timestamps
- Categorizes by level (ERROR, WARN, INFO, DEBUG)
- Maintains cache of last 100 notifications per category
- Provides search and filter capabilities

#### Statistics View
Shows:
- Total notification count
- Breakdown by type with percentages
- Cache status for each category
- Last clear timestamp

#### Search Function
- Interactive search through all notification history
- Case-insensitive matching
- Results displayed in floating window

## 2. Global Which-Key Help Menu

### Access Methods

| Key | Description |
|-----|-------------|
| `<M-h>` (Alt+h) | Open global help menu |
| `<C-?>` | Alternative global help key |
| `<F1>` | Show all keybindings (which-key) |
| `<leader>?` | Help menu prefix |

### Help Menu Options

| Key | Description |
|-----|-------------|
| `<leader>?` | Open help menu |
| `<leader>?k` | Show all keybindings |
| `<leader>?h` | Search help documentation |
| `<leader>?c` | Show command history |
| `<leader>?m` | Show marks |
| `<leader>?r` | Show registers |
| `<leader>?j` | Show jumps |
| `<leader>?n` | Show normal mode keys |
| `<leader>?i` | Show insert mode keys |
| `<leader>?v` | Show visual mode keys |

### Interactive Help Menu
The help menu provides quick access to:
- All keybindings by mode
- Leader and LocalLeader mappings
- Window, Git, LSP, Search, Buffer, File, Code mappings
- Session and Notification mappings
- Vim documentation (commands, functions, options, tips)

## 3. Extended Lualine Components

### New Status Line Components

#### Session Information
- **Location**: Right section of statusline
- **Shows**: Current session name with icon
- **Icons**:
  - ` ` for git repositories
  - ` ` for editorconfig roots
  - ` ` for marker-based roots
  - ` ` for directory sessions
- **Features**: Shows modified indicator when buffers have unsaved changes

#### LSP Information
- **Active LSP Clients**: Shows names of all active LSP servers
- **Format**: ` client1, client2, ...`

#### Enhanced Diagnostics
- **Detailed Count**: Shows errors, warnings, info, and hints separately
- **Format**: ` X  Y  Z 󰌵 W`
- **Clean State**: Shows "✓ Clean" when no issues

#### Git Status
- **Enhanced Display**: Shows branch with detailed change counts
- **Format**: ` branch [+X ~Y -Z]`

#### Notification Indicator
- **Shows**: Count of cached notifications
- **Error/Warning Priority**: Displays error and warning counts separately
- **Format**: `󰎟 X` or `󰎟  X  Y`

#### File Information
- **File Size**: Shows file size in human-readable format (B/K/M/G)
- **Indentation**: Shows indent type and size (e.g., "Spaces:2")
- **Word Count**: For text files (markdown, txt, org, etc.)

#### Development Features
- **Current Function**: Shows current function/method name using Treesitter
- **Python Environment**: Shows active virtual environment
- **Copilot Status**: Shows ` ON/OFF` status
- **Macro Recording**: Shows "Recording @X" when recording macro

#### Search & Navigation
- **Search Count**: Shows current match position (e.g., ` 3/10`)
- **Jump List**: Accessible via help menu

### Component Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│ MODE │ branch git_status diagnostics │ keymap function python file │
│      │                                │                              │
│ notifications lsp copilot size encoding format type │ indent search │
│                                                     │ progress      │
│                                                     │ session       │
│                                              location word_count    │
└─────────────────────────────────────────────────────────────────────┘
```

## 4. Commands

### Notification Commands
- `:NotifyErrors` - Show error notifications
- `:NotifyWarnings` - Show warning notifications
- `:NotifyInfo` - Show info notifications
- `:NotifyDebug` - Show debug notifications
- `:NotifySearch` - Search notifications
- `:NotifyStats` - Show notification statistics
- `:NotifyClear` - Clear notification cache
- `:NotifyRecent [N]` - Show N recent notifications (default: 10)

### Help Commands
- `:HelpMenu` - Show interactive help menu
- `:ShowKeys` - Show all keybindings
- `:ShowMarks` - Show all marks
- `:ShowRegisters` - Show all registers
- `:ShowJumps` - Show jump list

## 5. Integration Notes

### Which-Key Integration
All new keybindings are registered with which-key and have descriptive labels. Groups are properly organized:
- Notifications under `<leader>n`
- Help under `<leader>?`

### Session Integration
The lualine session component integrates with your existing auto-session setup, showing:
- Current session name
- Root directory type
- Modified status

### Notification System Integration
The notification system hooks into `vim.notify` to automatically track all notifications from:
- LSP servers
- Plugins
- User commands
- System messages

## 6. Usage Tips

### Quick Access
1. Press `<M-h>` (Alt+h) anytime to see the help menu
2. Press `<leader>nn` to quickly check recent notifications
3. Use `<leader>ne` to focus on errors only

### Workflow Integration
1. **Debugging**: Use `<leader>ne` and `<leader>nw` to filter errors and warnings
2. **History**: Use `<leader>ns` to search for specific messages
3. **Statistics**: Use `<leader>nS` to see notification patterns
4. **Help**: Press `<M-h>` when you forget a keybinding

### Customization
- Adjust `MAX_SESSIONS` in your config to control session count
- Modify lualine component positions in `lua/ui/lualine.lua`
- Add custom notification filters in `lua/mods/notifications.lua`

## 7. Troubleshooting

### If notifications aren't tracking:
1. Check that the notification module loaded: Look for "UI Enhancements loaded successfully"
2. Run `:NotifyStats` to verify the system is active

### If help menu doesn't open:
1. Try alternative keys: `<C-?>` or `<leader>?`
2. Check `:ShowKeys` command directly

### If lualine components don't show:
1. Restart Neovim for changes to take effect
2. Check `:LualineRefresh` if available
3. Verify no errors with `:messages`

## Files Modified/Created

### New Files
- `lua/mods/notifications.lua` - Core notification tracking system
- `lua/keymaps/notifications.lua` - Notification keybindings
- `lua/keymaps/global-help.lua` - Global help menu system
- `lua/mods/lualine-extended.lua` - Extended lualine components
- `lua/mods/ui-enhancements.lua` - UI enhancement loader

### Modified Files
- `init.lua` - Added UI enhancement initialization
- `lua/ui/lualine.lua` - Integrated extended components
- `lua/keymaps/which-key.lua` - Already had notification group defined

## Future Enhancements

Consider adding:
1. Notification persistence across sessions
2. Export notifications to file
3. Custom notification filters/rules
4. Integration with telescope for notification browsing
5. Notification sound alerts for errors
6. Auto-dismiss old notifications
7. Per-project notification settings