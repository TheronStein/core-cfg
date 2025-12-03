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
   ← j   ↑ i           ← <C-a>   ↑ <C-w>
   ↓ k   → k           ↓ <C-s>   → <C-d>

   _x_ : swap window
   _<Esc>_, _q_ : exit
  ]],

  heads = {
    -- Movement (wasd — you clearly prefer this layout)
    { "j", "<Cmd>WinShift left<CR>" },
    { "k", "<Cmd>WinShift down<CR>" },
    { "i", "<Cmd>WinShift up<CR>" },
    { "l", "<Cmd>WinShift right<CR>" },

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

-- wk.add({
--   -- { "<M-a>", "<C-w>h", desc = "Go left" },
--   -- { "<M-s>", "<C-w>j", desc = "Go down" },
--   -- { "<M-w>", "<C-w>k", desc = "Go up" },
--   -- { "<M-d>", "<C-w>l", desc = "Go right" },
--
--   -- Window resizing with Meta+Shift+w/s/a/d
--   { "<M-S-w>", "<cmd>resize +2<cr>", desc = "Increase height" },
--   { "<M-S-s>", "<cmd>resize -2<cr>", desc = "Decrease height" },
--   { "<M-S-a>", "<cmd>vertical resize -2<cr>", desc = "Decrease width" },
--   { "<M-S-d>", "<cmd>vertical resize +2<cr>", desc = "Increase width" },
--
--   { "<leader>wv", "<cmd>vsplit<cr>", desc = "Vertical split" },
--   { "<leader>wh", "<cmd>split<cr>", desc = "Horizontal split" },
--   {
--     "<leader>wc",
--     function()
--       local win_count = #vim.api.nvim_tabpage_list_wins(0)
--       local tab_count = #vim.api.nvim_list_tabpages()
--       if win_count > 1 then
--         vim.cmd("close")
--       elseif tab_count > 1 then
--         vim.cmd("tabclose")
--       else
--         vim.cmd("quit")
--       end
--     end,
--     desc = "Smart close (window/tab/quit)",
--   },
--   { "<leader>wo", "<cmd>only<cr>", desc = "Close other windows" },
--   -- Move window (OL;K - lowercase now)
--   { "<leader>wa", "<C-w>H", desc = "Move window left" },
--   { "<leader>ws", "<C-w>J", desc = "Move window down" },
--   { "<leader>ww", "<C-w>K", desc = "Move window up" },
--   { "<leader>wd", "<C-w>L", desc = "Move window right" },
--   { "<leader>wt", "<C-w>T", desc = "Move window to new tab" },
--   -- { "<leader>w-", "<cmd>resize -5<cr>", desc = "Decrease height" },/p/
--   -- { "<leader>w+", "<cmd>resize +5<cr>", desc = "Increase height" },
--   -- { "<leader>w<", "<cmd>vertical resize -5<cr>", desc = "Decrease width" },
--   -- { "<leader>w>", "<cmd>vertical resize +5<cr>", desc = "Increase width" },
-- })
-- -- Window utilities
-- wk.add({
--   {
--     "<leader>wz",
--     function()
--       local win_count = #vim.api.nvim_tabpage_list_wins(0)
--       if win_count == 2 then
--         local current_layout = vim.fn.winlayout()
--         if current_layout[1] == "col" then
--           vim.cmd("wincmd K")
--         else
--           vim.cmd("wincmd H")
--         end
--       else
--         vim.notify("Toggle split only works with exactly 2 windows", vim.log.levels.WARN)
--       end
--     end,
--     desc = "Toggle split orientation",
--   },
--   {
--     "<leader>wn",
--     function()
--       vim.cmd("vsplit")
--       vim.cmd("enew")
--       vim.bo.buftype = "nofile"
--       vim.bo.bufhidden = "wipe"
--       vim.bo.swapfile = false
--     end,
--     desc = "Create scratch window",
--   },
--   {
--     "<leader>wz",
--     function()
--       if vim.g.window_maximized then
--         vim.cmd("wincmd =")
--         vim.g.window_maximized = false
--       else
--         vim.cmd("wincmd |")
--         vim.cmd("wincmd _")
--         vim.g.window_maximized = true
--       end
--     end,
--     desc = "Toggle window maximize",
--   },
-- })
--
-- --
-- -- -- WinShift integration
-- vim.keymap.set("n", "<leader>wW", ":WinShift<CR>", { desc = "Start WinShift mode" })
-- vim.keymap.set("n", "<C-w>m", ":WinShift<CR>", { desc = "Start WinShift mode" })
-- --
-- -- -- -- WinShift with direction (immediate move)
-- vim.keymap.set("n", "<C-S-a>", ":WinShift left<CR>", { desc = "Move window left" })
-- vim.keymap.set("n", "<C-S-s>", ":WinShift down<CR>", { desc = "Move window down" })
-- vim.keymap.set("n", "<C-S-w>", ":WinShift up<CR>", { desc = "Move window up" })
-- vim.keymap.set("n", "<C-S-d>", ":WinShift right<CR>", { desc = "Move window right" })
-- -- --
-- -- -- -- WinShift swap (swap with window in direction)
-- vim.keymap.set("n", "<leader>wa", ":WinShift swap left<CR>", { desc = "Swap with left window" })
-- vim.keymap.set("n", "<leader>ws", ":WinShift swap down<CR>", { desc = "Swap with window below" })
-- vim.keymap.set("n", "<leader>ww", ":WinShift swap up<CR>", { desc = "Swap with window above" })
-- vim.keymap.set("n", "<leader>wd", ":WinShift swap right<CR>", { desc = "Swap with right window" })
-- --
-- -- -- Function to create a custom WinShift mode with additional features
-- local function enhanced_winshift_mode()
--   -- Store current window for reference
--   local start_win = vim.api.nvim_get_current_win()
--
--   print("🚀 Enhanced WinShift Mode - Type 'h' for help")
--
--   -- You could extend this to add custom behaviors
--   -- For now, just use standard WinShift
--   vim.cmd("WinShift")
-- end
-- --
-- vim.keymap.set("n", "<leader>wM", enhanced_winshift_mode, { desc = "Enhanced WinShift mode" })
--
-- -- If you want to integrate with tmux-style pane management
-- local function tmux_style_window_move()
--   -- This mimics tmux's prefix + { } for moving panes
--   local choice = vim.fn.input("Move window: (h)left (j)down (k)up (l)right (q)uit: ")
--   if choice == "h" then
--     vim.cmd("WinShift left")
--   elseif choice == "j" then
--     vim.cmd("WinShift down")
--   elseif choice == "k" then
--     vim.cmd("WinShift up")
--   elseif choice == "l" then
--     vim.cmd("WinShift right")
--   elseif choice == "q" then
--     return
--   else
--     print("Invalid choice")
--   end
-- end
-- -- --
-- vim.keymap.set("n", "<leader>wt", tmux_style_window_move, { desc = "Tmux-style window move" })
-- --
-- -- -- NOTE: Window utility functions moved to Tabby plugin (lua/plugins/tabby.lua)
-- -- --
-- -- Start WinShift in swap mode (for swapping windows)
-- vim.keymap.set("n", "<leader>wx", ":WinShift swap<CR>", { desc = "Start WinShift swap mode" })
-- -- --
-- -- -- -- Move window to far edges (WinShift versions)
-- vim.keymap.set("n", "<leader>wA", ":WinShift far_left<CR>", { desc = "Move window to far left" })
-- vim.keymap.set("n", "<leader>wS", ":WinShift far_down<CR>", { desc = "Move window to far down" })
-- vim.keymap.set("n", "<leader>wW", ":WinShift far_up<CR>", { desc = "Move window to far up" })
-- vim.keymap.set("n", "<leader>wD", ":WinShift far_right<CR>", { desc = "Move window to far right" })
-- -- --
-- -- -- -- Setup function to initialize everything
-- -- local function setup_window_management()
-- --   setup_winshift()
-- --   print("Window management setup complete")
-- -- end
-- -- --
-- -- -- -- Call setup
-- -- setup_window_management()
-- --
