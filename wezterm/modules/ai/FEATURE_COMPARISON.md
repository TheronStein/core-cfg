# CopilotChat Feature Comparison

## Neovim Version (`modules/ai/CopilotChat/`)
**Status**: ❌ Cannot be ported to WezTerm - requires Neovim APIs

### Dependencies (Neovim-specific):
- `plenary.async`, `plenary.log` - Neovim plugin libraries
- `vim.*` APIs (vim.api, vim.fn, vim.diagnostic, vim.treesitter, etc.)
- Neovim buffer/window management
- Neovim UI system (overlays, extmarks, virtual text)

### Features:
1. ✅ GitHub Copilot authentication (device flow, token caching)
2. ✅ GitHub Models provider support
3. ✅ Prompt templates:
   - COPILOT_EXPLAIN - Code explanations
   - COPILOT_REVIEW - Code reviews with diagnostics
   - Fix - Bug fixes
   - Optimize - Performance optimization
   - Docs - Documentation generation
   - Tests - Test generation
   - Commit - Commit message generation
4. ✅ Advanced tool/function calling
5. ✅ Resource URIs (buffers, files, git diffs)
6. ✅ Selection context from Neovim buffers
7. ✅ Chat history with sticky prompts
8. ✅ Multiple providers (copilot, github_models)
9. ✅ Treesitter-based markdown parsing
10. ✅ Diagnostic integration (code reviews show as diagnostics)

---

## WezTerm Version (`modules/copilot_chat_v2.lua`)
**Status**: ✅ Fully WezTerm-compatible and functional

### Features:
1. ✅ OpenAI API support
2. ✅ Anthropic (Claude) API support
3. ✅ GitHub API support (basic)
4. ✅ 1Password integration for API key management
5. ✅ Basic chat UI in WezTerm split pane
6. ✅ Session save/load to disk
7. ✅ Command system:
   - `/help` - Show available commands
   - `/clear` - Clear chat history
   - `/reset` - Reset session
   - `/model` - Cycle through models
   - `/save` - Save session
   - `/load` - Load session
   - `/list` - List saved sessions
   - `/exit` - Close chat
8. ✅ Selection context from WezTerm panes
9. ✅ Message history with limits
10. ✅ Auto-save functionality
11. ✅ Custom system prompts

### Missing Features (compared to Neovim):
1. ❌ Prompt templates (Explain, Review, Fix, etc.)
2. ❌ GitHub Copilot provider authentication
3. ❌ Tool/function calling support
4. ❌ Advanced UI (markdown rendering, syntax highlighting)
5. ❌ Resource URI system
6. ❌ Git diff context
7. ❌ Diagnostic integration

---

## Recommended Enhancements for WezTerm Version

### High Priority (Easy to add):
1. **Prompt Templates** - Add pre-built prompts for common tasks
2. **Better UI** - Improve message rendering with colors/formatting
3. **Git Context** - Add git diff/status context inclusion
4. **File Context** - Add current directory/file context

### Medium Priority:
1. **GitHub Copilot Provider** - Add GitHub Copilot authentication flow
2. **More Models** - Expand model support per provider
3. **Streaming Responses** - Stream API responses for better UX

### Low Priority (Complex):
1. **Tool Calling** - Advanced feature for function execution
2. **Resource URIs** - Complex abstraction for context management
3. **Markdown Rendering** - Would require external tool or ANSI formatting

---

## Decision: Archive Neovim, Enhance WezTerm

**Action Plan:**
1. Move `modules/ai/CopilotChat/` → `modules/ai/.archv/CopilotChat/`
2. Enhance `copilot_chat_v2.lua` with:
   - Prompt templates
   - Better UI rendering
   - Git context support
   - Optionally: GitHub Copilot provider
3. Update `config/binds.lua` to only use copilot_chat_v2
4. Remove Neovim-specific event handlers
