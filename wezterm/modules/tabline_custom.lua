-- ~/.core/.sys/configs/wezterm/util/tabline.lua

local wezterm = require("wezterm")

local nf = wezterm.nerdfonts

local M = {}

function M.setup(config)
	if not wezterm.gui then
		wezterm.log_info("Skipping tabline setup - not running in GUI context")
		return nil
	end

	-- Load local tabline module (assuming modules/tabline/init.lua is the entry point; adjust path if needed)
	local success, tabline = pcall(require, "gui.tabline")

	if not success then
		wezterm.log_error("Failed to load tabline module: " .. tostring(tabline))
		return nil
	end

	-- All custom components are now proper modules in components/window/
	-- No need for inline functions anymore

	-- Load preserved tabline theme (independent of workspace themes)
	local preserved_theme = require("modules.tabline_theme_preserved")

	-- Configure tabline
	local tabline_success, err = pcall(function()
		tabline.setup({
			options = {
				icons_enabled = true,
				icons_only = false,
				padding = 1, -- Minimal padding
				-- Always use Catppuccin Mocha for tabline (hardcoded, not affected by workspace themes)
				theme = "Catppuccin Mocha",
				tab_separators = {
					left = "",
					right = "",
				},
				-- Use preserved theme overrides
				theme_overrides = preserved_theme.preserved_theme,
			},
			sections = {
				tabline_a = { "mode" },
				tabline_b = { "tmux_server" },
				tabline_c = {},
				tab_active = {
					{ "smart_title", padding = { left = 1, right = 1 } },
				},
				tab_inactive = {
					{ "smart_title", padding = { left = 1, right = 1 } },
				},
				tabline_x = { "local_storage" },
				tabline_y = { "github" },
				tabline_z = { "domain" },
			},
			extensions = { "resurrect" },
		})
	end)

	if not tabline_success then
		wezterm.log_error("Failed to configure tabline: " .. tostring(err))
		return nil
	end

	return tabline
end

return M
