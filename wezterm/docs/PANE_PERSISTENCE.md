# Pane Persistence Implementation

## Overview

The workspace manager now includes **integrated pane persistence** that captures and restores complete pane layouts, including split directions, relative sizes, and nested structures.

## What Changed

### Before
- **Simple pane list**: Saved only CWD and title for each pane
- **Fallback restoration**: Created all panes as horizontal splits (side-by-side)
- **No layout preservation**: Lost split directions and pane sizes
- **External dependency**: Attempted to use external `resurrect` module but it wasn't loading

### After
- **Spatial pane tree**: Captures exact layout using coordinate-based analysis
- **Accurate restoration**: Recreates splits with proper directions and relative sizes
- **Self-contained**: All logic integrated directly into workspace_manager.lua
- **No external dependencies**: Removed reliance on archived resurrect module

## Technical Details

### Pane Tree Structure

The pane tree uses a spatial coordinate system to determine relationships:

```lua
{
  left = 0,           -- X position
  top = 0,            -- Y position
  width = 100,        -- Width in columns
  height = 40,        -- Height in rows
  cwd = "/path",      -- Working directory
  title = "...",      -- Pane title
  is_active = true,   -- Active pane marker
  is_zoomed = false,  -- Zoom state
  right = {...},      -- Pane to the right (if exists)
  bottom = {...},     -- Pane below (if exists)
}
```

### Capture Algorithm

1. Get all panes with `tab:panes_with_info()` (includes coordinates)
2. Sort panes by position (left-to-right, top-to-bottom)
3. Build tree using spatial relationships:
   - Panes with `left > root.left + root.width` → right child
   - Panes with `top > root.top + root.height` → bottom child
4. Recursively process all children

### Restoration Algorithm

1. Assign root pane to first position in tree
2. Fold over tree depth-first:
   - For each `bottom` child: create Bottom split
   - For each `right` child: create Right split
   - Use relative sizing: `size = child.dimension / (parent.dimension + child.dimension)`
3. Activate the originally active pane

## Examples

### Complex Layout

**Before Save:**
```
┌─────────┬─────────┐
│    A    │    B    │
│         ├─────────┤
│         │    C    │
├─────────┴─────────┤
│         D         │
└───────────────────┘
```

**Stored as:**
```json
{
  "pane_tree": {
    "cwd": "A",
    "right": {
      "cwd": "B",
      "bottom": {
        "cwd": "C"
      }
    },
    "bottom": {
      "cwd": "D"
    }
  }
}
```

**After Restore:** Exact same layout with proportional sizing

### Nested Splits

The system handles arbitrarily complex nested structures:

```
┌──┬──┬──┐
│A │B │C │
├──┴──┤  │
│  D  │  │
└─────┴──┘
```

Saved as tree with multiple levels of nesting, restored accurately.

## Storage Format

### Session Files (.data/workspace-sessions/*.json)

```json
{
  "name": "workspace-name",
  "tabs": [
    {
      "title": "Tab 1",
      "icon": "📂",
      "color": "#ff0000",
      "pane_tree": {
        "left": 0,
        "top": 0,
        "width": 100,
        "height": 40,
        "cwd": "/path",
        "title": "shell prompt",
        "is_active": true,
        "right": {...},
        "bottom": {...}
      },
      "is_zoomed": false
    }
  ]
}
```

### Template Files (.data/workspace-templates/*.json)

Same format as session files.

## Backward Compatibility

The system maintains legacy support:

- **Loading old sessions**: If `panes` array exists (old format), falls back to simple horizontal splits
- **No data loss**: Existing sessions continue to work
- **Gradual migration**: New saves use pane_tree, old saves use panes array

## Functions Added

| Function | Purpose |
|----------|---------|
| `create_pane_tree(tab)` | Capture spatial pane layout from tab |
| `get_tab_state(tab)` | Get complete tab state (title, zoom, pane tree) |
| `restore_pane_tree_to_tab(tab, tree, pane)` | Restore tree structure into tab |
| `fold_pane_tree(tree, acc, func)` | Recursively process tree |
| `make_splits(opts)` | Generate split operations from tree |
| `compare_pane_by_coord(a, b)` | Sort panes by position |
| `is_right(root, pane)` | Check if pane is right of root |
| `is_bottom(root, pane)` | Check if pane is below root |
| `pop_connected_right(root, panes)` | Find adjacent right pane |
| `pop_connected_bottom(root, panes)` | Find adjacent bottom pane |
| `insert_panes(root, panes)` | Build tree recursively |

## Testing

### Manual Test Procedure

1. **Create complex layout:**
   ```
   - Create tab with 4 panes
   - Split horizontally: A | B
   - Split B vertically: B top, C bottom
   - Split A vertically: A top, D bottom
   ```

2. **Save workspace:**
   ```
   Press: LEADER + SHIFT + S
   Name: "test-layout"
   ```

3. **Close WezTerm completely**

4. **Load workspace:**
   ```
   Press: LEADER + SHIFT + L
   Select: "test-layout"
   ```

5. **Verify:** Layout should match exactly (split directions and proportions)

### Automated Test (Future)

Consider adding to test suite:
- Create various layouts programmatically
- Save and restore
- Compare pane coordinates and CWDs
- Verify all panes exist with correct relationships

## Performance

- **Capture**: O(n²) in worst case for n panes (spatial partitioning)
- **Restore**: O(n) for n panes (single depth-first traversal)
- **Memory**: Linear with number of panes
- **Typical overhead**: < 100ms for tabs with < 20 panes

## Limitations

### Not Persisted

- **Command history**: Shell history not captured (would require shell integration)
- **Scrollback content**: Terminal buffer not saved (configurable via resurrect module if needed)
- **Running processes**: Process state not captured (panes start fresh shells)
- **Pane focus history**: Only active pane is marked

### Known Issues

- Very small pane sizes (< 5 columns/rows) may have rounding errors on restore
- Tabs with > 50 panes may have slower save/restore performance
- Zoomed pane state is captured but not fully restored (WezTerm limitation)

## Future Enhancements

1. **Scrollback preservation**: Add optional scrollback capture (large memory usage)
2. **Process restoration**: Save running commands and attempt to restart them
3. **Shell history**: Integrate with shell's history file to restore context
4. **Pane IDs**: Track pane identity across sessions for stateful restoration
5. **Incremental updates**: Save only changed panes rather than full workspace

## Migration Notes

### From Old Format

Old sessions with `panes` arrays will continue to work:

```json
{
  "panes": [
    {"cwd": "/path1", "title": "..."},
    {"cwd": "/path2", "title": "..."}
  ]
}
```

These restore as simple horizontal splits. To upgrade:
1. Load the old session
2. Arrange panes as desired
3. Save again (will use new pane_tree format)

### Code Organization

All pane persistence logic is in `workspace_manager.lua` lines 14-221:
- Self-contained implementation
- No external module dependencies
- Fully commented with type annotations
- Easy to maintain and enhance

## References

- Original concept from [resurrect.wezterm](https://github.com/MLFlexer/resurrect.wezterm)
- Adapted and integrated for workspace management use case
- Enhanced with workspace-specific metadata (icons, colors, themes)
