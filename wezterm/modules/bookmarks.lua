local wezterm = require("wezterm")
local M = {}

-- Path to bookmarks file
M.bookmarks_file = wezterm.home_dir .. "/.core/.sys/configs/wezterm/.data/bookmarks.json"

-- Migration function to convert old format to new
function M.migrate_bookmarks(old_bookmarks)
	local new_format = {
		version = 2,
		bookmarks = {
			uncategorized = {},
			categories = {}
		}
	}

	-- Convert old bookmarks to uncategorized in new format
	for name, path in pairs(old_bookmarks) do
		table.insert(new_format.bookmarks.uncategorized, {
			name = name,
			path = path,
			created = os.time(),
			accessed = 0
		})
	end

	return new_format
end

-- Load bookmarks from file
function M.load()
	local file = io.open(M.bookmarks_file, "r")
	if not file then
		return {
			version = 2,
			bookmarks = {
				uncategorized = {},
				categories = {}
			}
		}
	end

	local content = file:read("*all")
	file:close()

	local ok, data = pcall(wezterm.json_parse, content)
	if not ok then
		return {
			version = 2,
			bookmarks = {
				uncategorized = {},
				categories = {}
			}
		}
	end

	-- Check if migration needed
	if not data.version or data.version < 2 then
		data = M.migrate_bookmarks(data)
		M.save(data)
	end

	-- Normalize categories to ensure bookmarks is always an array
	if data.bookmarks and data.bookmarks.categories then
		for cat_name, category in pairs(data.bookmarks.categories) do
			if type(category.bookmarks) == "table" then
				-- Check if it's an empty object that should be an array
				local is_empty_object = true
				for k, v in pairs(category.bookmarks) do
					if type(k) == "number" then
						is_empty_object = false
						break
					end
				end
				-- Convert empty objects to proper arrays
				if is_empty_object and not category.bookmarks[1] then
					data.bookmarks.categories[cat_name].bookmarks = setmetatable({}, { __jsontype = "array" })
				end
			elseif not category.bookmarks then
				-- If bookmarks is missing, create it
				data.bookmarks.categories[cat_name].bookmarks = setmetatable({}, { __jsontype = "array" })
			end
		end
	end

	return data
end

-- Save bookmarks to file
function M.save(bookmarks)
	local file = io.open(M.bookmarks_file, "w")
	if not file then
		wezterm.log_error("Could not open bookmarks file for writing")
		return false
	end

	file:write(wezterm.json_encode(bookmarks))
	file:close()
	return true
end

-- Find bookmark by name across all categories
function M.find_bookmark(data, name)
	-- Check uncategorized
	for i, bookmark in ipairs(data.bookmarks.uncategorized or {}) do
		if bookmark.name == name then
			return bookmark, "uncategorized", i
		end
	end

	-- Check categories
	for cat_name, category in pairs(data.bookmarks.categories or {}) do
		for i, bookmark in ipairs(category.bookmarks or {}) do
			if bookmark.name == name then
				return bookmark, cat_name, i
			end
		end
	end

	return nil
end

-- Add current directory as bookmark
function M.add_bookmark(window, pane)
	local cwd = pane:get_current_working_dir()
	if not cwd then
		window:toast_notification("Bookmarks", "Could not get current directory", nil, 3000)
		return
	end

	-- Extract path from file:// URL
	local path = cwd.file_path or tostring(cwd)

	window:perform_action(
		wezterm.action.PromptInputLine({
			description = "Bookmark name:",
			action = wezterm.action_callback(function(win, _, name)
				if name and name ~= "" then
					local data = M.load()

					-- Check if bookmark already exists
					if M.find_bookmark(data, name) then
						win:toast_notification("Bookmarks", "Bookmark '" .. name .. "' already exists", nil, 3000)
						return
					end

					-- Add to uncategorized
					table.insert(data.bookmarks.uncategorized, {
						name = name,
						path = path,
						created = os.time(),
						accessed = 0
					})

					M.save(data)
					win:toast_notification("Bookmarks", "Saved: " .. name .. " -> " .. path, nil, 3000)
				end
			end),
		}),
		pane
	)
end

-- Multi-select picker state management
M.picker_state = {
	selected = {},
	current_category = nil
}

-- Clear picker state
function M.clear_picker_state()
	M.picker_state.selected = {}
	M.picker_state.current_category = nil
