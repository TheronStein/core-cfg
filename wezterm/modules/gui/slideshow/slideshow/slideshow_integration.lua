-- ~/.core/.sys/configs/wezterm/util/slideshow_integration.lua
-- Integrates slideshow module with WezTerm's window configuration

local wezterm = require("wezterm")
local slideshow = require("extra.slideshow")

local M = {}

-- Track window background states
M.window_states = {}

-- Initialize integration
function M.init()
	-- Listen for slideshow updates
	wezterm.on("slideshow-update", function(session_name, image_path)
		wezterm.log_info("Slideshow update: " .. session_name .. " -> " .. image_path)
		M.update_background(session_name, image_path)
	end)

	-- -- Listen for window focus to update background
	-- wezterm.on("window-focus-changed", function(window)
	-- 	M.refresh_window(window)
	-- end)
	--
	wezterm.log_info("Slideshow integration initialized")
end

-- Update background for a session
function M.update_background(session_name, image_path)
	-- Store the new image path for this session
	M.window_states[session_name] = M.window_states[session_name] or {}
	M.window_states[session_name].current_image = image_path

	-- Trigger reload for all windows
	-- Note: In WezTerm, we can't directly trigger reload from here,
	-- but the next window-config-reloaded will pick it up
	wezterm.log_info("Background updated for session: " .. session_name)
	-- Find windows associated with this session
	-- for window_id, state in pairs(M.window_states) do
	-- 	if state.session_name == session_name then
	-- 		M.set_window_background(window_id, image_path)
	-- 	end
	-- end
end

-- Set background for a specific window
function M.set_window_background(window_id, image_path)
	-- This would need to be called from window config reload
	-- Store the path for use in config reload
	M.window_states[window_id] = M.window_states[window_id] or {}
	M.window_states[window_id].current_image = image_path
end

-- -- Apply background to window config
-- function M.apply_to_config(window, config)
-- 	local window_id = tostring(window:window_id())
-- 	local state = M.window_states[window_id]
--
-- 	if not state or not state.current_image then
-- 		-- Try to get from active slideshow
-- 		local domain = window:active_domain()
-- 		local workspace = window:active_workspace()
-- 		local session_name = M.get_session_name(domain, workspace)
-- local image_path = nil
-- 		local image = slideshow.get_current_image(session_name)
-- 		if image then
-- 			state = state or {}
-- 			state.current_image = image
-- 			state.session_name = session_name
-- 			M.window_states[window_id] = state
-- 		end
-- 	end
--
-- 	if state and state.current_image then
-- 		-- Apply background image
-- 		config.background = {
-- 			{
-- 				source = {
-- 					File = state.current_image,
-- 				},
-- 				opacity = state.opacity or 0.8,
-- 				hsb = {
-- 					brightness = state.brightness or 0.05,
-- 					saturation = state.saturation or 0.9,
-- 				},
-- 				attachment = "Fixed",
-- 				vertical_align = "Middle",
-- 				horizontal_align = "Center",
-- 				repeat_x = "NoRepeat",
-- 				repeat_y = "NoRepeat",
-- 				width = "Cover",
-- 				height = "Cover",
-- 			},
-- 		}
-- 	end
--
-- 	return config
-- end

-- Apply background to window config
function M.apply_to_config(window, config)
	-- Get current session name
	local session_name = M.get_session_name(window)

	-- Check if we have an active slideshow for this session
	local image_path = nil

	-- First check if slideshow module has an image
	image_path = slideshow.get_current_image(session_name)

	-- Also check our stored state
	if not image_path and M.window_states[session_name] then
		image_path = M.window_states[session_name].current_image
	end

	if image_path then
		wezterm.log_info("Applying background: " .. image_path)

		-- Set the background
		config.background = {
			{
				source = {
					File = image_path,
				},
				opacity = 0.9,
				hsb = {
					brightness = 0.05,
					saturation = 0.9,
				},
				attachment = "Fixed",
				vertical_align = "Middle",
				horizontal_align = "Center",
				repeat_x = "NoRepeat",
				repeat_y = "NoRepeat",
				width = "Cover",
				height = "Cover",
			},
		}

		-- Make sure we can see through to the background
		config.window_background_opacity = 1.0
		config.text_background_opacity = 0.9
	end

	return config
end

-- Get session name from window context
function M.get_session_name(window)
	-- Try to get from environment or workspace
	local workspace = window:active_workspace()
	local domain_name = window:active_domain_name()

	-- For now, use workspace name as session name
	-- You can customize this logic
	local session_name = workspace or "default"

	-- If using tmux, try to get tmux session name
	-- This would need to be set via environment variable
	local tmux_session = os.getenv("TMUX_SESSION")
	if tmux_session then
		session_name = tmux_session
	end

	return session_name
end

-- Manually refresh window
function M.refresh_window(window)
	local session_name = M.get_session_name(window)
	local image = slideshow.get_current_image(session_name)

	if image then
		M.window_states[session_name] = M.window_states[session_name] or {}
		M.window_states[session_name].current_image = image

		-- Force a config reload
		window:reload_configuration()
	end
end

-- Register window with slideshow
function M.register_window(window, session_name)
	session_name = session_name or M.get_session_name(window)

	-- Get initial image if slideshow is active
	local image = slideshow.get_current_image(session_name)
	if image then
		M.window_states[session_name] = {
			current_image = image,
		}
		window:reload_configuration()
	end
end

-- Unregister window
function M.unregister_window(window)
	local window_id = tostring(window:window_id())
	M.window_states[window_id] = nil
end

-- Set window background properties
function M.set_properties(window, properties)
	local window_id = tostring(window:window_id())
	local state = M.window_states[window_id] or {}

	if properties.opacity then
		state.opacity = properties.opacity
	end
	if properties.brightness then
		state.brightness = properties.brightness
	end
	if properties.saturation then
		state.saturation = properties.saturation
	end

	M.window_states[window_id] = state
	window:reload_configuration()
end

return M
