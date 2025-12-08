-- ╓────────────────────────────────────────────────────────────╖
-- ║ Extended Lualine Components                               ║
-- ║ Comprehensive status information for lualine              ║
-- ╙────────────────────────────────────────────────────────────╜

local M = {}

-- Session component with detailed info
M.session = function()
	local ok, result = pcall(function()
		-- Check if AutoSession is available
		if _G.AutoSession then
			local current_session = vim.v.this_session
			if current_session and current_session ~= "" then
				local session_name = vim.fn.fnamemodify(current_session, ":t:r")
				local root_type = _G.AutoSession.get_root_type and _G.AutoSession.get_root_type() or "unknown"

				-- -- Add icon based on root type
				-- local icon = ""
				-- if root_type == "git" then
				--   icon = " "
				-- elseif root_type == "editorconfig" then
				--   icon = " "
				-- elseif root_type == "marker" then
				--   icon = " "
				-- else
				--   icon = " "
				-- end
				--
				-- Check if session is modified
				local modified = ""
				if vim.bo.modified then
					modified = " "
				end

				-- Shorten session name if too long
				if #session_name > 20 then
					session_name = session_name:sub(1, 17) .. "..."
				end

				return icon .. session_name .. modified
			end
		end
		return " No session"
	end)

	if ok then
		return result
	else
		return ""
	end
end

-- LSP clients component
M.lsp_clients = function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return "No LSP"
	end

	local client_names = {}
	for _, client in ipairs(clients) do
		table.insert(client_names, client.name)
	end

	return " " .. table.concat(client_names, ", ")
end

-- Diagnostics count with details
M.diagnostics_detailed = function()
	local counts = {
		errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
		warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
		info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }),
		hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
	}

	local parts = {}
	if counts.errors > 0 then
		table.insert(parts, " " .. counts.errors)
	end
	if counts.warnings > 0 then
		table.insert(parts, " " .. counts.warnings)
	end
	if counts.info > 0 then
		table.insert(parts, " " .. counts.info)
	end
	if counts.hints > 0 then
		table.insert(parts, "󰌵 " .. counts.hints)
	end

	if #parts == 0 then
		return "✓ Clean"
	end

	return table.concat(parts, " ")
end

-- Git status with more detail
M.git_status = function()
	local ok, result = pcall(function()
		local gitsigns_status = vim.b.gitsigns_status_dict
		if not gitsigns_status then
			return ""
		end

		local status = {}
		if gitsigns_status.added and gitsigns_status.added > 0 then
			table.insert(status, "+" .. gitsigns_status.added)
		end
		if gitsigns_status.changed and gitsigns_status.changed > 0 then
			table.insert(status, "~" .. gitsigns_status.changed)
		end
		if gitsigns_status.removed and gitsigns_status.removed > 0 then
			table.insert(status, "-" .. gitsigns_status.removed)
		end

		if #status > 0 then
			return " " .. gitsigns_status.head .. " [" .. table.concat(status, " ") .. "]"
		else
			return " " .. gitsigns_status.head
		end
	end)

	if ok then
		return result
	else
		return ""
	end
end

-- File size component
M.file_size = function()
	local file = vim.fn.expand("%:p")
	if file == nil or file == "" then
		return ""
	end

	local size = vim.fn.getfsize(file)
	if size <= 0 then
		return ""
	end

	local suffixes = { "B", "K", "M", "G" }
	local i = 1

	while size > 1024 and i < #suffixes do
		size = size / 1024
		i = i + 1
	end

	return string.format("%.1f%s", size, suffixes[i])
end

-- Current function/method component (using Treesitter)
M.current_function = function()
	-- local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
	-- if not ok then
	-- 	return ""
	-- end

	local node = vim.treesitter.get_node_at_cursor()
	if not node then
		return ""
	end

	while node do
		local node_type = node:type()
		if
			node_type == "function_declaration"
			or node_type == "method_definition"
			or node_type == "function_definition"
			or node_type == "arrow_function"
			or node_type == "function"
			or node_type == "method"
		then
			local success, name = pcall(vim.Treesitter.get_node_text, node:child(1), 0)
			if success and name and type(name) == "string" and #name > 0 then
				-- Limit name length to avoid statusline issues
				if #name > 30 then
					name = name:sub(1, 27) .. "..."
				end
				return "󰊕 " .. name
			elseif success and name and type(name) == "table" and #name > 0 then
				-- Handle case where get_node_text returns a table
				local text = table.concat(name, " ")
				if #text > 30 then
					text = text:sub(1, 27) .. "..."
				end
				return "󰊕 " .. text
			end
		end
		node = node:parent()
	end

	return ""
