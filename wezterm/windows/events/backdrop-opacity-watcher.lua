-- Backdrop opacity watcher
-- Watches opacity file from theme browser and updates backdrop opacity in real-time

local wezterm = require("wezterm")
local backdrops = require("modules.gui.backdrops")

local M = {}

-- Track last opacity value per workspace
local last_opacity = {}

-- Get opacity file path for workspace
local function get_opacity_file(workspace_name)
	local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
	if workspace_name and workspace_name ~= "" then
		return string.format("%s/wezterm_backdrop_opacity_%s.txt", runtime_dir, workspace_name)
	else
		return runtime_dir .. "/wezterm_backdrop_opacity.txt"
	end
end

-- Function to get file modification time
local function get_file_mtime(path)
	local handle = io.popen("stat -c %Y '" .. path .. "' 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		return tonumber(result) or 0
	end
	return 0
end

function M.setup()
	-- Check opacity file periodically
	wezterm.on("update-status", function(window, pane)
		-- Skip if backgrounds are disabled
		if not backdrops:are_backgrounds_enabled() then
			return
		end

		local workspace = window:active_workspace() or "default"
		local opacity_file = get_opacity_file(workspace)

		-- Read opacity value from file
		local f = io.open(opacity_file, "r")
		if f then
			local opacity_str = f:read("*line")
			f:close()

			if opacity_str then
				local opacity = tonumber(opacity_str)
				if opacity and opacity >= 0.0 and opacity <= 1.0 then
					-- Check if opacity changed
					local workspace_key = workspace or "default"
					if last_opacity[workspace_key] ~= opacity then
						last_opacity[workspace_key] = opacity

						-- Update backdrop with new opacity
						backdrops.overlay_opacity = opacity

						-- Force refresh to apply new opacity
						backdrops:set_img(window, backdrops.current_idx)

						wezterm.log_info(
							string.format("Updated backdrop opacity for workspace '%s': %.2f", workspace, opacity)
						)
					end
				end
			end
		end
	end)

	wezterm.log_info("Backdrop opacity watcher initialized")
end

return M
