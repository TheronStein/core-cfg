return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			animate = { enabled = true },
			toggle = { enabled = true },
			float = { enabled = true },
			terminal = { enabled = true },
			git = { enabled = true },
			notifier = {
				enabled = true,
				timeout = 3000,
				width = { min = 40, max = 0.6 },
				height = { min = 1, max = 0.8 },
			},
			-- NOTE: 'notify' is correctly disabled/unnecessary
			notify = { enabled = false },
			image = {
				enabled = true,
				backend = "auto", -- auto, kitty, ueberzug
				inline = true,
				integrations = {
					markdown = {
						enabled = true,
						only_render_image_at_cursor = false, -- Show all images inline
						floating_windows = false, -- Don't use popup/floating windows
					},
				},
			},
			lazygit = { enabled = true },
			statuscolumn = { enabled = true },
			scratch = { enabled = true },
			quickfile = { enabled = true },
			win = { enabled = false },
			layout = { enabled = false },
			scroll = {
				enabled = true,
				animate = {
					duration = { step = 15, total = 250 },
					easing = "linear",
				},
				-- Smooth scroll for these motions
				spamming = 10, -- threshold for key spam detection
			},
			picker = {
				enabled = false, -- Disabled in favor of fzf-lua
			},
		},
		keys = {
			-- Top Pickers & Explorer (MIGRATED TO FZF-LUA)
			{
				"<leader><space>",
				function()
					-- Smart detection: git files if in git repo, otherwise all files
					local ok = pcall(require("fzf-lua").git_files)
					if not ok then
						require("fzf-lua").files()
					end
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>fc",
				function()
					require("fzf-lua").command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>nn",
				function()
					require("snacks").notifier.show_history()
				end,
				desc = "Notification History",
			},
			-- find (MIGRATED TO FZF-LUA)
			{
				"<leader>fb",
				function()
					require("fzf-lua").buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fc",
				function()
					require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},
			{
				"<leader>ff",
				function()
					require("fzf-lua").files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").git_files()
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>fp",
				function()
					-- Projects picker - custom implementation needed
					-- For now, use files with a common project root detection
					local root = vim.fs.find({ ".git", "package.json", "Cargo.toml", "go.mod" }, {
						upward = true,
						path = vim.fn.expand("%:p:h"),
					})[1]
					if root then
						root = vim.fn.fnamemodify(root, ":h")
						require("fzf-lua").files({ cwd = root })
					else
						require("fzf-lua").files()
					end
				end,
				desc = "Projects",
			},
			{
				"<leader>fr",
				function()
					require("fzf-lua").oldfiles()
				end,
				desc = "Recent",
			},
			-- git (MIGRATED TO FZF-LUA)
			{
				"<leader>gb",
				function()
					require("fzf-lua").git_branches()
				end,
				desc = "Git Branches",
			},
			{
				"<leader>gl",
				function()
					require("fzf-lua").git_commits()
				end,
				desc = "Git Log",
			},
			{
				"<leader>gL",
				function()
					require("fzf-lua").git_bcommits()
				end,
				desc = "Git Log Line",
			},
			{
				"<leader>gs",
				function()
					require("fzf-lua").git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>gS",
				function()
					require("fzf-lua").git_stash()
				end,
				desc = "Git Stash",
			},
			{
				"<leader>gd",
				function()
					-- Git diff can be shown via git_status with preview
					require("fzf-lua").git_status()
				end,
				desc = "Git Diff (Hunks)",
			},
			{
				"<leader>gf",
				function()
					require("fzf-lua").git_bcommits()
				end,
				desc = "Git Log File",
			},
			-- Grep (MIGRATED TO FZF-LUA)
			{
				"<leader>sb",
				function()
					require("fzf-lua").lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sB",
				function()
					-- Grep in all open buffers
					require("fzf-lua").grep_curbuf()
				end,
				desc = "Grep Open Buffers",
			},
			{
				"<leader>sg",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>sw",
				function()
					-- Word under cursor or visual selection
					local mode = vim.api.nvim_get_mode().mode
					if mode == "v" or mode == "V" then
						require("fzf-lua").grep_visual()
					else
						require("fzf-lua").grep_cword()
					end
				end,
				desc = "Visual selection or word",
				mode = { "n", "x" },
			},
			-- search (MIGRATED TO FZF-LUA)
			{
				'<leader>s"',
				function()
					require("fzf-lua").registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>s/",
				function()
					require("fzf-lua").search_history()
				end,
				desc = "Search History",
			},
			{
				"<leader>sa",
				function()
					require("fzf-lua").autocmds()
				end,
				desc = "Autocmds",
			},
			{
				"<leader>sb",
				function()
					require("fzf-lua").lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sc",
				function()
					require("fzf-lua").command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>sC",
				function()
					require("fzf-lua").commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					require("fzf-lua").diagnostics_workspace()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sD",
				function()
					require("fzf-lua").diagnostics_document()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>sh",
				function()
					require("fzf-lua").help_tags()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sH",
				function()
					require("fzf-lua").highlights()
				end,
				desc = "Highlights",
			},
			{
				"<leader>si",
				function()
					-- Icons picker - custom implementation
					-- Use nvim-web-devicons to show available icons
					local icons = require("nvim-web-devicons").get_icons()
					local items = {}
					for name, icon_data in pairs(icons) do
						table.insert(items, string.format("%s %s %s", icon_data.icon, name, icon_data.color or ""))
					end
					require("fzf-lua").fzf_exec(items, {
						prompt = "Icons> ",
						actions = {
							["default"] = function(selected)
								local icon = selected[1]:match("^(%S+)")
								vim.fn.setreg("+", icon)
								vim.notify("Copied icon: " .. icon)
							end,
						},
					})
				end,
				desc = "Icons",
			},
			{
				"<leader>sj",
				function()
					require("fzf-lua").jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>sk",
				function()
					require("fzf-lua").keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sl",
				function()
					require("fzf-lua").loclist()
				end,
				desc = "Location List",
			},
			{
				"<leader>sm",
				function()
					require("fzf-lua").marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>sM",
				function()
					require("fzf-lua").man_pages()
				end,
				desc = "Man Pages",
			},
			{
				"<leader>sp",
				function()
					-- Lazy plugin picker - custom implementation
					local plugins = require("lazy.core.config").plugins
					local items = {}
					for name, plugin in pairs(plugins) do
						local status = plugin._.loaded and "✓" or "○"
						table.insert(items, string.format("%s %s %s", status, name, plugin.dir or ""))
					end
					require("fzf-lua").fzf_exec(items, {
						prompt = "Plugins> ",
						actions = {
							["default"] = function(selected)
								local name = selected[1]:match("%S+%s+(%S+)")
								if name then
									vim.cmd("Lazy show " .. name)
								end
							end,
						},
					})
				end,
				desc = "Search for Plugin Spec",
			},
			{
				"<leader>sq",
				function()
					require("fzf-lua").quickfix()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>sR",
				function()
					require("fzf-lua").resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>su",
				function()
					-- Undo history - use telescope-undo or custom implementation
					-- For now, show a simple command history
					vim.cmd("UndotreeToggle")
				end,
				desc = "Undo History",
			},
			{
				"<leader>cs",
				function()
					require("fzf-lua").colorschemes()
				end,
				desc = "Colorschemes",
			},
			{
				"<leader>fh",
				function()
					-- Custom highlights search for snacks
					require("fzf-lua").highlights({ pattern = "Snacks" })
				end,
				desc = "Snacks Highlights",
			},
			-- LSP (MIGRATED TO FZF-LUA)
			{
				"<leader>ld",
				function()
					require("fzf-lua").lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"<leader>lc",
				function()
					require("fzf-lua").lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"<leader>lr",
				function()
					require("fzf-lua").lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"<leader>li",
				function()
					require("fzf-lua").lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"<leader>lt",
				function()
					require("fzf-lua").lsp_typedefs()
				end,
				desc = "Goto T[y]pe Definition",
			},
			{
				"<leader>ss",
				function()
					require("fzf-lua").lsp_document_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>sS",
				function()
					require("fzf-lua").lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},
			-- Other (NON-PICKER FUNCTIONALITY - KEEP AS IS)
			{
				"<leader>.",
				function()
					require("snacks").scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>S",
				function()
					require("snacks").scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
			{
				"<leader>nh",
				function()
					require("snacks").notifier.show_history()
				end,
				desc = "Notification History",
			},
			{
				"<leader>bd",
				function()
					require("snacks").bufdelete()
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>cR",
				function()
					require("snacks").rename.rename_file()
				end,
				desc = "Rename File",
			},
			{
				"<leader>gg",
				function()
					require("snacks").lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>nd",
				function()
					require("snacks").notifier.hide()
				end,
				desc = "Dismiss All Notifications",
			},
			{
				"<leader>/",
				function()
					require("snacks").terminal()
				end,
				desc = "Toggle Terminal",
			},
			{
				"<c-_>",
				function()
					require("snacks").terminal()
				end,
				desc = "which_key_ignore",
			},
			{
				"]]",
				function()
					require("snacks").words.jump(vim.v.count1)
				end,
				desc = "Next Reference",
				mode = { "n", "t" },
			},
			{
				"[[",
				function()
					require("snacks").words.jump(-vim.v.count1)
				end,
				desc = "Prev Reference",
				mode = { "n", "t" },
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				callback = function()
					-- Setup some globals for debugging (lazy-loaded)
					_G.dd = function(...)
						require("snacks").debug.inspect(...)
					end
					_G.bt = function()
						require("snacks").debug.backtrace()
					end
					-- Override print to use snacks for `:=` command
					if vim.fn.has("nvim-0.11") == 1 then
						vim.print = function(...)
							require("snacks").debug.inspect(...)
						end
					else
						vim.print = _G.dd
					end
					-- Create some toggle mappings
					require("snacks").toggle.option("spell", { name = "Spelling" }):map("<leader>us")
					require("snacks").toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
					require("snacks").toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>un")
					require("snacks").toggle.diagnostics():map("<leader>ud")
					require("snacks").toggle.line_number():map("<leader>ul")
					require("snacks").toggle
						.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
						:map("<leader>uc")
					require("snacks").toggle.treesitter():map("<leader>ut")
					require("snacks").toggle
						.option("background", { off = "light", on = "dark", name = "Dark Background" })
						:map("<leader>ub")
					require("snacks").toggle.inlay_hints():map("<leader>uh")
					require("snacks").toggle.indent():map("<leader>ui")
				end,
			})
		end,
	},
	-- end,
	{
		"folke/edgy.nvim",
		---@module 'edgy'
		---@param opts Edgy.Config
		opts = function(_, opts)
			for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
				opts[pos] = opts[pos] or {}
				table.insert(opts[pos], {
					ft = "snacks_terminal",
					size = { height = 0.4 },
					title = "%{b:snacks_terminal.id}: %{b:term_title}",
					filter = function(_buf, win)
						return vim.w[win].snacks_win
							and vim.w[win].snacks_win.position == pos
							and vim.w[win].snacks_win.relative == "editor"
							and not vim.w[win].trouble_preview
					end,
				})
			end
		end,
	},
	{
		"gbprod/yanky.nvim",
		opts = {
			ring = {
				history_length = 100,
				storage = "shada",
				storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db", -- Only for sqlite storage
				sync_with_numbered_registers = true,
				cancel_event = "update",
				ignore_registers = { "_" },
				update_register_on_cycle = false,
				permanent_wrapper = nil,
			},
			picker = {
				select = {
					action = nil, -- nil to use default put action
				},
			},
			system_clipboard = {
				sync_with_ring = true,
				clipboard_register = nil,
			},
			highlight = {
				on_put = true,
				on_yank = true,
				timer = 500,
			},
			preserve_cursor_position = {
				enabled = true,
			},
			textobj = {
				enabled = false,
			},
		},
		keys = {
			-- Yanky history using fzf-lua instead of snacks picker
			{
				"<leader>yh",
				function()
					local history = require("yanky.history").all()
					local items = {}
					for i, entry in ipairs(history) do
						local text = type(entry.regcontents) == "table"
							and table.concat(entry.regcontents, "\\n")
							or tostring(entry.regcontents)
						-- Limit preview length and escape special chars
						text = text:gsub("\n", "\\n"):sub(1, 100)
						table.insert(items, string.format("%d: %s", i, text))
					end

					require("fzf-lua").fzf_exec(items, {
						prompt = "Yanky History> ",
						actions = {
							["default"] = function(selected)
								local idx = tonumber(selected[1]:match("^(%d+):"))
								if idx and history[idx] then
									local entry = history[idx]
									vim.fn.setreg('"', entry.regcontents, entry.regtype)
									vim.cmd('normal! ""p')
								end
							end,
						},
						winopts = {
							height = 0.5,
							width = 0.8,
						},
					})
				end,
				desc = "Yanky History (FZF)",
			},
		},
	},
}