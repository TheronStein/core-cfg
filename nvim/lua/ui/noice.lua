return {
	{
		"rcarriga/nvim-notify",
		opts = {
			stages = "fade_in_slide_out",
			render = "default",
			timeout = 3000,
			background_colour = "NotifyBackground",
			icons = {
				ERROR = "",
				WARN = "",
				INFO = "󰋼",
				DEBUG = "",
				TRACE = "✎",
			},
			max_height = function()
				return math.floor(vim.o.lines * 0.90)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.90)
			end,
			top_down = true,
		},
		init = function()
			vim.notify = require("notify")
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			format = {
				level = {
					icons = {
						error = "",
						warn = "",
						info = "󰋼",
						debug = "",
						trace = "✎ ",
					},
				},
			},
			views = {
				notify = {
					backend = "notify",
					fallback = "mini",
					format = "notify",
					replace = false,
					merge = false,
				},
				popup = {
					backend = "popup",
					enter = true,
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					position = {
						row = "50%",
						col = "50%",
					},
					size = {
						width = "90%",
						height = "90%",
					},
					win_options = {
						wrap = true,
						linebreak = true,
						winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
						cursorline = true,
					},
					format = "details",
					lang = "markdown",
					close = {
						keys = { "q", "<Esc>" },
					},
				},
				cmdline_popup = {
					position = {
						row = "95%", -- Position near bottom of screen
						col = "50%",
					},
					size = {
						width = 80,
						height = "auto",
					},
					border = {
						style = "rounded",
					},
				},
				popupmenu = {
					relative = "editor",
					position = {
						row = "85%", -- Position above the command line
						col = "50%",
					},
					size = {
						width = 80,
						height = 10,
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
					},
				},
				split = {
					backend = "split",
					enter = true,
					relative = "editor",
					position = "bottom",
					size = "40%",
					close = {
						keys = { "q" },
					},
					win_options = {
						wrap = true,
						linebreak = true,
					},
				},
			},
			lsp = {
				-- Override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					-- override the default lsp markdown formatter with Noice
					["vim.lsp.util.convert_input_to_markdown_lines"] = false,
					-- override the lsp markdown formatter with Noice
					["vim.lsp.util.stylize_markdown"] = false,
					-- override cmp documentation with Noice (needs the other options to work)
					["cmp.entry.get_documentation"] = false,
				},
				hover = { enabled = true },
				signature = { enabled = true },
				-- Let Trouble handle diagnostics, Noice handles messages
				progress = {
					enabled = true,
					format = "lsp_progress",
					format_done = "lsp_progress_done",
				},
			},
			-- You can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- Use a classic bottom cmdline for search
				command_palette = true, -- Position the cmdline and popupmenu together
				long_message_to_split = false, -- Use popup instead of split for long messages
				inc_rename = false, -- Enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- Add a border to hover docs and signature help
			},
			cmdline = {
				enabled = true,
				view = "cmdline_popup", -- Use popup for command line
			},
			popupmenu = {
				enabled = true, -- Use nui backend for popupmenu
				backend = "nui",
			},
			routes = {
				-- Skip "written" messages
				{
					filter = {
						event = "msg_show",
						kind = "",
						find = "written",
					},
					opts = { skip = true },
				},
				-- Route notifications to nvim-notify floating windows
				{
					filter = {
						event = "notify",
					},
					view = "notify",
				},
				-- Route LSP messages to notify
				{
					filter = {
						event = "lsp",
						kind = "message",
					},
					view = "notify",
				},
			},
			commands = {
				-- :Noice last
				last = {
					view = "popup",
					opts = {
						enter = true,
						format = "details",
						buf_options = { filetype = "noice" },
					},
					filter = {
						any = {
							{ event = "notify" },
							{ error = true },
							{ warning = true },
							{ event = "msg_show", kind = { "" } },
							{ event = "lsp", kind = "message" },
						},
					},
					filter_opts = { count = 1 },
				},
				-- :Noice errors
				errors = {
					view = "popup",
					opts = {
						enter = true,
						format = "details",
						buf_options = { filetype = "noice" },
					},
					filter = { error = true },
					filter_opts = { reverse = true },
				},
				all = {
					view = "popup",
					opts = {
						enter = true,
						format = "details",
						buf_options = { filetype = "noice" },
					},
					filter = {},
				},
				-- :Noice history
				history = {
					view = "popup",
					opts = {
						enter = true,
						format = "details",
						buf_options = { filetype = "noice" },
					},
					filter = {
						any = {
							{ event = "notify" },
							{ error = true },
							{ warning = true },
							{ event = "msg_show", kind = { "" } },
							{ event = "lsp", kind = "message" },
						},
					},
				},
			},
		},
		init = function()
			vim.o.wildmode = "longest:full,full"
			vim.o.wildoptions = "pum"
		end,
		keys = {},
	},
}