end

-- Toggle selection
function M.toggle_selection(id)
	if M.picker_state.selected[id] then
		M.picker_state.selected[id] = nil
	else
		M.picker_state.selected[id] = true
	end
end

-- Get selection count
function M.get_selection_count()
	local count = 0
	for _ in pairs(M.picker_state.selected) do
		count = count + 1
	end
	return count
end

-- Build choices for the multi-select picker
function M.build_picker_choices(data, in_category)
	local choices = {}

	if not in_category then
		-- Main menu: show categories and uncategorized bookmarks

		-- Add categories first
		for cat_name, category in pairs(data.bookmarks.categories or {}) do
			local count = #(category.bookmarks or {})
			local prefix = M.picker_state.selected["cat:" .. cat_name] and "[✓] " or "[ ] "
			table.insert(choices, {
				label = prefix .. "📁 " .. cat_name .. " (" .. count .. " items)",
				id = "cat:" .. cat_name
			})
		end

		-- Add separator if we have both categories and uncategorized
		if next(data.bookmarks.categories) and #data.bookmarks.uncategorized > 0 then
			table.insert(choices, {
				label = "─────────────────────────────",
				id = "__separator__"
			})
		end

		-- Add uncategorized bookmarks
		for _, bookmark in ipairs(data.bookmarks.uncategorized or {}) do
			local prefix = M.picker_state.selected["bm:" .. bookmark.name] and "[✓] " or "[ ] "
			table.insert(choices, {
				label = prefix .. "📍 " .. bookmark.name .. " -> " .. bookmark.path,
				id = "bm:" .. bookmark.name
			})
		end

		-- Add action items at the bottom
		if #choices > 0 then
			table.insert(choices, {
				label = "─────────────────────────────",
				id = "__separator2__"
			})
		end

		local selection_count = M.get_selection_count()

		-- Show selection-based actions
		if selection_count > 0 then
			table.insert(choices, {
				label = "🗂️  [ENTER] Move " .. selection_count .. " selected to category",
				id = "__move_to_category__"
			})
			table.insert(choices, {
				label = "🗑️  [d] Delete " .. selection_count .. " selected items",
				id = "__delete_selected__"
			})
			table.insert(choices, {
				label = "❌ [c] Clear selection",
				id = "__clear_selection__"
			})
		end

		table.insert(choices, {
			label = "➕ [n] Create new category",
			id = "__new_category__"
		})

		table.insert(choices, {
			label = "🚀 [j] Jump to bookmark",
			id = "__jump__"
		})

	else
		-- Inside a category
		local category = data.bookmarks.categories[in_category]

		if category then
			-- Add back navigation
			table.insert(choices, {
				label = "⬅️  Back to main menu",
				id = "__back__"
			})

			table.insert(choices, {
				label = "─────────────────────────────",
				id = "__separator__"
			})

			-- Add bookmarks in this category
			for _, bookmark in ipairs(category.bookmarks or {}) do
				local prefix = M.picker_state.selected["bm:" .. bookmark.name] and "[✓] " or "[ ] "
				table.insert(choices, {
					label = prefix .. "📍 " .. bookmark.name .. " -> " .. bookmark.path,
					id = "bm:" .. bookmark.name
				})
			end

			-- Add action items
			if #category.bookmarks > 0 then
				table.insert(choices, {
					label = "─────────────────────────────",
					id = "__separator2__"
				})
			end

			local selection_count = M.get_selection_count()

			if selection_count > 0 then
				table.insert(choices, {
					label = "📤 [u] Move " .. selection_count .. " selected to uncategorized",
					id = "__move_to_uncategorized__"
				})
				table.insert(choices, {
					label = "🗂️  [m] Move " .. selection_count .. " selected to another category",
					id = "__move_to_other_category__"
				})
				table.insert(choices, {
					label = "🗑️  [d] Delete " .. selection_count .. " selected items",
					id = "__delete_selected__"
				})
				table.insert(choices, {
					label = "❌ [c] Clear selection",
					id = "__clear_selection__"
				})
			end

			table.insert(choices, {
				label = "🗑️  [D] Delete this category (and all bookmarks)",
				id = "__delete_category__"
			})
		end
	end

	return choices
end

