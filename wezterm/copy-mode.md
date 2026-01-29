# WezTerm Copy Mode Keybindings

Custom keybindings defined in `keymaps/modes/copy.lua`. These **completely replace** WezTerm's default copy mode bindings.

## Navigation (i/k/j/l style, replaces vim h/j/k/l)

| Key | Action | Description |
|-----|--------|-------------|
| `i` | `MoveUp` | Move cursor one cell up |
| `k` | `MoveDown` | Move cursor one cell down |
| `j` | `MoveLeft` | Move cursor one cell left |
| `l` | `MoveRight` | Move cursor one cell right |

## Page Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+i` | `MoveByPage(-0.5)` | Half page up |
| `Ctrl+k` | `MoveByPage(0.5)` | Half page down |
| `Ctrl+Shift+I` | `PageUp` | Full page up |
| `Ctrl+Shift+K` | `PageDown` | Full page down |

## Selection Modes

| Key | Action | Description |
|-----|--------|-------------|
| `a` | `SetSelectionMode("Cell")` | Character-by-character selection |
| `v` | `SetSelectionMode("Line")` | Line-by-line selection |
| `V` | `SetSelectionMode("Block")` | Rectangular block selection |
| `W` | `SetSelectionMode("Word")` | Word-by-word selection |

## Scrollback Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `g` | `MoveToScrollbackTop` | Jump to top of scrollback |
| `G` | `MoveToScrollbackBottom` | Jump to bottom of scrollback |

## Viewport Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+t` | `MoveToViewportTop` | Jump to top of visible area |
| `Ctrl+m` | `MoveToViewportMiddle` | Jump to middle of visible area |
| `Ctrl+b` | `MoveToViewportBottom` | Jump to bottom of visible area |

## Word Movement

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+j` | `MoveBackwardWord` | Move one word left |
| `Ctrl+l` | `MoveForwardWord` | Move one word right |

## Line Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `Shift+J` | `MoveToStartOfLine` | Jump to first cell in line |
| `Ctrl+Shift+j` | `MoveToStartOfLineContent` | Jump to first non-space cell |
| `Ctrl+Shift+L` | `MoveToEndOfLineContent` | Jump to last non-space cell |

## Selection Manipulation

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+o` | `MoveToSelectionOtherEnd` | Jump to other end of selection |
| `Ctrl+Shift+O` | `MoveToSelectionOtherEndHoriz` | Jump to other horizontal end |

## Search (within copy mode)

| Key | Action | Description |
|-----|--------|-------------|
| `/` | `EditPattern` | Enter search mode |
| `?` | `EditPattern` | Enter search mode (reverse convention) |

## Jump Commands

| Key | Action | Description |
|-----|--------|-------------|
| `n` | `JumpForward(prev_char=true)` | Jump to next match |
| `N` | `JumpBackward(prev_char=true)` | Jump to previous match |

## Copy and Exit

| Key | Action | Description |
|-----|--------|-------------|
| `y` | Copy + ScrollToBottom + Close | Yank selection and exit |
| `Enter` | Copy + ScrollToBottom + Close | Copy selection and exit |
| `Space` | Copy + ScrollToBottom + Close | Copy selection and exit |

## Exit (without copying)

| Key | Action | Description |
|-----|--------|-------------|
| `Escape` | ScrollToBottom + Close | Exit copy mode |
| `q` | ScrollToBottom + Close | Exit copy mode |
| `Ctrl+c` | ScrollToBottom + Close | Exit copy mode |

---

## Unmapped Copy Mode Functions

These CopyMode actions are available but not currently mapped:

### Semantic Zone Navigation
| Action | Description |
|--------|-------------|
| `MoveBackwardSemanticZone` | Move cursor one semantic zone left |
| `MoveForwardSemanticZone` | Move cursor one semantic zone right |
| `MoveBackwardSemanticZoneOfType` | Move to previous zone of type (Input/Output/Prompt) |
| `MoveForwardSemanticZoneOfType` | Move to next zone of type (Input/Output/Prompt) |
| `SetSelectionMode("SemanticZone")` | Select by semantic zone |

### Additional Movement
| Action | Description |
|--------|-------------|
| `MoveForwardWordEnd` | Move forward to end of current/next word |
| `MoveToStartOfNextLine` | Move to first cell of next line |

### Selection/Pattern Management
| Action | Description |
|--------|-------------|
| `ClearSelectionMode` | Clear selection mode without leaving copy mode |
| `ClearPattern` | Clear the current search pattern |

### Search-Related (typically used in search mode)
| Action | Description |
|--------|-------------|
| `AcceptPattern` | Exit pattern editing, keep pattern active |
| `CycleMatchType` | Cycle between case-sensitive/insensitive/regex |
| `NextMatch` | Jump to next search match |
| `PriorMatch` | Jump to previous search match |
| `NextMatchPage` | Jump to next match on next page |
| `PriorMatchPage` | Jump to previous match on prior page |

### WezTerm Default Keys Not Mapped
These were default WezTerm copy mode bindings that are not in your config:

| Default Key | Action |
|-------------|--------|
| `h` | MoveLeft (replaced by `j`) |
| `j` | MoveDown (replaced by `k`) |
| `k` | MoveUp (replaced by `i`) |
| `l` | MoveRight (still `l`) |
| `w` / `Tab` | MoveForwardWord (replaced by `Ctrl+l`) |
| `b` / `Shift+Tab` | MoveBackwardWord (replaced by `Ctrl+j`) |
| `e` | MoveForwardWordEnd (unmapped) |
| `0` / `Home` | MoveToStartOfLine (replaced by `Shift+J`) |
| `$` / `End` | MoveToEndOfLineContent (replaced by `Ctrl+Shift+L`) |
| `^` / `Alt+m` | MoveToStartOfLineContent (replaced by `Ctrl+Shift+j`) |
| `H` | MoveToViewportTop (replaced by `Ctrl+t`) |
| `M` | MoveToViewportMiddle (replaced by `Ctrl+m`) |
| `L` | MoveToViewportBottom (replaced by `Ctrl+b`) |
| `Ctrl+u` | Half page up (replaced by `Ctrl+i`) |
| `Ctrl+d` | Half page down (replaced by `Ctrl+k`) |
| `Ctrl+b` | Page up (replaced by `Ctrl+Shift+I`) |
| `Ctrl+f` | Page down (replaced by `Ctrl+Shift+K`) |
| `o` | MoveToSelectionOtherEnd (replaced by `Ctrl+o`) |
| `O` | MoveToSelectionOtherEndHoriz (replaced by `Ctrl+Shift+O`) |
