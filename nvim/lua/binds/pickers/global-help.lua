-- ╓────────────────────────────────────────────────────────────╖
-- ║ Global Help and Which-Key Menu                            ║
-- ║ Comprehensive keybinding help system                       ║
-- ╙────────────────────────────────────────────────────────────╜

local M = {}
local wk = require("which-key")
-- Function to show all available keybindings
function M.show_all_keybindings()
	-- Use which-key's built-in show function with no prefix
	require("which-key").show({ keys = "", mode = "n" })
end

-- Function to show keybindings for specific mode
function M.show_mode_keybindings(mode)
	require("which-key").show({ keys = "", mode = mode })
end

-- Function to create a comprehensive help menu
function M.show_help_menu()
	local fzf = require("fzf-lua")

	local help_items = {
		{
			label = "All Keybindings",
			action = function()
				M.show_all_keybindings()
			end,
		},
		{
			label = "Normal Mode Keys",
			action = function()
				M.show_mode_keybindings("n")
			end,
		},
		{
			label = "Insert Mode Keys",
			action = function()
				M.show_mode_keybindings("i")
			end,
		},
		{
			label = "Visual Mode Keys",
			action = function()
				M.show_mode_keybindings("v")
			end,
		},
		{
			label = "Command Mode Keys",
			action = function()
				M.show_mode_keybindings("c")
			end,
		},
		{
			label = "Terminal Mode Keys",
			action = function()
				M.show_mode_keybindings("t")
			end,
		},
		{
			label = "Leader Mappings",
			action = function()
				require("which-key").show({ keys = "<leader>", mode = "n" })
			end,
		},
		{
			label = "LocalLeader Mappings",
			action = function()
				require("which-key").show({ keys = "<localleader>", mode = "n" })
			end,
		},
		{
			label = "Window Mappings",
			action = function()
				require("which-key").show({ keys = "<C-w>", mode = "n" })
			end,
		},
		{
			label = "Git Mappings",
			action = function()
				require("which-key").show({ keys = "<leader>g", mode = "n" })
			end,
		},
		{
			label = "LSP Mappings",
			action = function()
				require("which-key").show({ keys = "<leader>l", mode = "n" })
			end,
		},
		{
			label = "Search Mappings",
			action = function()
				require("which-key").show({ keys = "<leader>s", mode = "n" })
			end,
		},
		{
			label = "Buffer Mappings",
			action = function()
				require("which-key").show({ keys = "<leader>b", mode = "n" })
			end,
		},
		{
			label = "File Mappings",
			action = function()
				require("which-key").show({ keys = "<leader>f", mode = "n" })
			end,
		},
		{
			label = "Code Mappings",
			action = function()
				require("which-key").show({ keys = "<leader>c", mode = "n" })
			end,
		},
		{
			label = "Session Mappings",
			action = function()
				require("which-key").show({ keys = "<leader><tab>", mode = "n" })
			end,
		},
		{
			label = "Notification Mappings",
			action = function()
				require("which-key").show({ keys = "<leader>n", mode = "n" })
			end,
		},
		{
			label = "Toggle Mappings",
			action = function()
				require("which-key").show({ keys = "<leader>t", mode = "n" })
			end,
		},
		{
			label = "Vim Commands",
			action = function()
				vim.cmd("help index")
			end,
		},
		{
			label = "Ex Commands",
			action = function()
				vim.cmd("help ex-cmd-index")
			end,
		},
		{
			label = "Function List",
			action = function()
				vim.cmd("help function-list")
			end,
		},
		{
			label = "Option List",
			action = function()
				vim.cmd("help option-list")
			end,
		},
		{
			label = "Vim Tips",
			action = function()
				vim.cmd("help tips")
			end,
		},
	}

	-- Create menu items
	local menu_items = {}
	for _, item in ipairs(help_items) do
		table.insert(menu_items, item.label)
	end

	-- Show menu with fzf-lua
	fzf.fzf_exec(menu_items, {
		prompt = "Help Menu> ",
		preview = false,
		actions = {
			["default"] = function(selected)
				if selected and #selected > 0 then
					for _, item in ipairs(help_items) do
						if item.label == selected[1] then
							item.action()
							break
						end
					end
				end
			end,
		},
	})
end

-- Function to search help documentation
function M.search_help()
	require("fzf-lua").help_tags()
end

-- Function to show recent commands
function M.show_command_history()
	require("fzf-lua").command_history()
end

