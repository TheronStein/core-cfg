# FZF-Lua Testing Guide

## Quick Test Commands

Run these commands to verify fzf-lua is working correctly:

### Basic File Operations
```vim
:FzfLua files
:FzfLua git_files
:FzfLua buffers
:FzfLua oldfiles
```

### Search Operations
```vim
:FzfLua live_grep
:FzfLua grep
:FzfLua grep_word
:FzfLua lines
```

### Git Operations
```vim
:FzfLua git_status
:FzfLua git_commits
:FzfLua git_branches
:FzfLua git_stash
```

### LSP Operations
```vim
:FzfLua lsp_references
:FzfLua lsp_definitions
:FzfLua lsp_implementations
:FzfLua lsp_document_symbols
:FzfLua lsp_workspace_symbols
:FzfLua diagnostics_workspace
```

### Vim Features
```vim
:FzfLua commands
:FzfLua command_history
:FzfLua keymaps
:FzfLua marks
:FzfLua registers
:FzfLua helptags
:FzfLua colorschemes
```

## Testing Auto-Session Integration

The following custom functions are available for landing page integration:

```lua
-- Test session menu
:lua _G.fzf_session_menu({"session1", "session2", "session3"}, function(s) print("Selected: " .. s) end)

-- Test git status display
:lua _G.fzf_git_status_display()

-- Test recent files display
:lua _G.fzf_recent_files(vim.fn.getcwd())

-- Test git branches menu
:lua _G.fzf_git_branches_menu()
```

## Quick Keybinding Additions

You can add these temporary keybindings for testing (add to your config or run directly):

```lua
-- Test keybindings (add to keymaps or run in command mode)
vim.keymap.set("n", "<leader>tf", "<cmd>FzfLua files<cr>", { desc = "Test: FzfLua files" })
vim.keymap.set("n", "<leader>tg", "<cmd>FzfLua live_grep<cr>", { desc = "Test: FzfLua grep" })
vim.keymap.set("n", "<leader>tb", "<cmd>FzfLua buffers<cr>", { desc = "Test: FzfLua buffers" })
vim.keymap.set("n", "<leader>th", "<cmd>FzfLua helptags<cr>", { desc = "Test: FzfLua help" })
vim.keymap.set("n", "<leader>tc", "<cmd>FzfLua commands<cr>", { desc = "Test: FzfLua commands" })
```

## Performance Testing

### Check Startup Time
```bash
# From terminal
nvim --startuptime /tmp/nvim-startup.log -c quit
grep fzf-lua /tmp/nvim-startup.log
```

### Profile FZF-Lua Loading
```vim
:Lazy profile
" Look for fzf-lua in the list
```

## Comparison Testing

### Side-by-side comparison with Telescope (if still enabled)
```vim
" Telescope
:Telescope find_files
:Telescope live_grep
:Telescope buffers

" FZF-Lua
:FzfLua files
:FzfLua live_grep
:FzfLua buffers
```

## Troubleshooting

### If FZF-Lua doesn't load
1. Check if the plugin is installed:
   ```vim
   :Lazy
   " Look for ibhagwan/fzf-lua
   ```

2. Check for errors:
   ```vim
   :checkhealth fzf-lua
   ```

3. Verify FZF binary is installed:
   ```bash
   which fzf
   ```

### If preview doesn't work
1. Check if required tools are installed:
   ```bash
   which bat    # For syntax highlighting
   which rg     # For ripgrep
   which fd     # For fd-find (optional)
   ```

2. Test preview directly:
   ```vim
   :FzfLua files previewer=builtin
   ```

## Expected Behavior

When testing, you should observe:

1. **Fast Loading**: FZF-Lua windows should appear almost instantly
2. **Smooth Scrolling**: Navigation should be fluid with no lag
3. **Preview Updates**: File previews should update as you navigate
4. **Syntax Highlighting**: Preview should show syntax colors (if bat is installed)
5. **Git Integration**: Git status should show file states correctly
6. **Key Responsiveness**: All configured keymaps should work immediately

## Next Steps After Testing

Once basic functionality is confirmed:

1. **Phase 2 Migration**: Begin migrating telescope keybindings
2. **Custom Pickers**: Implement any missing telescope extensions
3. **Performance Tuning**: Adjust window sizes and preview settings
4. **User Training**: Document changed keybindings for users

## Report

After testing, document:
- [ ] All basic pickers work
- [ ] Preview functions correctly
- [ ] Git integration works
- [ ] LSP features work (when in a project with LSP)
- [ ] Performance is acceptable
- [ ] No errors in `:checkhealth`
- [ ] Session integration functions work