-- Disable optional providers to remove warnings
vim.g.loaded_perl_provider = 0
vim.g.python3_host_prog = "/usr/bin/python3"

-- ~/.config/nvim/init.lua
vim.g.mapleader = "\\" -- Set leader key to space (before loading plugins)
vim.g.maplocalleader = " " -- Set local leader to comma (optional, adjust as needed)

-- -- Load core configurations
require("core.lazy") -- Load lazy.nvim (sets up plugins)
require("options") -- Load general options
require("mods.keymaps").setup()
require("autocmds")
-- require("keymaps.lsp-diagnostic")
-- require("autocmds") -- Load autocommands

-- [[[ Outdated core/sys/cfg loader
-- Load modules
-- In your main init.lua or lazy.nvim setup
-- Only load cfg folders that live directly under lua/plugins/ or lua/core/
-- local cfg = os.getenv("CORE_CFG")
-- local dir = (cfg and vim.uv.fs_stat(cfg) and cfg) or vim.fn.stdpath("config") .. "/core/sys/cfg"
--
-- if vim.uv.fs_stat(dir) then
--   vim.iter(vim.fs.find("**.lua", { path = dir:gsub("/+$", ""), type = "file" })):each(dofile)
-- else
--   vim.schedule(function()
--     vim.notify("core/sys/cfg not found anywhere", vim.log.levels.WARN)
--   end)
-- end
-- ]]]
