-- ╓────────────────────────────────────────────────────────────╖
-- ║ UI Enhancements Initialization                            ║
-- ║ Load and configure all UI enhancement modules             ║
-- ╙────────────────────────────────────────────────────────────╜

return {
  -- This module initializes all UI enhancements
  {
    "folke/lazy.nvim",
    priority = 1000,
    config = function()
      -- Initialize notification system
      local notifications = require("mods.notifications")
      notifications.setup()

      -- Set up notification keymaps
      require("keymaps.notifications")

      -- Set up global help system
      local global_help = require("keymaps.global-help")
      global_help.setup()

      -- Note: Lualine extensions are loaded automatically when lualine loads

      -- Log successful initialization
      vim.notify("UI Enhancements loaded successfully", vim.log.levels.INFO)
    end
  }
}