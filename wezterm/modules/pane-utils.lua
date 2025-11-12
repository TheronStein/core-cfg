-- pane_utils.lua (Extended)
-- Enhanced module for interactive pane handling with selection and adjusting modes.
-- Adds layout inspection helpers for conditional movements (e.g., detect multiple adjacent panes,
-- move between them, pull/minimize under others).
-- Usage: Integrated into WezTerm config with key tables for modal behavior.

local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

-- Existing DIRECTIONS enum
local DIRECTIONS = {
	Left = "Left",
	Right = "Right",
	Up = "Up",
	Down = "Down",
}

-- Direction opposites for shrinking/pulling
local OPPOSITES = {
	Left = "Right",
	Right = "Left",
	Up = "Down",
	Down = "Up",
}

-- Helper: Chain adjacent panes in a direction to count multiples or traverse
local function chain_adjacent_pane(start_pane, direction, max_depth)
	max_depth = max_depth or 10 -- Prevent infinite loops in weird layouts
	local chain = { start_pane }
	local current = start_pane:tab():get_pane_direction(direction)
	local depth = 1
	while current and depth < max_depth do
		table.insert(chain, current)
		current = current:tab():get_pane_direction(direction)
		depth = depth + 1
	end
	return chain
end

-- Detect if multiple (>1 adjacent) panes in direction (linear chain approximation)
-- Also returns if it's a "single" setup in the axis based on positions/sizes (no adj + at edge)
function M.detect_layout_context(direction)
	local pane = mux.get_active_pane()
	if not pane then
		return { multiples = false, single_in_axis = false, is_horz_axis = false }
	end

	local tab = pane:tab()
	local adj_chain = chain_adjacent_pane(pane, direction)

	local multiples = #adj_chain > 2 -- Self + at least two adjs for "more than two panes"
	local pos = pane:position()
	local size = pane:get_size()
	local tab_size = tab:get_size()

	-- Clarify: "Vertical" split = side-by-side (horizontal adjacency)
	-- "Horizontal" split = top-bottom (vertical adjacency)
	local is_horz_adj = (direction == "Left" or direction == "Right")
	local edge_check = is_horz_adj and (pos.column == 0 or pos.column + size.cols >= tab_size.cols)
		or (not is_horz_adj and (pos.row == 0 or pos.row + size.lines >= tab_size.lines))
	local single_in_axis = #adj_chain == 1 and edge_check -- No adj + at edge

	return {
		multiples = multiples,
		single_in_axis = single_in_axis,
		is_horz_axis = is_horz_adj,
	}
end

-- Helper to get an action for expanding in a direction by a large amount (effectively maximal)
local function expand_action(direction, amount)
	amount = amount or 10000 -- Large enough to maximize
	return wezterm.action({ AdjustPaneSize = { direction = direction, pixels = amount } })
end

-- Helper to get adjacent pane in direction relative to active pane
local function get_adjacent_pane(direction)
	local pane = mux.get_active_pane()
	if not pane then
		return nil
	end
	local tab = pane:tab()
	if not tab then
		return nil
	end
	return tab:get_pane_direction(direction)
end

-- Swap current pane with adjacent in direction, or expand if no adjacent
-- If expand_only=true, always expand instead of swapping
function M.swap_or_expand(direction, expand_only)
	local adj_pane = get_adjacent_pane(direction)
	if adj_pane and not expand_only then
		-- Swap positions (focus follows the pane content)
		mux.get_active_pane():move_to(adj_pane)
		-- Optionally activate the direction to focus the swapped position's original content
		-- Comment out if you want focus to stay with the moved content
		return wezterm.action({ ActivatePaneDirection = direction })
	else
		-- Expand maximally in the direction
		return expand_action(direction)
	end
end

-- Always expand maximally in the direction (ignores adjacency)
function M.expand(direction)
	return expand_action(direction)
end

-- Maximize horizontally: expand left and right
function M.maximize_horizontal()
	return expand_action("Left"), expand_action("Right")
end

-- Maximize vertically: expand up and down
function M.maximize_vertical()
	return expand_action("Up"), expand_action("Down")
end

-- Maximize fully: horizontal + vertical
function M.maximize_full()
	return expand_action("Left"), expand_action("Right"), expand_action("Up"), expand_action("Down")
end

-- Shrink in direction (opposite of expand, for balancing)
function M.shrink(direction, amount)
	amount = amount or 1000 -- Reasonable shrink amount
	return wezterm.action({ AdjustPaneSize = { direction = direction, pixels = -amount } })
end

