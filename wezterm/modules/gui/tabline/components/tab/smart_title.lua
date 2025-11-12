local wezterm = require("wezterm")
local debug_config = require("config.debug")
local DEBUG = debug_config.debug_mods_smart_title or debug_config.debug_mods_tabline or debug_config.debug_all

if DEBUG then
	wezterm.log_info("===== smart_title.lua LOADED =====")
end

return {
	default_opts = {},
	update = function(tab, opts)
		if DEBUG then
			wezterm.log_info("===== smart_title.update() CALLED =====")
			wezterm.log_info("Tab ID: " .. tostring(tab.tab_id))
			wezterm.log_info("Tab Index: " .. tostring(tab.tab_index))
			wezterm.log_info("Is Active: " .. tostring(tab.is_active))
		end
		local tab_id_str = tostring(tab.tab_id)
		local has_custom = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id_str]

		if DEBUG then
			wezterm.log_info("smart_title: tab_id=" .. tab_id_str .. ", has_custom=" .. tostring(has_custom ~= nil))
			if wezterm.GLOBAL.custom_tabs then
				wezterm.log_info("custom_tabs data: " .. wezterm.to_string(wezterm.GLOBAL.custom_tabs))
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
				if DEBUG then
					wezterm.log_info("Using custom icon: " .. icon)
				end
			else
				if DEBUG then
					wezterm.log_info("No icon_key set for this tab")
				end
			end

			-- Get cwd directory
			local cwd = ""
			local cwd_uri = tab.active_pane.current_working_dir
			if cwd_uri then
				local file_path = cwd_uri.file_path
				cwd = file_path:match("([^/]+)/?$") or ""
				if opts.max_length and cwd and #cwd > opts.max_length then
					cwd = cwd:sub(1, opts.max_length - 1) .. "…"
				end
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

			if tab.is_active then
				-- Active: {index} {icon} {tab_name} {process_icon}/{zoomed} (zoomed replaces process_icon if zoomed)
				-- local suffix = zoomed or index
				local prefix = zoomed ~= "" and zoomed or icon
				-- index or         if pane.is_zoomed then
				-- return string.format("%s %s %d", icon, custom_data.title, display_icon, suffix)
				return string.format("%s  %s", prefix, custom_data.title)
			else
				-- Inactive: {index} {tab_name} {process_icon}{output} (output replaces process icon if there's output)
				-- local display_icon = has_output and output_icon or icon
				if opts.max_length and #custom_data.title > opts.max_length then
					custom_data.title = custom_data.title:sub(1, opts.max_length - 1) .. "…"
				end
				return string.format("%s  %s", icon, custom_data.title)
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
			local process_comp = require("gui.tabline.components.tab.process")
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
