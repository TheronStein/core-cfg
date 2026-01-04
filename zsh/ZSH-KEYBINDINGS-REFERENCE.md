# ZSH Keybindings Reference

> **Last Updated:** 2026-01-03
> **Config Location:** `~/.core/.sys/cfg/zsh/`

## Important Notes

- **Loading Order**: Keybindings are loaded in the sequence shown below. Later bindings override earlier ones.
- **Final Bindings Win**: If the same key is bound multiple times, the last binding in the load order takes effect.
- **Vi Mode**: The configuration uses `zsh-vi-mode` plugin, which requires special handling via `zvm_after_init()` hook.
- **Key Notation**:
  - `^X` = Ctrl+X
  - `^[` = Alt (Meta) or Escape
  - `^[[A` = Up arrow
  - `^M` = Enter/Return

---

## Loading Order Summary

1. **02-zinit.zsh** - Plugin initialization with vi-mode keybindings
2. **04-keybindings.zsh** - Main keybindings configuration
3. **06-snippets.zsh** - Snippet expansion bindings
4. **integrations/fzf.zsh** - FZF git integration
5. **integrations/widgets.zsh** - Widget keybindings
6. **integrations/zoxide.zsh** - Zoxide jump binding
7. **integrations/wezterm.zsh** - WezTerm integration
8. **modules/keybindings.zsh** - Extended keybindings module
9. **modules/main-menu.zsh** - Main menu system
10. **modules/widgets-advanced.zsh** - Advanced system widgets

---

## 1. Plugin Initialization (`02-zinit.zsh`)

### Vi Mode Integration - `zvm_after_init()` Hook

These bindings are set AFTER `zsh-vi-mode` loads to prevent conflicts:

#### Main Menu System

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Space` | Insert | `widget::universal-overlay` | Universal command palette |
| `Alt+Space` | Command | `_core_menu_widget` | Core menu widget |
| `Alt+/` | Insert | `widget::universal-overlay` | Alternate universal overlay |
| `Alt+/` | Command | `_core_menu_widget` | Alternate core menu |
| `Alt+M` | Insert | `_core_menu_widget` | Another menu trigger |
| `Alt+M` | Command | `_core_menu_widget` | Another menu trigger |

#### FZF Widgets (Re-bound after vi-mode)

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+R` | Insert | `widget::fzf-history-search` | Enhanced history search |
| `Ctrl+F` | Insert | `widget::fzf-file-selector` | Find and insert files |
| `Alt+F` | Insert | `widget::fzf-directory-selector` | Find directories |
| `Ctrl+K` | Insert | `widget::fzf-kill-process` | Kill processes |
| `Ctrl+P` | Insert | `widget::command-palette` | Command palette |

#### Git Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+G` | Insert | `widget::fzf-git-status` | Select changed files |
| `Alt+G` | Insert | `widget::fzf-git-branch` | Git branch selector |
| `Alt+C` | Insert | `widget::fzf-git-commits` | Browse commits |

#### Tmux Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+T` | Insert | `widget::fzf-tmux-session` | Switch tmux sessions |
| `Alt+T` | Insert | `widget::fzf-tmux-window` | Switch tmux windows |

#### Yazi Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Y` | Insert | `widget::yazi-picker` | Choose files via Yazi |
| `Ctrl+Y` | Insert | `widget::yazi-cd` | Change dir via Yazi |

#### Utility Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+S` | Insert | `widget::fzf-ssh` | SSH host selector |
| `Alt+E` | Insert | `widget::fzf-env` | Environment variable browser |
| `Ctrl+X Ctrl+E` | Insert | `widget::edit-command` | Edit command in $EDITOR |
| `Ctrl+L` | Insert | `widget::clear-scrollback` | Clear screen and scrollback |

#### Clipboard Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+W` | Insert | `widget::copy-buffer` | Copy buffer to clipboard |
| `Alt+V` | Insert | `widget::paste-clipboard` | Paste from clipboard |

#### Bitwarden & Notes

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+B` | Insert | `widget::bitwarden` | Bitwarden interactive |
| `Alt+J` | Insert | `widget::jump-bookmark` | Jump to bookmark |
| `Alt+N` | Insert | `widget::quick-note` | Quick note |

#### Text Manipulation

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+=` | Insert | `widget::calculator` | Evaluate expression |
| `Alt+D` | Insert | `widget::insert-date` | Insert current date |
| `Alt+Shift+T` | Insert | `widget::insert-timestamp` | Insert timestamp |

