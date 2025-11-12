# Tmux Menu Commands Reference

This document describes the interactive menu commands available in the tmux configuration.

## Menu Structure

### Main Menu
Entry point for all menu operations (accessible via keybinding)

### Window Menu (`window-menu.sh`)
Window management operations including splits, swaps, moves, and transfers.

#### New Submenus:
- **Swap Windows (interactive)** [S] → Opens window-swap-menu.sh
- **Move Window (interactive)** [M] → Opens window-move-menu.sh

### Pane Menu (`pane-menu.sh`)
Pane management operations including zoom, break, swap, and join.

#### New Submenus:
- **Swap Panes/Windows (interactive)** [P] → Opens pane-swap-menu.sh
- **Join Pane (interactive)** [J] → Opens pane-join-menu.sh

## New Menu Commands

### Window Swap Menu (`window-swap-menu.sh`)

Interactive window swapping and positioning operations:

| Key | Command | Description |
|-----|---------|-------------|
| `C` | `choose-tree { swapw -t '%%' }` | Swap windows, don't follow |
| `W` | `choose-tree { swapw -dt '%%' }` | Swap windows, follow |
| `<` | `choose-tree { movew -dbt '%%' }` | Move before selected, don't follow |
| `>` | `choose-tree { movew -dat '%%' }` | Move after selected, don't follow |
| `,` | `choose-tree { movew -bt '%%' }` | Move before selected, follow |
| `.` | `choose-tree { movew -at '%%' }` | Move after selected, follow |

**Usage:**
1. Open window menu
2. Select "Swap Windows (interactive)" [S]
3. Choose desired swap/move operation
4. Select target window from tree

### Window Move Menu (`window-move-menu.sh`)

Window position movement operations:

| Key | Command | Description |
|-----|---------|-------------|
| `,` | `choose-tree { movew -bt '%%' }` | Move before selected, follow |
| `.` | `choose-tree { movew -at '%%' }` | Move after selected, follow |
| `<` | `choose-tree { movew -dbt '%%' }` | Move before selected, don't follow |
| `>` | `choose-tree { movew -dat '%%' }` | Move after selected, don't follow |

**Usage:**
1. Open window menu
2. Select "Move Window (interactive)" [M]
3. Choose move direction
4. Select target position from tree

### Pane Swap Menu (`pane-swap-menu.sh`)

Interactive pane swapping operations:

| Key | Command | Description |
|-----|---------|-------------|
| `P` | `choose-tree { swapp -t '%%' }` | Swap panes/windows, don't follow |
| `q` | `display-panes { swapp -t '%%' }` | Swap with selected pane |

**Usage:**
1. Open pane menu
2. Select "Swap Panes/Windows (interactive)" [P]
3. Choose swap operation
4. Select target pane/window from display

### Pane Join Menu (`pane-join-menu.sh`)

Join panes horizontally or vertically:

| Key | Command | Description |
|-----|---------|-------------|
| `@` | `choose-tree { joinp -fh -t '%%' }` | Send current → selected (horizontal) |
| `#` | `choose-tree { joinp -fv -t '%%' }` | Send current → selected (vertical) |
| `h` | `choose-tree { joinp -fv -s '%%' }` | Join selected → current (horizontal) |
| `v` | `choose-tree { joinp -fh -s '%%' }` | Join selected → current (vertical) |

**Send vs Join:**
- **Send** (`-t`): Moves current pane TO selected location
- **Join** (`-s`): Brings selected pane FROM source to current location

**Horizontal vs Vertical:**
- **Horizontal** (`-h`): Panes side-by-side (─|─)
- **Vertical** (`-v`): Panes stacked (═/═)

**Usage:**
1. Open pane menu
2. Select "Join Pane (interactive)" [J]
3. Choose send direction or join direction
4. Select target/source pane from tree

## Command Reference

### Tmux Command Flags

**swap-pane / swapp:**
- `-t target`: Target pane
- `-s source`: Source pane
- `-d`: Don't make target current

**join-pane / joinp:**
- `-t target`: Target window/pane
- `-s source`: Source pane
- `-h`: Horizontal split
- `-v`: Vertical split
- `-f`: Full width/height

**move-window / movew:**
- `-t target`: Target position
- `-s source`: Source window
- `-a`: Move after target
- `-b`: Move before target
- `-d`: Don't make moved window current

**swap-window / swapw:**
- `-t target`: Target window
- `-s source`: Source window (default: current)
- `-d`: Don't make target current

## Original Keybindings Reference

These commands were originally bound to keys. They're now available through menus:

```tmux
# Window operations
bind C-w choose-tree { swapw -t "%%" }       # Swap windows, don't follow
bind W   choose-tree { swapw -dt "%%" }      # Swap windows, follow
bind S   choose-tree { movew -at "%%" }      # Move after selected, follow
bind C-, choose-tree { movew -bt "%%" }      # Move before selected, follow
bind C-. choose-tree { movew -at "%%" }      # Move after selected, follow

# Pane operations
bind P   choose-tree { swapp -t "%%" }       # Swap panes, don't follow
bind @   choose-tree { joinp -fh -t "%%" }   # Send current pane horizontal
bind #   choose-tree { joinp -fv -t "%%" }   # Send current pane vertical
bind h   choose-tree { joinp -fv -s "%%" }   # Join pane horizontal
bind v   choose-tree { joinp -fh -s "%%" }   # Join pane vertical
bind q   displayp { swapp -t '%%' }          # Swap with selected pane
```

## File List

Created/Modified files:

1. **window-menu.sh** - Added submenu entries for swap and move
2. **window-swap-menu.sh** - New: Window swap/move operations
3. **window-move-menu.sh** - New: Window position movement
4. **pane-menu.sh** - Added submenu entries for swap and join
5. **pane-swap-menu.sh** - New: Pane swapping operations
6. **pane-join-menu.sh** - New: Pane join operations

## Tips

### Quick Workflow Examples

**Merge two panes side-by-side:**
1. Pane menu → Join Pane [J]
2. Select "Join selected → current (horizontal)" [h]
3. Pick the pane to merge

**Swap window positions:**
1. Window menu → Swap Windows [S]
2. Select "Swap windows, follow" [W]
3. Choose target window

**Send current pane to another window:**
1. Pane menu → Join Pane [J]
2. Select "Send current → selected (vert)" [#]
3. Choose destination window

**Reorder windows:**
1. Window menu → Move Window [M]
2. Select "Move after selected, follow" [.]
3. Choose window to move after

## Testing

All menus have been syntax-checked and are ready to use:
- ✓ window-menu.sh
- ✓ window-swap-menu.sh
- ✓ window-move-menu.sh
- ✓ pane-menu.sh
- ✓ pane-swap-menu.sh
- ✓ pane-join-menu.sh

## Version
- Implementation Date: 2025-10-30
- Compatible with tmux >= 3.0
