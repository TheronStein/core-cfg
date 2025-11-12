-- ~/.core/cfg/wezterm/extra/slideshow.lua
-- Enhanced background image slideshow functionality with yazi integration

local wezterm = require("wezterm")

local M = {}

-- Slideshow state per session
M.sessions = {}

-- Global settings
M.settings = {
	default_interval = 30,
	fade_duration = 0.5,
	shuffle = false,
	loop = true,
	extensions = { "jpg", "jpeg", "png", "gif", "bmp", "webp", "tiff", "tif" },
}

-- Initialize slideshow for a session
function M.init(session_name, config)
	if not config then
		config = {}
	end

	-- Use provided directory or prompt for selection
	local directory = config.directory or config.slideshow and config.slideshow.directory

	if not directory then
		wezterm.log_warn("No directory specified for slideshow")
		return false
	end

	local interval = config.interval or (config.slideshow and config.slideshow.interval) or M.settings.default_interval
	local shuffle = config.shuffle or (config.slideshow and config.slideshow.shuffle) or M.settings.shuffle

	-- Load images from directory (recursively if specified)
	local images = M.scan_directory(directory, config.recursive)

	if #images == 0 then
		wezterm.log_warn("No images found in directory: " .. directory)
		return false
	end

	-- Shuffle images if requested
	if shuffle then
		M.shuffle_array(images)
	end

	-- Store session state
	M.sessions[session_name] = {
		images = images,
		directory = directory,
		current_index = 1,
		interval = interval,
		active = true,
		paused = false,
		timer_id = nil,
		history = {},
		shuffle = shuffle,
	}

	-- Start rotation
	M.start_rotation(session_name)

	wezterm.log_info(
		string.format("Slideshow started for session '%s' with %d images from %s", session_name, #images, directory)
	)

	return true
end

-- Initialize from yazi selection
function M.init_from_yazi(session_name, selected_path)
	-- Parse the yazi output
	local directory = selected_path:match("^(.*)/") or selected_path

	-- Check if it's a file or directory
	local file_type = M.get_file_type(selected_path)

	local config = {}
	if file_type == "directory" then
		config.directory = selected_path
		config.recursive = true
	elseif file_type == "file" then
		-- If a single image is selected, use its parent directory
		config.directory = directory
		config.recursive = false
	else
		wezterm.log_error("Invalid path from yazi: " .. selected_path)
		return false
	end

	config.interval = M.settings.default_interval
	config.shuffle = M.settings.shuffle

	return M.init(session_name, config)
end

-- Get file type (file/directory)
function M.get_file_type(path)
	local handle = io.popen('test -d "' .. path .. '" && echo "directory" || echo "file"')
	if handle then
		local result = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return result
	end
	return nil
end

-- Scan directory for images (with optional recursive scan)
function M.scan_directory(directory, recursive)
	local images = {}

	-- Build find command
	local find_cmd = 'find "' .. directory .. '"'
	if not recursive then
		find_cmd = find_cmd .. " -maxdepth 1"
	end
	find_cmd = find_cmd .. " -type f \\( "

	-- Add extension filters
	for i, ext in ipairs(M.settings.extensions) do
		if i > 1 then
			find_cmd = find_cmd .. " -o "
		end
		find_cmd = find_cmd .. '-iname "*.' .. ext .. '"'
	end
	find_cmd = find_cmd .. " \\) 2>/dev/null | sort"

	local handle = io.popen(find_cmd)
	if handle then
		for file in handle:lines() do
			table.insert(images, file)
		end
		handle:close()
	end

	return images
end

-- Shuffle array in place
function M.shuffle_array(array)
	local n = #array
	for i = n, 2, -1 do
		local j = math.random(i)
		array[i], array[j] = array[j], array[i]
	end
end

-- Start image rotation for session
function M.start_rotation(session_name)
	local session = M.sessions[session_name]
	if not session or not session.active then
		return
	end

	-- Clear any existing timer
	if session.timer_id then
		wezterm.time.cancel(session.timer_id)
	end

	-- Function to rotate image
	local function rotate()
		local s = M.sessions[session_name]
		if not s or not s.active or s.paused then
			return
		end

		-- Move to next image
		M.next(session_name)

		-- Schedule next change
		s.timer_id = wezterm.time.call_after(s.interval, rotate)
	end

	-- Start the rotation
	session.timer_id = wezterm.time.call_after(session.interval, rotate)
end

-- Get current image for session
function M.get_current_image(session_name)
	local session = M.sessions[session_name]
	if not session or #session.images == 0 then
		return nil
	end

	return session.images[session.current_index]
end

-- Set specific image by index
function M.set_image(session_name, index)
	local session = M.sessions[session_name]
	if not session or #session.images == 0 then
		return nil
	end

	if index < 1 or index > #session.images then
		return nil
	end

	-- Add to history
	table.insert(session.history, session.current_index)
	if #session.history > 50 then
		table.remove(session.history, 1)
	end

	session.current_index = index
	local image = session.images[index]

	-- Emit update event
	wezterm.emit("slideshow-update", session_name, image)

	return image
end

-- Stop slideshow for session
function M.stop(session_name)
	local session = M.sessions[session_name]
	if session then
		session.active = false
		if session.timer_id then
			wezterm.time.cancel(session.timer_id)
		end
		M.sessions[session_name] = nil
		wezterm.log_info("Slideshow stopped for session: " .. session_name)
	end
end

-- Pause slideshow
function M.pause(session_name)
	local session = M.sessions[session_name]
	if session and not session.paused then
		session.paused = true
		if session.timer_id then
			wezterm.time.cancel(session.timer_id)
			session.timer_id = nil
		end
		wezterm.log_info("Slideshow paused for session: " .. session_name)
		return true
	end
	return false
end

-- Resume slideshow
function M.resume(session_name)
	local session = M.sessions[session_name]
	if session and session.paused then
		session.paused = false
		M.start_rotation(session_name)
		wezterm.log_info("Slideshow resumed for session: " .. session_name)
		return true
	end
	return false
end

-- Toggle pause/resume
function M.toggle_pause(session_name)
	local session = M.sessions[session_name]
	if not session then
		return false
	end

	if session.paused then
		return M.resume(session_name)
	else
		return M.pause(session_name)
	end
end

-- Next image
function M.next(session_name)
	local session = M.sessions[session_name]
	if not session or #session.images == 0 then
		return nil
	end

	-- Add current to history
	table.insert(session.history, session.current_index)
	if #session.history > 50 then
		table.remove(session.history, 1)
	end

	session.current_index = (session.current_index % #session.images) + 1
	local image = session.images[session.current_index]

	-- Emit update event
	wezterm.emit("slideshow-update", session_name, image)

	return image
end

-- Previous image
function M.previous(session_name)
	local session = M.sessions[session_name]
	if not session or #session.images == 0 then
		return nil
	end

	-- Try to go back in history first
	if #session.history > 0 then
		session.current_index = table.remove(session.history)
	else
		session.current_index = session.current_index - 1
		if session.current_index < 1 then
			session.current_index = #session.images
		end
	end

	local image = session.images[session.current_index]

	-- Emit update event
	wezterm.emit("slideshow-update", session_name, image)

	return image
end

-- Jump to random image
function M.random(session_name)
	local session = M.sessions[session_name]
	if not session or #session.images <= 1 then
		return nil
	end

	-- Add current to history
	table.insert(session.history, session.current_index)
	if #session.history > 50 then
		table.remove(session.history, 1)
	end

	-- Pick random different image
	local new_index
	repeat
		new_index = math.random(#session.images)
	until new_index ~= session.current_index

	session.current_index = new_index
	local image = session.images[session.current_index]

	-- Emit update event
	wezterm.emit("slideshow-update", session_name, image)

	return image
end

-- Change slideshow interval
function M.set_interval(session_name, interval)
	local session = M.sessions[session_name]
	if not session then
		return false
	end

	session.interval = interval

	-- Restart rotation with new interval if active
	if session.active and not session.paused then
		M.start_rotation(session_name)
	end

	wezterm.log_info(string.format("Slideshow interval for '%s' set to %d seconds", session_name, interval))
	return true
end

-- Get slideshow info
function M.get_info(session_name)
	local session = M.sessions[session_name]
	if not session then
		return nil
	end

	return {
		directory = session.directory,
		total_images = #session.images,
		current_index = session.current_index,
		current_image = session.images[session.current_index],
		interval = session.interval,
		active = session.active,
		paused = session.paused,
		shuffle = session.shuffle,
	}
end

-- Toggle slideshow
function M.toggle(session_name, config)
	if M.sessions[session_name] then
		M.stop(session_name)
		return false
	else
		return M.init(session_name, config)
	end
end

-- List all active slideshows
function M.list_active()
	local active = {}
	for name, session in pairs(M.sessions) do
		if session.active then
			table.insert(active, {
				name = name,
				directory = session.directory,
				images = #session.images,
				paused = session.paused,
			})
		end
	end
	return active
end

return M
