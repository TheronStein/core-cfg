# DEPRECATED: scripts/ Directory

**Status:** Deprecated as of 2025-12-09
**Reason:** Consolidated into events/ and modules/

---

## Migration

This directory previously contained various utility scripts that have been
reorganized into a clearer structure:

### Where Scripts Moved

| Old Location | New Location | Notes |
|--------------|--------------|-------|
| `scripts/browsers/` | `modules/fzf/` | FZF-based browsers |
| `scripts/pickers/` | `events/` | Session/window pickers |
| `scripts/popups/` | `modules/popups/` | Popup handlers |
| `scripts/utils/` | `events/` | Event handlers |
| `scripts/fzf/` | `events/` or `modules/fzf/` | FZF integration |

### Canonical Locations

- **Event handlers** (triggered by keys/hooks) → `events/`
- **Feature modules** (cohesive functionality) → `modules/{name}/`
- **Shared utilities** (core functions) → `modules/lib/`

---

## Specific File Migrations

### Browsers
- `browsers/nerdfont.sh` → `modules/fzf/nerdfont-browser/wezterm-browser.sh`
- `fzf/windows.sh` → `events/tmux-pane-picker-enhanced.sh`

### Pickers
- `pickers/pick-session.sh` → `events/tmux-session-picker.sh`
- `pickers/pick-window.sh` → `events/tmux-pane-picker-enhanced.sh`

### Utils
- `utils/reload-config.sh` → `events/reload-config.sh`
- `utils/reset-tmux.sh` → `events/reset-tmux.sh`
- `utils/preview-session.sh` → `events/preview-session.sh`
- `utils/preview_window.sh` → `events/preview_window.sh`

---

## If You're Looking For...

### Session Management
→ `events/tmux-session-picker.sh`
→ `modules/coremux/`

### Window/Pane Operations
→ `events/tmux-pane-picker-enhanced.sh`
→ `events/split.sh`

### Popups
→ `modules/popups/`

### Configuration
→ `conf/` (tmux config files)
→ `keymaps/` (keybindings)

### Utilities
→ `modules/lib/` (shared functions)

---

## Deprecation Timeline

- **2025-12-09**: Directory deprecated, README created
- **Future**: Directory may be removed in a future cleanup

---

## Need Help?

See the main architecture documentation:
- `.docs/architecture-plan.md`
- `.docs/architecture-summary.md`
- `modules/README.md`
