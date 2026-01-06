-- CoreLine: lazy.nvim plugin specification
-- This file is loaded by lazy.nvim via { import = "modules" }

return {
  dir = vim.fn.stdpath('config') .. '/lua/local/coreline',
  name = 'coreline',
  lazy = false,
  priority = 1000,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('local.coreline').setup({})
  end,
}
