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
				enabled = true,
				win = {
					input = {
						bo = {
							filetype = "snacks_picker_input",
						},
						wo = {
							winhl = "Normal:PickerInputNormal,FloatBorder:PickerInputBorderNormal,CursorLine:Visual",
							cursorline = true,
							smoothscroll = true, -- Enable native smooth scrolling
						},
						border = "double",
						title = "  SEARCH (press 'i' to type)  ",
						title_pos = "center",
						keys = {
							["i"] = {
								-- Disabled to avoid accidental mode switchin
								function()
									vim.cmd("startinsert")
									vim.wo.winhl =
										"Normal:PickerInputInsert,FloatBorder:PickerInputBorderInsert,CursorLine:Visual"
									vim.api.nvim_win_set_config(0, { title = "  ⚡ TYPING MODE ⚡  " })
								end,
								mode = "n",
							},
							["a"] = {
								function()
									vim.cmd("startinsert!")
									vim.wo.winhl =
										"Normal:PickerInputInsert,FloatBorder:PickerInputBorderInsert,CursorLine:Visual"
									vim.api.nvim_win_set_config(0, { title = "  ⚡ TYPING MODE ⚡  " })
								end,
								mode = "n",
							},
							["<Esc>"] = {
								function()
									vim.cmd("stopinsert")
									vim.wo.winhl =
										"Normal:PickerInputNormal,FloatBorder:PickerInputBorderNormal,CursorLine:Visual"
									vim.api.nvim_win_set_config(0, { title = "  SEARCH (press 'i' to type)  " })
								end,
								mode = "i",
							},
							["j"] = { "list_down", mode = "n" },
							["k"] = { "list_up", mode = "n" },
							["<C-d>"] = { "list_scroll_down", mode = "n" },
							["<C-u>"] = { "list_scroll_up", mode = "n" },
							["gg"] = { "list_top", mode = "n" },
							["G"] = { "list_bottom", mode = "n" },
							["<CR>"] = { "confirm", mode = { "n", "i" } },
							["<C-c>"] = { "close", mode = { "n", "i" } },
							["q"] = { "close", mode = "n" },
							["<Tab>"] = { "toggle_focus", mode = "n" },
							["<C-p>"] = { "toggle_preview", mode = "n" },
						},
					},
				},
			},
		},
		keys = {
			-- { "<leader>snh", function() Snacks.notifier.show_history() end, desc = "Notification History" },
			-- { "<leader>snd", function() Snacks.notifier.hide() end, desc = "Dismiss Notifications" },
			-- Top Pickers & Explorer
			{
				"<leader><space>",
				function()
					require("snacks").picker.smart()
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>fg",
				function()
					require("snacks").picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>fc",
				function()
					require("snacks").picker.command_history()
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
			-- find
			{
				"<leader>fb",
				function()
					require("snacks").picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fc",
				function()
					require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},
			{
				"<leader>ff",
				function()
					require("snacks").picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fg",
				function()
					require("snacks").picker.git_files()
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>fp",
				function()
					require("snacks").picker.projects()
				end,
				desc = "Projects",
			},
			{
				"<leader>fr",
				function()
					require("snacks").picker.recent()
				end,
				desc = "Recent",
			},
			-- git
			{
				"<leader>gb",
				function()
					require("snacks").picker.git_branches()
				end,
				desc = "Git Branches",
			},
			{
				"<leader>gl",
				function()
					require("snacks").picker.git_log()
				end,
				desc = "Git Log",
			},
			{
				"<leader>gL",
				function()
					require("snacks").picker.git_log_line()
				end,
				desc = "Git Log Line",
			},
			{
				"<leader>gs",
				function()
					require("snacks").picker.git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>gS",
				function()
					require("snacks").picker.git_stash()
				end,
				desc = "Git Stash",
			},
			{
				"<leader>gd",
				function()
					require("snacks").picker.git_diff()
				end,
				desc = "Git Diff (Hunks)",
			},
			{
				"<leader>gf",
				function()
					require("snacks").picker.git_log_file()
				end,
				desc = "Git Log File",
			},
			-- Grep
			{
				"<leader>sb",
				function()
					require("snacks").picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sB",
				function()
					require("snacks").picker.grep_buffers()
				end,
				desc = "Grep Open Buffers",
			},
			{
				"<leader>sg",
				function()
					require("snacks").picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>sw",
				function()
					require("snacks").picker.grep_word()
				end,
				desc = "Visual selection or word",
				mode = { "n", "x" },
			},
			-- search
			{
				'<leader>s"',
				function()
					require("snacks").picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>s/",
				function()
					require("snacks").picker.search_history()
				end,
				desc = "Search History",
			},
			{
				"<leader>sa",
				function()
					require("snacks").picker.autocmds()
				end,
				desc = "Autocmds",
			},
			{
				"<leader>sb",
				function()
					require("snacks").picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sc",
				function()
					require("snacks").picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>sC",
				function()
					require("snacks").picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					require("snacks").picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sD",
				function()
					require("snacks").picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>sh",
				function()
					require("snacks").picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sH",
				function()
					require("snacks").picker.highlights()
				end,
				desc = "Highlights",
			},
			{
				"<leader>si",
				function()
					require("snacks").picker.icons()
				end,
				desc = "Icons",
			},
			{
				"<leader>sj",
				function()
					require("snacks").picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>sk",
				function()
					require("snacks").picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sl",
				function()
					require("snacks").picker.loclist()
				end,
				desc = "Location List",
			},
			{
				"<leader>sm",
				function()
					require("snacks").picker.marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>sM",
				function()
					require("snacks").picker.man()
				end,
				desc = "Man Pages",
			},
			{
				"<leader>sp",
				function()
					require("snacks").picker.lazy()
				end,
				desc = "Search for Plugin Spec",
			},
			{
				"<leader>sq",
				function()
					require("snacks").picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>sR",
				function()
					require("snacks").picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>su",
				function()
					require("snacks").picker.undo()
				end,
				desc = "Undo History",
			},
			{
				"<leader>cs",
				function()
					require("snacks").picker.colorschemes()
				end,
				desc = "Colorschemes",
			},
			{
				"<leader>fh",
				function()
					require("snacks").picker.highlights({ pattern = "hl_group:^require('snacks')" })
				end,
				desc = "Snacks Highlights",
			},
			-- LSP
			{
				"<leader>ld",
				function()
					require("snacks").picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"<leader>lc",
				function()
					require("snacks").picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"<leader>lr",
				function()
					require("snacks").picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"<leader>li",
				function()
					require("snacks").picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"<leader>lt",
				function()
					require("snacks").picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			{
				"<leader>ss",
				function()
					require("snacks").picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>sS",
				function()
					require("snacks").picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},
			-- Other
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
			-- This keymap uses a function that requires the snacks picker
			{
				"<leader>yh",
				function()
					-- Check if snacks is loaded before calling it
					if require("lazy.core.config").plugins["folke/snacks.nvim"] then
						-- Feed yanky's history data into the snacks picker UI
						require("snacks").picker.select({
							title = "Yanky History",
							source = require("yanky.history").get_history,
							-- Optional: add custom layout/preview options here
						})
					end
				end,
				desc = "Yanky History Snacks Picker",
			},
		},
	},
}

