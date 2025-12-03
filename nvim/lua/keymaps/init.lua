-- ╓────────────────────────────────────────────────────────────╖
-- ║ Keybindings Initialization                                ║
-- ║ Load all keybinding modules                               ║
-- ╙────────────────────────────────────────────────────────────╜

-- TODO: Implement modular keybinding loading system

-- local M = {}
--
-- M.setup = function()
-- 	-- Load session keybindings
-- 	local session_ok, session = pcall(require, "binds.session")
-- 	if session_ok then
-- 		session.setup()
-- 	else
-- 		vim.notify("Failed to load session keybindings", vim.log.levels.WARN)
-- 	end
--
-- 	-- Future keybinding modules will be loaded here:
-- 	-- require("binds.leader").setup()
-- 	-- require("binds.motion").setup()
-- 	require("binds.lsp").setup()
-- 	require("binds.git").setup()
-- 	require("binds.which-key").setup()
-- end
--
-- return M

local unmap = vim.keymap.del
local map = vim.keymap.set
local map = vim.keymap.set -- ({"n", "v", "x"})
local function safe_unmap(mode, key)
  pcall(vim.api.nvim_del_keymap, mode, key)
end
local function save_unvim(mode, key)
  pcall(unmap, mode, key)
end
local nav = require("mods.tmux-vim-navigation")
nav.setup()

--
local clipb = require("mods.clipboard")
clipb.setup()

-- Basic save: :w (write current buffer)
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save current file", noremap = true, silent = true })

-- Quick edit config picker with split
vim.keymap.set("n", "<localleader>ec", function()
  local snacks = require("snacks")
  local config_path = vim.fn.stdpath("config") .. "/lua"

  -- Custom picker that opens in a right split
  snacks.picker.files({
    cwd = config_path,
    prompt = "Config Files",
    -- Filter to only show active config files (lua files)
    find_command = { "fd", "--type", "f", "--extension", "lua" },
    preview = true,
    -- Custom action to open in right split
    confirm = function(item)
      vim.cmd("vsplit")
      vim.cmd("wincmd l")
      vim.cmd("edit " .. item.file)
    end,
  })
end, { desc = "Quick Edit Config (split)" })

