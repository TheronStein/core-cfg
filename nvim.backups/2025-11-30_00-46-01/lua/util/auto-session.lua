-- ╓────────────────────────────────────────────────────────────╖
-- ║ Auto-Session Configuration                                ║
-- ║ Git-aware session management with root detection          ║
-- ╙────────────────────────────────────────────────────────────╜

return {
	{
		"rmagatti/auto-session",
		lazy = false,
		dependencies = {
			"nvim-telescope/telescope.nvim", -- Optional integration
		},
		config = function()
			local auto_session = require("auto-session")

			-- Session directory
			local session_dir = vim.fn.expand("~/.core/.sys/cfg/nvim/.data/sessions/")

			-- Create session directory if it doesn't exist
			vim.fn.mkdir(session_dir, "p")

			-- Configuration
			auto_session.setup({
				-- Core settings
				auto_session_enabled = true,
				auto_save_enabled = true,
				auto_restore_enabled = false, -- We'll control restoration via landing page
				auto_create_enabled = true,

				-- Session directory
				auto_session_root_dir = session_dir,

				-- Session options to save
				session_options = {
					"blank",
					"buffers",
					"curdir",
					"folds",
					"help",
					"tabpages",
					"winsize",
					"winpos",
					"terminal",
					"localoptions",
				},

				-- Bypass saving session if only certain filetypes are open
				bypass_save_filetypes = {
					"alpha",
					"dashboard",
					"lazy",
					"mason",
					"neo-tree",
					"NvimTree",
					"Outline",
					"toggleterm",
					"Trouble",
					"undotree",
				},

				-- Custom session name function (git-aware)
				auto_session_use_git_branch = false, -- We'll handle this ourselves
				auto_session_create_enabled = function()
					local cmd = "git rev-parse --is-inside-work-tree 2>/dev/null"
					return vim.fn.system(cmd) == "true\n"
				end,

				-- Suppress session restore/create messages
				auto_session_suppress_dirs = {
					"~/",
					"~/Downloads",
					"~/Documents",
					"~/Desktop",
					"/",
				},

				-- Log level
				log_level = "error",

				-- Pre/post hooks
				pre_save_cmds = {
					function()
						-- Close all floating windows before saving
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							local config = vim.api.nvim_win_get_config(win)
							if config.relative ~= "" then
								vim.api.nvim_win_close(win, false)
							end
						end
						-- Clear search highlight
						vim.cmd("nohlsearch")
					end,
				},

				post_save_cmds = {},
				pre_restore_cmds = {},
				post_restore_cmds = {
					function()
						-- Refresh file explorer if it's open
						if vim.bo.filetype == "neo-tree" or vim.bo.filetype == "NvimTree" then
							vim.cmd("e")
						end
					end,
				},

				-- Delete old sessions
				pre_cwd_changed_cmds = {},
				post_cwd_changed_cmds = {
					function()
						require("auto-session").SaveSession()
					end,
				},
			})

			-- Custom functions for session management
			local M = {}

			-- Get session name based on git repo or directory
			M.get_session_name = function()
				local cwd = vim.fn.getcwd()
				local is_git = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true")

				if is_git then
					-- Get git root directory
					local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
					if git_root ~= "" then
						-- Get repo name from git root
						local repo_name = vim.fn.fnamemodify(git_root, ":t")
						-- Get current branch
						local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
						if branch == "" then
							branch = "detached"
						end
						return string.format("%s__%s", repo_name, branch)
					end
				end

				-- Fallback to directory name
				return vim.fn.fnamemodify(cwd, ":t")
			end

			-- List sessions for current root
			M.list_root_sessions = function()
				local sessions = {}
				local session_files = vim.fn.globpath(session_dir, "*.vim", 0, 1)
				local current_root = M.get_session_name():gsub("__.*", "") -- Get root part only

				for _, file in ipairs(session_files) do
					local name = vim.fn.fnamemodify(file, ":t:r")
					if name:match("^" .. vim.pesc(current_root)) then
						table.insert(sessions, name)
					end
				end

				-- Limit to MAX_SESSIONS
				local max_sessions = vim.g.max_sessions or 5
				if #sessions > max_sessions then
					-- Sort by modification time and keep only newest
					table.sort(sessions, function(a, b)
						local file_a = session_dir .. a .. ".vim"
						local file_b = session_dir .. b .. ".vim"
						return vim.fn.getftime(file_a) > vim.fn.getftime(file_b)
					end)
					-- Remove old sessions
					for i = max_sessions + 1, #sessions do
						vim.fn.delete(session_dir .. sessions[i] .. ".vim")
						sessions[i] = nil
					end
				end

				return sessions
			end

			-- Create new session with custom name
			M.create_session = function(name)
				if not name or name == "" then
					name = M.get_session_name()
				end
				local timestamp = os.date("%Y%m%d_%H%M%S")
				local session_name = string.format("%s__%s", name, timestamp)
				vim.cmd("mksession! " .. session_dir .. session_name .. ".vim")
				vim.notify("Session created: " .. session_name, vim.log.levels.INFO)
			end

			-- Save current session
			M.save_session = function()
				local current_session = vim.v.this_session
				if current_session and current_session ~= "" then
					vim.cmd("mksession! " .. current_session)
					vim.notify("Session saved: " .. vim.fn.fnamemodify(current_session, ":t:r"), vim.log.levels.INFO)
				else
					M.create_session()
				end
			end

			-- Load session
			M.load_session = function(session_name)
				local session_file = session_dir .. session_name .. ".vim"
				if vim.fn.filereadable(session_file) == 1 then
					vim.cmd("source " .. session_file)
					vim.v.this_session = session_file
					vim.notify("Session loaded: " .. session_name, vim.log.levels.INFO)
				else
					vim.notify("Session not found: " .. session_name, vim.log.levels.ERROR)
				end
			end

			-- Delete session
			M.delete_session = function(session_name)
				local session_file = session_dir .. session_name .. ".vim"
				if vim.fn.filereadable(session_file) == 1 then
					vim.fn.delete(session_file)
					vim.notify("Session deleted: " .. session_name, vim.log.levels.INFO)
				end
			end

			-- Quit and delete current session
			M.quit_and_delete = function()
				local current_session = vim.v.this_session
				if current_session and current_session ~= "" then
					vim.fn.delete(current_session)
				end
				vim.cmd("qa!")
			end

			-- List all session types (roots)
			M.list_session_roots = function()
				local roots = {}
				local session_files = vim.fn.globpath(session_dir, "*.vim", 0, 1)

				for _, file in ipairs(session_files) do
					local name = vim.fn.fnamemodify(file, ":t:r")
					local root = name:gsub("__.*", "")
					if not vim.tbl_contains(roots, root) then
						table.insert(roots, root)
					end
				end

				return roots
			end

			-- Expose functions globally for keymaps and landing page
			_G.AutoSession = M

			-- Set MAX_SESSIONS default
			vim.g.max_sessions = vim.g.max_sessions or 5

			-- Auto-save on exit
			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					if vim.v.this_session and vim.v.this_session ~= "" then
						vim.cmd("mksession! " .. vim.v.this_session)
					end
				end,
			})

			-- Auto-save periodically (every 5 minutes)
			vim.fn.timer_start(300000, function()
				if vim.v.this_session and vim.v.this_session ~= "" then
					vim.cmd("mksession! " .. vim.v.this_session)
				end
			end, { ["repeat"] = -1 })
		end,
	},
}