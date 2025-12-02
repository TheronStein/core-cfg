-- ╓────────────────────────────────────────────────────────────╖
-- ║ Landing Page Module                                       ║
-- ║ Git-aware startup screen with fzf-lua integration        ║
-- ╙────────────────────────────────────────────────────────────╜

local M = {}

-- Dependencies
local fzf = nil
local auto_session = nil

-- Major file patterns and their scores
local major_file_patterns = {
	-- Build files (highest priority)
	{ pattern = "^Makefile$", score = 100 },
	{ pattern = "^CMakeLists%.txt$", score = 95 },
	{ pattern = "^Cargo%.toml$", score = 95 },
	{ pattern = "^package%.json$", score = 95 },
	{ pattern = "^pom%.xml$", score = 90 },
	{ pattern = "^build%.gradle$", score = 90 },
	{ pattern = "^setup%.py$", score = 85 },
	{ pattern = "^pyproject%.toml$", score = 85 },
	{ pattern = "^go%.mod$", score = 85 },

	-- Documentation
	{ pattern = "^README%.md$", score = 80 },
	{ pattern = "^README%.txt$", score = 75 },
	{ pattern = "^README$", score = 70 },
	{ pattern = "^CLAUDE%.md$", score = 75 },
	{ pattern = "^DOCS%.md$", score = 70 },

	-- Entry points
	{ pattern = "^main%..*", score = 60 },
	{ pattern = "^index%..*", score = 60 },
	{ pattern = "^app%..*", score = 55 },
	{ pattern = "^server%..*", score = 55 },

	-- Config files
	{ pattern = "^%.env$", score = 50 },
	{ pattern = "^%.env%..*", score = 45 },
	{ pattern = "^config%..*", score = 40 },
	{ pattern = "^settings%..*", score = 40 },
}

-- Check if current directory is a git repository
M.is_git_repo = function()
	local result = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
	return result:match("true") ~= nil
end

-- Get git repository info
M.get_git_info = function()
	if not M.is_git_repo() then
		return nil
	end

	local info = {}

	-- Get repository name
	local remote = vim.fn.system("git remote get-url origin 2>/dev/null"):gsub("\n", "")
	if remote ~= "" then
		info.repo_name = remote:match("([^/]+)%.git$") or remote:match("([^/]+)$")
	else
		local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
		info.repo_name = vim.fn.fnamemodify(git_root, ":t")
	end

	-- Get current branch
	info.branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
	if info.branch == "" then
		info.branch = "detached"
	end

	-- Get status summary
	local status = vim.fn.system("git status --porcelain 2>/dev/null")
	local lines = vim.split(status, "\n")
	info.modified = 0
	info.untracked = 0
	info.staged = 0

	for _, line in ipairs(lines) do
		if line ~= "" then
			local first_char = line:sub(1, 1)
			local second_char = line:sub(2, 2)

			if first_char ~= " " and first_char ~= "?" then
				info.staged = info.staged + 1
			end
			if second_char == "M" then
				info.modified = info.modified + 1
			end
			if first_char == "?" then
				info.untracked = info.untracked + 1
			end
		end
	end

	-- Get last commit info
	info.last_commit = vim.fn.system("git log -1 --oneline 2>/dev/null"):gsub("\n", "")

	-- Get worktrees
	local worktrees = vim.fn.system("git worktree list 2>/dev/null")
	info.worktrees = vim.split(worktrees, "\n")

	-- Get tags
	local tags = vim.fn.system("git tag -l 2>/dev/null")
	info.tags = vim.split(tags, "\n")

	return info
end