-- Process selection action
function M.process_action(window, pane, action, data)
	if action == "__new_category__" then
		window:perform_action(
			wezterm.action.PromptInputLine({
				description = "Category name:",
				action = wezterm.action_callback(function(win, p, name)
					if name and name ~= "" then
						local d = M.load()
						if d.bookmarks.categories[name] then
							win:toast_notification("Bookmarks", "Category '" .. name .. "' already exists", nil, 3000)
						else
							-- Use a marker to ensure bookmarks is saved as an array
							d.bookmarks.categories[name] = {
								created = os.time(),
								bookmarks = setmetatable({}, { __jsontype = "array" })
							}
							M.save(d)
							win:toast_notification("Bookmarks", "Created category: " .. name, nil, 3000)
							M.open_manager(win, p) -- Reopen manager
						end
					end
				end)
			}),
			pane
		)
		return true

	elseif action == "__move_to_category__" then
		-- Get list of categories
		local categories = {}
		for cat_name, _ in pairs(data.bookmarks.categories or {}) do
			table.insert(categories, {
				label = cat_name,
				id = cat_name
			})
		end

		if #categories == 0 then
			window:toast_notification("Bookmarks", "No categories available. Create one first.", nil, 3000)
			return true
		end

		window:perform_action(
			wezterm.action.InputSelector({
				title = "Select target category",
				choices = categories,
				fuzzy = true,
				action = wezterm.action_callback(function(win, p, cat_name)
					if cat_name then
						local d = M.load()
						local moved = 0

						-- Process selected bookmarks
						for id, _ in pairs(M.picker_state.selected) do
							if id:sub(1, 3) == "bm:" then
								local bm_name = id:sub(4)
								local bookmark, location, index = M.find_bookmark(d, bm_name)

								if bookmark and location == "uncategorized" then
									-- Move to category
									table.insert(d.bookmarks.categories[cat_name].bookmarks, bookmark)
									table.remove(d.bookmarks.uncategorized, index)
									moved = moved + 1
								end
							end
						end

						M.save(d)
						M.clear_picker_state()
						win:toast_notification("Bookmarks", "Moved " .. moved .. " bookmarks to " .. cat_name, nil, 3000)
						M.open_manager(win, p) -- Reopen manager
					end
				end)
			}),
			pane
		)
		return true

	elseif action == "__move_to_uncategorized__" then
		local moved = 0

		for id, _ in pairs(M.picker_state.selected) do
			if id:sub(1, 3) == "bm:" then
				local bm_name = id:sub(4)
				local bookmark, location, index = M.find_bookmark(data, bm_name)

				if bookmark and location ~= "uncategorized" then
					-- Move to uncategorized
					table.insert(data.bookmarks.uncategorized, bookmark)
					table.remove(data.bookmarks.categories[location].bookmarks, index)
					moved = moved + 1
				end
			end
		end

		M.save(data)
		M.clear_picker_state()
		window:toast_notification("Bookmarks", "Moved " .. moved .. " bookmarks to uncategorized", nil, 3000)
		return true

	elseif action == "__move_to_other_category__" then
		-- Get list of other categories
		local categories = {}
		for cat_name, _ in pairs(data.bookmarks.categories or {}) do
			if cat_name ~= M.picker_state.current_category then
				table.insert(categories, {
					label = cat_name,
					id = cat_name
				})
			end
		end

		table.insert(categories, {
			label = "📋 Uncategorized",
			id = "__uncategorized__"
		})

		window:perform_action(
			wezterm.action.InputSelector({
				title = "Select target category",
				choices = categories,
				fuzzy = true,
				action = wezterm.action_callback(function(win, p, cat_name)
					if cat_name then
						local d = M.load()
						local moved = 0

						-- Process selected bookmarks
						for id, _ in pairs(M.picker_state.selected) do
							if id:sub(1, 3) == "bm:" then
								local bm_name = id:sub(4)
								local bookmark, location, index = M.find_bookmark(d, bm_name)

								if bookmark and location == M.picker_state.current_category then
									if cat_name == "__uncategorized__" then
										-- Move to uncategorized
										table.insert(d.bookmarks.uncategorized, bookmark)
									else
										-- Move to another category
										table.insert(d.bookmarks.categories[cat_name].bookmarks, bookmark)
									end
									table.remove(d.bookmarks.categories[location].bookmarks, index)
									moved = moved + 1
								end
							end
						end

						M.save(d)
						M.clear_picker_state()
						local target = cat_name == "__uncategorized__" and "uncategorized" or cat_name
						win:toast_notification("Bookmarks", "Moved " .. moved .. " bookmarks to " .. target, nil, 3000)
						M.open_manager(win, p) -- Reopen manager
					end
				end)
			}),
			pane
		)
		return true

	elseif action == "__delete_selected__" then
		local count = M.get_selection_count()

		window:perform_action(
			wezterm.action.InputSelector({
				title = "Confirm deletion",
				choices = {
					{ label = "Yes, delete " .. count .. " items", id = "yes" },
					{ label = "Cancel", id = "no" }
				},
				action = wezterm.action_callback(function(win, p, confirm)
					if confirm == "yes" then
						local deleted = 0

						-- Process deletions
						for id, _ in pairs(M.picker_state.selected) do
							if id:sub(1, 4) == "cat:" then
								-- Delete category
								local cat_name = id:sub(5)
								if data.bookmarks.categories[cat_name] then
									data.bookmarks.categories[cat_name] = nil
									deleted = deleted + 1
								end
							elseif id:sub(1, 3) == "bm:" then
								-- Delete bookmark
								local bm_name = id:sub(4)
								local bookmark, location, index = M.find_bookmark(data, bm_name)

								if bookmark then
									if location == "uncategorized" then
										table.remove(data.bookmarks.uncategorized, index)
									else
										table.remove(data.bookmarks.categories[location].bookmarks, index)
									end
									deleted = deleted + 1
								end
							end
						end

						M.save(data)
						M.clear_picker_state()
						win:toast_notification("Bookmarks", "Deleted " .. deleted .. " items", nil, 3000)
						M.open_manager(win, p) -- Reopen manager
					end
				end)
			}),
			pane
		)
		return true

	elseif action == "__delete_category__" then
		window:perform_action(
			wezterm.action.InputSelector({
				title = "Delete category '" .. M.picker_state.current_category .. "'?",
				choices = {
					{ label = "Yes, delete category and all bookmarks", id = "yes" },
					{ label = "Cancel", id = "no" }
				},
				action = wezterm.action_callback(function(win, p, confirm)
					if confirm == "yes" then
						data.bookmarks.categories[M.picker_state.current_category] = nil
						M.save(data)
						M.clear_picker_state()
						win:toast_notification("Bookmarks", "Deleted category: " .. M.picker_state.current_category, nil, 3000)
						M.open_manager(win, p) -- Reopen manager
					end
				end)
			}),
			pane
		)
		return true

	elseif action == "__clear_selection__" then
		M.clear_picker_state()
		return false -- Continue showing picker

	elseif action == "__jump__" then
		M.jump_to_bookmark(window, pane)
		return true

	elseif action == "__back__" then
		M.picker_state.current_category = nil
		return false -- Continue showing picker
	end

	return false
