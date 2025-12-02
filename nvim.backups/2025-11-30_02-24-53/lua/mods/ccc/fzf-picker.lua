-- Color picker for ccc.nvim using fzf-lua
-- Supports:
-- * hex colors (#rrggbb)
-- * rgb/rgba colors
-- * hypr_rgba format

local M = {}

M.setup = function()
	local fzf_ok = pcall(require, "fzf-lua")
	if not fzf_ok then
		return
	end

	local fzf = require("fzf-lua")

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
			-- Hypr RGBA pattern
			for color in line:gmatch("rgba%((%x%x%x%x%x%x%x%x)%)") do
				table.insert(colors, { color = "rgba(" .. color .. ")", line = i, type = "hypr_rgba" })
			end
			-- CSS RGBA pattern
			for color in line:gmatch("rgba%((.-)%)") do
				table.insert(colors, { color = "rgba(" .. color .. ")", line = i, type = "rgba" })
			end
			-- RGB pattern
			for color in line:gmatch("rgb%((%d+,%s*%d+,%s*%d+)%)") do
				table.insert(colors, { color = "rgb(" .. color .. ")", line = i, type = "rgb" })
			end
		end

		if #colors == 0 then
			vim.notify("No colors found in buffer", vim.log.levels.WARN)
			return
		end

		-- Create entries for fzf
		local entries = {}
		for _, entry in ipairs(colors) do
			local display = string.format("%-20s line %d (%s)", entry.color, entry.line, entry.type)
			table.insert(entries, display)
		end

		-- Use fzf-lua to pick a color
		fzf.fzf_exec(entries, {
			prompt = "Colors in Buffer> ",
			actions = {
				["default"] = function(selected)
					if not selected or #selected == 0 then
						return
					end

					-- Extract the color from the selected line
					local selection = selected[1]
					for _, color_data in ipairs(colors) do
						local display = string.format("%-20s line %d (%s)",
							color_data.color, color_data.line, color_data.type)
						if display == selection then
							vim.api.nvim_put({ color_data.color }, "c", true, true)
							break
						end
					end
				end,
			},
		})
	end

	-- Register command with fzf-lua name
	vim.api.nvim_create_user_command("FzfColors", M.pick_colors, { desc = "Pick colors from buffer (fzf-lua)" })
end

return M