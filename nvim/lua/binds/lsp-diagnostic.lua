-- TODO: Refactor this

-- LSP Diagnostic Commands
local M = {}

-- Check LSP status for current buffer
M.check_lsp = function()
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buf })

  if #clients == 0 then
    vim.notify("No LSP clients attached to current buffer", vim.log.levels.WARN)
    return
  end

  local info = {}
  table.insert(info, "LSP Clients attached:")
  for _, client in ipairs(clients) do
    table.insert(info, string.format("  • %s (id: %d)", client.name, client.id))
    table.insert(info, string.format("    Root: %s", client.root_dir or "none"))
    if client.server_capabilities then
      table.insert(info, "    Capabilities: ✓")
    end
  end

  vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
end

-- Check completion sources
M.check_completion = function()
  local ok, blink = pcall(require, "blink.cmp")
  if not ok then
    vim.notify("Blink.cmp not loaded", vim.log.levels.WARN)
    return
  end

  local info = {}
  table.insert(info, "Blink.cmp Status:")

  -- Check if completion is enabled
  if blink then
    table.insert(info, "  • Blink.cmp is loaded ✓")

    -- Check sources
    local sources_ok, sources = pcall(function()
      return blink.config.sources
    end)

    if sources_ok and sources then
      table.insert(info, "  • Configured sources:")
      if sources.default then
        for i, source in ipairs(sources.default) do
          table.insert(info, string.format("    %d. %s", i, source))
        end
      end
    end
  end

  vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
end

-- Check lazydev status
M.check_lazydev = function()
  local ok, lazydev = pcall(require, "lazydev")
  if not ok then
    vim.notify("Lazydev not loaded", vim.log.levels.WARN)
    return
  end

  vim.notify("Lazydev is loaded ✓\nCheck :LspInfo for lua_ls integration", vim.log.levels.INFO)
end

-- All-in-one diagnostic
M.diagnose = function()
  vim.notify("=== LSP & Completion Diagnostic ===", vim.log.levels.INFO)
  vim.defer_fn(M.check_lsp, 100)
  vim.defer_fn(M.check_completion, 200)
  vim.defer_fn(M.check_lazydev, 300)
end

-- Setup commands
M.setup = function()
  vim.api.nvim_create_user_command("LspCheck", M.check_lsp, { desc = "Check LSP attachment" })
  vim.api.nvim_create_user_command("CompletionCheck", M.check_completion, { desc = "Check completion sources" })
  vim.api.nvim_create_user_command("LazydevCheck", M.check_lazydev, { desc = "Check lazydev status" })
  vim.api.nvim_create_user_command("DiagnoseLsp", M.diagnose, { desc = "Full LSP diagnostic" })
  -- Quick keymap for diagnosis
  vim.keymap.set("n", "<leader>ld", M.diagnose, { desc = "Diagnose LSP & Completion" })
end


return M


wk.add({
  { "<leader>uW", desc = "Reset which-key" },
  { "<leader>uD", desc = "Debug which-key" },
})