end

-- Open the bookmark manager
function M.open_manager(window, pane)
	local data = M.load()

	local function show_picker()
		local choices = M.build_picker_choices(data, M.picker_state.current_category)

		local title = "Bookmark Manager"
		if M.picker_state.current_category then
			title = title .. " - " .. M.picker_state.current_category
		end

		local selection_count = M.get_selection_count()
		if selection_count > 0 then
			title = title .. " (" .. selection_count .. " selected)"
		end

		title = title .. " | Space: Select | Enter: Action"

		window:perform_action(
			wezterm.action.InputSelector({
				title = title,
				choices = choices,
				fuzzy = false,
				action = wezterm.action_callback(function(win, p, id)
					if not id then
						M.clear_picker_state()
						return
					end

					-- Handle separators
					if id:sub(1, 11) == "__separator" then
						show_picker() -- Reshow
						return
					end

					-- Handle special actions
					if id:sub(1, 2) == "__" then
						if M.process_action(win, p, id, data) then
							-- Action completed, exit
							return
						else
							-- Continue showing picker
							show_picker()
							return
						end
					end

					-- Handle category navigation
					if id:sub(1, 4) == "cat:" then
						local cat_name = id:sub(5)

						-- Check if we have bookmarks selected
						local has_bookmarks_selected = false
						for sel_id, _ in pairs(M.picker_state.selected) do
							if sel_id:sub(1, 3) == "bm:" then
								has_bookmarks_selected = true
								break
							end
						end

						if M.picker_state.selected[id] then
							-- If this category is selected, toggle selection
							M.toggle_selection(id)
							show_picker()
						elseif has_bookmarks_selected then
							-- If we have bookmarks selected, offer to move them to this category
							local count = 0
							for sel_id, _ in pairs(M.picker_state.selected) do
								if sel_id:sub(1, 3) == "bm:" then
									count = count + 1
								end
							end

							win:perform_action(
								wezterm.action.InputSelector({
									title = "Move " .. count .. " bookmarks to '" .. cat_name .. "'?",
									choices = {
										{ label = "Yes, move to " .. cat_name, id = "yes" },
										{ label = "No, enter category instead", id = "no" },
										{ label = "Cancel", id = "cancel" }
									},
									action = wezterm.action_callback(function(w, pn, choice)
										if choice == "yes" then
											-- Move bookmarks to category
											local d = M.load()
											local moved = 0

											for sel_id, _ in pairs(M.picker_state.selected) do
												if sel_id:sub(1, 3) == "bm:" then
													local bm_name = sel_id:sub(4)
													local bookmark, location, index = M.find_bookmark(d, bm_name)

													if bookmark and location == "uncategorized" then
														table.insert(d.bookmarks.categories[cat_name].bookmarks, bookmark)
														table.remove(d.bookmarks.uncategorized, index)
														moved = moved + 1
													end
												end
											end

											M.save(d)
											M.clear_picker_state()
											w:toast_notification("Bookmarks", "Moved " .. moved .. " bookmarks to " .. cat_name, nil, 3000)
											M.open_manager(w, pn)
										elseif choice == "no" then
											-- Enter category
											M.picker_state.current_category = cat_name
											show_picker()
										else
											-- Cancel, go back to picker
											show_picker()
										end
									end)
								}),
								p
							)
						else
							-- No bookmarks selected, just enter category
							M.picker_state.current_category = cat_name
							show_picker()
						end
						return
					end

					-- Handle bookmark selection/jump
					if id:sub(1, 3) == "bm:" then
						local bm_name = id:sub(4)
						if M.picker_state.selected[id] then
							-- If already selected, jump to it
							local bookmark = M.find_bookmark(data, bm_name)
							if bookmark then
								bookmark.accessed = bookmark.accessed + 1
								M.save(data)
								p:send_text("cd " .. wezterm.shell_quote_arg(bookmark.path) .. "\n")
								M.clear_picker_state()
							end
						else
							-- Toggle selection
							M.toggle_selection(id)
							show_picker()
						end
						return
					end
				end),
			}),
			pane
		)
	end

	-- Handle spacebar for selection
	wezterm.on("window-config-reloaded", function(win, p)
		win:perform_action(
			wezterm.action.Multiple({
				wezterm.action.SendKey({ key = "Space" }),
				wezterm.action_callback(function()
					-- Get current selection and toggle
					-- This is a simplified approach; proper implementation would need
					-- to track the current highlighted item
				end)
			}),
			p
		)
	end)

	show_picker()