-- return {
--
--
--
--   "gbprod/yanky.nvim",
-- 	event = "VeryLazy",
-- 	dependencies = { "folke/snacks.nvim" },
-- 	opts = {
-- 		ring = {
-- 			history_length = 100,
-- 			storage = "shada",
-- 			storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db",
-- 			sync_with_numbered_registers = true,
-- 			cancel_event = "update",
-- 			ignore_registers = { "_" },
-- 			update_register_on_cycle = false,
-- 			permanent_wrapper = nil,
-- 		},
-- 		picker = {
-- 			select = {
-- 				action = nil,
-- 			},
-- 		},
-- 		system_clipboard = {
-- 			sync_with_ring = true,
-- 			clipboard_register = nil,
-- 		},
-- 		highlight = {
-- 			on_put = true,
-- 			on_yank = true,
-- 			timer = 500,
-- 		},
-- 		preserve_cursor_position = {
-- 			enabled = true,
-- 		},
-- 		textobj = {
-- 			enabled = false,
-- 		},
-- 	},
-- 	keys = {
-- 		{
-- 			"<leader>yh",
-- 			function()
-- 				local yanky_history = require("yanky.history").all()
-- 				local items = {}
--
-- 				for _, entry in ipairs(yanky_history) do
-- 					table.insert(items, {
-- 						text = entry.regcontents,
-- 						regtype = entry.regtype,
-- 					})
-- 				end
--
-- 				require("snacks").picker.pick({
-- 					title = "Yanky History",
-- 					items = items,
-- 					format = function(item)
-- 						-- Display first line of yanked text
-- 						local text = item.text
-- 						if type(text) == "table" then
-- 							text = table.concat(text, "\n")
-- 						end
-- 						return text:gsub("\n", " ")
-- 					end,
-- 					confirm = function(item)
-- 						vim.fn.setreg('"', item.text, item.regtype)
-- 						vim.cmd('normal! ""p')
-- 					end,
-- 				})
-- 			end,
-- 			desc = "Yanky History (Snacks Picker)",
-- 		},
-- 	},
-- }
--
