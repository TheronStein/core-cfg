return {

  "nvim-lua/plenary.nvim",
  lazy = true, -- Defer loading until explicitly needed
  cmd = { "PlenaryBustedFile", "PlenaryBustedDirectory" }, -- Load for test commands (optional, low overhead)
  keys = {
    -- Profiling keymap: <leader>pp to start/stop profiling
    {
      "<leader>pp",
      function()
        local profile = require("plenary.profile")
        local log = vim.fn.tempname() .. ".log"
        if not profile.is_profiling() then
          profile.start(log)
          vim.notify("Profiling started → " .. log, vim.log.levels.INFO)
          vim.api.nvim_create_autocmd("VimLeavePre", {
            once = true,
            callback = function()
              profile.stop()
              vim.notify("Profiling stopped → " .. log, vim.log.levels.INFO)
            end,
          })
        else
          profile.stop()
          vim.notify("Profiling stopped → " .. log, vim.log.levels.INFO)
        end
      end,
      desc = "[P]rofile: Toggle plenary profiler",
    },
  },
  config = function()
    -- Optional: Any future config can go here, but keep it empty for now to avoid bloat
  end,

}
