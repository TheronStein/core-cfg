local wezterm = require("wezterm")

local M = {}

--- Get process information from a pane
---@param pane any WezTerm pane object
---@param shell_list string[] List of shell process names
---@return {name: string, args: string[], cwd: string, is_shell: boolean}
function M.get_pane_process(pane, shell_list)
	local process_info = pane:get_foreground_process_info()

	if not process_info then
		return {
			name = "unknown",
			args = {},
			cwd = "",
			is_shell = false,
		}
	end

	-- Extract process name from executable path
	local name = process_info.name or "unknown"
	local basename = name:match("([^/]+)$") or name

	-- Check if this is a shell process
	local is_shell = false
	for _, shell in ipairs(shell_list or {}) do
		if basename:lower() == shell:lower() then
			is_shell = true
			break
		end
	end

	return {
		name = basename,
		args = process_info.argv or {},
		cwd = process_info.cwd or "",
		is_shell = is_shell,
	}
end

--- Determine the orientation of two panes
---@param pane1 any First pane
---@param pane2 any Second pane
---@return boolean is_adjacent Whether panes are adjacent
---@return "horizontal"|"vertical"|"unknown" orientation The orientation relationship
function M.get_panes_orientation(pane1, pane2)
	local pos1 = pane1:get_position()
	local pos2 = pane2:get_position()
	local dims1 = pane1:get_dimensions()
	local dims2 = pane2:get_dimensions()

	-- Check if panes are horizontally adjacent (side by side)
	-- One pane should end where the other begins on the x-axis
	-- and they should overlap on the y-axis
	local horizontal_adjacent = (pos1.x + dims1.pixel_width == pos2.x or pos2.x + dims2.pixel_width == pos1.x)
		and (
			(pos1.y >= pos2.y and pos1.y < pos2.y + dims2.pixel_height)
			or (pos2.y >= pos1.y and pos2.y < pos1.y + dims1.pixel_height)
		)

	-- Check if panes are vertically adjacent (stacked)
	-- One pane should end where the other begins on the y-axis
	-- and they should overlap on the x-axis
	local vertical_adjacent = (pos1.y + dims1.pixel_height == pos2.y or pos2.y + dims2.pixel_height == pos1.y)
		and (
			(pos1.x >= pos2.x and pos1.x < pos2.x + dims2.pixel_width)
			or (pos2.x >= pos1.x and pos2.x < pos1.x + dims1.pixel_width)
		)

	if horizontal_adjacent then
		return true, "horizontal"
	elseif vertical_adjacent then
		return true, "vertical"
	else
		return false, "unknown"
	end
end

--- Capture scrollback from a pane
---@param pane any WezTerm pane object
---@param max_lines number Maximum number of lines to capture
---@return string|nil Scrollback content
function M.capture_scrollback(pane, max_lines)
	if max_lines <= 0 then
		return nil
	end

	-- Get the scrollback content
	local lines = pane:get_lines_as_text(max_lines)
	return lines
end

return M