end

-- Jump to a bookmarked directory (simplified for quick access)
function M.jump_to_bookmark(window, pane)
	local data = M.load()
	local choices = {}

	-- Add all bookmarks from uncategorized
	for _, bookmark in ipairs(data.bookmarks.uncategorized or {}) do
		table.insert(choices, {
			label = bookmark.name .. " -> " .. bookmark.path,
			id = bookmark.path
		})
	end

	-- Add all bookmarks from categories
	for cat_name, category in pairs(data.bookmarks.categories or {}) do
		for _, bookmark in ipairs(category.bookmarks or {}) do
			table.insert(choices, {
				label = "[" .. cat_name .. "] " .. bookmark.name .. " -> " .. bookmark.path,
				id = bookmark.path
			})
		end
	end

	if #choices == 0 then
		window:toast_notification("Bookmarks", "No bookmarks saved", nil, 3000)
		return
	end

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Jump to Bookmark",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, path)
				if path then
					p:send_text("cd " .. wezterm.shell_quote_arg(path) .. "\n")
				end
			end),
		}),
		pane
	)
end

-- Export commonly used functions
M.remove_bookmark = function(window, pane)
	window:toast_notification("Bookmarks", "Use the bookmark manager (LEADER+b) to delete bookmarks", nil, 3000)
end

M.list_bookmarks = function(window, pane)
	M.open_manager(window, pane)
end

return M