-- Balance all panes in the tab (simple even distribution; requires custom logic)
-- This gets all panes in the tab and resizes to equal proportions, but it's approximate
function M.balance_panes()
	local pane = mux.get_active_pane()
	local tab = pane:tab()
	local panes = tab:panes()
	local num_panes = #panes
	if num_panes <= 1 then
		return nil
	end

	-- This is a basic implementation; for complex layouts, more logic needed
	-- For now, assume simple row/column; in practice, use fixed sizes based on tab size
	local tab_size = tab:get_size()
	local target_width = math.floor(tab_size.cols / num_panes)
	local target_height = math.floor(tab_size.lines / num_panes)

	-- To actually balance, you'd need to iterate and adjust splits, but WezTerm lacks direct API
	-- Fallback to sequential resizes (not perfect for nested splits)
	local actions = {}
	for i = 1, num_panes - 1 do
		table.insert(actions, expand_action("Right", target_width * 10)) -- Approx pixels (10px per cell)
		table.insert(actions, M.shrink("Right", (target_width * 10) / 2)) -- Approximate balance
	end
	return actions
end

-- Move pane to new split in direction (splits if no adjacent, then swaps into it)
function M.move_to_new_split(direction)
	local pane = mux.get_active_pane()
	local split_dir = (direction == "Left" or direction == "Right") and "Vertical" or "Horizontal"
	pane:perform_action(
		split_dir == "Vertical" and wezterm.action.SplitVertical({ size = 0.5 })
			or wezterm.action.SplitHorizontal({ size = 0.5 }),
		false
	)
	-- After split, the new pane is adjacent in the split direction
	-- Then swap with it
	local new_dir = split_dir:lower() == "vertical" and "Right" or "Down"
	return M.swap_or_expand(new_dir, false) -- Approximate
end

-- New: Advanced directional move based on context
-- - If multiples in dir: Move/swap to between them (split the middle one if needed, approximate)
-- - If single in axis: Fully extend in axis
-- - If expanded: Pull/minimize under/in-between from dir (shrink opposites, then adjust)
-- Re-evaluates context each call for dynamic behavior
function M.advanced_move(direction)
	local context = M.detect_layout_context(direction)
	local pane = mux.get_active_pane()
	local adj = get_adjacent_pane(direction)
	local opp_dir = OPPOSITES[direction]

	-- Check if fully expanded in axis (size matches tab size in that dim)
	local tab_size = pane:tab():get_size()
	local pane_size = pane:get_size()
	local is_fully_horz = pane_size.cols >= tab_size.cols
	local is_fully_vert = pane_size.lines >= tab_size.lines
	local is_fully_in_axis = context.is_horz_axis and is_fully_horz or (not context.is_horz_axis and is_fully_vert)

	if is_fully_in_axis then
		-- Pull/minimize under/in-between: Shrink to minimal in opp dir, then "pull" by activating/moving if adj
		local minimize_actions = {
			M.shrink(opp_dir, 9999), -- Shrink massively in opposite
			expand_action(direction, 1), -- Minimal expand to hug the border
		}
		if adj then
			-- If adj exists, swap to "pull under" it
			pane:move_to(adj)
			table.insert(minimize_actions, wezterm.action({ ActivatePaneDirection = opp_dir }))
		end
		-- Return sequence (WezTerm callbacks can chain via multiple performs, but simplify to primary)
		return minimize_actions[1] -- Focus on shrink for now; extend chaining if needed
	elseif context.multiples then
		-- Move to between: Approximate by splitting the first adj and swapping into new
		local first_adj = adj
		if first_adj then
			-- Split adj in perpendicular direction to create "between"
			local split_dir = context.is_horz_axis and "Horizontal" or "Vertical"
			first_adj:perform_action(
				split_dir == "Horizontal" and wezterm.action.SplitHorizontal({ size = 0.5 })
					or wezterm.action.SplitVertical({ size = 0.5 }),
				false
			)
			-- Then swap current into the new sub-pane (approximate direction)
			local new_adj_dir = context.is_horz_axis and "Down" or "Right"
			return M.swap_or_expand(new_adj_dir)
		end
	elseif context.single_in_axis then
		-- Fully extend in axis
		local axis_actions = context.is_horz_axis and M.maximize_horizontal() or M.maximize_vertical()
		return axis_actions[1] -- Primary direction
	else
		-- Default: Simple swap/expand
		return M.swap_or_expand(direction)
	end
end

-- New: Basic resize (for adjusting mode)
function M.resize(direction, amount)
	amount = amount or 5 -- Default small increment
	return wezterm.action({ AdjustPaneSize = { direction = direction, pixels = amount } })
end

return M
