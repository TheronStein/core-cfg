# WezTerm Search Mode Keybindings

Custom keybindings defined in `keymaps/modes/search.lua`. These **completely replace** WezTerm's default search mode bindings.

## Match Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+n` | `NextMatch` | Jump to next search match |
| `Ctrl+N` | `PriorMatch` | Jump to previous search match |
| `UpArrow` | `PriorMatch` | Jump to previous match (arrow key) |
| `DownArrow` | `NextMatch` | Jump to next match (arrow key) |

## Page Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+i` | `PriorMatchPage` | Previous match on prior page |
| `Ctrl+k` | `NextMatchPage` | Next match on next page |
| `Ctrl+Shift+I` | `PageUp` | Scroll viewport up one page |
| `Ctrl+Shift+K` | `PageDown` | Scroll viewport down one page |
| `PageUp` | `PageUp` | Scroll viewport up one page |
| `PageDown` | `PageDown` | Scroll viewport down one page |

## Search Pattern Control

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+t` | `CycleMatchType` | Cycle: case-sensitive / case-insensitive / regex |
| `Ctrl+e` | `EditPattern` | Re-enter pattern editing mode |
| `Enter` | `AcceptPattern` | Accept pattern and enter copy mode |

## Exit

| Key | Action | Description |
|-----|--------|-------------|
| `Escape` | `Close` | Exit search mode |
| `Ctrl+c` | `Close` | Exit search mode |

---

## Unmapped Search Mode Functions

These functions are available but not currently mapped:

| Action | Description |
|--------|-------------|
| `ClearPattern` | Clear the current search pattern |

## WezTerm Default Keys Not Mapped

These were default WezTerm search mode bindings that are not in your config:

| Default Key | Action |
|-------------|--------|
| `Ctrl+r` | CycleMatchType (replaced by `Ctrl+t`) |
| `Ctrl+u` | ClearPattern (unmapped) |
| `Ctrl+p` | PriorMatch (replaced by `Ctrl+N`) |
| `Ctrl+n` | NextMatch (already mapped) |

---

## Search Mode Workflow

1. Enter search mode via copy mode (`/` or `?` in copy mode) or `CTRL+SHIFT+F`
2. Type search pattern (keyboard input goes to pattern editor)
3. Use `Ctrl+t` to cycle match type (case-sensitive/insensitive/regex)
4. Use `Ctrl+n`/`Ctrl+N` or arrows to navigate matches
5. Press `Enter` to accept pattern and enter copy mode with match selected
6. Press `Escape` to exit without selecting

## Match Type Modes

When using `Ctrl+t` to cycle, you get:

1. **Case Sensitive** - Exact case matching
2. **Case Insensitive** - Ignores case
3. **Regex** - Full regular expression matching
