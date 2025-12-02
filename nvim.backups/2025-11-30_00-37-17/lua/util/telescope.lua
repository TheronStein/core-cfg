return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			"nvim-tree/nvim-web-devicons",
			"danielpieper/telescope-tmuxinator.nvim",
			"debugloop/telescope-undo.nvim",
			"natecraddock/workspaces.nvim",
			"ahmedkhalf/project.nvim",
			"nvim-telescope/telescope-project.nvim",
			"lpoto/telescope-docker.nvim",
			"alduraibi/telescope-glyph.nvim",
			"lpoto/telescope-tasks.nvim",
			"cbochs/grapple.nvim",
			"piersolenski/import.nvim",
			"fhill2/telescope-ultisnips.nvim",
			"nvim-telescope/telescope-ghq.nvim",
			"OliverChao/telescope-picker-list.nvim",
			"nvim-telescope/telescope-github.nvim",
			"paopaol/telescope-git-diffs.nvim",
			"agoodshort/telescope-git-submodules.nvim",
			"Snikimonkd/telescope-git-conflicts.nvim",
			"zigotica/telescope-docker-commands.nvim",
			"tsakirist/telescope-lazy.nvim",
			"akinsho/nvim-toggleterm.lua",
			"kkharji/sqlite.lua",
			"ryanmsnyder/toggleterm-manager.nvim",
		},
		cmd = "Telescope",
		config = function()
			-- Fix for plenary path nil errors
			local Path = require("plenary.path")
			local original_new = Path.new
			Path.new = function(...)
				local args = { ... }
				local filtered = {}
				for _, arg in ipairs(args) do
					if arg ~= nil and arg ~= "" then
						table.insert(filtered, arg)
					end
				end
				if #filtered == 0 then
					filtered = { vim.fn.getcwd() }
				end
				return original_new(unpack(filtered))
			end

			local telescope = require("telescope")
			local actions = require("telescope.actions")
			telescope.setup({
				defaults = {
					prompt_prefix = " ",
					-- selection_caret = " ",
					path_display = { "truncate" },
					sorting_strategy = "ascending",
					-- Add these to fix indentation issues
					wrap_results = false,
					scroll_strategy = "limit",
					dynamic_preview_title = false,
					selection_strategy = "reset",
					winblend = 0,
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
							results_width = 0.8,
						},
						vertical = {
							mirror = false,
						},
						width = 0.87,
						height = 0.80,
						preview_cutoff = 120,
					},
					mappings = {
						i = {
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-c>"] = actions.close,
							["<Down>"] = actions.move_selection_next,
							["<Up>"] = actions.move_selection_previous,
							["<CR>"] = actions.select_default,
							["<C-x>"] = actions.select_horizontal,
							["<C-v>"] = actions.select_vertical,
							["<C-t>"] = actions.select_tab,
							["<C-u>"] = actions.preview_scrolling_up,
							["<C-d>"] = actions.preview_scrolling_down,
							["<PageUp>"] = actions.results_scrolling_up,
							["<PageDown>"] = actions.results_scrolling_down,
							["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
							["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
							["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
							["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-l>"] = actions.complete_tag,
						},
						n = {
							["<esc>"] = actions.close,
							["<CR>"] = actions.select_default,
							["<C-x>"] = actions.select_horizontal,
							["<C-v>"] = actions.select_vertical,
							["<C-t>"] = actions.select_tab,
							["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
							["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
							["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
							["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["j"] = actions.move_selection_next,
							["k"] = actions.move_selection_previous,
							["H"] = actions.move_to_top,
							["M"] = actions.move_to_middle,
							["L"] = actions.move_to_bottom,
							["<Down>"] = actions.move_selection_next,
							["<Up>"] = actions.move_selection_previous,
							["gg"] = actions.move_to_top,
							["G"] = actions.move_to_bottom,
							["<C-u>"] = actions.preview_scrolling_up,
							["<C-d>"] = actions.preview_scrolling_down,
							["<PageUp>"] = actions.results_scrolling_up,
							["<PageDown>"] = actions.results_scrolling_down,
							["?"] = actions.which_key,
						},
					},
				}, -- End of defaults

				pickers = {
					find_files = {
						-- Remove theme or use a different one
						-- theme = "dropdown",
						theme = "dropdown", -- Try ivy theme instead
						previewer = true,
						hidden = false,
						find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
						-- Add fixed layout config for this picker
						layout_config = {
							height = 0.4,
						},
					},
					live_grep = {
						theme = "dropdown",
						-- theme = "ivy", -- Change to ivy
						layout_config = {
							height = 0.4,
						},
					},
					buffers = {
						-- theme = "dropdown",
						theme = "ivy", -- Change to ivy
						previewer = true,
						initial_mode = "normal",
						layout_config = {
							height = 0.4,
						},
						mappings = {
							i = {
								["<C-d>"] = actions.delete_buffer,
							},
							n = {
								["dd"] = actions.delete_buffer,
							},
						},
					},
				}, -- End of pickers (this was missing!)

				extensions = {
					picker_list = {
						-- some picker options
						opts = {
							project = { display_type = "full" },
							emoji = require("telescope.themes").get_dropdown({}),
							luasnip = require("telescope.themes").get_dropdown({}),
							notify = require("telescope.themes").get_dropdown({}),
						},
						-- excluded pickers which will not list
						excluded_pickers = {
							"fzf",
							"fd",
						},
						-- user defined pickers
						user_pickers = {
							{
								"todo-comments",
								function()
									vim.cmd([[TodoTelescope theme=dropdown]])
								end,
							},
							{
								"urlview local",
								function()
									vim.cmd([[UrlView]])
								end,
							},
							{
								"urlview lazy",
								function()
									vim.cmd([[UrlView lazy]])
								end,
							},
						},
					}, -- end picker-list
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					undo = {
						use_delta = true,
						side_by_side = true,
						layout_strategy = "vertical",
						layout_config = {
							preview_height = 0.8,
						},
						vim_diff_opts = {
							ctxlen = vim.o.scrolloff,
						},
						entry_format = "state #$ID, $STAT, $TIME",
						time_format = "",
						saved_only = false,
					},
					tmuxinator = {
						select_action = "switch", -- | 'stop' | 'kill'
						stop_action = "stop", -- | 'kill'
						disable_icons = false,
					},

					docker = {
						-- These are the default values
						theme = "ivy",
						binary = "docker", -- in case you want to use podman or something
						compose_binary = "docker compose",
						buildx_binary = "docker buildx",
						machine_binary = "docker-machine",
						log_level = vim.log.levels.INFO,
						init_term = "tabnew", -- "vsplit new", "split new", ...
						-- NOTE: init_term may also be a function that receives
						-- a command, a table of env. variables and cwd as input.
						-- This is intended only for advanced use, in case you want
						-- to send the env. and command to a tmux terminal or floaterm
						-- or something other than a built in terminal.
					},
					glyph = {
						action = function(glyph)
							-- argument glyph is a table.
							-- {name="", value="", category="", description=""}

							vim.fn.setreg("*", glyph.value)
							print([[Press p or "*p to paste this glyph]] .. glyph.value)

							-- insert glyph when picked
							-- vim.api.nvim_put({ glyph.value }, 'c', false, true)
						end,
					},
					-- NOTE: this setup is optional
					tasks = {
						theme = "ivy",
						output = {
							style = "float", -- "split" | "float" | "tab"
							layout = "center", -- "left" | "right" | "center" | "below" | "above"
							scale = 0.4, -- output window to editor size ratio
							-- NOTE: scale and "center" layout are only relevant when style == "float"
						},
						env = {
							cargo = {
								-- Example environment used when running cargo projects
								RUST_LOG = "debug",
								-- ...
							},
							-- ...
						},
						binary = {
							-- Example binary used when running python projects
							python = "python3",
							-- ...
						},
					},
					import = {
						-- The picker to use
						picker = "telescope", -- Fixed: removed invalid syntax "telescope" | "snacks" | "fzf-lua"
						-- Imports can be added at a specified line whilst keeping the cursor in place
						insert_at_top = true,
						-- Optionally support additional languages or modify existing languages...
						custom_languages = {},
					},
					git_submodules = {
						git_cmd = "lazygit",
						previewer = true,
						terminal_id = 9,
						terminal_display_name = "Lazygit",
						diffview_keymap = "<C-d>",
					},
					git_diffs = {
						enable_preview_diff = true,
					},
					media_files = {
						-- filetypes whitelist
						-- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
						filetypes = { "png", "webp", "jpg", "jpeg" },
						-- find command (defaults to `fd`)
						find_cmd = "rg",
					},
				}, -- End of extensions
			}) -- End of telescope.setup

			local function safe_load_extension(name, setup_fn)
				local ok, err = pcall(function()
					if setup_fn then
						setup_fn()
					end
					telescope.load_extension(name)
				end)
				if not ok then
					vim.notify(
						string.format("Failed to load telescope extension '%s': %s", name, err),
						vim.log.levels.WARN
					)
				end
			end

			-- Load extensions with error handling
			safe_load_extension("fzf")
			safe_load_extension("undo")
			safe_load_extension("workspaces")
			safe_load_extension("project")
			safe_load_extension("projects")
			safe_load_extension("tmuxinator")
			safe_load_extension("glyph")
			safe_load_extension("tasks")
			safe_load_extension("picker_list")
			safe_load_extension("git_submodules")
			safe_load_extension("conflicts")
			safe_load_extension("git_diffs")
			safe_load_extension("ultisnips")
			safe_load_extension("ghq")
			safe_load_extension("gh")
			safe_load_extension("docker_commands")
			safe_load_extension("grapple")
		end,
	},
}
