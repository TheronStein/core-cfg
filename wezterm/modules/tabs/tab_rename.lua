local wezterm = require("wezterm")
local nf = wezterm.nerdfonts
local M = {}

-- Safe icon getter - returns the icon or a fallback if it doesn't exist
local function safe_icon(icon_ref, fallback)
	if icon_ref ~= nil then
		return icon_ref
	end
	wezterm.log_warn("Icon reference is nil, using fallback")
	return fallback or "?"
end

-- Load icons from a nerdfont data file
local function load_icons_from_file(filepath, prefix)
	local icons = {}
	local file = io.open(filepath, "r")
	if not file then
		wezterm.log_error("Could not open icon file: " .. filepath)
		return icons
	end

	-- Special icon mappings for custom icons that don't have direct nerdfont entries
	local special_mappings = {
		custom_yazi = "📁",  -- Use folder emoji for yazi file manager
	}

	for line in file:lines() do
		-- Skip comments and empty lines
		if not line:match("^#") and line:match("%S") then
			local icon_name = line:match("^%s*(.-)%s*$") -- trim whitespace
			local icon_glyph = nil

			-- Check for special mappings first
			if special_mappings[icon_name] then
				icon_glyph = special_mappings[icon_name]
			elseif nf[icon_name] then
				icon_glyph = nf[icon_name]
			end

			if icon_glyph then
				-- Create a friendly description from the icon name
				local desc = icon_name:gsub("^" .. prefix .. "_", ""):gsub("_", " ")
				desc = desc:gsub("(%a)(%w*)", function(first, rest)
					return first:upper() .. rest
				end)
				table.insert(icons, {
					name = icon_name,
					icon = icon_glyph,
					desc = desc
				})
			end
		end
	end

	file:close()
	wezterm.log_info("Loaded " .. #icons .. " icons from " .. filepath)
	return icons
end

-- Icon sets with popular icons from each category
-- NOTE: Font Awesome and Linux Logos use hardcoded lists for curated selections
-- All other categories load from auto-generated data files for full coverage
M.icon_sets = {
	material_design = {
		name = "Material Design Icons (md_)",
		prefix = "md_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-material-design.txt",
			"md"
		)
	},
	codicons = {
		name = "Codicons (cod_)",
		prefix = "cod_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-codicons.txt",
			"cod"
		)
	},
	devicons = {
		name = "Devicons (dev_)",
		prefix = "dev_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-devicons.txt",
			"dev"
		)
	},
	font_awesome = {
		name = "Font Awesome (fa_)",
		prefix = "fa_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-font-awesome.txt",
			"fa"
		)
	},
	fa_extension = {
		name = "Font Awesome Extension (fae_)",
		prefix = "fae_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-fa-extension.txt",
			"fae"
		)
	},
	octicons = {
		name = "Octicons (oct_)",
		prefix = "oct_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-octicons.txt",
			"oct"
		)
	},
	seti_ui = {
		name = "Seti UI (seti_)",
		prefix = "seti_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-seti-ui.txt",
			"seti"
		)
	},
	powerline = {
		name = "Powerline (pl_)",
		prefix = "pl_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-powerline.txt",
			"pl"
		)
	},
	powerline_extra = {
		name = "Powerline Extra (ple_)",
		prefix = "ple_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-powerline-extra.txt",
			"ple"
		)
	},
	pomicons = {
		name = "Pomicons (pom_)",
		prefix = "pom_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-pomicons.txt",
			"pom"
		)
	},
	weather = {
		name = "Weather Icons (weather_)",
		prefix = "weather_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-weather.txt",
			"weather"
		)
	},
	linux_logos = {
		name = "Linux Logos (linux_)",
		prefix = "linux_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-linux-logos.txt",
			"linux"
		)
	},
	custom = {
		name = "Custom Icons (custom_)",
		prefix = "custom_",
		icons = load_icons_from_file(
			wezterm.config_dir .. "/scripts/nerdfont-browser/data/wezterm-custom.txt",
			"custom"
		)
	},
}

