local wezterm = require("wezterm")
local M = {}

-- Path to bookmarks file
M.bookmarks_file = wezterm.home_dir .. "/.core/cfg/wezterm/.data/bookmarks.json"

-- Load bookmarks from file
function M.load()
	local file = io.open(M.bookmarks_file, "r")
	if not file then
		return {}
	end

	local content = file:read("*all")
	file:close()

	local ok, bookmarks = pcall(wezterm.json_parse, content)
	if ok then
		return bookmarks
	else
		return {}
	end
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
					local bookmarks = M.load()
					bookmarks[name] = path
					M.save(bookmarks)
					win:toast_notification("Bookmarks", "Saved: " .. name .. " -> " .. path, nil, 3000)
				end
			end),
		}),
		pane
	)
end

-- Remove a bookmark
function M.remove_bookmark(window, pane)
	local bookmarks = M.load()

	if not next(bookmarks) then
		window:toast_notification("Bookmarks", "No bookmarks to remove", nil, 3000)
		return
	end

	local choices = {}
	for name, path in pairs(bookmarks) do
		table.insert(choices, {
			label = name .. " (" .. path .. ")",
			id = name,
		})
	end

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Remove Bookmark",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, _, id, label)
				if id then
					bookmarks[id] = nil
					M.save(bookmarks)
					win:toast_notification("Bookmarks", "Removed: " .. id, nil, 3000)
				end
			end),
		}),
		pane
	)
end

-- Jump to a bookmarked directory
function M.jump_to_bookmark(window, pane)
	local bookmarks = M.load()

	if not next(bookmarks) then
		window:toast_notification("Bookmarks", "No bookmarks saved", nil, 3000)
		return
	end

	local choices = {}
	for name, path in pairs(bookmarks) do
		table.insert(choices, {
			label = name .. " -> " .. path,
			id = path,
		})
	end

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Jump to Bookmark",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, path, label)
				if path then
					p:send_text("cd " .. wezterm.shell_quote_arg(path) .. "\n")
				end
			end),
		}),
		pane
	)
end

-- List all bookmarks
function M.list_bookmarks(window, pane)
	local bookmarks = M.load()

	if not next(bookmarks) then
		window:toast_notification("Bookmarks", "No bookmarks saved", nil, 3000)
		return
	end

	local list = "Bookmarks:\n"
	for name, path in pairs(bookmarks) do
		list = list .. name .. " -> " .. path .. "\n"
	end

	window:toast_notification("Bookmarks", list, nil, 10000)
end

return M