-- Score and sort major files
M.get_major_files = function()
	local cwd = vim.fn.getcwd()
	local files = vim.fn.readdir(cwd)
	local major_files = {}

	for _, file in ipairs(files) do
		-- Check if it's a regular file (not directory)
		local full_path = cwd .. "/" .. file
		if vim.fn.isdirectory(full_path) == 0 then
			-- Check against patterns
			for _, pattern_info in ipairs(major_file_patterns) do
				if file:match(pattern_info.pattern) then
					table.insert(major_files, {
						name = file,
						score = pattern_info.score,
						path = full_path
					})
					break
				end
			end
		end
	end

	-- Sort by score (highest first)
	table.sort(major_files, function(a, b)
		return a.score > b.score
	end)

	-- Return top 10
	local result = {}
	for i = 1, math.min(10, #major_files) do
		table.insert(result, major_files[i])
	end

	return result
end

-- Create git repository landing page (4 panels)
M.create_git_landing = function(git_info)
	-- Ensure fzf-lua is loaded
	if not fzf then
		local ok, fzf_module = pcall(require, "fzf-lua")
		if not ok then
			vim.notify("fzf-lua not found", vim.log.levels.ERROR)
			return
		end
		fzf = fzf_module
	end

	-- Create buffer for landing page
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(buf)

	-- Set buffer options
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "landing"

	-- Create the landing page content
	local lines = {}
	local highlights = {}

	-- Header
	table.insert(lines, "")
	table.insert(lines, string.format("  🎯 Repository: %s", git_info.repo_name))
	table.insert(lines, string.format("  🌿 Branch: %s", git_info.branch))
	table.insert(lines, "")
	table.insert(lines, "  ╭────────────────────────────────────────────────────╮")
	table.insert(lines, "  │                  Session Menu                      │")
	table.insert(lines, "  ├────────────────────────────────────────────────────┤")
	table.insert(lines, "  │  [s] List Sessions      [n] New Session           │")
	table.insert(lines, "  │  [l] Load Last          [d] Delete Session        │")
	table.insert(lines, "  │  [r] Recent Files       [f] Find Files            │")
	table.insert(lines, "  │  [g] Git Status         [b] Git Branches          │")
	table.insert(lines, "  │  [w] Worktrees          [t] Tags                  │")
	table.insert(lines, "  │  [q] Quit               [h] Help                  │")
	table.insert(lines, "  ╰────────────────────────────────────────────────────╯")
	table.insert(lines, "")

	-- Git status summary
	table.insert(lines, "  📊 Git Status:")
	table.insert(lines, string.format("     Staged: %d  Modified: %d  Untracked: %d",
		git_info.staged, git_info.modified, git_info.untracked))
	table.insert(lines, "")
	table.insert(lines, string.format("  📝 Last Commit: %s", git_info.last_commit))
	table.insert(lines, "")

	-- Major files
	local major_files = M.get_major_files()
	if #major_files > 0 then
		table.insert(lines, "  📁 Major Files:")
		for _, file in ipairs(major_files) do
			table.insert(lines, string.format("     • %s", file.name))
		end
	end

	-- Set buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	-- Set up keymaps for the landing page
	local opts = { buffer = buf, silent = true }

	-- Session operations
	vim.keymap.set("n", "s", function()
		local sessions = AutoSession.list_root_sessions()
		if #sessions > 0 then
			fzf.fzf_exec(sessions, {
				prompt = "Sessions> ",
				actions = {
					["default"] = function(selected)
						if selected[1] then
							AutoSession.load_session(selected[1])
							vim.api.nvim_buf_delete(buf, { force = true })
						end
					end,
				},
			})
		else
			vim.notify("No sessions found", vim.log.levels.INFO)
		end
	end, opts)

	vim.keymap.set("n", "n", function()
		vim.ui.input({ prompt = "Session name: " }, function(name)
			if name then
				AutoSession.create_session(name)
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end)
	end, opts)

	vim.keymap.set("n", "l", function()
		local sessions = AutoSession.list_root_sessions()
		if #sessions > 0 then
			AutoSession.load_session(sessions[1])
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end, opts)

	vim.keymap.set("n", "d", function()
		local sessions = AutoSession.list_root_sessions()
		if #sessions > 0 then
			fzf.fzf_exec(sessions, {
				prompt = "Delete Session> ",
				actions = {
					["default"] = function(selected)
						if selected[1] then
							AutoSession.delete_session(selected[1])
							vim.notify("Session deleted: " .. selected[1], vim.log.levels.INFO)
						end
					end,
				},
			})
		end
	end, opts)

	-- File operations
	vim.keymap.set("n", "r", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		fzf.oldfiles()
	end, opts)

	vim.keymap.set("n", "f", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		fzf.files()
	end, opts)

	-- Git operations
	vim.keymap.set("n", "g", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		fzf.git_status()
	end, opts)

	vim.keymap.set("n", "b", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		fzf.git_branches()
	end, opts)

	vim.keymap.set("n", "w", function()
		if #git_info.worktrees > 1 then
			fzf.fzf_exec(git_info.worktrees, {
				prompt = "Worktrees> ",
				actions = {
					["default"] = function(selected)
						if selected[1] then
							local worktree_path = selected[1]:match("^([^%s]+)")
							if worktree_path then
								vim.cmd("cd " .. worktree_path)
								vim.api.nvim_buf_delete(buf, { force = true })
							end
						end
					end,
				},
			})
		else
			vim.notify("No additional worktrees", vim.log.levels.INFO)
		end
	end, opts)

	vim.keymap.set("n", "t", function()
		if #git_info.tags > 1 then
			fzf.fzf_exec(git_info.tags, {
				prompt = "Tags> ",
				actions = {
					["default"] = function(selected)
						if selected[1] then
							vim.cmd("Git checkout " .. selected[1])
							vim.api.nvim_buf_delete(buf, { force = true })
						end
					end,
				},
			})
		else
			vim.notify("No tags found", vim.log.levels.INFO)
		end
	end, opts)

	-- Other operations
	vim.keymap.set("n", "q", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		vim.cmd("qa")
	end, opts)

	vim.keymap.set("n", "h", function()
		vim.notify("Landing Page Help:\n" ..
			"s - List sessions\n" ..
			"n - New session\n" ..
			"l - Load last session\n" ..
			"d - Delete session\n" ..
			"r - Recent files\n" ..
			"f - Find files\n" ..
			"g - Git status\n" ..
			"b - Git branches\n" ..
			"w - Worktrees\n" ..
			"t - Tags\n" ..
			"q - Quit\n", vim.log.levels.INFO)
	end, opts)

	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_buf_delete(buf, { force = true })
	end, opts)
