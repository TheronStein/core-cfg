local M = {}


function M.setup()
  -- Setup code if needed
end
-- Assumes you have fzf-lua installed and set up.

local fzf = require("fzf-lua")

-- Function to get a list of installed figlet fonts
local function get_figlet_fonts()
	local fonts_str = vim.fn.system("figlet -l")
	local fonts = {}
	for font in fonts_str:gmatch("([^\\n]+)") do
		-- Extract just the font name from the file path
		local name = font:match(".*/?([^/.]+)")
		table.insert(fonts, name)
	end
	return fonts
end

-- Custom picker to select a figlet font and preview it
fzf.register_picker("FigletFonts", {
	-- Source of items for fzf
	source = get_figlet_fonts,
	-- Configuration for the preview window
	previewer = function(item, bufnr)
		local sample_text = "Neovim " .. item
		-- Command to run in the preview window (use bash to handle piping if needed)
		local cmd = string.format("figlet -f %s '%s'", item, sample_text)

		-- Use vim.fn.system to run the command and get output
		local output = vim.fn.system(cmd)

		-- Write the output to the preview buffer
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { output })
	end,
	-- Options to pass to the fzf CLI
	fzf_opts = {
		["--header"] = "Select a Figlet Font",
		["--ansi"] = true, -- Interpret ANSI color codes (some figlet fonts use colors)
	},
	-- Action to perform on selection (e.g., insert the font name)
	actions = {
		["enter"] = function(selected)
			if selected then
				print("Selected font: " .. selected[1])
				-- You could add a function here to insert the ASCII art into a buffer
			end
		end,
	},
})

  -- Keymap to open the picker (example: <leader>F)
  vim.api.nvim_set_keymap("n", "<Leader>F", ":FzfLua FigletFonts<CR>", { noremap = true, silent = true })
end


return M
