local wez = require("wezterm")

---@private
---@class bar.spotify
local M = {}

local last_update = 0
local stored_playback = ""

local _wait = function(throttle, last_update_time)
	local current_time = os.time()
	return current_time - last_update_time < throttle
end

---format spotify playback, to handle max_width nicely
---@param pb string
---@param max_width number
---@return string
local format_playback = function(pb, max_width)
	if #pb <= max_width then
		return pb
	end

	-- split on " - "
	local artist, track = pb:match("^(.-) %- (.+)$")

	-- If the pattern doesn't match (no " - " separator), just truncate
	if not artist or not track then
		return pb:sub(1, max_width)
	end

	-- get artist before first ","
	local main_artist = artist:match("([^,]+)")
	if main_artist then
		local pb_main_artist = main_artist .. " - " .. track
		if #pb_main_artist <= max_width then
			return pb_main_artist
		end
	end

	-- fallback, return track name (trimmed to max width)
	return track:sub(1, max_width)
end

---gets the currently playing song from spotify
---@param max_width number
---@param throttle number
---@return string|nil
M.get_currently_playing = function(max_width, throttle)
	if _wait(throttle, last_update) then
		return stored_playback
	end

	-- Just try to get metadata from any active player, don't check status first
	-- This avoids multiple playerctl calls that might trigger authentication
	local success, pb, stderr = wez.run_child_process({
		"bash", "-c",
		"playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null || true"
	})

	if not success then
		stored_playback = nil
		last_update = os.time()
		return nil
	end

	-- trim the playback string
	pb = pb:gsub("^%s*(.-)%s*$", "%1")

	-- If empty or just separator, return nil (nothing playing or paused)
	if pb == "" or pb == " - " or pb == "-" then
		stored_playback = nil
		last_update = os.time()
		return nil
	end

	local res = format_playback(pb, max_width)
	stored_playback = res
	last_update = os.time()

	return res
end

return {
	default_opts = {
		max_width = 50,
		throttle = 3,
		icon = wez.nerdfonts.md_spotify,
	},
	update = function(window, opts)
		return M.get_currently_playing(opts.max_width or 50, opts.throttle or 3)
	end,
}
