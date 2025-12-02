-- TODO:
-- * Add support for hypr_rgba color format
-- * Migrated to fzf-lua from telescope

local M = {}

M.setup = function()
	local telescope_ok = pcall(require, "telescope")
	if not telescope_ok then
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	M.pick_colors = function(opts)
		opts = opts or {}

		-- Collect all colors from buffer
		local colors = {}
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

		for i, line in ipairs(lines) do
			-- Find all color formats
			for color in line:gmatch("#%x%x%x%x%x%x") do
				table.insert(colors, { color = color, line = i, type = "hex" })
			end
			-- ADD THIS NEW PATTERN
			for color in line:gmatch("rgba%((%x%x%x%x%x%x%x%x)%)") do
				table.insert(colors, { color = "rgba(" .. color .. ")", line = i, type = "hypr_rgba" })
			end
			for color in line:gmatch("rgba%((.-)%)") do -- This will catch css rgba
				table.insert(colors, { color = "rgba(" .. color .. ")", line = i, type = "rgba" })
			end
			for color in line:gmatch("rgb%((%d+,%s*%d+,%s*%d+)%)") do
				table.insert(colors, { color = "rgb(" .. color .. ")", line = i, type = "rgb" })
			end
		end
		if #colors == 0 then
			vim.notify("No colors found in buffer", vim.log.levels.WARN)
			return
		end

		pickers
			.new(opts, {
				prompt_title = " Colors in Buffer",
				finder = finders.new_table({
					results = colors,
					entry_maker = function(entry)
						return {
							value = entry,
							display = string.format("%-20s line %d (%s)", entry.color, entry.line, entry.type),
							ordinal = entry.color,
						}
					end,
				}),
				sorter = conf.generic_sorter(opts),
				attach_mappings = function(prompt_bufnr, map)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						if selection then
							vim.api.nvim_put({ selection.value.color }, "c", true, true)
						end
					end)
					return true
				end,
			})
			:find()
	end

	-- Register telescope extension
	vim.api.nvim_create_user_command("TelescopeColors", M.pick_colors, { desc = "Pick colors from buffer" })
end

return M