-- System configuration picker
vim.keymap.set("n", "<localleader>ec", function()
  local snacks = require("snacks")

  -- Define configuration locations
  local configs = {
    { name = "nvim", path = "~/.core/.sys/cfg/nvim" },
    { name = "tmux", path = "~/.core/.sys/cfg/tmux" },
    { name = "wezterm", path = "~/.core/.sys/cfg/wezterm" },
    { name = "zsh", path = "~/.core/.sys/cfg/zsh" },
    { name = "yazi", path = "~/.core/.sys/cfg/yazi" },
    { name = "rofi", path = "~/.core/.sys/env/desktop/rofi" },
    { name = "hyprland", path = "~/.core/.sys/env/desktop/hypr" },
    { name = "waybar", path = "~/.core/.sys/env/desktop/waybar" },
    { name = "dunst", path = "~/.core/.sys/env/desktop/dunst" },
  }

  -- Build items list with proper format
  local items = {}
  local config_map = {} -- Store config data separately

  for _, config in ipairs(configs) do
    local expanded_path = vim.fn.expand(config.path)
    if vim.fn.isdirectory(expanded_path) == 1 then
      local display_text = config.name .. " → " .. expanded_path
      table.insert(items, display_text)
      config_map[display_text] = {
        name = config.name,
        path = expanded_path,
      }
    end
  end

  -- First picker: select configuration
  local Picker = require("snacks.picker")

  vim.ui.select(items, {
    prompt = "Select Configuration to Edit:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if not choice then
      return
    end

    local selected_config = config_map[choice]
    if not selected_config then
      vim.notify("Invalid selection", vim.log.levels.ERROR)
      return
    end

    -- Open file picker with selected config
    vim.schedule(function()
      local picker = Picker.files({
        cwd = selected_config.path,
        prompt = selected_config.name(" Files"),
        -- Exclude .archv, .ref, .bak directories
        find_command = {
          "fd",
          "--type",
          "f",
          "--exclude",
          ".archv",
          "--exclude",
          ".ref",
          "--exclude",
          ".bak",
        },
        preview = true,
      })

      -- Override the default action
      if picker and picker.opts then
        picker.opts.confirm = function(selected)
          -- Debug: print what we receive
          vim.notify("Selected item type: " .. type(selected), vim.log.levels.INFO)

          -- Try different ways to get the file path
          local file_path = nil
          if type(selected) == "table" then
            file_path = selected.file or selected.path or selected.filename or selected.text
            if not file_path and selected.item then
              file_path = selected.item.file or selected.item.path or selected.item
            end
          elseif type(selected) == "string" then
            file_path = selected
          end

          if file_path and type(file_path) == "string" then
            -- Make absolute path if needed
            if not vim.startswith(file_path, "/") then
              file_path = selected_config.path .. "/" .. file_path
            end
            vim.cmd("vsplit")
            vim.cmd("wincmd l")
            vim.cmd("edit " .. vim.fn.fnameescape(file_path))
          else
            vim.notify("Could not determine file path. Got: " .. vim.inspect(selected), vim.log.levels.ERROR)
          end
        end
      end
    end)
  end)
end, { desc = "System Config Browser" })

--
-- -- ==========================================================================
-- -- which-key Groups(define these first)
-- -- -- =========================================================================
--
-- -- - `icon` (`string`): the icon to use **(optional)**
-- -- - `hl` (`string`): the highlight group to use for the icon **(optional)**
-- -- - `color` (`string`): the color to use for the icon **(optional)**
-- --     valid colors are: `azure`, `blue`, `cyan`, `green`, `grey`, `orange`, `purple`, `red`, `yellow`
-- -- - `cat` (`string`): the category of the icon **(optional)**
-- --     valid categories are: `file`, `filetype`, `extension`
-- -- - `name` (`string`): the name of the icon in the specified category **(optional)**

local wk = require("which-key")
--
wk.add({
  { "<localleader>e", group = "editor" },
  { pattern = "tab", icon = "󰓩 ", color = "purple" },
  { pattern = "%f[%a]ai", icon = " ", color = "green" },
  -- { plugin = "grapple.nvim", pattern = "grapple", icon = "󰛢", color = "azure" },
  { pattern = "exit", icon = "󰈆 ", color = "red" },
  { pattern = "quit", icon = "󰈆 ", color = "red" },
  { plugin = "CopilotChat.nvim", icon = " ", color = "azure" },
  { pattern = "find", icon = " ", color = "blue" },
  -- { plugin = "yanky.nvim", icon = "󰅇", color = "yellow" },
  { "<localleader>b", group = "bookmarks", icon = { icon = "󰃅", "cyan" } },
  { "<leader>g", group = "git", icon = { icon = "󰊢", "orange" } }, --󰊢
  { "<leader>f", group = "file/find", icon = { icon = "", "blue" } },
  { "<leader>a", group = "ai", icon = { icon = " ", color = "azure" } },
  { "<leader>c", group = "code", icon = { icon = "", color = "purple" } },
  { "<leader>y", group = "yank/clipboard", icon = { icon = "󰅇", color = "yellow" } },
  { "<localleader>t", group = "tabs", icon = { icon = "󰓩", color = "purple" } },
  { "<localleader>F", group = "format", icon = { icon = "󰉼", color = "blue" } },
  { "<localleader>m", group = "markdown", icon = { icon = "", color = "cyan" } },
  { "<localleader>l", group = "LSP", icon = { icon = "󰵅⚡", color = "yellow" } },
  { "<localleader>u", group = "undo", icon = { icon = "", color = "orange" } },
  { "<leader>n", group = "notifications", icon = { icon = "󰵅 ", color = "yellow" } },
  { "<leader>u", group = "ui/toggle", icon = { icon = "󰙵 ", color = "cyan" } },
  { "<leader>w", group = "windows", icon = { icon = " ", color = "green" } },
  { "<leader>l", group = "lsp", icon = { icon = "", "orange" } },
  { "<leader>s", group = "search", icon = { icon = "", "cyan" } },
  { "<localleader>s", group = "sessions", icon = { icon = "󰆓 ", color = "purple" } },
  { "<C-g>", group = "diagnostics/reset", icon = { icon = "󰌑", color = "yellow" } },
})

-- which-key state management commands (registered in ui/which-key.lua)
wk.add({
  { "<leader>uW", desc = "Reset which-key" },
  { "<leader>uD", desc = "Debug which-key" },
})

-- wk.add({
--   map({
--
--   })
-- })

-- -- =============================================================================
-- -- FOLD MAPPINGS
-- -- =============================================================================
-- -- Configure fold settings for marker-based folding (supports [[[, ]]] markers)
-- vim.opt.foldmethod = "marker"
-- vim.opt.foldmarker = "[[[,]]]"
-- vim.opt.foldlevel = 0 -- Start with all folds closed
-- vim.opt.foldlevelstart = 0 -- Start with all folds closed when opening a file
--
-- -- Fold mappings with which-key integration
-- wk.add({
-- 	{ "<localleader>f", group = "fold", icon = { icon = "", color = "purple" } },
-- 	{ "<localleader>ft", "za", desc = "Toggle fold" },
-- 	{ "<localleader>fc", "zc", desc = "Close fold" },
-- 	{ "<localleader>fo", "zo", desc = "Open fold" },
-- 	{ "<localleader>fC", "zM", desc = "Close all folds" },
-- 	{ "<localleader>fO", "zR", desc = "Open all folds" },
-- 	{ "<localleader>fn", "zj", desc = "Next fold" },
-- 	{ "<localleader>fp", "zk", desc = "Previous fold" },
-- 	{ "<localleader>fa", "zA", desc = "Toggle all levels" },
-- 	{ "<localleader>fr", "zr", desc = "Reduce folding (open more)" },
-- 	{ "<localleader>fm", "zm", desc = "More folding (close more)" },
-- })
--
-- -- vim.keymap.set("n", "<localleader>pp", clipb.paste_markdown(), { desc = "Paste as Markdown" })

-- Remap insert mode: i becomes insert (replacing old 'a')
-- map("n", "i", "i", { noremap = true, silent = true })
-- map("n", "I", "I", { noremap = true, silent = true })
map("n", "u", "<C-u>", { desc = "Page up (remapped)", noremap = true, silent = true })
map("v", "u", "<C-u>", { desc = "Page up (remapped)", noremap = true, silent = true })
map("n", "<C-u>", "u", { desc = "Undo (remapped)", noremap = true, silent = true })
map("v", "<C-u>", "u", { desc = "Undo (remapped)", noremap = true, silent = true })

map({ "i" }, "<Tab>", "<C-t>", { desc = "Indent in insert mode", noremap = true, silent = true })
-- -- safe_unmap("v", "/")
-- -- safe_unmap("x", "/")
--
--
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
-- Removed old <localleader>f mapping to make room for fold group
map("i", "<S-Tab>", "<C-d>", { desc = "Unindent in insert mode" })
-- -- vim.keymap.set("n", "<S-Tab>", function()
-- -- 	local col = vim.fn.col(".")
-- -- 	local line = vim.fn.getline(".")
-- --
-- -- 	-- Check if there's whitespace before cursor
-- -- 	if col > 1 and line:sub(1, col - 1):match("%s+$") then
-- -- 		-- Delete up to a tab's worth of spaces before cursor
-- -- 		local tabstop = vim.bo.tabstop
-- -- 		local spaces_to_delete = math.min(
-- -- 			tabstop,
-- -- 			col - 1 - (line:sub(1, col - 1):match("(.-)%s+$") and #line:sub(1, col - 1):match("(.-)%s+$") or 0)
-- -- 		)
-- -- 		vim.cmd("normal! " .. spaces_to_delete .. "X")
-- -- 	end
-- -- end, { noremap = true, silent = true })
--
-- Fast vertical movement (5 lines at a time)
map("n", "<C-i>", "5k", { noremap = true, silent = true, desc = "Jump up 5 lines" })
map("n", "<C-k>", "5j", { noremap = true, silent = true, desc = "Jump down 5 lines" })
map("v", "<C-i>", "5k", { noremap = true, silent = true, desc = "Jump up 5 lines" })
map("v", "<C-k>", "5j", { noremap = true, silent = true, desc = "Jump down 5 lines" })

map({ "n", "v" }, "PageUp", "<C-u>zz", { noremap = true, silent = true })
map({ "n", "v" }, "PageDown", "<C-d>zz", { noremap = true, silent = true })
map({ "n", "v" }, "K", "<C-d>zz", { noremap = true, silent = true }) -- L = big down jump (shift+l)
map({ "n", "v" }, "I", "<C-u>zz", { noremap = true, silent = true }) -- O = big up jump (shift+o)
-- -- map({ "n", "v" }, "<C-S-K>", function()

map({ "n", "v" }, "A", "i", { noremap = true, silent = true })

map({ "i" }, "<C-d>", "<C-h>", { noremap = true, silent = true }) -- O = big up jump (shift+o)

-- -- 	-- require("nvim-treesitter.textobjects.move").goto_next_end("@function.outer")
-- -- end, { silent = true })
-- --
-- -- -- C-S-O: Beginning of function (using Treesitter)
-- -- vim.keymap.set({ "n", "v" }, "<C-S-O>", function()
-- -- 	-- require("nvim-treesitter.textobjects.move").goto_previous_start("@function.outer")
-- -- end, { silent = true })
--
-- -- Resize panels with OL;K
-- map("n", "<D-j>", "<C-w><", { silent = true, noremap = true }) -- left
-- map("n", "<D-k>", "<C-w>-", { silent = true, noremap = true }) -- down
-- map("n", "<D-i>", "<C-w>+", { silent = true, noremap = true }) -- up
-- map("n", "<D-l>", "<C-w>>", { silent = true, noremap = true }) -- right
--
-- -- Open line functionality (o/O replaced by navigation)
-- -- map("n", "<C-i>", "o<Esc>", { noremap = true, silent = true, desc = "Open line below" })
-- -- map("n", "<C-S-i>", "O<Esc>", { noremap = true, silent = true, desc = "Open line above" })
--
-- OL;K Navigation (o=up, l=down, k=left, ;=right)
--
wk.add({
  { "<C-i>", "5k", desc = "Jump up 5 lines" },
  { "<C-k>", "5j", desc = "Jump down 5 lines" },
  { "i", "k", desc = "cursor up" },
  { "k", "j", desc = "cursor down" },
  { "j", "h", desc = "cursor left" },
  { "l", "l", desc = "cursor right" },
})

map({ "n", "v" }, "i", "k", { noremap = true, silent = true })
map({ "n", "v" }, "k", "j", { noremap = true, silent = true })
map({ "n", "v" }, "j", "h", { noremap = true, silent = true })
map({ "n", "v" }, "l", "l", { noremap = true, silent = true })

-- Line start/end with C-S-k and C-S-;
map({ "n", "v" }, "<C-S-J>", "0", { noremap = true, silent = true })
map({ "n", "v" }, "<C-S-L>", "$", { noremap = true, silent = true })

map({ "n", "v" }, "<C-j>", "b", { noremap = true, silent = true })
map({ "n", "v" }, "<C-l>", "w", { noremap = true, silent = true })

-- Word movement with Alt
map({ "n", "v" }, "<A-j>", "<C-Left>", { noremap = true, silent = true })
map({ "n", "v" }, "<A-l>", "<C-Right>", { noremap = true, silent = true })

-- Word boundaries (WORD jumps)
map({ "n", "v" }, "J", "B", { noremap = true, silent = true })
map({ "n", "v" }, "L", "E", { noremap = true, silent = true })
--
-- -- Visual mode with mark
-- -- map("n", "v", "mVv", { noremap = true, silent = true })
-- -- map("n", "V", "mVV", { noremap = true, silent = true })
-- -- map("v", "<C-/>", "`V", { noremap = true, silent = true })
--
-- -- Repeat last command (semicolon functionality moved to <leader>;)
-- -- map("n", "<leader>;", ".", { noremap = true, silent = true, desc = "Repeat last command" })
--
-- -- -- J-based jump motions (j is now freed up)
wk.add({
  { "<leader>j", group = "jumps", icon = { icon = "󰞘", color = "cyan" } },
  { "<leader>jb", "<C-o>", desc = "Jump backward" },
  { "<leader>je", "<C-i>", desc = "Jump forward" },
  { "<leader>jB", "{", desc = "Previous paragraph" },
  { "<leader>jE", "}", desc = "Next paragraph" },
  { "<leader>jS", "[[", desc = "Previous section" },
  { "<leader>js", "]]", desc = "Next section" },
  { "<leader>jd", "gd", desc = "Go to definition" },
  { "<leader>jD", "gD", desc = "Go to declaration" },
  { "<leader>jm", "`", desc = "Jump to mark" },
  { "<leader>jM", "'", desc = "Jump to mark (line)" },
})

vim.keymap.set("v", "s", ":sort<CR>", { desc = "Sort selected lines" })

--
-- -- N-based next/previous navigation
-- map("n", "n", "n", { noremap = true, silent = true })
-- map("n", "N", "N", { noremap = true, silent = true })
--
-- -- Ctrl-Enter opens Vim command-line
-- map("n", "<C-CR>", ":", { noremap = true, desc = "Command-line" })
-- map("i", "<C-CR>", "<Esc>:", { noremap = true, desc = "Command-line (exit insert)" })
-- map("v", "<C-CR>", ":", { noremap = true, desc = "Command-line" })
--
-- -- =============================================================================
-- -- TAB & BUFFER MANAGEMENT (replacing Tabby keybinds)
-- -- =============================================================================
--
-- -- Tab operations: <leader>t
-- wk.add({
-- 	{ "<leader>t", group = "tabs" },
-- 	{ "<leader>tn", "<cmd>tabnew<cr>", desc = "New tab" },
-- 	{ "<leader>tc", "<cmd>tabclose<cr>", desc = "Close tab" },
-- 	{ "<leader>to", "<cmd>tabonly<cr>", desc = "Close other tabs" },
-- 	{ "<leader>th", "<cmd>tabprevious<cr>", desc = "Previous tab" },
-- 	{ "<leader>tl", "<cmd>tabnext<cr>", desc = "Next tab" },
-- 	{ "<leader>t[", "<cmd>tabfirst<cr>", desc = "First tab" },
-- 	{ "<leader>t]", "<cmd>tablast<cr>", desc = "Last tab" },
-- 	{ "<leader>tH", "<cmd>-tabmove<cr>", desc = "Move tab left" },
--
-- 	{ "<leader>tL", "<cmd>+tabmove<cr>", desc = "Move tab right" },
-- 	{ "<leader>t1", "1gt", desc = "Tab 1" },
-- 	{ "<leader>t2", "2gt", desc = "Tab 2" },
-- 	{ "<leader>t3", "3gt", desc = "Tab 3" },
-- 	{ "<leader>t4", "4gt", desc = "Tab 4" },
-- 	{ "<leader>t5", "5gt", desc = "Tab 5" },
-- 	{ "<leader>t6", "6gt", desc = "Tab 6" },
-- 	{ "<leader>t7", "7gt", desc = "Tab 7" },
-- 	{ "<leader>t8", "8gt", desc = "Tab 8" },
-- 	{ "<leader>t9", "9gt", desc = "Tab 9" },
-- 	{ "<leader>t0", "<cmd>tablast<cr>", desc = "Last tab" },
-- })
--
-- Buffer operations: <leader>b
wk.add({
  { "<leader>b", group = "buffers" },
  { "<leader>bn", "<cmd>bwipeout<cr>", desc = "Wipeout buffer" },
  { "<leader>be", "<cmd>bnext<cr>", desc = "Next buffer" },
  { "<leader>bq", "<cmd>bprevious<cr>", desc = "Previous buffer" },
  { "<leader>bf", "<cmd>bfirst<cr>", desc = "First buffer" },
  { "<leader>bl", "<cmd>blast<cr>", desc = "Last buffer" },
  { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete buffer" },
  { "<leader>bD", "<cmd>bdelete!<cr>", desc = "Delete buffer (force)" },
  { "<leader>bw", "<cmd>bwipeout<cr>", desc = "Wipeout buffer" },
  { "<leader>bo", "<cmd>%bd|e#|bd#<cr>", desc = "Close other buffers" },
  { "<leader>bt", "<cmd>tab split<cr>", desc = "Buffer to new tab" },
  { "<leader>tn", "<cmd>tabnew %<cr>", desc = "Open buffer in new tab" },
  { "<leader>bs", "<cmd>buffers<cr>", desc = "List buffers" },
})
-- local custom_fzf = require("modules.fzf.plugin-commands") -- Adjust path if needed
-- vim.keymap.set("n", "<localleader>fp", custom_fzf.export_plugin_commands, { desc = "Export Plugin Commands" })

--          ╭─────────────────────────────────────────────────────────╮
--           |                          INDENTING                       │
--          ╰─────────────────────────────────────────────────────────╯

-- Visual mode indenting (keeps selection after indent)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Normal mode line indenting
vim.keymap.set("n", "<localleader>F>", ">>", { desc = "Indent line right" })
vim.keymap.set("n", "<localleader>F<", "<<", { desc = "Indent line left" })

-- Indent entire file and return to position
vim.keymap.set("n", "<localleader>F=", "gg=G<C-o>", { desc = "Auto-indent entire file" })

-- Indent current paragraph
vim.keymap.set("n", "<localleader>Fp", "=ip", { desc = "Indent paragraph" })

-- Indent current function/block (with treesitter)
vim.keymap.set("n", "<localleader>Ff", "=af", { desc = "Indent function" })

-- Fix indentation in visual selection
vim.keymap.set("v", "=", "=", { desc = "Auto-indent selection" })

-- Tab/Shift-Tab for indenting in visual mode
--       vim.keymap.set({ "n", "v" }, "<Tab>", ">gv", { desc = "Indent right" })
-- vim.keymap.set({ "n", "v" }, "<S-Tab>", "<gv", { desc = "Indent left" })

-- Reindent and format (if you have formatter setup)
vim.keymap.set("n", "<localleader>FF", function()
  vim.cmd("normal! gg=G")
  vim.lsp.buf.format({ async = false })
end, { desc = "Reindent and format file" })

-- **Built-in commands you can also use directly:**
-- - `gg=G` - Auto-indent entire file
-- - `==` - Auto-indent current line
-- - `=` in visual mode - Auto-indent selection
-- - `>ip` / `<ip` - Indent/outdent paragraph
-- - `>i{` / `<i{` - Indent/outdent inside braces

-- Tab navigation moved to <localleader>t
wk.add({
  { "<localleader>tq", "<cmd>tabprevious<cr>", desc = "Previous tab" },
  { "<localleader>te", "<cmd>tabnext<cr>", desc = "Next tab" },
  { "<localleader>ta", "<cmd>-tabmove<cr>", desc = "Move tab left" },
  { "<localleader>td", "<cmd>+tabmove<cr>", desc = "Move tab right" },
  { "<localleader>tn", "<cmd>tabnew<cr>", desc = "New tab" },
  { "<localleader>tc", "<cmd>tabclose<cr>", desc = "Close tab" },
  { "<localleader>to", "<cmd>tabonly<cr>", desc = "Close other tabs" },
  -- 	{ "<M-1>", "1gt", desc = "Tab 1" },
  -- 	{ "<M-2>", "2gt", desc = "Tab 2" },
  -- 	{ "<M-3>", "3gt", desc = "Tab 3" },
  -- 	{ "<M-4>", "4gt", desc = "Tab 4" },
  -- 	{ "<M-5>", "5gt", desc = "Tab 5" },
  -- 	{ "<M-6>", "6gt", desc = "Tab 6" },
  -- 	{ "<M-7>", "7gt", desc = "Tab 7" },
  -- 	{ "<M-8>", "8gt", desc = "Tab 8" },
  -- 	{ "<M-9>", "9gt", desc = "Tab 9" },
  -- 	-- { "<C->", "<cmd>tablast<cr>", desc = "Last tab" },

  { "<M-e>", "<cmd>bnext<cr>", desc = "Next buffer" },
  { "<M-q>", "<cmd>bprevious<cr>", desc = "Previous buffer" },
})
--
-- -- -- Tab navigation
-- -- vim.keymap.set("n", "<leader>1", "1gt", { desc = "Go to tab 1" })
-- -- vim.keymap.set("n", "<leader>2", "2gt", { desc = "Go to tab 2" })
-- -- vim.keymap.set("n", "<leader>3", "3gt", { desc = "Go to tab 3" })
-- -- vim.keymap.set("n", "<leader>4", "4gt", { desc = "Go to tab 4" })
-- -- vim.keymap.set("n", "<leader>5", "5gt", { desc = "Go to tab 5" })
-- -- vim.keymap.set("n", "<leader>6", "6gt", { desc = "Go to tab 6" })
-- -- vim.keymap.set("n", "<leader>7", "7gt", { desc = "Go to tab 7" })
-- -- vim.keymap.set("n", "<leader>8", "8gt", { desc = "Go to tab 8" })
-- -- vim.keymap.set("n", "<leader>9", "9gt", { desc = "Go to tab 9" })
--
-- -- map({ "n", "v", "x" }, "<A-q>", ":BufferPrevious<CR>", { desc = "Go to previous buffer" })
-- -- map({ "n", "v", "x" }, "<A-e>", ":BufferNext<CR>", { desc = "Go to next buffer" })
-- -- map({ "n", "v", "x" }, "<A-S-q>", ":BufferMovePrevious<CR>", { desc = "Move buffer to the left" })
-- -- map({ "n", "v", "x" }, "<A-S-e>", ":BufferMoveNext<CR>", { desc = "Move buffer to the right" })
--

require("keymaps.ai")

-- wk.add({
--   {
--     "<leader>aa",
--     function()
--       require("CopilotChat").toggle()
--     end,
--     desc = "Toggle Copilot Chat",
--   },
--   {
--     "<leader>at",
--     function()
--       local suggestion = require("copilot.suggestion")
--       if suggestion.is_visible() then
--         suggestion.dismiss()
--       end
--
--       -- Toggle auto_trigger
--       suggestion.toggle_auto_trigger()
--
--       vim.notify("Copilot auto-trigger toggled", vim.log.levels.INFO)
--     end,
--     desc = "Toggle Copilot auto-trigger",
--   },
-- })

-- -- =============================================================================
-- -- WINDOW MANAGEMENT (replacing Tabby keybinds)
-- -- =============================================================================
--
-- wk.add({
-- 	{ "<leader>w", group = "windows" },
-- 	-- Splits
-- 	-- { "<C-S-v>", "<cmd>vsplit<cr>", desc = "Vertical split" },
-- 	-- { "<C-S-d>", "<cmd>split<cr>", desc = "Horizontal split" },
-- 	-- { "<C-S-c>", "<cmd>close<cr>", desc = "Close window" },
-- 	-- { "<C-S-A-a>", "<cmd>only<cr>", desc = "Close other windows" },
--
-- 	-- Navigation (OL;K: o=up, l=down, k=left, ;=right)
-- 	-- { "<leader>w=", "<C-w>=", desc = "Equal size" },
-- 	-- { "<A-S-l>", "<cmd>resize -5<cr>", desc = "Decrease height" },
-- 	-- { "<A-S-o>", "<cmd>resize +5<cr>", desc = "Increase height" },
-- 	-- { "<A-S-k>", "<cmd>vertical resize -5<cr>", desc = "Decrease width" },
-- 	-- { "<A-S-;>", "<cmd>vertical resize +5<cr>", desc = "Increase width" },
--
-- 	-- Alt navigation
-- 	{ "<A-a>", "<C-w>h", desc = "Go left" },
-- 	{ "<A-s>", "<C-w>j", desc = "Go down" },
-- 	{ "<A-w>", "<C-w>k", desc = "Go up" },
-- 	{ "<A-d>", "<C-w>l", desc = "Go right" },
--
-- 	{ "<A-A>", "<C-w>H", desc = "Move left" },
-- 	{ "<A-S>", "<C-w>J", desc = "Move down" },
-- 	{ "<A-W>", "<C-w>K", desc = "Move up" },
-- 	{ "<A-D>", "<C-w>L", desc = "Move right" },
--
wk.add({
  -- { "<M-a>", "<C-w>h", desc = "Go left" },
  -- { "<M-s>", "<C-w>j", desc = "Go down" },
  -- { "<M-w>", "<C-w>k", desc = "Go up" },
  -- { "<M-d>", "<C-w>l", desc = "Go right" },

  -- Window resizing with Meta+Shift+w/s/a/d
  { "<M-S-w>", "<cmd>resize +2<cr>", desc = "Increase height" },
  { "<M-S-s>", "<cmd>resize -2<cr>", desc = "Decrease height" },
  { "<M-S-a>", "<cmd>vertical resize -2<cr>", desc = "Decrease width" },
  { "<M-S-d>", "<cmd>vertical resize +2<cr>", desc = "Increase width" },

  { "<leader>wv", "<cmd>vsplit<cr>", desc = "Vertical split" },
  { "<leader>wh", "<cmd>split<cr>", desc = "Horizontal split" },
  {
    "<leader>wc",
    function()
      local win_count = #vim.api.nvim_tabpage_list_wins(0)
      local tab_count = #vim.api.nvim_list_tabpages()
      if win_count > 1 then
        vim.cmd("close")
      elseif tab_count > 1 then
        vim.cmd("tabclose")
      else
        vim.cmd("quit")
      end
    end,
    desc = "Smart close (window/tab/quit)",
  },
  { "<leader>wo", "<cmd>only<cr>", desc = "Close other windows" },
  -- Move window (OL;K - lowercase now)
  { "<leader>wa", "<C-w>H", desc = "Move window left" },
  { "<leader>ws", "<C-w>J", desc = "Move window down" },
  { "<leader>ww", "<C-w>K", desc = "Move window up" },
  { "<leader>wd", "<C-w>L", desc = "Move window right" },
  { "<leader>wt", "<C-w>T", desc = "Move window to new tab" },
  -- { "<leader>w-", "<cmd>resize -5<cr>", desc = "Decrease height" },/p/
  -- { "<leader>w+", "<cmd>resize +5<cr>", desc = "Increase height" },
  -- { "<leader>w<", "<cmd>vertical resize -5<cr>", desc = "Decrease width" },
  -- { "<leader>w>", "<cmd>vertical resize +5<cr>", desc = "Increase width" },
})
-- Window utilities
wk.add({
  {
    "<leader>wz",
    function()
      local win_count = #vim.api.nvim_tabpage_list_wins(0)
      if win_count == 2 then
        local current_layout = vim.fn.winlayout()
        if current_layout[1] == "col" then
          vim.cmd("wincmd K")
        else
          vim.cmd("wincmd H")
        end
      else
        vim.notify("Toggle split only works with exactly 2 windows", vim.log.levels.WARN)
      end
    end,
    desc = "Toggle split orientation",
  },
  {
    "<leader>wn",
    function()
      vim.cmd("vsplit")
      vim.cmd("enew")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.swapfile = false
    end,
    desc = "Create scratch window",
  },
  {
    "<leader>wz",
    function()
      if vim.g.window_maximized then
        vim.cmd("wincmd =")
        vim.g.window_maximized = false
      else
        vim.cmd("wincmd |")
        vim.cmd("wincmd _")
        vim.g.window_maximized = true
      end
    end,
    desc = "Toggle window maximize",
  },
})

--
-- -- WinShift integration
vim.keymap.set("n", "<leader>wW", ":WinShift<CR>", { desc = "Start WinShift mode" })
vim.keymap.set("n", "<C-w>m", ":WinShift<CR>", { desc = "Start WinShift mode" })
--
-- -- -- WinShift with direction (immediate move)
vim.keymap.set("n", "<C-S-a>", ":WinShift left<CR>", { desc = "Move window left" })
vim.keymap.set("n", "<C-S-s>", ":WinShift down<CR>", { desc = "Move window down" })
vim.keymap.set("n", "<C-S-w>", ":WinShift up<CR>", { desc = "Move window up" })
vim.keymap.set("n", "<C-S-d>", ":WinShift right<CR>", { desc = "Move window right" })
-- --
-- -- -- WinShift swap (swap with window in direction)
vim.keymap.set("n", "<leader>wa", ":WinShift swap left<CR>", { desc = "Swap with left window" })
vim.keymap.set("n", "<leader>ws", ":WinShift swap down<CR>", { desc = "Swap with window below" })
vim.keymap.set("n", "<leader>ww", ":WinShift swap up<CR>", { desc = "Swap with window above" })
vim.keymap.set("n", "<leader>wd", ":WinShift swap right<CR>", { desc = "Swap with right window" })
--
-- -- Function to create a custom WinShift mode with additional features
local function enhanced_winshift_mode()
  -- Store current window for reference
  local start_win = vim.api.nvim_get_current_win()

  print("🚀 Enhanced WinShift Mode - Type 'h' for help")

  -- You could extend this to add custom behaviors
  -- For now, just use standard WinShift
  vim.cmd("WinShift")
end
--
vim.keymap.set("n", "<leader>wM", enhanced_winshift_mode, { desc = "Enhanced WinShift mode" })

-- If you want to integrate with tmux-style pane management
local function tmux_style_window_move()
  -- This mimics tmux's prefix + { } for moving panes
  local choice = vim.fn.input("Move window: (h)left (j)down (k)up (l)right (q)uit: ")
  if choice == "h" then
    vim.cmd("WinShift left")
  elseif choice == "j" then
    vim.cmd("WinShift down")
  elseif choice == "k" then
    vim.cmd("WinShift up")
  elseif choice == "l" then
    vim.cmd("WinShift right")
  elseif choice == "q" then
    return
  else
    print("Invalid choice")
  end
end
-- --
vim.keymap.set("n", "<leader>wt", tmux_style_window_move, { desc = "Tmux-style window move" })
--
-- -- NOTE: Window utility functions moved to Tabby plugin (lua/plugins/tabby.lua)
-- --
-- Start WinShift in swap mode (for swapping windows)
vim.keymap.set("n", "<leader>wx", ":WinShift swap<CR>", { desc = "Start WinShift swap mode" })
-- --
-- -- -- Move window to far edges (WinShift versions)
vim.keymap.set("n", "<leader>wA", ":WinShift far_left<CR>", { desc = "Move window to far left" })
vim.keymap.set("n", "<leader>wS", ":WinShift far_down<CR>", { desc = "Move window to far down" })
vim.keymap.set("n", "<leader>wW", ":WinShift far_up<CR>", { desc = "Move window to far up" })
vim.keymap.set("n", "<leader>wD", ":WinShift far_right<CR>", { desc = "Move window to far right" })
-- --
-- -- -- Setup function to initialize everything
-- local function setup_window_management()
--   setup_winshift()
--   print("Window management setup complete")
-- end
-- --
-- -- -- Call setup
-- setup_window_management()
--
-- -- =============================================================================
-- -- QUICK REFERENCE SUMMARY
-- -- =============================================================================
--
-- --[[
-- NAVIGATION:
--   <C-h/j/k/l>       - Navigate windows
--   <leader>ww        - Pick window
--
-- CREATION:
--   <leader>wv        - Vertical split
--   <leader>ws        - Horizontal split
--   <leader>wn        - Scratch window
--
-- MANAGEMENT:
--   <leader>we        - Equalize windows
--   <leader>wz        - Toggle split orientation
--   <leader>wM        - Toggle maximize
--   <leader>wx        - Close window
--   <leader>wo        - Close others
--   <leader>q         - Smart close
--
-- MOVING (WinShift):
--   <C-w>m           - Start WinShift mode
--   <C-w>H/J/K/L     - Move window in direction
--   <leader>ws       - WinShift swap mode
--   <leader>wsh/j/k/l - Swap with direction
--   <leader>wfh/j/k/l - Move to far edge
--
-- RESIZING:
--   <C-Up/Down>      - Resize height
--   <C-Left/Right>   - Resize width
--
-- TABS:
--   <leader>to/x     - Open/close tab
--   <leader>tn/p     - Next/previous tab
--   <leader>wt       - Move window to new tab
-- --]]
--
-- -- local neoscroll = require("neoscroll")
-- -- local keymap = {
-- -- 	["<C-Up>"] = function()
-- -- 		neoscroll.ctrl_b({ duration = 550 })
-- -- 	end,
-- -- 	["<PageUp>"] = function()
-- -- 		neoscroll.ctrl_b({ duration = 750 })
-- -- 	end,
-- -- 	["<C-Down>"] = function()
-- -- 		neoscroll.ctrl_f({ duration = 550 })
-- -- 	end,
-- -- 	["<PageDown>"] = function()
-- -- 		neoscroll.ctrl_f({ duration = 750 })
-- -- 	end,
-- -- 	["<C-w>"] = function()
-- -- 		neoscroll.ctrl_b({ duration = 400 })
-- -- 	end,
-- -- 	["<C-s>"] = function()
-- -- 		neoscroll.ctrl_f({ duration = 400 })
-- -- 	end,
-- -- }
--
map({ "n", "v" }, "<localleader>ut", ":UndotreeToggle<CR>", { desc = "Toggle undo tree " })
map({ "n", "v" }, "<localleader>uu", "undo", { desc = "undo" })
map({ "n", "v" }, "<localleader>ur", "redo", { desc = "redo" })

map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
map("i", "<C-c>", "<Esc>")

map({ "n", "v" }, "<leader>d", '"_d')

map("v", "W", ":m '>+1<CR>gv=gv")
map("v", "S", ":m '<-2<CR>gv=gv")

vim.keymap.set("v", "<leader>pb", function()
  -- Get visual block selection marks
  local start_pos = vim.api.nvim_buf_get_mark(0, "<")
  local end_pos = vim.api.nvim_buf_get_mark(0, ">")
  local start_line, start_col = unpack(start_pos)
  local end_line, end_col = unpack(end_pos)

  -- Ensure start_line <= end_line and start_col <= end_col
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  if start_col > end_col then
    start_col, end_col = end_col, start_col
  end

  -- Get clipboard content (single line or first line if multi-line)
  local clipboard_content = vim.fn.getreg("+"):match("[^\n]*") -- Get first line of clipboard

  -- Iterate over each line in the block
  for line = start_line, end_line do
    -- Get the current line content
    local current_line = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""

    -- Calculate padding if the line is too short
    local padding = string.rep(" ", math.max(0, start_col - #current_line))

    -- Construct new line: content before start_col + clipboard + content after end_col
    local new_line = string.sub(current_line, 1, start_col)
      .. padding
      .. clipboard_content
      .. string.sub(current_line, end_col + 1)

    -- Set the modified line
    vim.api.nvim_buf_set_lines(0, line - 1, line, false, { new_line })
  end

  -- Restore cursor to start of block
  vim.api.nvim_win_set_cursor(0, { start_line, start_col })
end, {
  desc = "Paste clipboard on each line in visual block mode",
})

vim.keymap.set("n", "<localleader>Fa", "ma=ap'a", { desc = "Format around cursor" })

vim.keymap.set("n", "<localleader>Ft", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local char = line:sub(col + 1, col + 1)

  -- Set mark to return to
  vim.cmd("normal! ma")

  -- Detect surrounding context
  local pairs = {
    ["{"] = "a{",
    ["}"] = "a{",
    ["("] = "a(",
    [")"] = "a(",
    ["["] = "a[",
    ["]"] = "a[",
    ["<"] = "a<",
    [">"] = "a<",
    ['"'] = 'a"',
    ["'"] = "a'",
    ["`"] = "a`",
  }

  -- Check if cursor is on/near a bracket or quote
  if pairs[char] then
    vim.cmd("normal! =" .. pairs[char])
  else
    -- Try to detect if we're in a function/block
    local ok = pcall(vim.cmd, "normal! =aB")
    if not ok then
      -- Fall back to paragraph
      vim.cmd("normal! =ap")
    end
  end

  -- Return to original position
  vim.cmd("normal! 'a")
end, { desc = "Smart format text object" })

vim.keymap.set("n", "<localleader>Fs", function()
  vim.cmd("normal! ma")

  -- Try treesitter-aware formatting first (requires nvim-treesitter-textobjects)
  local ok = pcall(vim.cmd, "normal! =aB") -- Try block first
  if not ok then
    vim.cmd("normal! =ap") -- Fall back to paragraph
  end

  vim.cmd("normal! 'a")
end, { desc = "Smart format" })

vim.keymap.set("n", "<localleader>Fb", "ma=aBgv=gv'a", { desc = "Format block/paragraph" })

-- map("n", "<leader>pv", vim.cmd.Ex)

-- CLIPBOARD

-- map("v", "<leader>p", "_dP", { desc = "Paste before/Replace Clipboard" })
-- map("v", "<leader>P", "_dp", { desc = "Paste after/Replace Clipboard" })
-- map({ "n", "v" }, "<leader>y", [["+y]])
-- map({ "n", "v" }, "<leader>Y", [["+Y]])

-- vim.keymap.set("v", "P", function()
-- 	local content = vim.fn.getreg('"')
-- 	local mode = vim.fn.getregtype('"')
-- 	vim.cmd('normal! "_dp')
-- 	vim.fn.setreg('"', content, mode)
-- end, { noremap = true, silent = true })
-- vim.keymap.set("v", "p", function()
-- 	local content = vim.fn.getreg('"')
-- 	local mode = vim.fn.getregtype('"')
-- 	vim.cmd('normal! "_dP')
-- 	vim.fn.setreg('"', content, mode)
-- end, { noremap = true, silent = true })
--
-- -- Lazy load the rest
-- -- vim.api.nvim_create_autocmd("VeryLazy", {
-- -- 	callback = function()
-- -- 		require("core.keymaps.markdown")
-- -- 		require("core.keymaps.window-management")
-- -- 		require("core.keymaps.advanced")
-- -- 	end,
-- -- })
--
-- --
wk.add({
  -- -- { "<leader>f", group = "find" },
  -- -- { "<localleader>f", group = "file browser" },
  -- -- You can also add specific mappings here
  -- -- { "<leader>ff", desc = "Find Files" },
  -- -- { "<leader>fg", desc = "Live Grep" },
  -- -- { "<leader>fb", desc = "Buffers" },
  -- -- { "<leader>fh", desc = "Help Tags" },
  -- -- { "<leader>fr", desc = "Recent Files" },
  -- -- { "<leader>fc", desc = "Grep String" },
  -- -- { "<leader>fd", desc = "Diagnostics" },
  -- --
  -- -- { "<localleader>fb", desc = "Browse Files" },
  -- -- { "<localleader>fe", desc = "File Explorer" },
  -- --
  -- -- -- LSP mappings (these will show when in a buffer with LSP attached)
  -- -- { "<leader>la", desc = "Code Action", mode = { "n", "v" } },
  -- -- { "<leader>ld", desc = "Type Definition" },
  -- -- { "<leader>lf", desc = "Format" },
  -- -- { "<leader>lr", desc = "Rename" },
  -- -- { "<leader>lR", desc = "References" },
  -- --
  -- -- -- Git mappings (if you add git plugins later)
  { "<leader>gs", desc = "Git Status" },
  { "<leader>gb", desc = "Git Blame" },
  { "<leader>gd", desc = "Git Diff" },
})

-- fzf-lua command search
vim.keymap.set("n", "<leader>:", function()
  require("fzf-lua").commands()
end, { desc = "Search Commands" })

vim.keymap.set("n", "<leader>sc", function()
  require("fzf-lua").commands()
end, { desc = "Search Commands" })

-- Map Ctrl-P in command-line mode to open fzf-lua command search
vim.keymap.set("c", "<C-p>", function()
  vim.cmd("stopinsert")
  require("fzf-lua").commands()
end, { desc = "Search Commands (cmdline)" })
