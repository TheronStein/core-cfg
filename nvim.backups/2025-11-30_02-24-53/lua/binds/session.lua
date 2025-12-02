-- ╓────────────────────────────────────────────────────────────╖
-- ║ Session Management Keybinds                               ║
-- ║ All session operations under <leader><tab>                ║
-- ╙────────────────────────────────────────────────────────────╜

local M = {}

M.setup = function()
	local fzf = require("fzf-lua")

	-- Helper function to show session management menu
	local function session_management_menu()
		local items = {
			"Create New Session",
			"Save Current Session",
			"Load Session",
			"Delete Session",
			"List Root Sessions",
			"Show Landing Page",
		}

		fzf.fzf_exec(items, {
			prompt = "Session Management> ",
			actions = {
				["default"] = function(selected)
					local action = selected[1]
					if action == "Create New Session" then
						vim.ui.input({ prompt = "Session name: " }, function(name)
							if name then
								_G.AutoSession.create_session(name)
							end
						end)
					elseif action == "Save Current Session" then
						_G.AutoSession.save_session()
					elseif action == "Load Session" then
						local sessions = _G.AutoSession.list_root_sessions()
						fzf.fzf_exec(sessions, {
							prompt = "Load Session> ",
							actions = {
								["default"] = function(sel)
									if sel[1] then
										_G.AutoSession.load_session(sel[1])
									end
								end,
							},
						})
					elseif action == "Delete Session" then
						local sessions = _G.AutoSession.list_root_sessions()
						fzf.fzf_exec(sessions, {
							prompt = "Delete Session> ",
							actions = {
								["default"] = function(sel)
									if sel[1] then
										_G.AutoSession.delete_session(sel[1])
									end
								end,
							},
						})
					elseif action == "List Root Sessions" then
						local roots = _G.AutoSession.list_session_roots()
						fzf.fzf_exec(roots, {
							prompt = "Session Types> ",
							winopts = { height = 0.3, width = 0.4 },
						})
					elseif action == "Show Landing Page" then
						require("mods.landing-page").show()
					end
				end,
			},
			winopts = {
				height = 0.4,
				width = 0.5,
			},
		})
	end

	-- Helper function for reload menu
	local function reload_menu()
		local items = {
			"Smart Reload (auto-detect)",
			"Reload Full Config",
			"Reload Current File",
			"Reload Keymaps",
			"Reload LSP",
			"Reload Theme",
			"Reload Plugins",
		}

		fzf.fzf_exec(items, {
			prompt = "Reload Configuration> ",
			actions = {
				["default"] = function(selected)
					local action = selected[1]
					if action:match("Smart") then
						vim.cmd("ReloadSmart")
					elseif action:match("Full Config") then
						vim.cmd("ReloadConfig")
					elseif action:match("Current File") then
						vim.cmd("ReloadCurrent")
					elseif action:match("Keymaps") then
						vim.cmd("ReloadKeymaps")
					elseif action:match("LSP") then
						vim.cmd("ReloadLsp")
					elseif action:match("Theme") then
						vim.cmd("ReloadTheme")
					elseif action:match("Plugins") then
						vim.cmd("ReloadPlugins")
					end
				end,
			},
			winopts = {
				height = 0.4,
				width = 0.5,
			},
		})
	end

	-- <leader><tab> prefix for all session operations
	local prefix = "<leader><tab>"

	-- Main session management menu
	vim.keymap.set("n", prefix .. "s", session_management_menu, {
		desc = "Session Management Menu",
	})

	-- Direct session operations
	vim.keymap.set("n", prefix .. "m", function()
		-- Manage Root Sessions
		local sessions = _G.AutoSession.list_root_sessions()
		fzf.fzf_exec(sessions, {
			prompt = "Manage Sessions> ",
			actions = {
				["default"] = function(selected)
					if selected[1] then
						_G.AutoSession.load_session(selected[1])
					end
				end,
				["ctrl-d"] = function(selected)
					if selected[1] then
						_G.AutoSession.delete_session(selected[1])
						vim.notify("Session deleted: " .. selected[1])
					end
				end,
			},
			winopts = { height = 0.4, width = 0.5 },
		})
	end, { desc = "Manage Root Sessions" })

	vim.keymap.set("n", prefix .. "l", function()
		-- List Root Session Types
		local roots = _G.AutoSession.list_session_roots()
		fzf.fzf_exec(roots, {
			prompt = "Session Types> ",
			winopts = { height = 0.3, width = 0.4 },
		})
	end, { desc = "List Root Session Types" })

	-- Reload Configuration Menu
	vim.keymap.set("n", prefix .. "r", reload_menu, {
		desc = "Reload Configuration Menu",
	})

	-- Undo tree toggle (extended for session integration)
	vim.keymap.set("n", prefix .. "u", function()
		vim.cmd("UndotreeToggle")
	end, { desc = "Undo tree toggle" })

	-- Git worktree session management
	vim.keymap.set("n", prefix .. "w", function()
		fzf.fzf_exec("git worktree list", {
			prompt = "Git Worktrees> ",
			actions = {
				["default"] = function(selected)
					if selected[1] then
						local worktree_path = selected[1]:match("^(%S+)")
						if worktree_path then
							vim.cmd("cd " .. worktree_path)
							-- Create/load session for this worktree
							local session_name = vim.fn.fnamemodify(worktree_path, ":t")
							_G.AutoSession.create_session(session_name)
						end
					end
				end,
			},
		})
	end, { desc = "Git worktree session management" })

	-- Git diff view session management
	vim.keymap.set("n", prefix .. "d", function()
		-- Open git diff and create a session for diff viewing
		fzf.git_diff({
			actions = {
				["default"] = function(selected)
					-- Create a diff session
					_G.AutoSession.create_session("diff_" .. os.date("%Y%m%d_%H%M%S"))
				end,
			},
		})
	end, { desc = "Git diff view session" })

	-- Quit and delete session
	vim.keymap.set("n", prefix .. "q", function()
		vim.ui.select({ "Yes", "No" }, {
			prompt = "Quit and delete current session?",
		}, function(choice)
			if choice == "Yes" then
				_G.AutoSession.quit_and_delete()
			end
		end)
	end, { desc = "Quit and delete session" })

	-- Additional convenience mappings

	-- Quick save session
	vim.keymap.set("n", prefix .. "S", function()
		_G.AutoSession.save_session()
	end, { desc = "Quick save session" })

	-- Quick create session
	vim.keymap.set("n", prefix .. "n", function()
		vim.ui.input({ prompt = "New session name: " }, function(name)
			if name then
				_G.AutoSession.create_session(name)
			end
		end)
	end, { desc = "Create new session" })

	-- Landing page
	vim.keymap.set("n", prefix .. "h", function()
		require("mods.landing-page").show()
	end, { desc = "Show landing page (home)" })

	-- Session info display
	vim.keymap.set("n", prefix .. "i", function()
		local current_session = vim.v.this_session
		if current_session and current_session ~= "" then
			local session_name = vim.fn.fnamemodify(current_session, ":t:r")
			local root_dir, root_type = _G.AutoSession.detect_root_directory()
			local root_name = vim.fn.fnamemodify(root_dir, ":t")

			vim.notify(string.format(
				"Session: %s\nRoot: %s (%s)\nPath: %s",
				session_name,
				root_name,
				root_type,
				root_dir
			), vim.log.levels.INFO)
		else
			vim.notify("No active session", vim.log.levels.INFO)
		end
	end, { desc = "Session info" })
end

return M