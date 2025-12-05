-- Quick edit config picker with split
vim.keymap.set("n", "<localleader>ec", function()
	local snacks = require("snacks")
	local config_path = vim.fn.stdpath("config") .. "/lua"
	-- Custom picker that opens in a right split
	snacks.picker.files({
		cwd = config_path,
		prompt = "Config Files",
		-- Filter to only show active config files (lua files)
		find_command = { "fd", "--type", "f", "--extension", "lua" },
		preview = true,
		-- Custom action to open in right split
		confirm = function(item)
			vim.cmd("vsplit")
			vim.cmd("wincmd l")
			vim.cmd("edit " .. item.file)
		end,
	})
end, { desc = "Quick Edit Config (split)" })
