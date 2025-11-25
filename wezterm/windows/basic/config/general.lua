local Icons = require("utils.class.icon")
local fs = require("utils.fn").fs

local Config = {}

if fs.platform().is_win then
	Config.default_prog = { "pwsh", "-NoLogo", "-ExecutionPolicy", "RemoteSigned", "-NoProfileLoadTime" }

	Config.launch_menu = {
		{
			label = Icons.Progs["pwsh.exe"] .. " PowerShell V7",
			args = {
				"pwsh",
				"-NoLogo",
				"-ExecutionPolicy",
				"RemoteSigned",
				"-NoProfileLoadTime",
			},
			cwd = "~",
		},
		{
			label = Icons.Progs["pwsh.exe"] .. " PowerShell V5",
			args = { "powershell" },
			cwd = "~",
		},
		{ label = "Command Prompt", args = { "cmd.exe" }, cwd = "~" },
		{ label = Icons.Progs["git"] .. " Git bash", args = { "sh", "-l" }, cwd = "~" },
	}

	-- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
	Config.wsl_domains = {}
	--   {
	--     name = "WSL:Ubuntu",
	--     distribution = "Ubuntu",
	--     username = "sravioli",
	--     default_cwd = "~",
	--     default_prog = { "bash", "-i", "-l" },
	--   },
	--   {
	--     name = "WSL:Alpine",
	--     distribution = "Alpine",
	--     username = "sravioli",
	--     default_cwd = "/home/sravioli",
	--   },
	-- }
end

Config.default_cwd = fs.home()

-- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
Config.ssh_domains = {}

-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
Config.unix_domains = {}

return Config

