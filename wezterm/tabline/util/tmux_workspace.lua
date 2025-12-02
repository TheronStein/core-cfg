local wezterm = require("wezterm")

local M = {}

function M.get_tmux_workspace_color(server_name, opts)
	local debug_config = require("config.debug")
	local tmux_workspaces = require("modules.tmux.workspaces")

	-- Check if we have workspace metadata
	if tmux_workspaces then
		local workspace = tmux_workspaces.get_workspace_info(server_name)
		if debug_config.is_enabled("debug_tabline_tmux") then
			wezterm.log_info("[TABLINE:TMUX] workspace found:", tostring(workspace ~= nil))
			if workspace then
				wezterm.log_info("[TABLINE:TMUX] workspace:", workspace.display_name, "color:", workspace.color)
			end
		end
		if workspace then
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

			-- Return string in uppercase - the component system will handle formatting
			return workspace.display_name:upper()
		end
	end

	-- Fallback: show server name without metadata
	return server_name
end

return M

-- -- Check if we have workspace metadata
--           if tmux_workspaces then
--             local workspace = tmux_workspaces.get_workspace_info(server_name)
--             if debug_config.is_enabled('debug_tabline_tmux') then
--               wezterm.log_info('[TABLINE:TMUX] workspace found:', tostring(workspace ~= nil))
--               if workspace then
--                 wezterm.log_info('[TABLINE:TMUX] workspace:', workspace.display_name, 'color:', workspace.color)
--               end
--             end
--             if workspace then
--               -- Set icon with workspace color as background
--               opts.icon = {
--                 workspace.icon,
--                 color = {
--                   fg = "#292D3E", -- Dark text
--                   bg = workspace.color, -- Workspace color background
--                 },
--               }
--
--               -- Set background color for the text to match icon
--               opts.color = {
--                 fg = "#292D3E", -- Dark text
--                 bg = workspace.color, -- Workspace color background
--               }
--
--               -- Return string in uppercase - the component system will handle formatting
--               return workspace.display_name:upper()
--             end
--           end
--
--           -- Fallback: show server name without metadata
--           return server_name
--         end
--       end
--     end
--
