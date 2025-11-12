local wezterm = require("wezterm")

local M = {}

-- Overlay modes
M.modes = {
	DARK = "dark",
	TRANSPARENT = "transparent",
	COLOR_SCHEME = "color_scheme",
	GRADIENT = "gradient",
}

-- Default mode
M.current_mode = M.modes.DARK

-- Store the current color scheme background for color_scheme mode
M.current_scheme_bg = nil

function M.setup()
	wezterm.on("trigger-overlay-mode-picker", function(window, pane)
		local backdrops = require("modules.gui.backdrops")

		local choices = {
			{
				id = M.modes.DARK,
				label = "Dark/Black Overlay - Semi-transparent dark overlay (current default)",
			},
			{
				id = M.modes.TRANSPARENT,
				label = "Transparent/Minimal - Light overlay, shows more backdrop",
			},
			{
				id = M.modes.COLOR_SCHEME,
				label = "Color Scheme Background - Uses active theme's background",
			},
			{
				id = M.modes.GRADIENT,
				label = "Custom Gradient - Custom gradient overlay",
			},
		}

		window:perform_action(
			wezterm.action.InputSelector({
				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
					if not id then
						return -- User cancelled
					end

					-- Update the mode
					M.current_mode = id

					-- Get current color scheme if switching to color_scheme mode
					if id == M.modes.COLOR_SCHEME then
						local overrides = inner_window:get_config_overrides() or {}
						local color_scheme = overrides.color_scheme or inner_window:effective_config().color_scheme
						if color_scheme then
							local schemes = wezterm.get_builtin_color_schemes()
							local scheme_def = schemes[color_scheme]
							if scheme_def and scheme_def.background then
								M.current_scheme_bg = scheme_def.background
							end
						end
					end

					-- Force backdrop refresh with new mode
					if backdrops.backgrounds_enabled then
						backdrops:_set_opt(inner_window, backdrops:_create_opts(inner_window))
					end

					inner_window:toast_notification("Overlay Mode", "Switched to: " .. label, nil, 2000)
				end),
				title = "Choose Background Overlay Mode",
				choices = choices,
				fuzzy = true,
				fuzzy_description = "Search overlay modes: ",
			}),
			pane
		)
	end)
end

-- Function to get overlay config based on current mode
function M.get_overlay_config(colors_background)
	local overlay = {
		height = "100%",
		width = "100%",
	}

	if M.current_mode == M.modes.DARK then
		-- Current default: dark overlay with 0.85 opacity
		overlay.source = { Color = colors_background }
		overlay.opacity = 0.85

	elseif M.current_mode == M.modes.TRANSPARENT then
		-- Minimal overlay: lighter and more transparent
		overlay.source = { Color = colors_background }
		overlay.opacity = 0.3

	elseif M.current_mode == M.modes.COLOR_SCHEME then
		-- Use the current color scheme's background
		local bg_color = M.current_scheme_bg or colors_background
		overlay.source = { Color = bg_color }
		overlay.opacity = 0.7

	elseif M.current_mode == M.modes.GRADIENT then
		-- Custom gradient overlay
		overlay.source = {
			Gradient = {
				orientation = { Linear = { angle = -90.0 } },
				colors = { "#1f1f28", "#2a2a37" }, -- Dark blue-grey gradient
			},
		}
		overlay.opacity = 0.75
	end

	return overlay
end

-- Update color scheme background when theme changes
wezterm.on("window-config-reloaded", function(window, pane)
	if M.current_mode == M.modes.COLOR_SCHEME then
		local overrides = window:get_config_overrides() or {}
		local color_scheme = overrides.color_scheme or window:effective_config().color_scheme
		if color_scheme then
			local schemes = wezterm.get_builtin_color_schemes()
			local scheme_def = schemes[color_scheme]
			if scheme_def and scheme_def.background then
				M.current_scheme_bg = scheme_def.background
			end
		end
	end
end)

return M