-- Show icon set selection menu
function M.show_icon_set_menu(window, pane, callback)
	local choices = {}

	-- Define explicit order for icon sets (most popular first)
	local icon_set_order = {
		"material_design",
		"codicons",
		"devicons",
		"font_awesome",
		"fa_extension",
		"octicons",
		"seti_ui",
		"linux_logos",
		"custom",
		"powerline",
		"powerline_extra",
		"pomicons",
		"weather"
	}

	-- Add icon set choices in order
	for _, set_id in ipairs(icon_set_order) do
		local set_data = M.icon_sets[set_id]
		if set_data then
			table.insert(choices, {
				label = set_data.name .. " (" .. #set_data.icons .. " icons)",
				id = "set:" .. set_id
			})
		end
	end

	-- Add separator
	table.insert(choices, {
		label = "─────────────────────────────",
		id = "__separator__"
	})

	-- Add special options
	table.insert(choices, {
		label = "✏️  Enter custom icon/emoji",
		id = "__custom__"
	})

	table.insert(choices, {
		label = "📝 No icon, just text",
		id = "__text_only__"
	})

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Select Icon Set",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				if not id or id == "__separator__" then
					return
				end

				if id == "__custom__" then
					M.prompt_custom_icon(win, p, callback)
				elseif id == "__text_only__" then
					M.prompt_tab_title(win, p, "", callback)
				elseif id:sub(1, 4) == "set:" then
					local set_id = id:sub(5)
					M.show_icon_picker(win, p, set_id, callback)
				end
			end)
		}),
		pane
	)
end

-- Show icons from a specific set
function M.show_icon_picker(window, pane, set_id, callback)
	local set_data = M.icon_sets[set_id]
	if not set_data then
		window:toast_notification("Tab Rename", "Icon set not found", nil, 3000)
		return
	end

	local choices = {}

	-- Add back option
	table.insert(choices, {
		label = "⬅️  Back to icon sets",
		id = "__back__"
	})

	table.insert(choices, {
		label = "─────────────────────────────",
		id = "__separator__"
	})

	-- Add icons
	for _, icon_data in ipairs(set_data.icons) do
		table.insert(choices, {
			label = icon_data.icon .. "  " .. icon_data.desc .. " (" .. icon_data.name .. ")",
			id = "icon:" .. icon_data.icon
		})
	end

	window:perform_action(
		wezterm.action.InputSelector({
			title = set_data.name,
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				if not id or id == "__separator__" then
					return
				end

				if id == "__back__" then
					M.show_icon_set_menu(win, p, callback)
				elseif id:sub(1, 5) == "icon:" then
					local icon = id:sub(6)
					M.prompt_tab_title(win, p, icon, callback)
				end
			end)
		}),
		pane
	)
end

-- Prompt for custom icon/emoji
function M.prompt_custom_icon(window, pane, callback)
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = "Enter custom icon or emoji:",
			action = wezterm.action_callback(function(win, p, icon)
				if icon and icon ~= "" then
					M.prompt_tab_title(win, p, icon, callback)
				end
			end)
		}),
		pane
	)
end

-- Prompt for tab title
function M.prompt_tab_title(window, pane, icon, callback)
	local description = icon ~= "" and "Enter tab title (icon: " .. icon .. "):" or "Enter tab title:"

	window:perform_action(
		wezterm.action.PromptInputLine({
			description = description,
			action = wezterm.action_callback(function(win, p, title)
				if title and title ~= "" then
					local full_title = icon ~= "" and (icon .. " " .. title) or title
					if callback then
						callback(win, p, full_title, icon, title)
					else
						-- Default behavior: store in custom_tabs
						if not wezterm.GLOBAL.custom_tabs then
							wezterm.GLOBAL.custom_tabs = {}
						end

						local tab_id = tostring(win:active_tab():tab_id())
						wezterm.GLOBAL.custom_tabs[tab_id] = {
							title = title,
							icon_key = icon ~= "" and icon or nil
						}

						win:toast_notification("Tab Rename", "Tab renamed to: " .. full_title, nil, 2000)
					end
				end
			end)
		}),
		pane
	)
end

-- Main entry point for tab rename (name first, then icon)
function M.rename_tab(window, pane)
	wezterm.log_info("=== TAB RENAME STARTED ===")

	-- Prompt for name first
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = "Enter tab title:",
			action = wezterm.action_callback(function(win, p, tab_title)
				wezterm.log_info("Got tab title: " .. tostring(tab_title))

				if not tab_title or tab_title == "" then
					wezterm.log_info("Tab title was empty, aborting")
					return
				end

				-- Now show icon picker with the title we have
				wezterm.log_info("Calling show_icon_set_menu_with_title")
				M.show_icon_set_menu_with_title(win, p, tab_title)
			end)
		}),
		pane
	)
end