end

-- Create non-git landing page (4 panels)
M.create_normal_landing = function()
	-- Ensure fzf-lua is loaded
	if not fzf then
		local ok, fzf_module = pcall(require, "fzf-lua")
		if not ok then
			vim.notify("fzf-lua not found", vim.log.levels.ERROR)
			return
		end
		fzf = fzf_module
	end

	-- Create buffer for landing page
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(buf)

	-- Set buffer options
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "landing"

	-- Create the landing page content
	local lines = {}
	local cwd = vim.fn.getcwd()
	local dir_name = vim.fn.fnamemodify(cwd, ":t")

	-- Header
	table.insert(lines, "")
	table.insert(lines, string.format("  📁 Directory: %s", dir_name))
	table.insert(lines, string.format("  📍 Path: %s", cwd))
	table.insert(lines, "")
	table.insert(lines, "  ╭────────────────────────────────────────────────────╮")
	table.insert(lines, "  │                  Session Menu                      │")
	table.insert(lines, "  ├────────────────────────────────────────────────────┤")
	table.insert(lines, "  │  [s] List Sessions      [n] New Session           │")
	table.insert(lines, "  │  [l] Load Last          [d] Delete Session        │")
	table.insert(lines, "  │  [r] Recent Files       [f] Find Files            │")
	table.insert(lines, "  │  [m] Major Files        [a] All Files             │")
	table.insert(lines, "  │  [q] Quit               [h] Help                  │")
	table.insert(lines, "  ╰────────────────────────────────────────────────────╯")
	table.insert(lines, "")

	-- Major files
	local major_files = M.get_major_files()
	if #major_files > 0 then
		table.insert(lines, "  📄 Major Files:")
		for _, file in ipairs(major_files) do
			table.insert(lines, string.format("     • %s", file.name))
		end
		table.insert(lines, "")
	end

	-- Recent files in this directory
	table.insert(lines, "  🕒 Recent Files (in current directory):")
	local recent_files = vim.v.oldfiles or {}
	local count = 0
	for _, file in ipairs(recent_files) do
		if vim.startswith(file, cwd) and count < 10 then
			local relative_path = file:sub(#cwd + 2)
			table.insert(lines, string.format("     • %s", relative_path))
			count = count + 1
		end
	end

	if count == 0 then
		table.insert(lines, "     No recent files in this directory")
	end

	-- Set buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	-- Set up keymaps for the landing page
	local opts = { buffer = buf, silent = true }

	-- Session operations
	vim.keymap.set("n", "s", function()
		local sessions = AutoSession.list_root_sessions()
		if #sessions > 0 then
			fzf.fzf_exec(sessions, {
				prompt = "Sessions> ",
				actions = {
					["default"] = function(selected)
						if selected[1] then
							AutoSession.load_session(selected[1])
							vim.api.nvim_buf_delete(buf, { force = true })
						end
					end,
				},
			})
		else
			vim.notify("No sessions found", vim.log.levels.INFO)
		end
	end, opts)

	vim.keymap.set("n", "n", function()
		vim.ui.input({ prompt = "Session name: " }, function(name)
			if name then
				AutoSession.create_session(name)
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end)
	end, opts)

	vim.keymap.set("n", "l", function()
		local sessions = AutoSession.list_root_sessions()
		if #sessions > 0 then
			AutoSession.load_session(sessions[1])
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end, opts)

	vim.keymap.set("n", "d", function()
		local sessions = AutoSession.list_root_sessions()
		if #sessions > 0 then
			fzf.fzf_exec(sessions, {
				prompt = "Delete Session> ",
				actions = {
					["default"] = function(selected)
						if selected[1] then
							AutoSession.delete_session(selected[1])
							vim.notify("Session deleted: " .. selected[1], vim.log.levels.INFO)
						end
					end,
				},
			})
		end
	end, opts)

	-- File operations
	vim.keymap.set("n", "r", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		fzf.oldfiles()
	end, opts)

	vim.keymap.set("n", "f", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		fzf.files()
	end, opts)

	vim.keymap.set("n", "m", function()
		if #major_files > 0 then
			local file_list = {}
			for _, file in ipairs(major_files) do
				table.insert(file_list, file.name)
			end
			fzf.fzf_exec(file_list, {
				prompt = "Major Files> ",
				actions = {
					["default"] = function(selected)
						if selected[1] then
							vim.api.nvim_buf_delete(buf, { force = true })
							vim.cmd("edit " .. selected[1])
						end
					end,
				},
			})
		else
			vim.notify("No major files found", vim.log.levels.INFO)
		end
	end, opts)

	vim.keymap.set("n", "a", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		fzf.files()
	end, opts)

	-- Other operations
	vim.keymap.set("n", "q", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		vim.cmd("qa")
	end, opts)

	vim.keymap.set("n", "h", function()
		vim.notify("Landing Page Help:\n" ..
			"s - List sessions\n" ..
			"n - New session\n" ..
			"l - Load last session\n" ..
			"d - Delete session\n" ..
			"r - Recent files\n" ..
			"f - Find files\n" ..
			"m - Major files\n" ..
			"a - All files\n" ..
			"q - Quit\n", vim.log.levels.INFO)
	end, opts)

	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_buf_delete(buf, { force = true })
	end, opts)
end

-- Initialize landing page
M.init = function()
	-- Check if we should show landing page
	if vim.fn.argc() > 0 then
		-- Files were passed as arguments, don't show landing page
		return
	end

	-- Check if we're in a git repository
	local is_git = M.is_git_repo()

	if is_git then
		local git_info = M.get_git_info()
		if git_info then
			M.create_git_landing(git_info)
		else
			M.create_normal_landing()
		end
	else
		M.create_normal_landing()
	end
end

-- Setup autocmd to show landing page on startup
M.setup = function()
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			vim.schedule(function()
				M.init()
			end)
		end,
	})
end

return M