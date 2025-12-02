-- ~/.core/.sys/configs/wezterm/util/env_helper.lua
-- Environment configuration helper for Hyprland/Wayland

local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or os.getenv("HOME") .. "/.local/share/wezterm"

local M = {}

function M.init()
	local env = {}

	-- Core environment
	env["HOME"] = os.getenv("HOME")
	env["USER"] = os.getenv("USER")
	env["SHELL"] = os.getenv("SHELL") or "/bin/zsh"
	env["TERM"] = "wezterm"
	env["COLORTERM"] = "truecolor"

	-- XDG directories (use CORECFG env var with fallback)
	env["XDG_RUNTIME_DIR"] = os.getenv("XDG_RUNTIME_DIR")
	env["XDG_CONFIG_HOME"] = os.getenv("XDG_CONFIG_HOME") or os.getenv("CORECFG") or (env["HOME"] .. "/.core/.sys/cfg")
	env["XDG_DATA_HOME"] = os.getenv("XDG_DATA_HOME") or (env["HOME"] .. "/.local/share")
	env["XDG_CACHE_HOME"] = os.getenv("XDG_CACHE_HOME") or (env["HOME"] .. "/.cache")
	env["XDG_STATE_HOME"] = os.getenv("XDG_STATE_HOME") or (env["HOME"] .. "/.local/state")

	-- Wayland/Hyprland specific
	env["WAYLAND_DISPLAY"] = os.getenv("WAYLAND_DISPLAY")
	env["HYPRLAND_INSTANCE_SIGNATURE"] = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
	env["XDG_CURRENT_DESKTOP"] = os.getenv("XDG_CURRENT_DESKTOP") or "Hyprland"
	env["XDG_SESSION_TYPE"] = "wayland"
	env["GDK_BACKEND"] = "wayland,x11"
	env["QT_QPA_PLATFORM"] = "wayland;xcb"
	env["SDL_VIDEODRIVER"] = "wayland"
	env["CLUTTER_BACKEND"] = "wayland"

	-- GPU/Rendering (for your ASUS setup)
	env["WLR_DRM_DEVICES"] = os.getenv("WLR_DRM_DEVICES")
	env["__GLX_VENDOR_LIBRARY_NAME"] = os.getenv("__GLX_VENDOR_LIBRARY_NAME")
	env["VK_ICD_FILENAMES"] = os.getenv("VK_ICD_FILENAMES")

	-- Development paths
	env["PATH"] = os.getenv("PATH")
	env["LD_LIBRARY_PATH"] = os.getenv("LD_LIBRARY_PATH")

	-- SSH/GPG
	env["SSH_AUTH_SOCK"] = os.getenv("SSH_AUTH_SOCK")
	env["GPG_TTY"] = os.getenv("GPG_TTY")

	-- Locale
	env["LANG"] = os.getenv("LANG") or "en_US.UTF-8"
	env["LC_ALL"] = os.getenv("LC_ALL")

	-- Remove nil values
	local clean_env = {}
	for k, v in pairs(env) do
		if v ~= nil then
			clean_env[k] = v
		end
	end

	return clean_env
end

return M
