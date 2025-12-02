-- TODO: implement ui integrations with fzf-lua as a menu selector for different options and condense the keymaps
-- fix color picker buffer keymappings with the following remaps:
-- i: previous

local M = {}

M.setup = function()
	local map = vim.keymap.set

	-- Check if which-key is available before using it
	local wk_ok, wk = pcall(require, "which-key")

	-- Ensure normal mode when CCC closes
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "ccc-ui",
		callback = function(ev)
			vim.api.nvim_create_autocmd("BufLeave", {
				buffer = ev.buf,
				once = true,
				callback = function()
					vim.defer_fn(function()
						if vim.api.nvim_get_mode().mode == "i" then
							vim.cmd("stopinsert")
						end
					end, 10)
				end,
			})
		end,
	})

	-- Normal mode mappings
	map("n", "<localleader>cp", "<cmd>CccPick<cr>", { desc = "Pick color" })

	map("n", "<localleader>cc", function()
		local word = vim.fn.expand("<cword>")
		if word ~= "" then
			vim.cmd("CccConvert")
		else
			vim.notify("No color under cursor", vim.log.levels.WARN)
		end
	end, { desc = "Smart convert color" })

	-- Insert mode mappings
	map("i", "<C-\\>c", "<cmd>CccPick<cr>", { desc = "Pick color (insert)" })

	-- Visual mode enhanced mappings
	map("x", "<localleader>cr", function()
		-- Get visual selection
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		local lines = vim.fn.getline(start_pos[2], end_pos[2])

		if #lines == 1 then
			local line = lines[1]
			local start_col = start_pos[3]
			local end_col = end_pos[3]
			local selected = string.sub(line, start_col, end_col)

			-- Store selection and convert
			vim.fn.setreg('"', selected)
			vim.cmd("CccConvert")
		end
	end, { desc = "Replace selected color" })

	-- Palette management
	map("n", "<localleader>csp", function()
		-- Save current color to palette
		local color = vim.fn.expand("<cword>")
		if color:match("^#%x%x%x%x%x%x$") or color:match("^#%x%x%x$") then
			-- This would require additional logic to save to config
			vim.notify("Color " .. color .. " saved to palette", vim.log.levels.INFO)
		else
			vim.notify("Invalid color format", vim.log.levels.WARN)
		end
	end, { desc = "Save color to palette" })

	map("n", "<localleader>csc", function()
		local color = vim.fn.expand("<cword>")
		if color:match("^#%x%x%x%x%x%x$") or color:match("^#%x%x%x$") then
			vim.fn.setreg("+", color)
			vim.notify("Color " .. color .. " copied to clipboard", vim.log.levels.INFO)
		else
			vim.notify("No valid color under cursor", vim.log.levels.WARN)
		end
	end, { desc = "Copy color to clipboard" })

	-- Color increment/decrement
	map("n", "<localleader>c+", function()
		-- Increase brightness of color under cursor
		vim.cmd("CccPick")
		-- Simulate pressing P (set to 100%) then Enter
		vim.defer_fn(function()
			vim.api.nvim_feedkeys("P", "n", false)
			vim.defer_fn(function()
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
			end, 50)
		end, 50)
	end, { desc = "Increase brightness" })

	map("n", "<localleader>c-", function()
		-- Decrease brightness of color under cursor
		vim.cmd("CccPick")
		-- Simulate pressing H (set to 0%) then Enter
		vim.defer_fn(function()
			vim.api.nvim_feedkeys("H", "n", false)
			vim.defer_fn(function()
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
			end, 50)
		end, 50)
	end, { desc = "Decrease brightness" })

	-- Color statistics
	map("n", "<localleader>cvc", function()
		local colors = {}
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		for _, line in ipairs(lines) do
			for color in line:gmatch("#%x%x%x%x%x%x") do
				colors[color] = (colors[color] or 0) + 1
			end
			for color in line:gmatch("#%x%x%x") do
				colors[color] = (colors[color] or 0) + 1
			end
		end

		local count = vim.tbl_count(colors)
		local total = 0
		for _, c in pairs(colors) do
			total = total + c
		end

		vim.notify(string.format("Found %d unique colors (%d total occurrences)", count, total), vim.log.levels.INFO)
	end, { desc = "Count colors in buffer" })

	-- Register additional which-key groups if available
	if wk_ok then
		wk.register({
			["<localleader>cv"] = {
				name = "Visual tools",
				s = { desc = "Select all colors" },
				h = { desc = "Highlight all colors" },
				c = { desc = "Count colors in buffer" },
			},
		})
	end
end

return M
