local M = {}

function M.setup()
	-- Setup code if needed
	vim.api.nvim_create_user_command("Banner", function(opts)
		local text = opts.args
		local output = vim.fn.system('figlet -f banner3 "' .. text .. '" | sed "s/^/--      /"')
		local lines = vim.split(output, "\n")
		vim.api.nvim_put(lines, "l", true, true)
	end, { nargs = 1 })

	local fzf = require("fzf-lua")

	-- Function to get a list of installed figlet fonts
	local function get_figlet_fonts()
		-- List .flf files from figlet font directories
		local font_cmd = "find /usr/share/figlet -maxdepth 1 -name '*.flf' -type f 2>/dev/null | sort"
		local fonts_str = vim.fn.system(font_cmd)
		local fonts = {}
		for font_path in fonts_str:gmatch("([^\n]+)") do
			-- Extract just the font name without .flf extension
			local name = font_path:match("([^/]+)%.flf$")
			if name then
				table.insert(fonts, name)
			end
		end
		return fonts
	end

	-- Custom picker to select a figlet font and preview it
	vim.api.nvim_create_user_command("FigletPicker", function(opts)
		local preview_text = opts.args ~= "" and opts.args or "Neovim"

		fzf.fzf_exec(get_figlet_fonts(), {
			prompt = "Figlet Font> ",
			previewer = false,
			preview = fzf.shell.raw_preview_action_cmd(function(items)
				return string.format("figlet -f %s '%s'", items[1], preview_text)
			end),
			actions = {
				["default"] = function(selected)
					if selected and #selected > 0 then
						local font = selected[1]
						-- Generate ASCII art with selected font
						local result = vim.fn.system(string.format("figlet -f %s '%s'", font, preview_text))
						-- Insert into current buffer
						local lines = vim.split(result, "\n")
						-- Remove empty last line if present
						if lines[#lines] == "" then
							table.remove(lines)
						end
						vim.api.nvim_put(lines, "l", true, true)
					end
				end,
			},
		})
	end, { nargs = "?" })

	-- Keymap to open the picker
	vim.api.nvim_set_keymap(
		"n",
		"<Leader>F",
		":FigletPicker ",
		{ noremap = true, silent = false, desc = "Figlet font picker" }
	)
end

return M
