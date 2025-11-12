local wezterm = require("wezterm")
local M = {}

-- Path to the templates JSON file
M.templates_file = wezterm.config_dir .. "/.data/tabs/templates.json"

-- Load templates from JSON file
function M.load_templates()
	local file = io.open(M.templates_file, "r")
	if not file then
		wezterm.log_info("No tab templates file found, creating new one")
		return {}
	end

	local content = file:read("*a")
	file:close()

	if content == "" then
		return {}
	end

	local success, templates = pcall(wezterm.json_parse, content)
	if not success then
		wezterm.log_error("Failed to parse tab templates: " .. tostring(templates))
		return {}
	end

	return templates or {}
end

-- Save templates to JSON file
function M.save_templates(templates)
	-- Ensure directory exists
	os.execute("mkdir -p " .. wezterm.config_dir .. "/.data/tabs")

	local file = io.open(M.templates_file, "w")
	if not file then
		wezterm.log_error("Failed to open templates file for writing")
		return false
	end

	local content = wezterm.json_encode(templates)
	file:write(content)
	file:close()

	return true
end

-- Save current tab as a template
function M.save_current_tab_as_template(window, pane)
	local tab = window:active_tab()
	local tab_id = tostring(tab:tab_id())

	-- Get the current custom tab data if it exists
	local custom_tab = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]

	if not custom_tab then
		window:toast_notification(
			"Tab Template",
			"No custom name/icon set for this tab. Please rename it first.",
			nil,
			3000
		)
		return
	end

	-- Prompt for template name
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = "Enter template name:",
			action = wezterm.action_callback(function(win, p, template_name)
				if not template_name or template_name == "" then
					return
				end

				-- Load existing templates
				local templates = M.load_templates()

				-- Create new template
				local template = {
					name = template_name,
					title = custom_tab.title,
					icon = custom_tab.icon_key,
					created_at = os.date("%Y-%m-%d %H:%M:%S"),
					-- Store full title for display
					full_title = custom_tab.icon_key and
						(custom_tab.icon_key .. " " .. custom_tab.title) or
						custom_tab.title
				}

				-- Check if this tab is attached to a tmux session
				if custom_tab.tmux_session then
					template.tmux_session = custom_tab.tmux_session
					wezterm.log_info("Saved template with tmux session: " .. custom_tab.tmux_session)
				end

				templates[template_name] = template

				-- Save templates
				if M.save_templates(templates) then
					local msg = "Template saved: " .. template_name
					if template.tmux_session then
						msg = msg .. " (tmux: " .. template.tmux_session .. ")"
					end
					win:toast_notification("Tab Template", msg, nil, 2000)
					wezterm.log_info("Saved tab template: " .. template_name)
				else
					win:toast_notification(
						"Tab Template",
						"Failed to save template",
						nil,
						3000
					)
				end
			end)
		}),
		pane
	)
end

-- Load a template and apply to current tab
function M.load_template(window, pane)
	local templates = M.load_templates()

	if not templates or next(templates) == nil then
		window:toast_notification(
			"Tab Template",
			"No templates saved yet",
			nil,
			2000
		)
		return
	end

	local choices = {}

	-- Add header
	table.insert(choices, {
		label = "Select a template to load:",
		id = "__header__"
	})

	table.insert(choices, {
		label = "─────────────────────────────",
		id = "__separator__"
	})

	-- Sort templates by name
	local sorted_names = {}
	for name, _ in pairs(templates) do
		table.insert(sorted_names, name)
	end
	table.sort(sorted_names)

	-- Add templates as choices
	for _, name in ipairs(sorted_names) do
		local template = templates[name]
		local display = template.full_title .. " (" .. name .. ")"
		if template.created_at then
			display = display .. " - " .. template.created_at
		end
		table.insert(choices, {
			label = display,
			id = name
		})
	end

	-- Add management options
	table.insert(choices, {
		label = "─────────────────────────────",
		id = "__separator2__"
	})

	table.insert(choices, {
		label = "🗑️  Delete a template",
		id = "__delete__"
	})

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Load Tab Template",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				if not id or id:sub(1, 2) == "__" then
					if id == "__delete__" then
						M.delete_template(win, p)
					end
					return
				end

				local template = templates[id]
				if template then
					-- Apply template to current tab
					if not wezterm.GLOBAL.custom_tabs then
						wezterm.GLOBAL.custom_tabs = {}
					end

					local tab_id = tostring(win:active_tab():tab_id())
					wezterm.GLOBAL.custom_tabs[tab_id] = {
						title = template.title,
						icon_key = template.icon
					}

					win:toast_notification(
						"Tab Template",
						"Applied template: " .. template.full_title,
						nil,
						2000
					)

					wezterm.log_info("Applied tab template: " .. id)
				end
			end)
		}),
		pane
	)