-- Icon picker with pre-defined title
function M.show_icon_set_menu_with_title(window, pane, tab_title)
	wezterm.log_info("=== ICON SET MENU FOR: " .. tab_title .. " ===")

	local choices = {}

	-- Define explicit order for icon sets (most popular first)
	local icon_set_order = {
		"material_design",
		"codicons",
		"devicons",
		"font_awesome",
		"fa_extension",
		"octicons",
		"seti_ui",
		"linux_logos",
		"custom",
		"powerline",
		"powerline_extra",
		"pomicons",
		"weather"
	}

	-- Add icon set choices in order
	for _, set_id in ipairs(icon_set_order) do
		local set_data = M.icon_sets[set_id]
		if set_data then
			local choice = {
				-- Simplify label - avoid special characters
				label = set_data.name:gsub("%s*%([^)]*%)%s*", "") .. " - " .. #set_data.icons .. " icons",
				id = "set:" .. set_id
			}
			table.insert(choices, choice)
			wezterm.log_info("Added choice: " .. choice.label .. " with id: " .. choice.id)
		else
			wezterm.log_error("Missing icon set: " .. set_id)
		end
	end

	wezterm.log_info("Total icon set choices: " .. #choices)

	-- Add separator
	table.insert(choices, {
		label = "---",
		id = "__separator__"
	})

	-- Add special options
	table.insert(choices, {
		label = "Custom icon or emoji",
		id = "__custom__"
	})

	table.insert(choices, {
		label = "No icon - text only",
		id = "__text_only__"
	})

	wezterm.log_info("Total choices (with options): " .. #choices)
	wezterm.log_info("About to show InputSelector...")

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Select Icon Set for: " .. tab_title,
			choices = choices,
			fuzzy = false, -- Disable fuzzy to avoid filtering issues
			action = wezterm.action_callback(function(win, p, id)
				wezterm.log_info("=== ICON SET CALLBACK INVOKED ===")
				wezterm.log_info("Parameters: win=" .. tostring(win) .. ", p=" .. tostring(p) .. ", id=" .. tostring(id))

				if not id or id == "__separator__" then
					wezterm.log_info("Ignoring separator or nil selection")
					return
				end

				if id == "__custom__" then
					wezterm.log_info("Custom icon selected")
					win:perform_action(
						wezterm.action.PromptInputLine({
							description = "Enter custom icon or emoji:",
							action = wezterm.action_callback(function(w, pn, icon)
								if icon and icon ~= "" then
									local full_title = icon .. " " .. tab_title
									wezterm.log_info("Setting tab title to: " .. full_title)

									-- Initialize custom_tabs if needed
									if not wezterm.GLOBAL.custom_tabs then
										wezterm.GLOBAL.custom_tabs = {}
									end

									-- Store custom tab data
									local tab_id = tostring(w:active_tab():tab_id())
									wezterm.GLOBAL.custom_tabs[tab_id] = {
										title = tab_title,
										icon_key = icon
									}
									wezterm.log_info("Stored custom tab data for tab_id: " .. tab_id)

									w:toast_notification("Tab Rename", "Tab renamed to: " .. full_title, nil, 2000)
								end
							end)
						}),
						p
					)
				elseif id == "__text_only__" then
					wezterm.log_info("Text only selected, setting title to: " .. tab_title)

					-- Initialize custom_tabs if needed
					if not wezterm.GLOBAL.custom_tabs then
						wezterm.GLOBAL.custom_tabs = {}
					end

					-- Store custom tab data (no icon)
					local tab_id = tostring(win:active_tab():tab_id())
					wezterm.GLOBAL.custom_tabs[tab_id] = {
						title = tab_title,
						icon_key = nil
					}
					wezterm.log_info("Stored text-only tab data for tab_id: " .. tab_id)

					win:toast_notification("Tab Rename", "Tab renamed to: " .. tab_title, nil, 2000)
				elseif id:sub(1, 4) == "set:" then
					local set_id = id:sub(5)
					wezterm.log_info("Icon set selected: " .. set_id)
					M.show_icon_picker_with_title(win, p, set_id, tab_title)
				else
					wezterm.log_error("Unknown selection id: " .. tostring(id))
				end
			end)
		}),
		pane
	)
end

