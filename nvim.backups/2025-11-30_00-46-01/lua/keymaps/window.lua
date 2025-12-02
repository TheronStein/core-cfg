-- lua/keymaps/windows.lua
local map = vim.keymap.set

-- True fullscreen (hide tabline + statusline + signcolumn)
map("n", "<leader>wz", function()
  local is_fullscreen = vim.g.fullscreen ~= nil and vim.g.fullscreen
  if is_fullscreen then
    -- Restore normal view
    vim.cmd("WinShift") -- if you were in WinShift, exit it cleanly
    vim.opt.laststatus = vim.g.saved_statusline or 3
    vim.opt.showtabline = vim.g.saved_tabline or 2
    vim.opt.signcolumn = vim.g.saved_signcolumn or "yes"
    vim.g.fullscreen = false
  else
    -- Enter true fullscreen
    vim.g.saved_statusline = vim.opt.laststatus:get()
    vim.g.saved_tabline = vim.opt.showtabline:get()
    vim.g.saved_signcolumn = vim.opt.signcolumn:get()
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
    vim.opt.signcolumn = "no"
    vim.g.fullscreen = true
  end
end, { desc = "Window Zoom" })

-- 1. WinShift core bindings
-- Use <leader>w as the namespace (clean and discoverable)
map("n", "<leader>wm", "<cmd>WinShift<CR>", { desc = "Enter WinShift mode" })
map("n", "<leader>wx", "<cmd>WinShift swap<CR>", { desc = "Swap with next window" })
map("n", "<leader>wf", "<cmd>WinShift far<CR>", { desc = "Move window far (to another tab)" })

-- Smart close: close buffer if it’s “safe”, otherwise close window/tab
map("n", "q", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype

  -- List of buffers that are safe to just :q or :bd
  local safe_fts = {
    "help",
    "qf",
    "fugitive",
    "git",
    "toggleterm",
    "lspinfo",
    "notify",
    "neo-tree",
    "aerial",
    "Trouble",
    "lspsagaoutline",
    "lazy",
    "mason",
    "null-ls-info",
  }

  local is_safe = buftype ~= "" or vim.tbl_contains(safe_fts, filetype)

  if is_safe then
    pcall(vim.cmd, "close") -- tries to close window-close first
    if vim.api.nvim_win_is_valid(0) then -- if still open, force buffer delete
      pcall(vim.cmd, "bdelete")
    end
  else
    -- Normal buffer → try to delete it properly (keeps window if alternatives exist)
    local ok, _ = pcall(vim.cmd, "Bdelete") -- if you use bufdelete.nvim
    if not ok then
      vim.cmd("bdelete")
    end
  end
end, { desc = "Smart close" })

-- Force close even sticky buffers (when you’re really stuck)
map("n", "<leader>qd", "<cmd>close<CR>", { desc = "Force close buffer" })
map("n", "<leader>qd", "<cmd>bdelete!<CR>", { desc = "Force close buffer" })

-- Optional: if you really want one-key access without leader
-- (most people keep this — it's muscle memory from tmux)
map("n", "<C-w>w", "<cmd>WinShift<CR>", { desc = "WinShift mode" })

-- 2. which-key — perfect groups + auto desc pickup
require("which-key").add({
  { "<leader>w", group = "windows" },
  { "<leader>wm", desc = "Move / resize mode" },
  { "<leader>wx", desc = "Swap windows" },
  { "<leader>wf", desc = "Move far (tab)" },
  { "<C-w>w", desc = "WinShift mode" },
})

-- 3. Hydra — now actually activates when you press <leader>wm
local Hydra = require("hydra")

Hydra({
  name = "WinShift Mode",
  mode = "n",
  -- This hydra activates exactly when you press the key that starts WinShift
  body = "<leader>wm",
  color = "amaranth",
  timeout = false,

  config = {
    hint = {
      type = "window",
      position = "middle-right",
      border = "rounded",
    },
    invoke_on_body = true, -- critical: start hydra when body key is pressed
  },

  hint = [[
      Move               Resize
   ← a   ↑ w           ← <C-a>   ↑ <C-w>
   ↓ s   → d           ↓ <C-s>   → <C-d>

   _x_ : swap window
   _<Esc>_, _q_ : exit
  ]],

  heads = {
    -- Movement (wasd — you clearly prefer this layout)
    { "a", "<Cmd>WinShift left<CR>" },
    { "s", "<Cmd>WinShift down<CR>" },
    { "w", "<Cmd>WinShift up<CR>" },
    { "d", "<Cmd>WinShift right<CR>" },

    -- Resize with Ctrl
    { "<C-a>", "<Cmd>WinShift left<CR>" },
    { "<C-s>", "<Cmd>WinShift down<CR>" },
    { "<C-w>", "<Cmd>WinShift up<CR>" },
    { "<C-d>", "<Cmd>WinShift right<CR>" },

    -- Swap
    { "x", "<Cmd>WinShift swap<CR>", { desc = "swap" } },

    -- Exit
    { "<Esc>", nil, { exit = true, nowait = true } },
    { "q", nil, { exit = true, nowait = true } },
    { "<C-c>", nil, { exit = true, nowait = true } },
  },
})
-- -- lua/keymaps/window.lua
-- local map = vim.keymap.set
-- local wk = require("which-key")
-- local Hydra = require("hydra")
--
-- map("n", "<C-w>z", "<cmd>WindowsMaximize<CR>", { desc = "Zoom window" })
--
-- wk.add({
--   { "<C-w>", group = "windows" },
--   { "<C-w>z", desc = "Zoom / unzoom" },
-- })
--
-- Hydra({
--   name = "Window Management",
--   mode = "n",
--   body = "<C-w>",
--   color = "red",
--   heads = {
--     { "h", "<C-w>h" },
--     { "j", "<C-w>j" },
--     { "k", "<C-w>k" },
--     { "l", "<C-w>l" },
--     { "s", "<C-w>s", { desc = "split horizontal" } },
--     { "v", "<C-w>v", { desc = "split vertical" } },
--     { "=", "<C-w>=", { desc = "balance" } },
--     { "z", "<cmd>WindowsMaximize<CR>", { desc = "zoom" } },
--     { "q", "<C-w>q", { desc = "close" } },
--   },
-- })