--
-- -- ~/.core/.sys/configs/wezterm/config/general.lua
-- -- General configuration settings
-- local wezterm = require("wezterm")
-- local act = wezterm.action
-- -- local gpu_adapters = require("utils.gpuadapters")  -- DISABLED: causes EGL crash
-- local debug_config = require("config.debug")
--
-- -- Register the URI handler first (outside the config table)
-- wezterm.on("open-uri", function(window, pane, uri)
-- 	local editor = os.getenv("EDITOR") or "nvim"
--
-- 	local function is_shell(process_name)
-- 		local shells = { "bash", "zsh", "fish", "sh" }
-- 		for _, shell in ipairs(shells) do
-- 			if process_name and process_name:find(shell) then
-- 				return true
-- 			end
-- 		end
-- 		return false
-- 	end
--
-- 	if uri:find("^file:") == 1 and not pane:is_alt_screen_active() then
-- 		local url = wezterm.url.parse(uri)
-- 		if is_shell(pane:get_foreground_process_name()) then
-- 			local success, stdout, _ = wezterm.run_child_process({
-- 				"file",
-- 				"--brief",
-- 				"--mime-type",
-- 				url.file_path,
-- 			})
-- 			if success then
-- 				if stdout:find("directory") then
-- 					pane:send_text(wezterm.shell_join_args({ "cd", url.file_path }) .. "\r")
-- 					pane:send_text(wezterm.shell_join_args({
-- 						"ls",
-- 						"-la",
-- 						"--color=auto",
-- 						"--group-directories-first",
-- 					}) .. "\r")
-- 					return false
-- 				end
-- 				if stdout:find("text") then
-- 					if url.fragment then
-- 						pane:send_text(wezterm.shell_join_args({
-- 							editor,
-- 							"+" .. url.fragment,
-- 							url.file_path,
-- 						}) .. "\r")
-- 					else
-- 						pane:send_text(wezterm.shell_join_args({ editor, url.file_path }) .. "\r")
-- 					end
-- 					return false
-- 				end
-- 			end
-- 		else
-- 			local edit_cmd = url.fragment and editor .. " +" .. url.fragment .. ' "$_f"' or editor .. ' "$_f"'
-- 			local cmd = '_f="'
-- 				.. url.file_path
-- 				.. '"; { test -d "$_f" && { cd "$_f" ; ls -la --color=auto --group-directories-first; }; } '
-- 				.. '|| { test "$(file --brief --mime-type "$_f" | cut -d/ -f1 || true)" = "text" && '
-- 				.. edit_cmd
-- 				.. "; }; echo"
-- 			pane:send_text(cmd .. "\r")
-- 			return false
-- 		end
-- 	end
-- end)
--
-- -- Build the configuration table
-- local config = {
-- 	-- Terminal
-- 	-- Use wezterm TERM for native features, tmux will override inside sessions
-- 	term = "wezterm",
-- 	scrollback_lines = 10000,
--
-- 	-- IMPORTANT: Only use ONE keyboard protocol at a time
-- 	-- CSI-u is REQUIRED to distinguish C-` from C-Space, C-2 from C-@, etc.
-- 	-- Kitty protocol can cause conflicts with tmux key bindings
-- 	-- Graphics protocol (required for inline image rendering in neovim)
-- 	enable_kitty_graphics = true,
-- 	-- debug_key_events = debug_config.debug_key_events or false,
-- 	automatically_reload_config = false,
-- 	default_cwd = "/home/theron/.core",
-- 	-- enable_osc52 = true,
--
-- 	-- GPU Configuration
-- 	-- front_end = "WebGpu",
-- 	-- enable_wayland = false, -- Disable Wayland, use X11
-- 	front_end = "OpenGL",
-- 	prefer_egl = true,
-- 	enable_wayland = true, -- Disable Wayland, use X11
-- 	-- prefer_egl = true,
-- 	enable_csi_u_key_encoding = true,
-- 	enable_kitty_keyboard = false,
-- 	unicode_version = 9,
-- 	-- Performance
-- 	max_fps = 144,
-- 	animation_fps = 144,
-- 	mux_output_parser_buffer_size = 1024 * 1024,
-- 	mux_output_parser_coalesce_delay_ms = 2,
--
-- 	-- Window behavior
-- 	exit_behavior = "Close",
-- 	window_close_confirmation = "NeverPrompt",
-- 	skip_close_confirmation_for_processes_named = {
-- 		"bash",
-- 		"sh",
-- 		"zsh",
-- 		"fish",
-- 		"tmux",
-- 	},
--
-- 	-- Quick select patterns
-- 	quick_select_patterns = {
-- 		"https?://[^\\s]+",
-- 		"(?:[.~\\w\\-@]+)?(?:/[.~\\w\\-@]+)+/?",
-- 		"\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b",
-- 		"\\b[0-9a-fA-F]{7,40}\\b",
-- 		"\\b[0-9a-fA-F]{12,64}\\b",
-- 	},
--
-- 	-- -- Disable mouse wheel scrolling on tabline to prevent tab switching
-- 	-- mouse_bindings = {
-- 	-- 	-- Disable tab switching on mouse wheel scroll over tabline
-- 	-- 	{
-- 	-- 		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
-- 	-- 		mods = "NONE",
-- 	-- 		action = wezterm.action.DisableDefaultAssignment,
-- 	-- 	},
-- 	-- 	{
-- 	-- 		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
-- 	-- 		mods = "NONE",
-- 	-- 		action = wezterm.action.DisableDefaultAssignment,
-- 	-- 	},
-- 	-- },
-- }
--
-- -- Auto-pick the best GPU adapter
-- -- DISABLED: enumerate_gpus() crashes on wezterm 2024-10-05 with EGL error
-- -- local DEBUG_GPU = debug_config.debug_config_gpu or debug_config.debug_all
-- -- local best_adapter = gpu_adapters:pick_best()
-- -- if best_adapter then
-- -- 	config.webgpu_preferred_adapter = best_adapter
-- -- 	if DEBUG_GPU then
-- -- 		wezterm.log_info("Using GPU adapter: " .. best_adapter.name .. " (" .. best_adapter.backend .. ")")
-- -- 	end
-- -- else
-- -- 	if DEBUG_GPU then
-- -- 		wezterm.log_warn("No suitable GPU adapter found; using WezTerm default.")
-- -- 	end
-- -- end
--
-- return config