-- Show icons from a specific set with pre-defined title
function M.show_icon_picker_with_title(window, pane, set_id, tab_title)
	wezterm.log_info("=== ICON PICKER FOR SET: " .. set_id .. ", TAB: " .. tab_title .. " ===")

	local set_data = M.icon_sets[set_id]
	if not set_data then
		wezterm.log_error("Icon set not found: " .. set_id)
		window:toast_notification("Tab Rename", "Icon set not found: " .. set_id, nil, 3000)
		return
	end

	wezterm.log_info("Icon set found: " .. set_data.name .. " with " .. #set_data.icons .. " icons")

	local choices = {}

	-- Add back option
	table.insert(choices, {
		label = "< Back to icon sets",
		id = "__back__"
	})

	table.insert(choices, {
		label = "---",
		id = "__separator__"
	})

	-- Add icons with the icon displayed in the label
	for i, icon_data in ipairs(set_data.icons) do
		local choice = {
			-- Include icon in label for visual preview
			label = icon_data.icon .. "  " .. icon_data.desc .. " (" .. icon_data.name .. ")",
			id = tostring(i) -- Use index for reliable selection
		}
		table.insert(choices, choice)
		if i <= 3 then -- Log first 3 icons
			wezterm.log_info("Icon " .. i .. ": " .. choice.label .. " = " .. icon_data.icon)
		end
	end

	wezterm.log_info("Total icons in picker: " .. (#choices - 2)) -- -2 for back button and separator

	window:perform_action(
		wezterm.action.InputSelector({
			title = set_data.name .. " - Pick icon for: " .. tab_title,
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				wezterm.log_info("Icon selected: id=" .. tostring(id))

				if not id or id == "__separator__" then
					wezterm.log_info("Ignoring separator or nil")
					return
				end

				if id == "__back__" then
					wezterm.log_info("Going back to icon set menu")
					M.show_icon_set_menu_with_title(win, p, tab_title)
				else
					-- id is the index, look up the icon
					local index = tonumber(id)
					if index and set_data.icons[index] then
						local icon = set_data.icons[index].icon
						local full_title = icon .. " " .. tab_title
						wezterm.log_info("Setting tab title to: " .. full_title .. " (icon index " .. index .. ")")

						-- Initialize custom_tabs if needed
						if not wezterm.GLOBAL.custom_tabs then
							wezterm.GLOBAL.custom_tabs = {}
						end

						-- Store custom tab data
						local tab_id = tostring(win:active_tab():tab_id())
						wezterm.GLOBAL.custom_tabs[tab_id] = {
							title = tab_title,
							icon_key = icon
						}
						wezterm.log_info("Stored custom tab data for tab_id: " .. tab_id)

						win:toast_notification("Tab Rename", "Renamed to: " .. full_title, nil, 2000)
					else
						wezterm.log_error("Invalid icon index: " .. tostring(id))
					end
				end
			end)
		}),
		pane
	)
end

-- Alternative: Icon first, then name (old workflow)
function M.rename_tab_icon_first(window, pane)
	M.show_icon_set_menu(window, pane, function(win, p, full_title, icon, title)
		-- Store in custom_tabs
		if not wezterm.GLOBAL.custom_tabs then
			wezterm.GLOBAL.custom_tabs = {}
		end

		local tab_id = tostring(win:active_tab():tab_id())
		wezterm.GLOBAL.custom_tabs[tab_id] = {
			title = title,
			icon_key = icon ~= "" and icon or nil
		}

		win:toast_notification("Tab Rename", "Tab renamed to: " .. full_title, nil, 2000)
	end)
end

-- Quick rename without icon (legacy support)
function M.rename_tab_simple(window, pane)
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = "Enter new name for tab:",
			action = wezterm.action_callback(function(win, p, line)
				if line and line ~= "" then
					-- Store in custom_tabs
					if not wezterm.GLOBAL.custom_tabs then
						wezterm.GLOBAL.custom_tabs = {}
					end

					local tab_id = tostring(win:active_tab():tab_id())
					wezterm.GLOBAL.custom_tabs[tab_id] = {
						title = line,
						icon_key = nil
					}

					win:toast_notification("Tab Rename", "Tab renamed to: " .. line, nil, 2000)
				end
			end)
		}),
		pane
	)
end

-- Debug function to test icon sets
function M.test_icon_sets(window, pane)
	local output = "Icon Sets Test:\n\n"

	for set_id, set_data in pairs(M.icon_sets) do
		output = output .. set_id .. ": " .. set_data.name .. " - " .. #set_data.icons .. " icons\n"
	end

	window:toast_notification("Icon Sets Debug", output, nil, 10000)
	wezterm.log_info(output)
end

-- Simplified test rename - direct approach
function M.test_rename_simple(window, pane)
	wezterm.log_info("=== SIMPLE TEST RENAME ===")

	local choices = {
		{ label = "Option 1: Material Design", id = "1" },
		{ label = "Option 2: Codicons", id = "2" },
		{ label = "Option 3: Devicons", id = "3" },
		{ label = "Option 4: Font Awesome", id = "4" },
		{ label = "Option 5: Linux Logos", id = "5" },
		{ label = "Option 6: Custom", id = "6" },
	}

	wezterm.log_info("Created " .. #choices .. " test choices")

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Simple Test - Select Any",
			choices = choices,
			fuzzy = false,
			action = wezterm.action_callback(function(win, p, id, label)
				wezterm.log_info("Test selected - id: " .. tostring(id) .. ", label: " .. tostring(label))
				win:toast_notification("Test", "You selected: " .. tostring(label), nil, 3000)

				-- Try to set tab title as test
				local test_title = "TEST " .. id
				win:active_tab():set_title(test_title)
				wezterm.log_info("Set tab title to: " .. test_title)
			end)
		}),
		pane
	)
end

return M
