-- ╓────────────────────────────────────────────────────────────╖
-- ║ fzf-lua Configuration                                     ║
-- ║ Complete replacement for telescope and snacks pickers     ║
-- ╙────────────────────────────────────────────────────────────╜

return {
	{
		"ibhagwan/fzf-lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		cmd = "FzfLua",
		lazy = false, -- Load immediately for auto-session integration
		config = function()
			local fzf = require("fzf-lua")

			-- Configuration
			fzf.setup({
				-- Global options
				global_resume = true,
				global_resume_query = true,
				winopts = {
					height = 0.85,
					width = 0.90,
					row = 0.35,
					col = 0.50,
					border = "rounded",
					fullscreen = false,
					preview = {
						default = "bat",
						border = "border",
						wrap = "nowrap",
						hidden = "nohidden",
						vertical = "down:45%",
						horizontal = "right:50%",
						layout = "flex",
						flip_columns = 120,
						title = true,
						title_pos = "center",
						scrollbar = "float",
						scrolloff = "-2",
						scrollchars = {"█", "" },
						delay = 100,
						winopts = {
							number = true,
							relativenumber = false,
							cursorline = true,
							cursorlineopt = "both",
							cursorcolumn = false,
							signcolumn = "no",
							list = false,
							foldenable = false,
							foldmethod = "manual",
						},
					},
					on_create = function()
						-- Add custom keymaps for the fzf window
						vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
						vim.keymap.set("t", "<C-k>", "<Up>", { silent = true, buffer = true })
					end,
				},

				-- Keymaps (similar to telescope)
				keymap = {
					builtin = {
						["<F1>"] = "toggle-help",
						["<F2>"] = "toggle-fullscreen",
						["<F3>"] = "toggle-preview-wrap",
						["<F4>"] = "toggle-preview",
						["<F5>"] = "toggle-preview-ccw",
						["<F6>"] = "toggle-preview-cw",
						["<M-j>"] = "preview-page-down",
						["<M-k>"] = "preview-page-up",
						["<S-left>"] = "preview-reset",
					},
					fzf = {
						["ctrl-z"] = "abort",
						["ctrl-u"] = "unix-line-discard",
						["ctrl-f"] = "half-page-down",
						["ctrl-b"] = "half-page-up",
						["ctrl-a"] = "beginning-of-line",
						["ctrl-e"] = "end-of-line",
						["alt-a"] = "toggle-all",
						["f3"] = "toggle-preview-wrap",
						["f4"] = "toggle-preview",
						["shift-down"] = "preview-page-down",
						["shift-up"] = "preview-page-up",
						["ctrl-d"] = "preview-page-down",
						["ctrl-u"] = "preview-page-up",
						["ctrl-q"] = "select-all+accept",
					},
				},

				-- Actions
				actions = {
					files = {
						["default"] = fzf.actions.file_edit_or_qf,
						["ctrl-s"] = fzf.actions.file_split,
						["ctrl-v"] = fzf.actions.file_vsplit,
						["ctrl-t"] = fzf.actions.file_tabedit,
						["alt-q"] = fzf.actions.file_sel_to_qf,
						["alt-l"] = fzf.actions.file_sel_to_ll,
					},
					buffers = {
						["default"] = fzf.actions.buf_edit,
						["ctrl-s"] = fzf.actions.buf_split,
						["ctrl-v"] = fzf.actions.buf_vsplit,
						["ctrl-t"] = fzf.actions.buf_tabedit,
					},
				},

				-- Providers configuration
				files = {
					prompt = "Files❯ ",
					multiprocess = true,
					git_icons = true,
					file_icons = true,
					color_icons = true,
					find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
					rg_opts = [[--color=never --files --hidden --follow -g "!.git"]],
					fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
				},

				buffers = {
					prompt = "Buffers❯ ",
					file_icons = true,
					color_icons = true,
					sort_mru = true,
					sort_lastused = true,
					show_all_buffers = true,
					show_unloaded = true,
					cwd_only = false,
					cwd = nil,
					actions = {
						["ctrl-x"] = { fn = fzf.actions.buf_del, reload = true },
					},
				},

				grep = {
					prompt = "Rg❯ ",
					input_prompt = "Grep For❯ ",
					multiprocess = true,
					git_icons = true,
					file_icons = true,
					color_icons = true,
					grep_opts = "--binary-files=without-match --line-number --recursive --color=auto --perl-regexp -e",
					rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
					rg_glob = false,
					glob_flag = "--iglob",
					glob_separator = "%s%-%-",
				},

				git = {
					files = {
						prompt = "GitFiles❯ ",
						cmd = "git ls-files --exclude-standard",
						multiprocess = true,
						git_icons = true,
						file_icons = true,
						color_icons = true,
					},
					status = {
						prompt = "GitStatus❯ ",
						cmd = "git -c color.status=false status --porcelain=v1 -z",
						file_icons = true,
						git_icons = true,
						color_icons = true,
						actions = {
							["right"] = { fn = fzf.actions.git_unstage, reload = true },
							["left"] = { fn = fzf.actions.git_stage, reload = true },
							["ctrl-x"] = { fn = fzf.actions.git_reset, reload = true },
						},
						preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
					},
					commits = {
						prompt = "Commits❯ ",
						cmd = [[git log --color --pretty=format:"%C(yellow)%h%Creset -%C(red)%d%Creset %s %C(green)(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --all]],
						preview = "git show --pretty='%Cred%H%n%Cblue%an <%ae>%n%C(yellow)%cD%n%Cgreen%s' --color {1}",
						actions = {
							["default"] = fzf.actions.git_checkout,
							["ctrl-y"] = function(selected)
								vim.fn.setreg("+", selected[1]:match("[^ ]+"))
							end,
						},
					},
					branches = {
						prompt = "Branches❯ ",
						cmd = "git branch --all --color",
						preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
						actions = {
							["default"] = fzf.actions.git_switch,
							["ctrl-x"] = { fn = fzf.actions.git_branch_del, reload = true },
							["ctrl-a"] = { fn = fzf.actions.git_branch_add, reload = true },
						},
					},
					stash = {
						prompt = "Stash❯ ",
						cmd = "git --no-pager stash list",
						preview = "git --no-pager stash show --patch --color {1}",
						actions = {
							["default"] = fzf.actions.git_stash_apply,
							["ctrl-x"] = { fn = fzf.actions.git_stash_drop, reload = true },
						},
					},
				},

				-- LSP providers
				lsp = {
					prompt_postfix = "❯ ",
					cwd_only = false,
					async = true,
					file_icons = true,
					color_icons = true,
					git_icons = false,
					lsp_icons = true,
					ui_select = true,
					symbol_style = 1,
					symbol_hl_prefix = "CmpItemKind",
					symbol_fmt = function(s) return "["..s.."]" end,
				},

				-- Oldfiles
				oldfiles = {
					prompt = "History❯ ",
					cwd_only = false,
					stat_file = true,
					include_current_session = false,
				},

				-- Quickfix/Location list
				quickfix = {
					file_icons = true,
					git_icons = true,
				},

				loclist = {
					file_icons = true,
					git_icons = true,
				},

				-- Help tags
				helptags = {
					prompt = "Help❯ ",
					winopts = {
						height = 0.65,
						width = 0.80,
						preview = {
							layout = "vertical",
							vertical = "down:45%",
						},
					},
				},

				-- Man pages
				manpages = {
					prompt = "Man❯ ",
					cmd = "man -k .",
					actions = {
						["default"] = fzf.actions.man,
						["ctrl-v"] = function(selected)
							vim.cmd("vertical Man " .. selected[1]:match("^[^%s]+"))
						end,
					},
				},

				-- Colorschemes
				colorschemes = {
					prompt = "Colorschemes❯ ",
					live_preview = true,
					actions = {
						["default"] = fzf.actions.colorscheme,
					},
					winopts = {
						height = 0.40,
						width = 0.60,
					},
				},

				-- Marks
				marks = {
					prompt = "Marks❯ ",
					actions = {
						["default"] = fzf.actions.goto_mark,
					},
					previewer = "builtin",
				},

				-- Registers
				registers = {
					prompt = "Registers❯ ",
					ignore_empty = true,
				},

				-- Tags
				tags = {
					prompt = "Tags❯ ",
					ctags_file = nil,
					multiprocess = true,
					file_icons = true,
					git_icons = true,
					color_icons = true,
					rg_opts = "--no-heading --color=always --smart-case",
				},

				-- Keymaps
				keymaps = {
					prompt = "Keymaps❯ ",
					winopts = {
						height = 0.80,
						width = 0.85,
					},
					actions = {
						["default"] = function(selected)
							local mode, lhs = selected[1]:match("^(%S+)%s+(%S+)")
							if mode and lhs then
								local key = vim.api.nvim_replace_termcodes(lhs, true, false, true)
								vim.api.nvim_feedkeys(key, mode, false)
							end
						end,
					},
				},

				-- Commands
				commands = {
					prompt = "Commands❯ ",
					actions = {
						["default"] = fzf.actions.ex_run,
						["ctrl-e"] = function(selected)
							vim.fn.setreg("+", selected[1])
						end,
					},
				},

				-- Command history
				command_history = {
					prompt = "History❯ ",
					actions = {
						["default"] = fzf.actions.ex_run_cr,
						["ctrl-e"] = function(selected)
							vim.cmd("norm! :" .. selected[1])
						end,
					},
				},

				-- Search history
				search_history = {
					prompt = "Search❯ ",
					actions = {
						["default"] = fzf.actions.search,
						["ctrl-e"] = function(selected)
							vim.cmd("norm! /" .. selected[1])
						end,
					},
				},

				-- Spell suggestions
				spell_suggest = {
					prompt = "Spell❯ ",
					actions = {
						["default"] = fzf.actions.spell_apply,
					},
				},

				-- Jumplist
				jumps = {
					prompt = "Jumps❯ ",
					cmd = "jumps",
					actions = {
						["default"] = fzf.actions.goto_jump,
					},
				},

				-- Changes
				changes = {
					prompt = "Changes❯ ",
					cmd = "changes",
					previewer = "builtin",
				},

				-- Tagstack
				tagstack = {
					prompt = "Tagstack❯ ",
					file_icons = true,
					color_icons = true,
				},

				-- Highlights
				highlights = {
					prompt = "Highlights❯ ",
				},

				-- Icons (for nvim-web-devicons)
				nvim = {
					marks = {
						prompt = "Marks❯ ",
					},
					jumps = {
						prompt = "Jumps❯ ",
					},
					commands = {
						prompt = "Commands❯ ",
					},
					keymaps = {
						prompt = "Keymaps❯ ",
					},
				},
			})

			-- Custom fzf-lua functions for auto-session integration
			_G.fzf_session_menu = function(sessions, on_select)
				fzf.fzf_exec(sessions, {
					prompt = "Sessions> ",
					actions = {
						["default"] = function(selected)
							if on_select and selected[1] then
								on_select(selected[1])
							end
						end,
					},
					winopts = {
						height = 0.4,
						width = 0.5,
						row = 0.5,
						col = 0.1,
					},
				})
			end

			-- Git status display for landing page
			_G.fzf_git_status_display = function()
				fzf.git_status({
					winopts = {
						height = 0.3,
						width = 0.4,
						row = 0.2,
						col = 0.55,
						preview = { hidden = "hidden" },
					},
				})
			end

			-- Recent files display for landing page
			_G.fzf_recent_files = function(cwd)
				fzf.oldfiles({
					cwd = cwd,
					winopts = {
						height = 0.3,
						width = 0.4,
						row = 0.55,
						col = 0.55,
						preview = { hidden = "hidden" },
					},
				})
			end

			-- Git branches for landing page
			_G.fzf_git_branches_menu = function()
				fzf.git_branches({
					winopts = {
						height = 0.25,
						width = 0.4,
						row = 0.5,
						col = 0.55,
						preview = { hidden = "hidden" },
					},
				})
			end
		end,
	},
}