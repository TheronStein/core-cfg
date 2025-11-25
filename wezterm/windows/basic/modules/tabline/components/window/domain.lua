local wezterm = require("wezterm")
local util = require("tabline.util")

return {
	default_opts = {
		domain_to_icon = {
			default = wezterm.nerdfonts.md_monitor,
			ssh = wezterm.nerdfonts.md_ssh,
			sshmux = wezterm.nerdfonts.md_ssh,
			wsl = wezterm.nerdfonts.md_microsoft_windows,
			docker = wezterm.nerdfonts.md_docker,
			unix = wezterm.nerdfonts.cod_terminal_linux,
		},
	},
	update = function(window, opts)
		-- Wrap in pcall to handle race conditions when panes are closed
		local success, pane = pcall(function()
			return window:active_pane()
		end)

		if not success or not pane then
			return nil
		end

		-- Get domain name with error handling
		local domain_success, domain_name = pcall(function()
			return pane:get_domain_name()
		end)

		if not domain_success or not domain_name then
			return nil
		end

		local domain_type, new_domain_name = domain_name:match("^([^:]+):%s*(.*)")
		domain_type = (domain_type or "default"):lower()
		new_domain_name = new_domain_name ~= "" and new_domain_name or domain_name

		if opts.icons_enabled and opts.domain_to_icon then
			local icon = opts.domain_to_icon[domain_type] or opts.domain_to_icon.default
			util.overwrite_icon(opts, icon)
		end

		if new_domain_name == "local" then
			new_domain_name = wezterm.hostname()
			opts.icon = { wezterm.nerdfonts.linux_archlinux, align = "right" }
		elseif wezterm.hostname() == "chaoscore" then
			opts.icon = { " ", align = "right" } -- Custom icon for chaoscore
		elseif opts.icon then
			-- Set alignment for other icons too
			if type(opts.icon) == "string" then
				opts.icon = { opts.icon, align = "right" }
			else
				opts.icon.align = "right"
			end
		end

		return new_domain_name:upper()
	end,
}