-- Function to show marks
function M.show_marks()
	require("fzf-lua").marks()
end

-- Function to show registers
function M.show_registers()
	require("fzf-lua").registers()
end

-- Function to show jumps
function M.show_jumps()
	require("fzf-lua").jumps()
end

-- Setup keybindings
function M.setup()
	-- -- Main global help key - Using <leader>? to avoid conflict with tmux navigation
	-- vim.keymap.set("n", "", function()
	-- 	M.show_help_menu()
	-- end, { desc = "Global Help Menu" })
	--
	-- -- Alternative global help key with F1
	-- vim.keymap.set("n", "<F1>", function()
	-- 	M.show_help_menu()
	-- end, { desc = "Global Help Menu" })
	--
	-- Alternative: F1 for which-key (already set in which-key config)
	-- vim.keymap.set("n", "<F1>", function() M.show_all_keybindings() end, { desc = "Show All Keybindings" })

	wk.add({
		{ group = "<localleader>h", desc = "Help & Info" },

		["h"] = {
			function()
				M.show_help_menu()
			end,
			desc = "Help Menu",
		},
	}, {
		["2"] = { name = "Help Queries" },
		{ ["s"] = {
			function()
				M.search_help()
			end,
			desc = "Search Help",
		} },
		{ ["c"] = {
			function()
				M.show_command_history()
			end,
			desc = "Command History",
		} },
		{ ["m"] = {
			function()
				M.show_marks()
			end,
			desc = "Show Marks",
		} },
		{ ["r"] = {
			function()
				M.show_registers()
			end,
			desc = "Show Registers",
		} },
		{ ["j"] = {
			function()
				M.show_jumps()
			end,
			desc = "Show Jumps",
		} },
		{ ["n"] = {
			function()
				M.show_mode_keybindings("n")
			end,
			desc = "Normal Mode Keys",
		} },
		{ ["i"] = {
			function()
				M.show_mode_keybindings("i")
			end,
			desc = "Insert Mode Keys",
		} },
		{ ["v"] = {
			function()
				M.show_mode_keybindings("v")
			end,
			desc = "Visual Mode Keys",
		} },
		mode = "n",
		noremap = true,
		silent = true,
	})

	-- Additional help bindings
	vim.keymap.set("n", "<S-Space>1", function()
		M.show_help_menu()
	end, { desc = "Help Menu" })
	vim.keymap.set("n", "<S-Space>", function()
		M.show_all_keybindings()
	end, { desc = "All Keybindings" })
	vim.keymap.set("n", "<S-Space>?h", function()
		M.search_help()
	end, { desc = "Search Help" })
	vim.keymap.set("n", "<S-Space>?c", function()
		M.show_command_history()
	end, { desc = "Command History" })
	vim.keymap.set("n", "<S-Space>?m", function()
		M.show_marks()
	end, { desc = "Show Marks" })
	vim.keymap.set("n", "<S-Space>?r", function()
		M.show_registers()
	end, { desc = "Show Registers" })
	vim.keymap.set("n", "<S-Space>?j", function()
		M.show_jumps()
	end, { desc = "Show Jumps" })
	vim.keymap.set("n", "<S-Space>?n", function()
		M.show_mode_keybindings("n")
	end, { desc = "Normal Mode Keys" })
	vim.keymap.set("n", "<S-Space>?i", function()
		M.show_mode_keybindings("i")
	end, { desc = "Insert Mode Keys" })
	vim.keymap.set("n", "<S-Space>?v", function()
		M.show_mode_keybindings("v")
	end, { desc = "Visual Mode Keys" })

	-- Register which-key group
	if pcall(require, "which-key") then
		require("which-key").add({
			{ "<leader>?", group = "help", desc = "Help & Info" },
		})
	end

	-- Create user commands
	vim.api.nvim_create_user_command("HelpMenu", function()
		M.show_help_menu()
	end, { desc = "Show help menu" })
	vim.api.nvim_create_user_command("ShowKeys", function()
		M.show_all_keybindings()
	end, { desc = "Show all keybindings" })
	vim.api.nvim_create_user_command("ShowMarks", function()
		M.show_marks()
	end, { desc = "Show marks" })
	vim.api.nvim_create_user_command("ShowRegisters", function()
		M.show_registers()
	end, { desc = "Show registers" })
	vim.api.nvim_create_user_command("ShowJumps", function()
		M.show_jumps()
	end, { desc = "Show jumps" })
end

return M