#### History Substring Search

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Up Arrow` | Insert | `history-substring-search-up` | Search history up |
| `Down Arrow` | Insert | `history-substring-search-down` | Search history down |
| `K` | Command | `history-substring-search-up` | Search history up (vi) |
| `J` | Command | `history-substring-search-down` | Search history down (vi) |

#### Documentation Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+H` | Insert | `_doc_help_widget` | Documentation help |
| `Alt+?` | Insert | `_doc_search_widget` | Search documentation |
| `Alt+R` | Insert | `_doc_quick_ref_widget` | Quick reference |
| `Ctrl+X ?` | Insert | `doc-menu` | Documentation menu |
| `Ctrl+X H` | Insert | `widget::doc-generate` | Generate documentation |

#### Sudo Toggle

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Esc Esc` | Insert | `widget::toggle-sudo` | Toggle sudo prefix |
| `Esc Esc` | Command | `widget::toggle-sudo` | Toggle sudo prefix |

### Backup Bindings (Outside Hook)

These are also set outside `zvm_after_init()` as fallback:

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Space` | Insert | `widget::universal-overlay` | Universal overlay (backup) |
| `Alt+Space` | Command | `_core_menu_widget` | Core menu (backup) |
| `Alt+/` | Insert | `widget::universal-overlay` | Alternate overlay (backup) |
| `Alt+/` | Command | `_core_menu_widget` | Alternate menu (backup) |
| `Alt+M` | Insert | `_core_menu_widget` | Menu trigger (backup) |
| `Alt+M` | Command | `_core_menu_widget` | Menu trigger (backup) |