end

-- Delete a template
function M.delete_template(window, pane)
	local templates = M.load_templates()

	if not templates or next(templates) == nil then
		window:toast_notification(
			"Tab Template",
			"No templates to delete",
			nil,
			2000
		)
		return
	end

	local choices = {}

	-- Add go back option as first item
	table.insert(choices, {
		label = "⬅️  Go back to Tab Manager",
		id = "__back__"
	})

	table.insert(choices, {
		label = "─────────────────────────────",
		id = "__separator__"
	})

	-- Sort templates by name
	local sorted_names = {}
	for name, _ in pairs(templates) do
		table.insert(sorted_names, name)
	end
	table.sort(sorted_names)

	-- Add templates as choices
	for _, name in ipairs(sorted_names) do
		local template = templates[name]
		local display = "🗑️  " .. template.full_title .. " (" .. name .. ")"
		table.insert(choices, {
			label = display,
			id = name
		})
	end

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Delete Tab Template",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				if not id or id:sub(1, 2) == "__" then
					if id == "__back__" then
						local tab_manager = require("modules.tab_manager")
						tab_manager.show_main_menu(win, p)
					end
					return
				end

				-- Delete the template
				templates[id] = nil

				-- Save updated templates
				if M.save_templates(templates) then
					win:toast_notification(
						"Tab Template",
						"Template deleted: " .. id,
						nil,
						2000
					)
					wezterm.log_info("Deleted tab template: " .. id)
				else
					win:toast_notification(
						"Tab Template",
						"Failed to delete template",
						nil,
						3000
					)
				end
			end)
		}),
		pane
	)
end

-- Quick load: Apply most recent template
function M.quick_load_recent(window, pane)
	local templates = M.load_templates()

	if not templates or next(templates) == nil then
		window:toast_notification(
			"Tab Template",
			"No templates saved yet",
			nil,
			2000
		)
		return
	end

	-- Find most recent template
	local most_recent = nil
	local most_recent_time = nil

	for name, template in pairs(templates) do
		if template.created_at then
			if not most_recent_time or template.created_at > most_recent_time then
				most_recent = template
				most_recent_time = template.created_at
			end
		end
	end

	if most_recent then
		-- Apply template to current tab
		if not wezterm.GLOBAL.custom_tabs then
			wezterm.GLOBAL.custom_tabs = {}
		end

		local tab_id = tostring(window:active_tab():tab_id())
		wezterm.GLOBAL.custom_tabs[tab_id] = {
			title = most_recent.title,
			icon_key = most_recent.icon
		}

		window:toast_notification(
			"Tab Template",
			"Applied recent: " .. most_recent.full_title,
			nil,
			2000
		)
	end
end

-- List all templates (for debugging or info)
function M.list_templates(window, pane)
	local templates = M.load_templates()

	if not templates or next(templates) == nil then
		window:toast_notification(
			"Tab Templates",
			"No templates saved",
			nil,
			2000
		)
		return
	end

	local output = "Tab Templates:\n\n"

	-- Sort templates by name
	local sorted_names = {}
	for name, _ in pairs(templates) do
		table.insert(sorted_names, name)
	end
	table.sort(sorted_names)

	for _, name in ipairs(sorted_names) do
		local template = templates[name]
		output = output .. "• " .. name .. ": " .. template.full_title
		if template.created_at then
			output = output .. " (created: " .. template.created_at .. ")"
		end
		output = output .. "\n"
	end

	window:toast_notification(
		"Tab Templates",
		output,
		nil,
		5000
	)
end

