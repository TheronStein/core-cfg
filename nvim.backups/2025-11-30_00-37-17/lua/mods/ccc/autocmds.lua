local M = {}

M.setup = function()
  local augroup = vim.api.nvim_create_augroup("CccAutoCommands", { clear = true })

  -- Auto-enable color highlighting for specific file types
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = { "*.css", "*.scss", "*.sass", "*.less", "*.styl" },
    callback = function()
      vim.defer_fn(function()
        vim.cmd("CccHighlighterEnable")
        vim.notify("Color highlighting enabled", vim.log.levels.INFO, { title = "CCC" })
      end, 100)
    end,
    desc = "Enable color highlighting for CSS files",
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = {
      "*.conf",
      "*.cfg",
      "*.ini",
      "*.toml",
      "*.yaml",
      "*.yml",
      "hypr*.conf", -- Add this pattern
    },
    callback = function()
      if vim.fn.line("$") < 1000 then -- Only for smaller files
        vim.defer_fn(function()
          vim.cmd("CccHighlighterEnable")
        end, 100)
      end
    end,
    desc = "Enable color highlighting for config files",
  })

  -- Auto-enable for theme and colorscheme files
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = { "*theme*.lua", "*colors*.lua", "*colorscheme*.vim", "*.tmTheme" },
    callback = function()
      vim.defer_fn(function()
        vim.cmd("CccHighlighterEnable")
        vim.notify("Theme file detected - colors highlighted", vim.log.levels.INFO, { title = "CCC" })
      end, 100)
    end,
    desc = "Enable color highlighting for theme files",
  })

  -- Auto-convert colors on paste (optional, can be toggled)
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
      local content = vim.fn.getreg('"')
      if content:match("#%x%x%x%x%x%x") then
        vim.g.ccc_yanked_color = content
      end
    end,
    desc = "Store yanked color",
  })

  -- Color format detection for new files
  vim.api.nvim_create_autocmd({ "BufNewFile" }, {
    group = augroup,
    pattern = { "*.css", "*.scss" },
    callback = function()
      -- Set preferred color format based on file type
      vim.b.ccc_preferred_format = "css_rgb"
      vim.notify("CSS file: RGB format preferred", vim.log.levels.INFO, { title = "CCC" })
    end,
    desc = "Set preferred color format for new CSS files",
  })

  -- Update color highlighting on color scheme change
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = function()
      if vim.g.ccc_highlighter_enabled then
        vim.defer_fn(function()
          vim.cmd("CccHighlighterDisable")
          vim.cmd("CccHighlighterEnable")
        end, 50)
      end
    end,
    desc = "Refresh color highlighting on colorscheme change",
  })

  -- Save last used color format
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*",
    callback = function()
      if vim.b.ccc_last_format then
        vim.g.ccc_default_format = vim.b.ccc_last_format
      end
    end,
    desc = "Save last used color format",
  })

  -- Auto-disable highlighting for large files
  vim.api.nvim_create_autocmd({ "BufReadPre" }, {
    group = augroup,
    callback = function()
      local file_size = vim.fn.getfsize(vim.fn.expand("%:p"))
      if file_size > 100 * 1024 then -- 100KB
        vim.b.ccc_disable_highlighter = true
        vim.notify("Large file: Color highlighting disabled", vim.log.levels.WARN, { title = "CCC" })
      end
    end,
    desc = "Disable color highlighter for large files",
  })

  -- Show helpful message on first use
  vim.api.nvim_create_autocmd("User", {
    pattern = "CccFirstUse",
    callback = function()
      vim.notify("Press <localleader>c? for key reference", vim.log.levels.INFO, { title = "CCC Color Picker" })
    end,
    desc = "Show help message on first use",
  })
end

return M
