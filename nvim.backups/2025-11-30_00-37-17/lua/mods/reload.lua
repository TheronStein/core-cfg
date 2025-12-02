-- Hot Reload System for Neovim Configuration
local M = {}

-- Track what's been loaded to avoid duplicates
M.loaded_modules = {}

-- Clear Lua module cache for a given module pattern
M.clear_cache = function(pattern)
	local count = 0
	for module_name, _ in pairs(package.loaded) do
		if module_name:match(pattern) then
			package.loaded[module_name] = nil
			count = count + 1
		end
	end
	return count
end

-- Reload a specific Lua module
M.reload_module = function(module_name)
	-- Clear from cache
	package.loaded[module_name] = nil

	-- Require it again
	local ok, result = pcall(require, module_name)
	if ok then
		vim.notify("✓ Reloaded: " .. module_name, vim.log.levels.INFO)
		return result
	else
		vim.notify("✗ Failed to reload " .. module_name .. ": " .. result, vim.log.levels.ERROR)
		return nil
	end
end

-- Reload current file
M.reload_current_file = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)

	-- Check if it's a Lua file
	if not filepath:match("%.lua$") then
		vim.notify("Not a Lua file", vim.log.levels.WARN)
		return
	end

	-- Source the file
	vim.cmd("source " .. vim.fn.fnameescape(filepath))
	vim.notify("✓ Reloaded: " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
end

-- Reload keymaps
M.reload_keymaps = function()
	-- Clear existing keymaps cache
	M.clear_cache("^keymaps")
	M.clear_cache("^binds%.")

	-- Reload keymap modules
	local modules = {
		"binds.init",
		"binds.keymap-scopes",
		"binds.keymaps-organized",
	}

	for _, mod in ipairs(modules) do
		M.reload_module(mod)
	end

	vim.notify("✓ Keymaps reloaded", vim.log.levels.INFO)
end

-- Reload LSP configuration
M.reload_lsp = function()
	M.clear_cache("^core%.lsp")

	-- Restart LSP clients
	vim.cmd("LspRestart")

	vim.notify("✓ LSP restarted", vim.log.levels.INFO)
end

-- Reload completion
M.reload_completion = function()
	M.clear_cache("^core%.completion")

	-- Restart blink.cmp if loaded
	local ok, blink = pcall(require, "blink.cmp")
	if ok and blink then
		vim.notify("✓ Completion config reloaded (restart insert mode to see changes)", vim.log.levels.INFO)
	end
end

-- Reload colorscheme/theme
M.reload_theme = function()
	M.clear_cache("^ui%.themes")

	-- Reapply colorscheme
	local current_colorscheme = vim.g.colors_name
	if current_colorscheme then
		vim.cmd("colorscheme " .. current_colorscheme)
		vim.notify("✓ Theme reloaded: " .. current_colorscheme, vim.log.levels.INFO)
	end
end

-- Smart reload based on current file
M.smart_reload = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	local filename = vim.fn.fnamemodify(filepath, ":t")

	-- Detect what type of config file this is
	if filepath:match("keymaps") or filepath:match("binds/") then
		M.reload_keymaps()
	elseif filepath:match("lsp%.lua") then
		M.reload_lsp()
	elseif filepath:match("completion%.lua") then
		M.reload_completion()
	elseif filepath:match("themes%.lua") or filepath:match("colors/") then
		M.reload_theme()
	elseif filepath:match("%.lua$") then
		-- Generic Lua file - just source it
		M.reload_current_file()
	else
		vim.notify("Don't know how to reload this file", vim.log.levels.WARN)
	end
end

-- Full config reload (nuclear option)
M.reload_config = function()
	-- Save current state
	local current_buf = vim.api.nvim_get_current_buf()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)

	vim.notify("Reloading entire config...", vim.log.levels.INFO)

	-- Clear all Lua module cache (except plugins)
	local cleared = 0
	for module_name, _ in pairs(package.loaded) do
		-- Don't clear lazy.nvim and other plugin modules
		if
			not module_name:match("^lazy")
			and not module_name:match("^telescope")
			and not module_name:match("^plenary")
		then
			package.loaded[module_name] = nil
			cleared = cleared + 1
		end
	end

	-- Source init.lua
	vim.cmd("source $MYVIMRC")

	-- Restore cursor position
	pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)

	vim.notify(
		string.format("✓ Config reloaded (%d modules cleared)", cleared),
		vim.log.levels.INFO
	)
end

-- Reload plugins (using lazy.nvim)
M.reload_plugins = function()
	local ok, lazy = pcall(require, "lazy")
	if not ok then
		vim.notify("Lazy.nvim not loaded", vim.log.levels.WARN)
		return
	end

	-- Clear plugin cache
	M.clear_cache("^core%.")
	M.clear_cache("^util%.")
	M.clear_cache("^ui%.")
	M.clear_cache("^git%.")
	M.clear_cache("^ai%.")

	-- Reload lazy.nvim
	lazy.reload()

	vim.notify("✓ Plugins reloaded (some may require restart)", vim.log.levels.INFO)
end

-- Setup commands and keybinds
M.setup = function()
	-- Commands
	vim.api.nvim_create_user_command("ReloadConfig", M.reload_config, {
		desc = "Reload entire Neovim config",
	})

	vim.api.nvim_create_user_command("ReloadCurrent", M.reload_current_file, {
		desc = "Reload current Lua file",
	})

	vim.api.nvim_create_user_command("ReloadSmart", M.smart_reload, {
		desc = "Smart reload based on current file",
	})

	vim.api.nvim_create_user_command("ReloadKeymaps", M.reload_keymaps, {
		desc = "Reload keymaps",
	})

	vim.api.nvim_create_user_command("ReloadLsp", M.reload_lsp, {
		desc = "Reload LSP config",
	})

	vim.api.nvim_create_user_command("ReloadTheme", M.reload_theme, {
		desc = "Reload colorscheme",
	})

	vim.api.nvim_create_user_command("ReloadPlugins", M.reload_plugins, {
		desc = "Reload plugins (lazy.nvim)",
	})

	-- Keybinds
	vim.keymap.set("n", "<leader>rr", M.smart_reload, {
		desc = "Reload (smart)",
		silent = true,
	})

	vim.keymap.set("n", "<leader>rc", M.reload_config, {
		desc = "Reload config (full)",
		silent = true,
	})

	vim.keymap.set("n", "<leader>rf", M.reload_current_file, {
		desc = "Reload current file",
		silent = true,
	})

	vim.keymap.set("n", "<leader>rk", M.reload_keymaps, {
		desc = "Reload keymaps",
		silent = true,
	})

	vim.keymap.set("n", "<leader>rl", M.reload_lsp, {
		desc = "Reload LSP",
		silent = true,
	})

	vim.keymap.set("n", "<leader>rt", M.reload_theme, {
		desc = "Reload theme",
		silent = true,
	})

	vim.keymap.set("n", "<leader>rp", M.reload_plugins, {
		desc = "Reload plugins",
		silent = true,
	})

	-- Quick reload with <localleader>r
	vim.keymap.set("n", "<localleader>r", M.smart_reload, {
		desc = "Quick reload (smart)",
		silent = true,
	})

	-- Source current file with <localleader>s
	vim.keymap.set("n", "<localleader>s", function()
		vim.cmd("source %")
		vim.notify("✓ Sourced: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
	end, {
		desc = "Source current file",
		silent = true,
	})

	vim.notify("Reload system loaded. Use <leader>rr or :ReloadSmart", vim.log.levels.INFO)
end

return M
