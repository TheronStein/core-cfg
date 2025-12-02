local wezterm = require("wezterm")
local debug_config = require("config.debug")

return {
	default_opts = {},
	update = function(tab, opts)
		local tab_id_str = tostring(tab.tab_id)
		local has_custom = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id_str]

		if debug_config.is_enabled("debug_tabline_smart_title") then
			wezterm.log_info("[TABLINE:SMART_TITLE] update() called - tab_id=" .. tab_id_str .. ", has_custom=" .. tostring(has_custom ~= nil))
			if wezterm.GLOBAL.custom_tabs then
				wezterm.log_info("[TABLINE:SMART_TITLE] custom_tabs data: " .. wezterm.to_string(wezterm.GLOBAL.custom_tabs))
			end
		end

		if has_custom then
			-- Tab has custom title and icon
			local custom_data = wezterm.GLOBAL.custom_tabs[tab_id_str]
			local index = tab.tab_index + 1

			-- Get custom icon
			local icon = ""
			if custom_data.icon_key then
				-- icon_key stores the actual icon character, use it directly
				icon = custom_data.icon_key
				if debug_config.is_enabled("debug_tabline_smart_title") then
					wezterm.log_info("[TABLINE:SMART_TITLE] Using custom icon: " .. icon)
				end
			else
				if debug_config.is_enabled("debug_tabline_smart_title") then
					wezterm.log_info("[TABLINE:SMART_TITLE] No icon_key set for this tab")
				end
			end

			-- Build title from tmux workspace shortname + session name
			local title_text = custom_data.title
			if custom_data.tmux_workspace then
				-- Get shortname from workspace
				local tmux_workspaces = nil
				pcall(function()
					tmux_workspaces = require("modules.tmux.workspaces")
				end)

				local server_name = custom_data.tmux_workspace
				if tmux_workspaces then
					local workspace_info = tmux_workspaces.get_workspace_info(custom_data.tmux_workspace)
					if workspace_info and workspace_info.shortname then
						server_name = workspace_info.shortname
					end
				end

				-- Get session name from tab_tmux_info
				local tab_tmux_info = wezterm.GLOBAL.tab_tmux_info and wezterm.GLOBAL.tab_tmux_info[tab_id_str]
				local tmux_session = tab_tmux_info and tab_tmux_info.session or custom_data.tmux_workspace

				title_text = server_name .. "/" .. tmux_session
			end

			-- -- Get process icon for fallback
			-- local process_icon = temp_opts.icon
			-- 		and (type(temp_opts.icon) == "table" and temp_opts.icon[1] or temp_opts.icon)
			-- 	or ""
			-- -- local process_comp = require('gui.tabline.components.tab.process')
			-- -- local temp_opts = { icons_enabled = true, process_to_icon = process_comp.default_opts.process_to_icon }
			-- -- local process_name = process_comp.update(tab, temp_opts)
			-- -- process_icon =

			-- Check for zoomed pane
			local zoomed = ""
			for _, pane in ipairs(tab.panes) do
				if pane.is_zoomed then
					zoomed = wezterm.nerdfonts.oct_zoom_in
					break
				end
			end

			-- Check for unseen output
			local has_output = false
			for _, pane in ipairs(tab.panes) do
				if pane.has_unseen_output then
					has_output = true
					break
				end
			end

			local output_icon = has_output and wezterm.nerdfonts.md_bell_badge_outline or ""

			-- Truncate title to fit in narrower tabs
			local title = title_text
			local max_title_len = 5
			if debug_config.is_enabled("debug_tabline_smart_title") then
				wezterm.log_info("[TABLINE:SMART_TITLE] Before truncate: '" .. title .. "' (len=" .. #title .. ")")
			end
			if #title > max_title_len then
				title = title:sub(1, max_title_len - 2) .. ".."
				if debug_config.is_enabled("debug_tabline_smart_title") then
					wezterm.log_info("[TABLINE:SMART_TITLE] After truncate: '" .. title .. "'")
				end
			end

			if tab.is_active then
				-- Active: {index} {icon} {tab_name} {process_icon}/{zoomed} (zoomed replaces process_icon if zoomed)
				-- local suffix = zoomed or index
				local prefix = zoomed ~= "" and zoomed or icon
				-- index or         if pane.is_zoomed then
				-- return string.format("%s %s %d", icon, custom_data.title, display_icon, suffix)
				return string.format(" %s  %s", prefix, title)
			else
				-- Inactive: {index} {tab_name} {process_icon}{output} (output replaces process icon if there's output)
				-- local display_icon = has_output and output_icon or icon
				return string.format(" %s  %s", icon, title)
			end
		else
			-- Tab uses default formatting
			local index = tab.tab_index + 1

			-- Get parent directory (cwd)
			local cwd = ""
			if tab.active_pane and tab.active_pane.current_working_dir then
				local cwd_path = tab.active_pane.current_working_dir.file_path or ""
				cwd = cwd_path:match("([^/]+)/?$") or ""
			end

			-- Get process icon
			local process_comp = require("tabline.components.tab.process")
			local temp_opts = {
				icons_enabled = true,
				process_to_icon = process_comp.default_opts.process_to_icon,
			}
			process_comp.update(tab, temp_opts)
			local process_icon = temp_opts.icon
					and (type(temp_opts.icon) == "table" and temp_opts.icon[1] or temp_opts.icon)
				or ""

			-- Check for zoomed pane
			local zoomed = ""
			for _, pane in ipairs(tab.panes) do
				if pane.is_zoomed then
					zoomed = wezterm.nerdfonts.oct_zoom_in
					break
				end
			end

			-- Check for unseen output
			local has_output = false
			for _, pane in ipairs(tab.panes) do
				if pane.has_unseen_output then
					has_output = true
					break
				end
			end
			local output_icon = has_output and wezterm.nerdfonts.md_bell_badge_outline or ""

			if tab.is_active then
				-- Active: {index} {cwd} {process_icon or zoomed}
				local suffix = zoomed ~= "" and zoomed or process_icon
				return string.format("%s %s", suffix, cwd)
			else
				-- Inactive: {index} {cwd} {process_icon or output_icon}
				-- local suffix = has_output and output_icon or process_icon
				return string.format("%s %s", process_icon, cwd)
			end
		end
	end,
}
