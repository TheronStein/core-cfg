-- Keymap Scoping System
-- Manages buffer-specific, filetype-specific, and plugin-specific keybindings
local M = {}

-- List of buffer types where custom navigation should NOT apply
M.excluded_buftypes = {
  "nofile",
  "prompt",
  "quickfix",
  "help",
  "terminal",
}

-- List of filetypes where custom navigation should NOT apply
M.excluded_filetypes = {
  "TelescopePrompt",
  "TelescopeResults",
  "TelescopePreview",
  "fzf",
  "neo-tree",
  "NvimTree",
  "Trouble",
  "qf",
  "help",
  "man",
  "lspinfo",
  "lazy",
  "mason",
  "Oil",
  "fugitive",
  "git",
  "diff",
  "DiffviewFiles",
  "notify",
  "noice",
  "toggleterm",
  "snacks_dashboard",
  "snacks_notif",
  "snacks_terminal",
  "snacks_win",
}

-- Check if current buffer should have custom keymaps
M.should_apply_custom_maps = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check buftype
  local buftype = vim.bo[bufnr].buftype
  if vim.tbl_contains(M.excluded_buftypes, buftype) then
    return false
  end

  -- Check filetype
  local filetype = vim.bo[bufnr].filetype
  if vim.tbl_contains(M.excluded_filetypes, filetype) then
    return false
  end

  return true
end

-- Apply buffer-local keymaps
M.apply_buffer_maps = function(bufnr, maps)
  if not M.should_apply_custom_maps(bufnr) then
    return
  end

  for _, map_config in ipairs(maps) do
    local mode = map_config[1]
    local lhs = map_config[2]
    local rhs = map_config[3]
    local opts = map_config[4] or {}
    opts.buffer = bufnr

    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- Setup filetype-specific keymaps
M.setup_filetype_maps = function()
  -- Lua-specific keymaps
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "lua",
    callback = function(ev)
      local bufnr = ev.buf
      vim.keymap.set("n", "<leader>x", ":.lua<CR>", { buffer = bufnr, desc = "Execute Lua line" })
      vim.keymap.set("v", "<leader>x", ":lua<CR>", { buffer = bufnr, desc = "Execute Lua selection" })
      vim.keymap.set("n", "<leader>X", ":source %<CR>", { buffer = bufnr, desc = "Source current file" })
    end,
  })

  -- Markdown-specific keymaps
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(ev)
      local bufnr = ev.buf
      -- Add markdown-specific keymaps here
      vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { buffer = bufnr, desc = "Preview Markdown" })
    end,
  })

  -- Terminal-specific keymaps
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function(ev)
      local bufnr = ev.buf
      -- Terminal uses default navigation
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = bufnr, desc = "Exit terminal mode" })
    end,
  })

  -- Quickfix-specific keymaps
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function(ev)
      local bufnr = ev.buf
      -- Standard j/k navigation in quickfix
      vim.keymap.set("n", "k", "j", { buffer = bufnr, desc = "Next item" })
      vim.keymap.set("n", "i", "k", { buffer = bufnr, desc = "Previous item" })
      vim.keymap.set("n", "q", ":q<CR>", { buffer = bufnr, desc = "Close quickfix" })
    end,
  })

  -- Help files - use default navigation
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    callback = function(ev)
      local bufnr = ev.buf
      vim.keymap.set("n", "q", ":q<CR>", { buffer = bufnr, desc = "Close help" })
    end,
  })
end

-- Setup plugin buffer detection
M.setup_plugin_buffers = function()
  -- Detect and exclude plugin buffers automatically
  vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
    callback = function(ev)
      local bufnr = ev.buf
      local buftype = vim.bo[bufnr].buftype
      local filetype = vim.bo[bufnr].filetype

      -- Mark plugin buffers
      if vim.tbl_contains(M.excluded_buftypes, buftype) or vim.tbl_contains(M.excluded_filetypes, filetype) then
        vim.b[bufnr].custom_navigation_disabled = true
      end
    end,
  })
end

-- Create a scoped keymap setter
M.set = function(mode, lhs, rhs, opts)
  opts = opts or {}

  -- If no buffer specified, check if we should apply globally
  if not opts.buffer then
    -- Apply to all normal buffers (will be filtered by autocmds)
    vim.keymap.set(mode, lhs, rhs, opts)
  else
    -- Buffer-specific mapping
    if M.should_apply_custom_maps(opts.buffer) then
      vim.keymap.set(mode, lhs, rhs, opts)
    end
  end
end

-- Create command to toggle custom navigation for current buffer
M.toggle_custom_navigation = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_state = vim.b[bufnr].custom_navigation_disabled

  if current_state then
    vim.b[bufnr].custom_navigation_disabled = false
    vim.notify("Custom navigation ENABLED for this buffer", vim.log.levels.INFO)
  else
    vim.b[bufnr].custom_navigation_disabled = true
    vim.notify("Custom navigation DISABLED for this buffer", vim.log.levels.INFO)
  end

  -- Prompt to reload buffer for changes to take effect
  vim.notify("Reload buffer for changes to take effect", vim.log.levels.WARN)
end

-- Debug function to check current buffer scope
M.debug_current_buffer = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype
  local should_apply = M.should_apply_custom_maps(bufnr)
  local manually_disabled = vim.b[bufnr].custom_navigation_disabled

  local info = {
    "=== Buffer Keymap Scope Debug ===",
    "Buffer: " .. bufnr,
    "Buftype: " .. (buftype ~= "" and buftype or "normal"),
    "Filetype: " .. (filetype ~= "" and filetype or "none"),
    "Should apply custom maps: " .. tostring(should_apply),
    "Manually disabled: " .. tostring(manually_disabled or false),
  }

  vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
end

-- Setup all scoping systems
M.setup = function()
  M.setup_filetype_maps()
  M.setup_plugin_buffers()

  -- Create commands
  vim.api.nvim_create_user_command("ToggleCustomNav", M.toggle_custom_navigation, {
    desc = "Toggle custom navigation for current buffer",
  })

  vim.api.nvim_create_user_command("DebugKeymap", M.debug_current_buffer, {
    desc = "Debug keymap scope for current buffer",
  })

  -- Add keybind for debugging
  vim.keymap.set("n", "<leader>dk", M.debug_current_buffer, { desc = "Debug keymap scope" })
end

return M
