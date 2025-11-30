local wezterm = require("wezterm") --[[@as Wezterm]]

local M = {}

--- Determines if two panes are adjacent and their split orientation
---@param pane1 any WezTerm pane object
---@param pane2 any WezTerm pane object
---@return boolean is_adjacent
---@return orientation orientation
function M.get_panes_orientation(pane1, pane2)
	local pos1 = pane1:get_position()
	local pos2 = pane2:get_position()
	local dims1 = pane1:get_dimensions()
	local dims2 = pane2:get_dimensions()

	-- Check if panes are adjacent horizontally (side by side)
	if
		(pos1.y == pos2.y and dims1.height == dims2.height)
		and ((pos1.x + dims1.pixel_width == pos2.x) or (pos2.x + dims2.pixel_width == pos1.x))
	then
		return true, "horizontal"
	end

	-- Check if panes are adjacent vertically (stacked)
	if
		(pos1.x == pos2.x and dims1.width == dims2.width)
		and ((pos1.y + dims1.pixel_height == pos2.y) or (pos2.y + dims2.pixel_height == pos1.y))
	then
		return true, "vertical"
	end

	return false, "unknown"
end
