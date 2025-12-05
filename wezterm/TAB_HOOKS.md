# Tab Template Hooks System

Automatically apply tab templates when working directories match defined patterns.

## Overview

The Tab Template Hooks system monitors the current working directory of each pane and automatically applies tab templates when the directory matches a configured pattern. This allows you to have consistent tab styling and configuration for specific projects or directories.

## Features

- **Pattern Matching**: Use exact paths, wildcards, or Lua patterns
- **Automatic Application**: Templates apply when you cd into matching directories
- **State Tracking**: Prevents repeated applications in the same directory
- **User Control**: Enable/disable globally or per-rule
- **Notification Support**: Optional notifications when hooks trigger
- **Integration**: Works seamlessly with existing tab template system

## Configuration

Hooks are configured in `.data/tabs/hooks.json`:

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "myapp_dev",
      "pattern": "~/projects/myapp",
      "template": "dev-environment",
      "description": "Development environment for myapp",
      "enabled": true,
      "notify": true,
      "created_at": "2025-12-04 12:00:00"
    }
  ]
}
```

### Configuration Fields

- **enabled** (global): Master switch for the entire hooks system
- **rules**: Array of hook definitions

### Rule Fields

- **name**: Unique identifier for the rule (auto-generated)
- **pattern**: Directory pattern to match (see Pattern Syntax below)
- **template**: Name of the tab template to apply
- **description**: Human-readable description
- **enabled**: Enable/disable this specific rule (default: true)
- **notify**: Show notification when hook triggers (default: true)
- **created_at**: Timestamp of rule creation

## Pattern Syntax

### Exact Match
```json
{
  "pattern": "/home/user/projects/myapp",
  "template": "myapp-dev"
}
```
Matches only when CWD is exactly `/home/user/projects/myapp`

### Tilde Expansion
```json
{
  "pattern": "~/projects/myapp",
  "template": "myapp-dev"
}
```
The `~` expands to your home directory

### Wildcard Match (Prefix)
```json
{
  "pattern": "~/projects/*",
  "template": "project-work"
}
```
Matches any directory under `~/projects/` (e.g., `~/projects/app1`, `~/projects/app2`)

### Lua Pattern
```json
{
  "pattern": ".*/nvim.*",
  "template": "neovim-config"
}
```
Uses Lua pattern matching (more powerful but requires escaping special characters)

## User Interface

### Access Points

1. **Tab Manager Menu**: `LEADER+F1` → Tab Management → 🪝 Manage Template Hooks
2. **Quick Add**: `LEADER+F1` → Tab Management → ⚡ Quick Add Hook for Current Dir

### Hook Management Menu

From the hooks menu you can:

- **Toggle Global Status**: Enable/disable all hooks
- **Add New Hook**: Create a new hook rule with pattern, template, and description
- **View Existing Hooks**: See all configured rules with status indicators
- **Edit Rules**: Select a rule to enable/disable, toggle notifications, test, or delete

### Individual Rule Menu

When viewing a specific rule, you can:

- **✗/✓ Toggle Enable**: Enable or disable the rule
- **🔔/🔕 Toggle Notifications**: Enable or disable notifications for this rule
- **🧪 Test Hook**: Force immediate re-evaluation (useful for testing)
- **🗑️ Delete**: Remove the hook rule
- **← Back**: Return to hooks menu

### Quick Add Current Directory

This shortcut allows you to quickly create a hook for your current working directory:

1. Opens a prompt asking for the template name
2. Verifies the template exists
3. Creates a hook rule for the exact current directory
4. Saves the configuration

## Usage Examples

### Example 1: Project-Specific Environment

```json
{
  "pattern": "~/projects/myapp",
  "template": "dev-environment",
  "description": "Load dev environment with server, logs, and editor panes"
}
```

**What it does**: When you `cd ~/projects/myapp`, the "dev-environment" template is applied, which might include:
- Custom icon (e.g., 🚀)
- Custom title (e.g., "MyApp Dev")
- Custom color
- Default working directory

### Example 2: Config Editing

```json
{
  "pattern": "~/.core/.sys/cfg/*",
  "template": "config-editor",
  "description": "Config editing layout"
}
```

**What it does**: When you `cd` into any config directory under `~/.core/.sys/cfg/`, applies the "config-editor" template

### Example 3: Dotfiles Management

```json
{
  "pattern": "~/dotfiles",
  "template": "dotfiles",
  "description": "Dotfiles management"
}
```

**What it does**: Exact match for the dotfiles directory

### Example 4: All Neovim Directories

```json
{
  "pattern": ".*/nvim.*",
  "template": "neovim",
  "description": "Neovim configuration editing"
}
```

**What it does**: Matches any path containing "nvim" (e.g., `~/.config/nvim`, `~/projects/nvim-plugin`)

## How It Works

### Detection Mechanism

1. **Polling**: The system checks the current working directory every 3 seconds (configurable)
2. **Pattern Matching**: When a pane's CWD changes, all enabled rules are evaluated
3. **State Tracking**: Each pane tracks which hook was applied and at which directory
4. **Application**: When a match is found and no hook was previously applied at this location, the template is applied

### Template Application

When a hook triggers, it applies the template by:

1. Setting the tab title and icon (from template)
2. Setting the tab color (if defined in template)
3. Changing to the template's CWD (if different from current)
4. Storing TMUX session reference (if defined, but not auto-attaching)

### State Management

The system tracks applied hooks per pane:

```lua
{
  [pane_id] = {
    cwd = "/path/to/directory",
    hook_name = "rule_identifier",
    template = "template_name",
    applied_at = timestamp
  }
}
```

This prevents:
- Re-applying the same hook when already applied
- Interfering with manual tab customization
- Excessive notifications

### Cleanup

When a pane closes, its hook state is automatically cleaned up via the `mux-tab-closed` event handler.

## Integration with Existing Systems

### Tab Templates

Hooks use the existing tab template system (`modules/tabs/tab_templates.lua`), so:
- All template features are supported
- Templates can be managed independently
- Templates can be used manually or via hooks

### TMUX Integration

If a template has a TMUX session defined:
- The session reference is stored but not auto-attached
- This allows manual attachment later if desired
- Prevents disrupting existing workflows

### Event System

Hooks integrate cleanly with the unified event system:
- **update-status.lua**: Polls for directory changes (every 3 seconds)
- **tab-lifecycle.lua**: Cleans up state when panes close
- **wezterm.lua**: Initializes the hooks system on startup

## Performance Considerations

### Rate Limiting

- Polling interval: 3 seconds per pane
- Prevents excessive CPU usage
- Configurable in `events/update-status.lua` (`tab_hooks_poll.POLL_INTERVAL`)

### Efficient Matching

- Pattern matching is lazy (stops at first match)
- State tracking prevents repeated evaluations
- Disabled rules are skipped

## Troubleshooting

### Hook Not Triggering

1. **Check Global Status**: Ensure hooks are globally enabled
2. **Check Rule Status**: Ensure the specific rule is enabled
3. **Check Pattern**: Test your pattern with the 🧪 Test Hook button
4. **Check Template**: Verify the template exists in `.data/tabs/templates.json`
5. **Check Logs**: Look for `[TAB_HOOKS]` messages in WezTerm logs

### Template Not Found

If you see "Template 'name' not found":
- The template doesn't exist in the templates system
- Create the template first using "Save Current Tab as Template"
- Check `.data/tabs/templates.json` for the template name

### Pattern Not Matching

Debug pattern matching:
1. Use 🧪 Test Hook to force immediate evaluation
2. Check WezTerm logs for match attempts
3. Try simpler patterns (exact match) first
4. Remember `~` must be at the start to expand

### Hooks Applying Too Often

This shouldn't happen due to state tracking, but if it does:
- Check if directory is changing (e.g., symlinks)
- Verify polling interval isn't too short
- Check logs for repeated applications

## Advanced Configuration

### Custom Polling Interval

Edit `/home/theron/.core/.sys/cfg/wezterm/events/update-status.lua`:

```lua
local tab_hooks_poll = {
	last_poll = {},
	POLL_INTERVAL = 5, -- Change from 3 to 5 seconds
}
```

### Disable Hooks Temporarily

From the hooks menu:
- Toggle the global status to disable all hooks
- Or disable individual rules

### Complex Patterns

For complex directory matching, use Lua patterns:

- `.` matches any character
- `.*` matches zero or more of any character
- `^` matches start of string
- `$` matches end of string
- `%` escapes special characters

Example: Match any path ending in "config":
```json
{
  "pattern": ".*config$",
  "template": "config-edit"
}
```

## API Reference

### Module: `modules/tabs/tab_hooks`

#### Functions

**`check_and_apply_hooks(window, pane)`**
- Main hook detection function
- Called by update-status event
- Checks current directory and applies matching template

**`cleanup_pane(pane_id)`**
- Removes hook state for closed pane
- Called by mux-tab-closed event

**`show_hooks_menu(window, pane)`**
- Shows the main hooks management UI
- Accessible from tab manager

**`show_rule_menu(window, pane, rule_idx)`**
- Shows individual rule configuration
- Allows toggling, testing, deleting

**`add_hook(window, pane)`**
- Interactive hook creation workflow
- Prompts for pattern, template, description

**`quick_add_current_directory(window, pane)`**
- Quick hook creation for current directory
- Prompts only for template name

**`initialize()`**
- Creates default hooks.json if missing
- Called on WezTerm startup

#### Configuration

**`M.hooks_file`**
- Path to hooks configuration file
- Default: `.data/tabs/hooks.json`

**`M.hooks_enabled`**
- Global enable/disable flag
- Read from hooks.json

**`M.applied_hooks`**
- Runtime state tracking
- Format: `{ [pane_id] = { cwd, hook_name, template, applied_at } }`

## Best Practices

1. **Start Simple**: Use exact path matches first, then add wildcards
2. **Test Patterns**: Use the 🧪 Test Hook feature to verify patterns work
3. **Descriptive Names**: Use clear descriptions to remember what each hook does
4. **Template Organization**: Create templates before setting up hooks
5. **Notification Control**: Disable notifications for frequently-used hooks
6. **Workspace Integration**: Combine with workspace templates for full environment setup

## Migration from Manual Template Loading

If you currently manually load templates for specific directories:

1. Navigate to the directory
2. Use "Quick Add Hook for Current Dir"
3. Enter the template name you normally use
4. The hook will now auto-apply when you return to that directory

## Limitations

- **Polling-Based**: 3-second delay between directory changes and hook application
- **No Shell Integration**: Cannot detect directory changes without polling
- **Pattern Complexity**: Lua patterns require learning special syntax
- **First Match Only**: Only the first matching rule is applied

## Future Enhancements

Possible future additions:
- Shell integration for instant detection (via `$PROMPT_COMMAND` or similar)
- Priority ordering for rules
- Multiple templates per rule
- Conditional logic (time-based, workspace-based)
- Template inheritance

## See Also

- **Tab Templates**: `modules/tabs/tab_templates.lua`
- **Tab Manager**: `modules/tabs/tab_manager.lua`
- **Event System**: `events/update-status.lua`, `events/tab-lifecycle.lua`
- **Session Manager**: `modules/sessions/manager.lua`