-- Main menu - Load template (displays all templates for selection)
-- Note: Save and Delete are now accessed through the Tab Manager menu
function M.show_menu(window, pane)
	-- Force a fresh load of templates
	local templates = M.load_templates()
	local choices = {}

	-- Debug logging
	wezterm.log_info("Tab Templates - show_menu called")
	wezterm.log_info("Templates file: " .. M.templates_file)
	wezterm.log_info("Templates type: " .. type(templates))
	wezterm.log_info("Templates loaded: " .. wezterm.json_encode(templates or {}))

	-- Count templates
	local count = 0
	if templates then
		for _ in pairs(templates) do
			count = count + 1
		end
	end
	wezterm.log_info("Template count: " .. tostring(count))

	-- Check if there are templates
	if not templates or next(templates) == nil then
		window:toast_notification(
			"Tab Templates",
			"No templates saved yet. Save a template first!",
			nil,
			3000
		)
		return
	end

	-- Add go back option as first item
	table.insert(choices, {
		label = "⬅️  Go back to Tab Manager",
		id = "__back__"
	})

	table.insert(choices, {
		label = "─────────────────────────────",
		id = "__separator_top__"
	})

	-- Add templates directly (no save/delete options)
	if templates and next(templates) ~= nil then
		wezterm.log_info("Templates found, adding to menu")

		-- Sort templates by name
		local sorted_names = {}
		for name, _ in pairs(templates) do
			table.insert(sorted_names, name)
		end
		table.sort(sorted_names)

		-- Add each template as a choice
		for _, name in ipairs(sorted_names) do
			local template = templates[name]
			local display = template.full_title .. " (" .. name .. ")"
			if template.tmux_session then
				display = display .. " 📺 tmux:" .. template.tmux_session
			end
			if template.created_at then
				display = display .. " - " .. template.created_at
			end
			wezterm.log_info("Adding template to menu: " .. display)
			table.insert(choices, {
				label = display,
				id = name
			})
		end
	else
		wezterm.log_info("No templates found or templates is nil/empty")
	end

	wezterm.log_info("Total choices in menu: " .. tostring(#choices))

	-- Show the menu
	window:perform_action(
		wezterm.action.InputSelector({
			title = "📂 Load Tab Template",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				if not id then
					return
				end

				-- Handle go back
				if id:sub(1, 2) == "__" then
					if id == "__back__" then
						local tab_manager = require("modules.tab_manager")
						tab_manager.show_main_menu(win, p)
					end
					return
				end

				-- Load the selected template
				local template = templates[id]
				if template then
					wezterm.log_info("Loading template: " .. id)
					wezterm.log_info("Template data: " .. wezterm.json_encode(template))

					-- Check if template has tmux session
					if template.tmux_session then
						-- Try to load tmux_sessions module
						local ok, tmux_sessions = pcall(require, "modules.tmux_sessions")
						if ok and tmux_sessions then
							-- Spawn new tab with tmux session
							local tab = tmux_sessions.spawn_tab_with_custom_session(
								win,
								p,
								template.tmux_session,
								template.title,
								template.icon,
								true -- create if missing
							)

							if tab then
								win:toast_notification(
									"Tab Template",
									"Loaded " .. template.full_title .. " with tmux: " .. template.tmux_session,
									nil,
									2000
								)
							end
						else
							wezterm.log_error("Failed to load tmux_sessions module")
							win:toast_notification(
								"Tab Template",
								"Error: tmux_sessions module not available",
								nil,
								3000
							)
						end
					else
						-- No tmux session, just apply template to current tab
						if not wezterm.GLOBAL.custom_tabs then
							wezterm.GLOBAL.custom_tabs = {}
						end

						local tab_id = tostring(win:active_tab():tab_id())
						wezterm.GLOBAL.custom_tabs[tab_id] = {
							title = template.title,
							icon_key = template.icon  -- template stores as 'icon', we use as 'icon_key'
						}

						win:toast_notification(
							"Tab Template",
							"Applied template: " .. template.full_title,
							nil,
							2000
						)

						wezterm.log_info("Applied tab template: " .. id)
					end
				else
					wezterm.log_error("Template not found: " .. id)
				end
			end)
		}),
		pane
	)
end

return M