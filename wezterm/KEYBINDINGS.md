# WezTerm Keybindings Reference

**Leader Key:** `SUPER+Space` (Windows/Command + Space)

---

## LEADER Keybindings

### Session & Workspace Management
| Key | Description |
|-----|-------------|
| `F1` | Show session/workspace menu |
| `w` | Show workspace manager menu |
| `W` (Shift) | Browse/launch tmux workspaces |
| `R` (Shift) | Rename current workspace |
| `S` (Shift) | Save current workspace as template |
| `L` (Shift) | Load workspace template |

### Tmux Integration
| Key | Description |
|-----|-------------|
| `a` | Attach to tmux session (workspace → session selector) |
| `A` (Shift) | Create new tmux session |
| `t` | Toggle WezTerm/tmux context mode |

### Pane Management
| Key | Description |
|-----|-------------|
| `m` | Move pane to another tab |
| `g` | Grab pane from another tab |
| `T` (Shift) | Move pane to its own tab |
| `p` | Pane picker (select with arrows) |
| `v` | Split pane vertically (right) |
| `d` | Split pane horizontally (down) |
| `x` | Close current pane |

### Tab Management
| Key | Description |
|-----|-------------|
| `c` | Create new tab |

### Utilities
| Key | Description |
|-----|-------------|
| `F3` | Browse Nerd Fonts icons |
| `F4` | Browse keybindings (this reference) |
| `F5` | Browse and preview themes |
| `` ` `` | Activate copy mode |
| `/` | Search (current selection or empty) |
| `r` | Reload configuration |

---

## CTRL+SHIFT Keybindings

### Pane Navigation (Neovim-aware)
| Key | Description |
|-----|-------------|
| `CTRL+SHIFT+I` | Navigate to pane above |
| `CTRL+SHIFT+K` | Navigate to pane below |
| `CTRL+SHIFT+J` | Navigate to pane left |
| `CTRL+SHIFT+L` | Navigate to pane right |

### Tab Navigation
| Key | Description |
|-----|-------------|
| `CTRL+SHIFT+Q` | Previous tab |
| `CTRL+SHIFT+E` | Next tab |

### Window Management
| Key | Description |
|-----|-------------|
| `CTRL+SHIFT+N` | New window |
| `CTRL+SHIFT+W` | Close current tab |

---

## SUPER (Windows/Command) Keybindings

### Backdrop Management
| Key | Description |
|-----|-------------|
| `SUPER+ALT+E` | Next backdrop image |
| `SUPER+ALT+Q` | Previous backdrop image |
| `SUPER+ALT+R` | Random backdrop image |
| `SUPER+ALT+S` | Select backdrop from list |

### Quick Actions
| Key | Description |
|-----|-------------|
| `SUPER+Space` | **Leader key** |
| `SUPER+Enter` | Toggle fullscreen |
| `SUPER+F` | Search |

---

## Context-Aware Bindings

When in **tmux context mode** (`LEADER+t` to toggle):
- Context-aware keys send tmux prefix (`CTRL+Space`) + key to tmux
- When in **wezterm context mode**: keys execute WezTerm actions

**Current context shown in status bar**

---

## Copy Mode

Activated with: `LEADER+` `` ` ``

| Key | Description |
|-----|-------------|
| `v` | Start selection |
| `V` | Start line selection |
| `y` | Copy selection |
| `ESC` | Exit copy mode |
| `h/j/k/l` | Navigate (vim keys) |
| `0/$` | Start/end of line |
| `g/G` | Top/bottom of scrollback |

---

## Tmux Workspaces

Workspaces are tmux server instances with dedicated configurations:

| Workspace | Icon | Color | Description |
|-----------|------|-------|-------------|
| configuration | 󰒓 | Blue | System configuration and dotfiles |
| development | 󰅩 | Green | Software development projects |
| documentation | 󰂺 | Yellow | Documentation and knowledge base |
| environment | 󰀻 | Peach | Environment setup and management |
| objective | 󰛕 | Red | Goal tracking and task management |
| personal | 󰀄 | Mauve | Personal projects and files |
| system | 󰍹 | Teal | System administration |
| testing | 󰻉 | Pink | Testing and experimentation |

**Access:** `LEADER+W` or `LEADER+a`

---

## Quick Reference Card

```
LEADER (SUPER+Space) + ...

Sessions & Workspaces:     Panes:              Utilities:
  F1  Session menu           m  Move pane        F3  Nerd fonts
  w   Workspace menu         g  Grab pane        F4  Keybindings
  W   Tmux workspaces        T  Extract pane     F5  Themes
  R   Rename workspace       v  Split right      `   Copy mode
  S   Save template          d  Split down       /   Search
  L   Load template          x  Close pane       r   Reload

Tmux:                      Tabs:
  a   Attach session         c  New tab
  A   Create session
  t   Toggle context
```

---

## Tips

1. **Tab titles with tmux workspaces**: When attached to a tmux session in a workspace, tab titles show `Workspace → session-name`

2. **Independent tmux views**: Each WezTerm tab attached to the same tmux session gets an independent view (different windows/panes)

3. **Context mode**: Toggle between WezTerm and tmux context to control whether keys go to WezTerm or tmux

4. **Workspace templates**: Save entire workspace layouts (all tabs, panes, cwds) and restore them later

5. **Theme preview**: Use `LEADER+F5` to browse themes with live preview

---

*Last updated: 2025-11-16*
*Config location: `~/.core/cfg/wezterm/`*
