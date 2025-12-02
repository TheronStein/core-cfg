-- Navigation event handlers
-- Handles navigation-related events:
--   - open-uri (smart file/directory opening)
--   - key-event (key event logging/debugging)

local wezterm = require("wezterm")

local M = {}

-- ============================================================================
-- OPEN URI
-- ============================================================================

-- Check if process is a shell
local function is_shell(process_name)
	if not process_name then
		return false
	end
	local basename = process_name:match("([^/]+)$") or process_name
	return basename == "bash" or basename == "zsh" or basename == "fish" or basename == "sh"
end

function M.handle_open_uri(window, pane, uri)
	local editor = os.getenv("EDITOR") or "nvim"

	-- Only handle file:// URIs when not in alt screen (e.g., not in vim)
	if uri:find("^file:") == 1 and not pane:is_alt_screen_active() then
		local url = wezterm.url.parse(uri)

		if is_shell(pane:get_foreground_process_name()) then
			-- Shell is active - use file command to determine type
			local success, stdout, _ = wezterm.run_child_process({
				"file",
				"--brief",
				"--mime-type",
				url.file_path,
			})

			if success then
				if stdout:find("directory") then
					-- Directory: cd and ls
					pane:send_text(wezterm.shell_join_args({ "cd", url.file_path }) .. "\r")
					pane:send_text(wezterm.shell_join_args({
						"ls",
						"-la",
						"--color=auto",
						"--group-directories-first",
					}) .. "\r")
					return false
				end

				if stdout:find("text") then
					-- Text file: open in editor
					if url.fragment then
						pane:send_text(wezterm.shell_join_args({
							editor,
							"+" .. url.fragment,
							url.file_path,
						}) .. "\r")
					else
						pane:send_text(wezterm.shell_join_args({ editor, url.file_path }) .. "\r")
					end
					return false
				end
			end
		else
			-- Not in shell - construct command to run
			local edit_cmd = url.fragment and editor .. " +" .. url.fragment .. ' "$_f"' or editor .. ' "$_f"'
			local cmd = '_f="'
				.. url.file_path
				.. '"; { test -d "$_f" && { cd "$_f" ; ls -la --color=auto --group-directories-first; }; } '
				.. '|| { test "$(file --brief --mime-type "$_f" | cut -d/ -f1 || true)" = "text" && '
				.. edit_cmd
				.. "; }; echo"
			pane:send_text(cmd .. "\r")
			return false
		end
	end
end

-- ============================================================================
-- KEY EVENT (DEBUG/LOGGING)
-- ============================================================================

-- Custom logging function for key events
local function log_key_event(event_data)
	-- Only log if debug mode is enabled
	local debug_config = require("config.debug")
	if debug_config.is_enabled("debug_key_events") then
		wezterm.log_info(
			string.format(
				"[KEY_EVENT] key=%s mods=%s event=%s",
				event_data.key or "nil",
				event_data.mods or "nil",
				event_data.event or "nil"
			)
		)
	end
end

function M.handle_key_event(window, pane, key, mods, event)
	log_key_event({ key = key, mods = mods, event = event })
	return true -- Allow the event to propagate
end

-- ============================================================================
-- SETUP
-- ============================================================================
function M.setup()
	if wezterm.GLOBAL.navigation_initialized then
		return
	end
	wezterm.GLOBAL.navigation_initialized = true

	-- Open URI event
	wezterm.on("open-uri", function(window, pane, uri)
		return M.handle_open_uri(window, pane, uri)
	end)

	-- Key event (for debugging/logging)
	wezterm.on("key-event", function(window, pane, key, mods, event)
		return M.handle_key_event(window, pane, key, mods, event)
	end)

	wezterm.log_info("[EVENT] Navigation handlers initialized")
end

return M
