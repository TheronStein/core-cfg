local wezterm = require("wezterm")
local backdrops = require("modules.gui.backdrops")
local debug_config = require("config.debug")

local M = {}

-- Track last cycle time per window
local last_cycle = {}
local CYCLE_INTERVAL = 300 -- seconds

function M.setup()
	-- Set backdrop when a new window is created
	wezterm.on("window-config-reloaded", function(window, pane)
		local window_id = tostring(window:window_id())
		-- Set initial backdrop for new window
		if not last_cycle[window_id] then
			backdrops:set_img(window, 1)
			if debug_config.is_enabled("debug_mods_backdrop_events") then
				wezterm.log_info("[EVENT:BACKDROP] Initial backdrop set for window " .. window_id)
			end
		end
		-- window:toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
	end)

	-- Also handle gui-startup event
	wezterm.on("gui-startup", function(cmd)
		-- This will be called when the GUI starts
		if debug_config.is_enabled("debug_mods_backdrop_events") then
			wezterm.log_info("[EVENT:BACKDROP] GUI started, backdrops initialized")
		end
	end)

	wezterm.on("update-status", function(window, pane)
		-- Skip if backgrounds are disabled
		if not backdrops:are_backgrounds_enabled() then
			return
		end

		local window_id = tostring(window:window_id())
		local now = os.time()

		-- Initialize if first run
		if not last_cycle[window_id] then
			last_cycle[window_id] = now
			-- Set initial backdrop
			backdrops:set_img(window, 1)
			return
		end

		-- Check if interval has passed
		if now - last_cycle[window_id] > CYCLE_INTERVAL then
			backdrops:cycle_forward(window)
			last_cycle[window_id] = now
			if debug_config.is_enabled("debug_mods_backdrop_events") then
				wezterm.log_info("[EVENT:BACKDROP] Cycled for window " .. window_id)
			end
		end
	end)
end

return M

-- local wezterm = require("wezterm")
-- local backdrops = require("modules.gui.backdrops")
--
-- local M = {}
--
-- -- Track last cycle time per window
-- local last_cycle = {}
-- local CYCLE_INTERVAL = 10 -- seconds
--
-- function M.setup()
--   -- wezterm.on("backdrop-action", function(window, pane, action)
--   --   if action == "cycle_forward" then
--   --     backdrops:cycle_forward(window)
--   --     elseif action == "cycle_back" then
--   --     backdrops:cycle_back(window)
--   --   elseif action == "random" then
--   --     backdrops:random(window)
--   --   elseif action == "rotate_cycles" then
--   --     window:toast_notification('wezterm', 'Rotating backdrops...', nil, 4000)
--   --     wezterm.log_info("Rotating backdrop cycles...")
--   --     backdrops:rotate_cycles(window)
--   --   end
--   --   wezterm.action.EmitEvent("window-config-reloaded"),
--   --   if not last_cycle[window_id] then
--   --    wezterm.reload_configuration()
--   --
--   -- 	wezterm.log_info("Initial backdrop set for window " .. window_id)
--   -- end
--   -- window:toast_notification('wezterm', 'backdrops background cycle', nil, 4000)
--   -- end)
--
--
-- -- 	-- Set backdrop when a new window is created
-- -- 	wezterm.on("window-config-reloaded", function(window, pane)
-- -- 		local window_id = tostring(window:window_id())
-- -- 		-- Set initial backdrop for new window
-- -- 		if not last_cycle[window_id] then
-- -- 			backdrops:set_img(window, 1)
-- -- 			wezterm.log_info("Initial backdrop set for window " .. window_id)
-- -- 		end
-- -- end)
-- 	wezterm.on("update-status", function(window, pane)
-- 		local window_id = tostring(window:window_id())
-- 		local now = os.time()
--
-- 		-- -- Initialize if first run
-- 		-- if not last_cycle[window_id] then
-- 		-- 	last_cycle[window_id] = now
-- 		-- 	-- Set initial backdrop
-- 		-- 	backdrops:set_img(window, 1)
-- 		-- 	return
-- 		-- end
-- 		-- Check if interval has passed
-- 		if now - last_cycle[window_id] >= CYCLE_INTERVAL then
-- 			backdrops:cycle_forward(window)
-- 			last_cycle[window_id] = now
--
--       wezterm.log_info("Backdrop cycled for window " .. window_id)
--       window:toast_notification('wezterm', 'Background cycled for ' .. window_id, nil, 4000)
--     end
-- 	end)
-- end
--
-- return M