### History Plugin Bindings

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Up Arrow` | All | `history-substring-search-up` | Search history up |
| `Down Arrow` | All | `history-substring-search-down` | Search history down |
| `K` | Command | `history-substring-search-up` | Search history up (vi) |
| `J` | Command | `history-substring-search-down` | Search history down (vi) |

---

## 2. Main Keybindings (`04-keybindings.zsh`)

### History Navigation

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `^[OA` | All | `history-substring-search-up` | Terminal compatibility up |
| `^[OB` | All | `history-substring-search-down` | Terminal compatibility down |
| `Alt+P` | All | `up-line-or-beginning-search` | History up from cursor |
| `Alt+N` | All | `down-line-or-beginning-search` | History down from cursor |

### Line Movement (Emacs Style)

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+A` | All | `beginning-of-line` | Start of line |
| `Ctrl+E` | All | `end-of-line` | End of line |
| `Ctrl+B` | All | `backward-char` | Back one character |
| `Alt+B` | All | `backward-word` | Back one word |
| `Alt+F` | All | `forward-word` | Forward one word |
| `^[[8;5u` | All | `backward-word` | Backward word (special) |
| `^[[H` | All | `beginning-of-line` | Home key |
| `^[[F` | All | `end-of-line` | End key |
| `^[[1~` | All | `beginning-of-line` | Home (alternate) |
| `^[[4~` | All | `end-of-line` | End (alternate) |

### Text Deletion

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+H` | All | `backward-delete-char` | Backspace |
| `^?` | All | `backward-delete-char` | Backspace (alternate) |
| `^[[3~` | All | `delete-char` | Delete |
| `Ctrl+W` | All | `backward-kill-word` | Delete word back |
| `Alt+D` | All | `kill-word` | Delete word forward |
| `Alt+K` | All | `kill-line` | Delete to end |

### Text Transformation

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+U` | All | `up-case-word` | Uppercase word |
| `Alt+L` | All | `down-case-word` | Lowercase word |
| `Alt+C` | All | `capitalize-word` | Capitalize word |
| `Alt+T` | All | `transpose-words` | Swap words |
| `Ctrl+T` | All | `transpose-chars` | Swap characters |

### Completion

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+I` | All | `expand-or-complete` | Standard completion |
| `Alt+!` | All | `expand-history` | Expand history |
| `Alt+~` | All | `_bash_complete-word` | Bash completion |

### Menu Navigation

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Shift+Tab` | Menu | `reverse-menu-complete` | Reverse through menu |
| `Escape` | Menu | `send-break` | Cancel menu |
| `Enter` | Menu | `.accept-line` | Accept selection |
| `J` | Menu | `vi-backward-char` | Left (vi-style) |
| `K` | Menu | `vi-down-line-or-history` | Down (vi-style) |
| `I` | Menu | `vi-up-line-or-history` | Up (vi-style) |
| `L` | Menu | `vi-forward-char` | Right (vi-style) |

### Vi Command Mode Bindings

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `J` | Command | `beginning-of-line` | Jump to line start |
| `L` | Command | `end-of-line` | Jump to line end |
| `Ctrl+U` | Command | `undo` | Undo |
| `Ctrl+R` | Command | `redo` | Redo |
| `/` | Command | `widget::fzf-history-search` | FZF history search |
| `V` | Command | `widget::edit-command` | Edit in editor |

### Special Function Keys

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Page Up` | All | `beginning-of-buffer-or-history` | Buffer/history start |
| `Page Down` | All | `end-of-buffer-or-history` | Buffer/history end |

### Help Keys

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `F1` | All | `widget::show-keybindings` | Show keybindings reference |
| `Alt+?` | All | `widget::show-keybindings` | Show keybindings reference |

---

## 3. Snippet Expansion (`06-snippets.zsh`)

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Space` | All | `magic-space` | Expand abbreviations |
| `Enter` | All | `magic-enter` | Expand and execute |
| `Ctrl+X Ctrl+S` | All | `expand-snippet` | Expand code snippets |

**Note:** See `abbrs` and `snips` commands for lists of abbreviations and snippets.

---

## 4. FZF Integration (`integrations/fzf.zsh`)

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+G Ctrl+A` | All | `fzf-git-add` | FZF git add (conditional) |

---

## 5. Widget Integration (`integrations/widgets.zsh`)

**Note:** These may conflict with earlier bindings and might be overridden.

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+F` | All | `widget::fzf-file` | FZF file selector |
| `Ctrl+D` | All | `widget::fzf-dir` | FZF directory selector |
| `Ctrl+R` | All | `widget::fzf-history` | FZF history search |
| `Ctrl+K` | All | `widget::fzf-kill` | FZF process killer |
| `Ctrl+G` | All | `widget::fzf-git-status` | FZF git status |

---

## 6. Zoxide Integration (`integrations/zoxide.zsh`)

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Z` | All | `widget::zoxide-jump` | Zoxide directory jump |

---

## 7. WezTerm Integration (`integrations/wezterm.zsh`)

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Shift+Y` | All | `wezterm-copy-cmd` | Copy command to WezTerm |

---

## 8. Extended Keybindings Module (`modules/keybindings.zsh`)

### Mode Setup

| Command | Description |
|---------|-------------|
| `bindkey -e` | Use Emacs keybindings as base |

### FZF Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+R` | All | `widget::fzf-history-search` | Enhanced history |
| `Ctrl+F` | All | `widget::fzf-file-selector` | Find files |
| `Alt+F` | All | `widget::fzf-directory-selector` | Find directories |
| `Ctrl+K` | All | `widget::fzf-kill-process` | Kill process |
| `Ctrl+P` | All | `widget::command-palette` | Command palette |

### Git Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+G` | All | `widget::fzf-git-status` | Git status files |
| `Alt+G` | All | `widget::fzf-git-branch` | Git branches |
| `Alt+C` | All | `widget::fzf-git-commits` | Git commits |
| `Alt+R` | All | `widget::fzf-git-remotes` | Git remotes |

### Tmux Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+T` | All | `widget::fzf-tmux-session` | Tmux sessions |
| `Alt+T` | All | `widget::fzf-tmux-window` | Tmux windows |
| `Alt+P` | All | `widget::fzf-tmux-pane` | Tmux panes |

### File Management

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Y` | All | `widget::yazi-picker` | Yazi file picker |
| `Ctrl+Y` | All | `widget::yazi-cd` | Yazi with cd |

### Editor Integration

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+X Ctrl+E` | All | `widget::edit-command-nvim` | Edit in nvim |
| `Alt+O` | All | `widget::nvim-recent-files` | Recent nvim files |

### Clipboard

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+W` | All | `widget::copy-buffer` | Copy buffer |
| `Alt+V` | All | `widget::paste-clipboard` | Paste clipboard |
| `Alt+X` | All | `widget::cut-buffer` | Cut buffer |

### Bookmarks & Navigation

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+B` | All | `widget::bookmark-directory` | Bookmark directory |
| `Alt+J` | All | `widget::jump-bookmark` | Jump to bookmark |
| `Alt+Z` | All | `widget::zoxide-interactive` | Zoxide jump |

### Text Utilities

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+=` | All | `widget::calculator` | Calculator |
| `Alt+D` | All | `widget::insert-date` | Insert date |
| `Alt+Shift+D` | All | `widget::insert-timestamp` | Insert timestamp |
| `Alt+U` | All | `widget::insert-uuid` | Insert UUID |

### Miscellaneous

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+S` | All | `widget::fzf-ssh` | SSH host selector |
| `Alt+E` | All | `widget::fzf-env` | Environment variables |
| `Ctrl+L` | All | `widget::clear-scrollback` | Clear with scrollback |
| `Alt+N` | All | `widget::quick-note` | Quick note |
| `Alt+Space` | All | `widget::expand-alias` | Expand alias |

### Sudo Toggle

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Esc Esc` | All | `widget::toggle-sudo` | Toggle sudo |

### History Search

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Up Arrow` | All | `history-substring-search-up` | Search up |
| `Down Arrow` | All | `history-substring-search-down` | Search down |
| `^[OA` | All | `history-substring-search-up` | Terminal compat up |
| `^[OB` | All | `history-substring-search-down` | Terminal compat down |

### History Beginning Search

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+P` | All | `up-line-or-beginning-search` | History up |
| `Alt+N` | All | `down-line-or-beginning-search` | History down |

### Line Movement

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+A` | All | `beginning-of-line` | Start of line |
| `Ctrl+E` | All | `end-of-line` | End of line |
| `Ctrl+B` | All | `backward-char` | Back one char |
| `Alt+B` | All | `backward-word` | Back one word |
| `Alt+F` | All | `forward-word` | Forward one word |
| `^[[H` | All | `beginning-of-line` | Home |
| `^[[F` | All | `end-of-line` | End |
| `^[[1~` | All | `beginning-of-line` | Home (alt) |
| `^[[4~` | All | `end-of-line` | End (alt) |

### Text Deletion

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+H` | All | `backward-delete-char` | Backspace |
| `^?` | All | `backward-delete-char` | Backspace (alt) |
| `^[[3~` | All | `delete-char` | Delete |
| `Ctrl+W` | All | `backward-kill-word` | Delete word back |
| `Alt+D` | All | `kill-word` | Delete word forward |
| `Ctrl+U` | All | `backward-kill-line` | Delete to start |
| `Alt+K` | All | `kill-line` | Delete to end |

### Text Transformation

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Shift+U` | All | `up-case-word` | Uppercase word |
| `Alt+L` | All | `down-case-word` | Lowercase word |
| `Alt+Shift+C` | All | `capitalize-word` | Capitalize word |
| `Alt+T` | All | `transpose-words` | Swap words |
| `Ctrl+T` | All | `transpose-chars` | Swap chars |

### Undo/Redo

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Ctrl+_` | All | `undo` | Undo |
| `Alt+/` | All | `redo` | Redo |

### Menu Select

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Shift+Tab` | Menu | `reverse-menu-complete` | Reverse |
| `Escape` | Menu | `send-break` | Cancel |
| `Enter` | Menu | `.accept-line` | Accept |
| `H` | Menu | `vi-backward-char` | Left |
| `J` | Menu | `vi-down-line-or-history` | Down |
| `K` | Menu | `vi-up-line-or-history` | Up |
| `L` | Menu | `vi-forward-char` | Right |

### Vi Command Mode

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `H` | Command | `beginning-of-line` | Line start |
| `L` | Command | `end-of-line` | Line end |
| `U` | Command | `undo` | Undo |
| `Ctrl+R` | Command | `redo` | Redo |
| `/` | Command | `widget::fzf-history-search` | FZF history |
| `V` | Command | `widget::edit-command-nvim` | Edit command |

### Special Keys

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Page Up` | All | `beginning-of-buffer-or-history` | Buffer start |
| `Page Down` | All | `end-of-buffer-or-history` | Buffer end |

### Help

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `F1` | All | `widget::show-keybindings` | Show keybindings |
| `Alt+?` | All | `widget::show-keybindings` | Show keybindings |

---

## 9. Main Menu System (`modules/main-menu.zsh`)

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Ctrl+F` | All | `_core_menu_fzf_widget` | Core menu FZF widget |

---

## 10. Advanced System Widgets (`modules/widgets-advanced.zsh`)

### Systemd Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Ctrl+S` | All | `widget::systemd-unit-manager` | Systemd unit manager |
| `Alt+Ctrl+J` | All | `widget::systemd-journal-browser` | Journal browser |

### Docker Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Ctrl+D` | All | `widget::docker-container-manager` | Container manager |
| `Alt+Ctrl+I` | All | `widget::docker-image-manager` | Image manager |
| `Alt+Ctrl+C` | All | `widget::docker-compose-manager` | Compose manager |

### Workspace & Session Management

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Ctrl+W` | All | `widget::workspace-launcher` | Workspace launcher |
| `Alt+Ctrl+M` | All | `widget::session-manager` | Session manager |

### Miscellaneous Advanced Widgets

| Keybinding | Mode | Widget | Description |
|------------|------|--------|-------------|
| `Alt+Ctrl+V` | All | `widget::clipboard-history-manager` | Clipboard history |
| `Alt+Ctrl+N` | All | `widget::network-manager` | Network manager |
| `Alt+Ctrl+P` | All | `widget::process-manager` | Process manager |

---

## Keybinding Conflicts & Overrides

### Known Conflicts

1. **Alt+C**: Multiple bindings
   - `04-keybindings.zsh`: `capitalize-word`
   - `02-zinit.zsh` (zvm_after_init): `widget::fzf-git-commits` (WINS in insert mode)
   - `modules/keybindings.zsh`: `widget::fzf-git-commits` (confirms override)

2. **Alt+D**: Multiple bindings
   - `04-keybindings.zsh`: `kill-word` (delete word forward)
   - `02-zinit.zsh` (zvm_after_init): `widget::insert-date` (WINS in insert mode)
   - `modules/keybindings.zsh`: `widget::insert-date` (confirms override)

3. **Alt+N**: Multiple bindings
   - `04-keybindings.zsh`: `down-line-or-beginning-search`
   - `02-zinit.zsh` (zvm_after_init): `widget::quick-note` (WINS in insert mode)
   - `modules/keybindings.zsh`: `widget::quick-note` (confirms override)

4. **Alt+P**: Multiple bindings
   - `04-keybindings.zsh`: `up-line-or-beginning-search`
   - `modules/keybindings.zsh`: `widget::fzf-tmux-pane` (WINS)

5. **Alt+R**: Multiple bindings
   - No conflicts in main files
   - `modules/keybindings.zsh`: `widget::fzf-git-remotes`

6. **Ctrl+Y**: Multiple bindings
   - `02-zinit.zsh` (zvm_after_init): `widget::yazi-cd`
   - `modules/keybindings.zsh`: `widget::yazi-cd` (confirms)

7. **Alt+B**: Multiple bindings
   - `04-keybindings.zsh`: `backward-word`
   - `02-zinit.zsh` (zvm_after_init): `widget::bitwarden` (WINS in insert mode)
   - `modules/keybindings.zsh`: `widget::bookmark-directory` (CONFLICTS!)

### Resolution Strategy

The **last loaded binding wins**. Based on loading order:
- `modules/keybindings.zsh` loads AFTER `02-zinit.zsh`
- BUT `zvm_after_init()` is called AFTER vi-mode plugin initialization
- This means `zvm_after_init()` bindings may override module bindings in vi insert mode

To check current bindings:
```zsh
bindkey | grep "^\"\\^\\[b\""  # Check Alt+B binding
bindkey | grep "desired-key"   # Check any key
```

---

## Quick Reference Commands

| Command | Description |
|---------|-------------|
| `bindkey` | List all current keybindings |
| `bindkey -M viins` | List insert mode bindings |
| `bindkey -M vicmd` | List command mode bindings |
| `bindkey -M menuselect` | List menu selection bindings |
| `keys` | Show keybindings reference (alias) |
| `abbrs` | List all abbreviations |
| `snips` | List all snippets |
| `F1` or `Alt+?` | Show keybindings help widget |

---

## Finding Key Codes

To find the code for any key:

```zsh
# Method 1: Using cat
cat -v
# Press the key, then Ctrl+C

# Method 2: Using showkey (may need to install)
showkey -a
# Press the key, then wait 10 seconds

# Method 3: Using read
read
# Press the key, then Enter
```

---

## Additional Resources

- **ZSH Line Editor**: `man zshzle`
- **ZSH Keymaps**: `man zshmodules` (search for zsh/complist)
- **Vi Mode Plugin**: [jeffreytse/zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode)

---

**Generated:** 2026-01-03
**By:** Claude Code
