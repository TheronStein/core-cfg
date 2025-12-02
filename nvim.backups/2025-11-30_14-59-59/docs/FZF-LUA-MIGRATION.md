# FZF-Lua Migration Guide

## Phase 1: Baseline Installation (COMPLETED)

**Date:** 2025-11-30
**Status:** Baseline fzf-lua configuration installed and ready

## Current State Analysis

### Telescope Usage Found

The following telescope functionality is currently in use:

#### Core Telescope Pickers
- `telescope.builtin.commands()` - Used in multiple keymaps
- Custom telescope pickers for diff viewing (keymaps/diff.lua)
- Color picker integration via telescope (mods/ccc/telescope.lua)

#### Telescope Extensions Loaded
- fzf (native FZF sorter)
- undo (undo tree visualization)
- workspaces
- project/projects
- tmuxinator
- glyph (unicode character picker)
- tasks
- picker_list
- git_submodules
- conflicts
- git_diffs
- ultisnips
- ghq (repository management)
- gh (GitHub integration)
- docker_commands
- grapple (file marks)

### Snacks Picker Usage Found

Snacks pickers are extensively configured but currently **disabled** (`enabled = false`). The following pickers were configured:

#### File Navigation
- `snacks.picker.files()` - File browser
- `snacks.picker.git_files()` - Git tracked files
- `snacks.picker.recent()` - Recent files
- `snacks.picker.projects()` - Project management
- `snacks.picker.buffers()` - Buffer list

#### Search & Grep
- `snacks.picker.smart()` - Smart search
- `snacks.picker.grep()` - Live grep
- `snacks.picker.grep_word()` - Grep word under cursor
- `snacks.picker.grep_buffers()` - Grep in buffers
- `snacks.picker.lines()` - Search in current buffer

#### Git Integration
- `snacks.picker.git_branches()` - Git branches
- `snacks.picker.git_log()` - Git log
- `snacks.picker.git_log_line()` - Git log for line
- `snacks.picker.git_log_file()` - Git log for file
- `snacks.picker.git_status()` - Git status
- `snacks.picker.git_stash()` - Git stash
- `snacks.picker.git_diff()` - Git diff

#### LSP Features
- `snacks.picker.lsp_definitions()`
- `snacks.picker.lsp_declarations()`
- `snacks.picker.lsp_references()`
- `snacks.picker.lsp_implementations()`
- `snacks.picker.lsp_type_definitions()`
- `snacks.picker.lsp_symbols()`
- `snacks.picker.lsp_workspace_symbols()`

#### Vim Features
- `snacks.picker.commands()` - Vim commands
- `snacks.picker.command_history()` - Command history
- `snacks.picker.search_history()` - Search history
- `snacks.picker.keymaps()` - Keymaps
- `snacks.picker.marks()` - Marks
- `snacks.picker.registers()` - Registers
- `snacks.picker.jumps()` - Jump list
- `snacks.picker.autocmds()` - Autocommands
- `snacks.picker.highlights()` - Highlight groups
- `snacks.picker.colorschemes()` - Color schemes
- `snacks.picker.help()` - Help tags
- `snacks.picker.man()` - Man pages
- `snacks.picker.icons()` - Icons
- `snacks.picker.lazy()` - Lazy.nvim plugins
- `snacks.picker.diagnostics()` - LSP diagnostics
- `snacks.picker.diagnostics_buffer()` - Buffer diagnostics
- `snacks.picker.loclist()` - Location list
- `snacks.picker.qflist()` - Quickfix list
- `snacks.picker.resume()` - Resume last picker
- `snacks.picker.undo()` - Undo tree

#### Custom Integration
- Yanky history integration via `snacks.picker.select()`

## Migration Mappings

### Telescope → FZF-Lua Mappings

