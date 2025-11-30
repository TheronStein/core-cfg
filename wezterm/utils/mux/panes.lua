local wezterm = require("wezterm") --[[@as Wezterm]]

local M = {}

function M.get_pane_process(pane, shell_list)
	shell_list = shell_list or { "bash", "zsh", "fish", "sh", "dash", "ksh", "csh", "tcsh", "nushell" }

	-- Default return values
	local result = {
		name = "unknown",
		args = {},
		is_shell = false,
		pid = nil,
		cwd = "",
	}

	-- Try to get process info
	local success, process_info = pcall(function()
		return pane:get_foreground_process_info()
	end)

	if success and process_info then
		result.name = process_info.name or "unknown"
		result.args = process_info.args or {}
		result.pid = process_info.pid

		-- Check if this is a shell process
		for _, shell in ipairs(shell_list) do
			if result.name:find(shell) then
				result.is_shell = true
				break
			end
		end
	end

	-- Try to get current working directory
	local cwd_success, cwd = pcall(function()
		return pane:get_current_working_dir()
	end)

	if cwd_success and cwd then
		if type(cwd) == "string" then
			result.cwd = cwd
		elseif type(cwd) == "table" and cwd.file_path then
			result.cwd = cwd.file_path
		end
	end

	return result
end

--- Get current working directory from a pane
---@param pane any WezTerm pane object
---@return string cwd
function M.get_cwd(pane)
	local success, cwd = pcall(function()
		return pane:get_current_working_dir()
	end)

	if success and cwd then
		if type(cwd) == "string" then
			return cwd
		elseif type(cwd) == "table" and cwd.file_path then
			return cwd.file_path
		end
	end

	return ""
end

--- Capture scrollback buffer from a pane
---@param pane any WezTerm pane object
---@param max_lines number|nil Maximum number of lines to capture (nil for all available)
---@return string|nil scrollback
function M.capture_scrollback(pane, max_lines)
	local success, scrollback

	if max_lines then
		success, scrollback = pcall(function()
			return pane:get_lines_as_text(max_lines)
		end)
	else
		success, scrollback = pcall(function()
			return pane:get_lines_as_text()
		end)
	end

	if success and scrollback then
		return scrollback
	end

	return nil
end

return M