end

-- Macro recording indicator
M.macro_recording = function()
	local recording_register = vim.fn.reg_recording()
	if recording_register == "" then
		return ""
	else
		return "Recording @" .. recording_register
	end
end

-- Search count component
M.search_count = function()
	if vim.v.hlsearch == 0 then
		return ""
	end

	local ok, searchcount = pcall(vim.fn.searchcount)
	if not ok then
		return ""
	end

	if searchcount.total == 0 then
		return ""
	end

	return string.format(" %d/%d", searchcount.current, searchcount.total)
end

-- Word count for text files
M.word_count = function()
	local ft = vim.bo.filetype
	local text_filetypes = { "markdown", "text", "txt", "org", "asciidoc", "rst" }

	if not vim.tbl_contains(text_filetypes, ft) then
		return ""
	end

	local wc = vim.fn.wordcount()
	if wc["visual_words"] then
		return string.format("Words: %d (sel: %d)", wc["words"], wc["visual_words"])
	else
		return string.format("Words: %d", wc["words"])
	end
end

-- Python virtual environment
M.python_env = function()
	local ok, result = pcall(function()
		local venv = vim.env.VIRTUAL_ENV
		if venv then
			local venv_name = vim.fn.fnamemodify(venv, ":t")
			-- Limit length to avoid statusline issues
			if #venv_name > 20 then
				venv_name = venv_name:sub(1, 17) .. "..."
			end
			return " " .. venv_name
		end
		return ""
	end)

	if ok then
		return result
	else
		return ""
	end
end

-- Indentation info
M.indent_info = function()
	local indent_type = vim.bo.expandtab and "Spaces" or "Tabs"
	local indent_size = vim.bo.shiftwidth
	return indent_type .. ":" .. indent_size
end

-- Notification count indicator
M.notification_count = function()
	local ok, result = pcall(function()
		local notifications = require("mods.notifications")
		local cache = notifications.get_all_notifications and notifications.get_all_notifications() or {}

		if #cache == 0 then
			return ""
		end

		-- Count by type
		local errors = 0
		local warnings = 0

		for _, notif in ipairs(cache) do
			if notif.level == vim.log.levels.ERROR then
				errors = errors + 1
			elseif notif.level == vim.log.levels.WARN then
				warnings = warnings + 1
			end
		end

		local parts = {}
		if errors > 0 then
			table.insert(parts, " " .. errors)
		end
		if warnings > 0 then
			table.insert(parts, " " .. warnings)
		end

		if #parts > 0 then
			return "󰎟 " .. table.concat(parts, " ")
		else
			return "󰎟 " .. #cache
		end
	end)

	if ok then
		return result
	else
		-- Module not found or error occurred
		return ""
	end
end

-- Copilot status
M.copilot_status = function()
	local copilot = vim.b.copilot_enabled
	if copilot == nil then
		copilot = vim.g.copilot_enabled
	end

	if copilot == false then
		return " OFF"
	else
		return " ON"
	end
end

-- Setup function to integrate with lualine
function M.setup_lualine_extension()
	-- Get the current lualine config
	local ok, lualine = pcall(require, "lualine")
	if not ok then
		vim.notify("Lualine not found", vim.log.levels.ERROR)
		return
	end

	-- Extend the current configuration
	local config = require("lualine").get_config()

	-- Add our custom components to appropriate sections
	-- You can modify these positions as needed
	table.insert(config.sections.lualine_b, { M.session })
	table.insert(config.sections.lualine_b, { M.git_status })

	table.insert(config.sections.lualine_c, { M.current_function })
	table.insert(config.sections.lualine_c, { M.python_env })

	table.insert(config.sections.lualine_x, { M.lsp_clients })
	table.insert(config.sections.lualine_x, { M.diagnostics_detailed })
	table.insert(config.sections.lualine_x, { M.notification_count })
	table.insert(config.sections.lualine_x, { M.copilot_status })

	table.insert(config.sections.lualine_y, { M.file_size })
	table.insert(config.sections.lualine_y, { M.indent_info })
	table.insert(config.sections.lualine_y, { M.macro_recording })

	table.insert(config.sections.lualine_z, { M.search_count })
	table.insert(config.sections.lualine_z, { M.word_count })

	-- Refresh lualine with new config
	lualine.setup(config)
end

return M
