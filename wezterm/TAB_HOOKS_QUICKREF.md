# Tab Template Hooks - Quick Reference

## Access Points

| Action | Keybinding | Path |
|--------|-----------|------|
| Hooks Menu | `LEADER+F1` | Session Manager → Tab Management → 🪝 Manage Template Hooks |
| Quick Add | `LEADER+F1` | Session Manager → Tab Management → ⚡ Quick Add Hook |

## Pattern Syntax

| Pattern Type | Example | Matches |
|-------------|---------|---------|
| Exact | `~/projects/myapp` | Only `~/projects/myapp` |
| Wildcard | `~/projects/*` | Any dir under `~/projects/` |
| Lua Pattern | `.*nvim.*` | Any path containing "nvim" |
| End Match | `.*/docs$` | Any path ending in "/docs" |

## Rule Structure

```json
{
  "name": "unique_id",
  "pattern": "~/path/to/match",
  "template": "template-name",
  "description": "Human-readable description",
  "enabled": true,
  "notify": true
}
```

## Common Patterns

```lua
-- Single project
"~/projects/myapp"

-- All projects
"~/projects/*"

-- Config files
"~/.core/.sys/cfg/*"

-- Any nvim directory
".*nvim.*"

-- Ends with test/tests
".*/tests?$"

-- Temporary files
"/tmp/.*"
```

## Workflow

### Create Hook

1. Navigate to target directory
2. `LEADER+F1` → Tab Management
3. Select "⚡ Quick Add Hook"
4. Enter template name
5. Done!

### Manage Hooks

1. `LEADER+F1` → Tab Management
2. Select "🪝 Manage Template Hooks"
3. Options:
   - Toggle global enable/disable
   - Add new hook (full config)
   - Select existing hook to edit
   - Test, enable, disable, delete

### Edit Rule

1. Access hooks menu
2. Select a rule
3. Options:
   - ✓/✗ Enable/disable
   - 🔔/🔕 Notifications on/off
   - 🧪 Test now
   - 🗑️ Delete
   - ← Back

## Files

| File | Purpose |
|------|---------|
| `.data/tabs/hooks.json` | Hook rules configuration |
| `.data/tabs/templates.json` | Tab templates (must exist) |
| `modules/tabs/tab_hooks.lua` | Hook system implementation |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Hook not triggering | Check: Global enabled? Rule enabled? Template exists? |
| Wrong template | Check rule order (specific before general) |
| Too many notifications | Disable notify on frequently-used rules |
| Pattern not matching | Test with 🧪 Test Hook button |

## Best Practices

1. ✅ Start with exact matches, add wildcards later
2. ✅ Test patterns before relying on them
3. ✅ Disable notifications for frequent directories
4. ✅ Use descriptive names and descriptions
5. ✅ Create templates before adding hooks

## Performance

- **Polling interval**: 3 seconds
- **Per-pane state tracking**: Prevents repeated applications
- **Lazy evaluation**: Stops at first match
- **Clean shutdown**: Auto-cleanup on pane close

## Integration

- **Event**: `update-status` (polling)
- **Event**: `mux-tab-closed` (cleanup)
- **Module**: `modules/tabs/tab_templates` (template system)
- **Init**: `wezterm.lua` (startup)

## Quick Examples

### Example 1: Single Project
```json
{
  "pattern": "~/projects/myapp",
  "template": "myapp-dev"
}
```

### Example 2: All Configs
```json
{
  "pattern": "~/.core/.sys/cfg/*",
  "template": "config-editor"
}
```

### Example 3: Language-Specific
```json
{
  "pattern": ".*/python/.*",
  "template": "python-dev"
}
```

## Debug Log Messages

Look for these in WezTerm logs:

```
[TAB_HOOKS] Path '/path' matched pattern '~/projects/*'
[TAB_HOOKS] Applying template: myapp-dev
[TAB_HOOKS] Successfully applied hook: myapp -> myapp-dev
[TAB_HOOKS] Cleaning up hook state for pane 123
```

## See Also

- **Full Documentation**: `TAB_HOOKS.md`
- **Examples**: `TAB_HOOKS_EXAMPLES.md`
- **Tab Manager**: `modules/tabs/tab_manager.lua`
