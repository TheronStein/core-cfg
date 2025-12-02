local wezterm = require("wezterm")

-- Try to load tmux workspaces module for metadata
local tmux_workspaces = nil
pcall(function()
	tmux_workspaces = require("modules.tmux.workspaces")
end)

return {
	default_opts = {
		icon = " ",
		show_when_not_in_tmux = false,
		fallback_text = "",
		show_workspace_icon = true,
		show_workspace_color = true,
	},
	update = function(window, opts)
		local debug_config = require("config.debug")

		-- Try to get workspace from custom_tabs metadata first (more reliable)
		local mux_window = window:mux_window()
		if mux_window then
			local active_tab = mux_window:active_tab()
			if active_tab and wezterm.GLOBAL.custom_tabs then
				local tab_id = tostring(active_tab:tab_id())
				local tab_meta = wezterm.GLOBAL.custom_tabs[tab_id]

				if debug_config.is_enabled("debug_tabline_tmux") then
					wezterm.log_info("[TABLINE:TMUX] tab_id:", tab_id)
					wezterm.log_info("[TABLINE:TMUX] tab_meta exists:", tostring(tab_meta ~= nil))
					if tab_meta then
						wezterm.log_info("[TABLINE:TMUX] tmux_workspace:", tab_meta.tmux_workspace or "nil")
					end
				end

				if tab_meta and tab_meta.tmux_workspace then
					local server_name = tab_meta.tmux_workspace

					if debug_config.is_enabled("debug_tabline_tmux") then
						wezterm.log_info("[TABLINE:TMUX] Using workspace from tab metadata:", server_name)
					end

					-- Check if we have workspace metadata
					if tmux_workspaces then
						local workspace = tmux_workspaces.get_workspace_info(server_name)
						if debug_config.is_enabled("debug_tabline_tmux") then
							wezterm.log_info("[TABLINE:TMUX] workspace found:", tostring(workspace ~= nil))
							if workspace then
								wezterm.log_info(
									"[TABLINE:TMUX] workspace:",
									workspace.display_name,
									"color:",
									workspace.color
								)
							end
						end
						if workspace then
							-- Update tab metadata with workspace color if missing
							if not tab_meta.tmux_workspace_color then
								tab_meta.tmux_workspace_color = workspace.color
							end

							-- Set icon with workspace color as background
							opts.icon = {
								workspace.icon,
								color = {
									fg = "#292D3E", -- Dark text
									bg = workspace.color, -- Workspace color background
								},
							}

							-- Set background color for the text to match icon
							opts.color = {
								fg = "#292D3E", -- Dark text
								bg = workspace.color, -- Workspace color background
							}

							-- Return shortname in uppercase - the component system will handle formatting
							return (workspace.shortname or workspace.display_name):upper()
						end
					end

					-- Fallback: show server name without metadata
					return server_name
				end
			end
		end

		-- No tmux workspace found - fall back to showing domain name
		if debug_config.is_enabled("debug_tabline_tmux") then
			wezterm.log_info("[TABLINE:TMUX] Not in tmux, showing domain name")
		end

		-- Get domain name from active pane
		local pane = window:active_pane()
		if pane then
			local success, domain_name = pcall(function()
				return pane:get_domain_name()
			end)

			if success and domain_name then
				local domain_type, new_domain_name = domain_name:match("^([^:]+):%s*(.*)")
				new_domain_name = new_domain_name ~= "" and new_domain_name or domain_name
				return new_domain_name:upper()
			end
		end

		return opts.show_when_not_in_tmux and opts.fallback_text or nil
	end,
}