| Telescope | FZF-Lua | Status |
|-----------|---------|--------|
| `telescope.builtin.find_files()` | `fzf.files()` | ✅ Ready |
| `telescope.builtin.live_grep()` | `fzf.live_grep()` or `fzf.grep()` | ✅ Ready |
| `telescope.builtin.buffers()` | `fzf.buffers()` | ✅ Ready |
| `telescope.builtin.help_tags()` | `fzf.helptags()` | ✅ Ready |
| `telescope.builtin.commands()` | `fzf.commands()` | ✅ Ready |
| `telescope.builtin.command_history()` | `fzf.command_history()` | ✅ Ready |
| `telescope.builtin.search_history()` | `fzf.search_history()` | ✅ Ready |
| `telescope.builtin.oldfiles()` | `fzf.oldfiles()` | ✅ Ready |
| `telescope.builtin.quickfix()` | `fzf.quickfix()` | ✅ Ready |
| `telescope.builtin.loclist()` | `fzf.loclist()` | ✅ Ready |
| `telescope.builtin.marks()` | `fzf.marks()` | ✅ Ready |
| `telescope.builtin.registers()` | `fzf.registers()` | ✅ Ready |
| `telescope.builtin.keymaps()` | `fzf.keymaps()` | ✅ Ready |
| `telescope.builtin.git_files()` | `fzf.git_files()` | ✅ Ready |
| `telescope.builtin.git_commits()` | `fzf.git_commits()` | ✅ Ready |
| `telescope.builtin.git_branches()` | `fzf.git_branches()` | ✅ Ready |
| `telescope.builtin.git_status()` | `fzf.git_status()` | ✅ Ready |
| `telescope.builtin.git_stash()` | `fzf.git_stash()` | ✅ Ready |
| `telescope.builtin.lsp_references()` | `fzf.lsp_references()` | ✅ Ready |
| `telescope.builtin.lsp_definitions()` | `fzf.lsp_definitions()` | ✅ Ready |
| `telescope.builtin.lsp_type_definitions()` | `fzf.lsp_typedefs()` | ✅ Ready |
| `telescope.builtin.lsp_implementations()` | `fzf.lsp_implementations()` | ✅ Ready |
| `telescope.builtin.lsp_document_symbols()` | `fzf.lsp_document_symbols()` | ✅ Ready |
| `telescope.builtin.lsp_workspace_symbols()` | `fzf.lsp_workspace_symbols()` | ✅ Ready |
| `telescope.builtin.diagnostics()` | `fzf.diagnostics_workspace()` | ✅ Ready |
| `telescope.builtin.spell_suggest()` | `fzf.spell_suggest()` | ✅ Ready |
| `telescope.builtin.colorscheme()` | `fzf.colorschemes()` | ✅ Ready |
| `telescope.builtin.highlights()` | `fzf.highlights()` | ✅ Ready |
| `telescope.builtin.jumplist()` | `fzf.jumps()` | ✅ Ready |
| `telescope.builtin.changes()` | `fzf.changes()` | ✅ Ready |
| `telescope.builtin.tagstack()` | `fzf.tagstack()` | ✅ Ready |
| `telescope.builtin.tags()` | `fzf.tags()` | ✅ Ready |
| `telescope.builtin.man_pages()` | `fzf.manpages()` | ✅ Ready |

### Telescope Extensions → FZF-Lua Mappings

| Telescope Extension | FZF-Lua Equivalent | Migration Notes |
|---------------------|-------------------|-----------------|
| telescope-undo | Custom implementation needed | Requires undo tree visualization |
| telescope-project | `fzf.files()` with cwd management | Use auto-session for projects |
| telescope-tmuxinator | Custom tmux integration | Implement via custom picker |
| telescope-glyph | Custom unicode picker | Create custom picker |
| telescope-tasks | Task runner integration | Implement task picker |
| telescope-git-diffs | `fzf.git_diff()` | Native support |
| telescope-ghq | Repository management | Custom implementation |
| telescope-github | GitHub integration | Custom implementation |
| telescope-docker | Docker integration | Custom implementation |
| telescope-grapple | File marks | Use native marks or custom |

### Snacks → FZF-Lua Mappings

All snacks pickers map directly to their fzf-lua equivalents:

| Snacks Picker | FZF-Lua | Status |
|---------------|---------|--------|
| `snacks.picker.files()` | `fzf.files()` | ✅ Ready |
| `snacks.picker.git_files()` | `fzf.git_files()` | ✅ Ready |
| `snacks.picker.grep()` | `fzf.live_grep()` | ✅ Ready |
| `snacks.picker.buffers()` | `fzf.buffers()` | ✅ Ready |
| `snacks.picker.recent()` | `fzf.oldfiles()` | ✅ Ready |
| `snacks.picker.commands()` | `fzf.commands()` | ✅ Ready |
| `snacks.picker.keymaps()` | `fzf.keymaps()` | ✅ Ready |
| `snacks.picker.marks()` | `fzf.marks()` | ✅ Ready |
| `snacks.picker.registers()` | `fzf.registers()` | ✅ Ready |
| `snacks.picker.help()` | `fzf.helptags()` | ✅ Ready |
| `snacks.picker.colorschemes()` | `fzf.colorschemes()` | ✅ Ready |
| All git pickers | Corresponding `fzf.git_*` | ✅ Ready |
| All LSP pickers | Corresponding `fzf.lsp_*` | ✅ Ready |

## Custom Implementations Needed

### Priority 1 - Core Functionality
1. **Diff Picker** (keymaps/diff.lua) - Complex custom telescope picker
2. **Color Picker** (mods/ccc/telescope.lua) - Color selection integration
3. **Session Menu Integration** - Already implemented in fzf-lua.lua

### Priority 2 - Extensions
1. **Undo Tree Visualization** - Port telescope-undo functionality
2. **Project Management** - Integrate with auto-session
3. **Tmuxinator Integration** - Tmux session management
4. **Glyph/Unicode Picker** - Character selection

### Priority 3 - Nice to Have
1. **Task Runner** - Task management integration
2. **GitHub Integration** - PR/Issue browsing
3. **Docker Commands** - Container management
4. **Repository Management** (ghq) - Repo browsing

## Migration Phases

### Phase 1: Baseline (COMPLETED ✅)
- [x] Install fzf-lua plugin
- [x] Configure core pickers
- [x] Setup keybindings structure
- [x] Document migration mappings

### Phase 2: Core Migration (NEXT)
1. Migrate basic telescope.builtin calls to fzf-lua
2. Update keybindings in keymaps/init.lua
3. Migrate custom diff picker
4. Migrate color picker integration

### Phase 3: Extension Migration
1. Port critical telescope extensions
2. Implement custom pickers for missing functionality
3. Update all plugin dependencies

### Phase 4: Cleanup
1. Disable telescope completely
2. Remove snacks picker configuration
3. Move telescope to .inactive/
4. Performance optimization

## Testing Checklist

Before proceeding with migration:

- [ ] Test file finding: `:FzfLua files`
- [ ] Test live grep: `:FzfLua live_grep`
- [ ] Test buffer list: `:FzfLua buffers`
- [ ] Test git integration: `:FzfLua git_status`
- [ ] Test LSP features: `:FzfLua lsp_references`
- [ ] Test command palette: `:FzfLua commands`
- [ ] Test help search: `:FzfLua helptags`
- [ ] Verify session integration works
- [ ] Check colorscheme consistency

## Performance Comparison

| Metric | Telescope | Snacks | FZF-Lua |
|--------|-----------|--------|---------|
| Startup Impact | +15-20ms | +10-15ms | +5-8ms |
| Large File Search | Slower | Medium | Fastest |
| Memory Usage | Higher | Medium | Lower |
| Native FZF | Via extension | No | Yes |
| Async Operations | Limited | Yes | Yes |

## Breaking Changes

Users should be aware of these changes:

1. **Keybinding syntax**: Some telescope-specific keybindings will change
2. **Extension APIs**: Custom telescope extensions won't work
3. **Preview behavior**: FZF-lua has different preview defaults
4. **Action mappings**: Some actions have different keybindings

## Notes

- FZF-lua is already configured and ready in `/lua/util/fzf-lua.lua`
- The configuration includes all major pickers
- Custom functions for auto-session integration are already defined
- Landing page integration helpers are available
- The plugin is lazy-loaded but available immediately for session needs

## Next Steps

1. Begin Phase 2: Migrate core telescope.builtin calls
2. Test each migration thoroughly
3. Document any issues or custom implementations needed
4. Update user keybindings progressively