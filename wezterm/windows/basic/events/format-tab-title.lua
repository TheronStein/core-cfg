local wezterm = require("wezterm")

-- Icon mapping for common processes
local process_icons = {
	["zsh"] = "",
	["bash"] = "",
	["nvim"] = "",
	["vim"] = "",
	["git"] = "",
	["lazygit"] = "",
	["ssh"] = "",
	["docker"] = "",
	["python"] = "",
	["node"] = "",
	["cargo"] = "",
	["tmux"] = "",
	["yazi"] = "",
}

local function get_process_icon(process_name)
	-- Extract base process name (remove path)
	local basename = process_name:match("([^/]+)$") or process_name
	-- Check if we have a custom icon
	return process_icons[basename] or ""
end

-- Truncate string to max length with ".." suffix
local function truncate(str, max_len)
	if #str <= max_len then
		return str
	end
	return str:sub(1, max_len - 2) .. ".."
end

-- Get CWD or process name for display
local function get_cwd_or_process(pane)
	local cwd = pane.current_working_dir
	if cwd then
		local cwd_path = cwd.file_path or cwd
		-- Extract just the directory name
		local dir = cwd_path:match("([^/]+)/?$") or cwd_path
		return dir
	end

	-- Fallback to process name
	local process = pane.foreground_process_name or ""
	return process:match("([^/]+)$") or process
end

local M = {}

function M.setup()
	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local pane = tab.active_pane
		local process_name = pane.foreground_process_name or ""
		local process_icon = get_process_icon(process_name)

		-- Get user variables (tmux info)
		local user_vars = pane:get_user_vars()
		local tmux_session = user_vars.TMUX_SESSION or ""
		local tmux_window = user_vars.TMUX_WINDOW or ""
		local tmux_server_icon = user_vars.TMUX_SERVER_ICON or ""

		-- Decode base64 values
		if tmux_session ~= "" then
			local ok, decoded = pcall(wezterm.base64_decode, tmux_session)
			if ok then
				tmux_session = decoded
			end
		end
		if tmux_window ~= "" then
			local ok, decoded = pcall(wezterm.base64_decode, tmux_window)
			if ok then
				tmux_window = decoded
			end
		end
		if tmux_server_icon ~= "" then
			local ok, decoded = pcall(wezterm.base64_decode, tmux_server_icon)
			if ok then
				-- Trim any trailing newlines/whitespace from icon
				tmux_server_icon = decoded:gsub("%s+$", "")
			end
		end

		-- Get CWD/process
		local cwd_proc = get_cwd_or_process(pane)
		local cwd_proc_display = truncate(cwd_proc, 20)

		-- Build context string [tmux_icon WINDOW] or [DOMAIN]
		local context = ""
		if tmux_window ~= "" then
			-- Inside tmux: show window name with optional icon
			local window_part = truncate(tmux_window, 10)
			if tmux_server_icon ~= "" then
				context = "[" .. tmux_server_icon .. " " .. window_part .. "]"
			else
				context = "[ " .. window_part .. "]"
			end
		else
			-- Not in tmux: show domain
			local domain = pane.domain_name or "local"
			local domain_display = truncate(domain, 14)
			context = "[" .. domain_display .. "]"
		end

		-- Build final title: icon cwd/proc [context]
		local title = cwd_proc_display .. " " .. context

		-- Build the formatted title: "icon" in first section, title in second
		local process_display = process_icon ~= "" and process_icon or ""

		-- Colors matching tmux style
		local bg_inactive_arrow = "#5b4996"
		local fg_inactive_text = "#FFFFFF"
		local bg_inactive_text = "#5b4996"
		local bg_content = "#45475a"
		local fg_content = "#cdd6f4"
		local bg_tab_bar = "#292D3E"

		local bg_active_arrow = "#01F9C6"
		local fg_active_text = "#1e1e2e"
		local bg_active_text = "#01F9C6"

		local zoomed_indicator = pane.is_zoomed and "⬢ " or ""

		if tab.is_active then
			-- Active tab styling (matches tmux cyan theme)
			return {
				{ Foreground = { Color = bg_active_arrow } },
				{ Text = "" },
				{ Foreground = { Color = fg_active_text } },
				{ Background = { Color = bg_active_text } },
				{ Text = zoomed_indicator .. process_display .. " " },
				{ Foreground = { Color = bg_content } },
				{ Background = { Color = bg_active_text } },
				{ Text = "" },
				{ Foreground = { Color = fg_content } },
				{ Background = { Color = bg_content } },
				{ Text = " " .. title .. " " },
				{ Foreground = { Color = bg_content } },
				{ Background = { Color = bg_tab_bar } },
				{ Text = " " },
			}
		else
			-- Inactive tab styling (matches tmux purple theme)
			return {
				{ Foreground = { Color = bg_inactive_arrow } },
				{ Text = "" },
				{ Foreground = { Color = fg_inactive_text } },
				{ Background = { Color = bg_inactive_text } },
				{ Text = zoomed_indicator .. process_display .. " " },
				{ Foreground = { Color = bg_content } },
				{ Background = { Color = bg_inactive_text } },
				{ Text = "" },
				{ Foreground = { Color = fg_content } },
				{ Background = { Color = bg_content } },
				{ Text = " " .. title .. " " },
				{ Foreground = { Color = bg_content } },
				{ Background = { Color = bg_tab_bar } },
				{ Text = " " },
			}
		end
	end)
end

return M

