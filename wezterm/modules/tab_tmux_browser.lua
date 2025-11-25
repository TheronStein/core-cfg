-- ~/.core/.sys/configs/wezterm/modules/tab_tmux_browser.lua
-- Unified browser for both tab templates and tmux sessions

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- Try to load required modules
local function safe_require(module_name)
	local ok, mod = pcall(require, module_name)
	return ok and mod or nil
end

local tab_templates = safe_require("modules.tab_templates")
local tmux_sessions = safe_require("modules.tmux_sessions")

-- Show unified menu with both tab templates and tmux sessions
function M.show_browser(window, pane)
	local choices = {}

	-- Header
	table.insert(choices, {
		label = "📋 Tab Templates & 📺 Tmux Sessions",
		id = "__header__",
	})

	table.insert(choices, {
		label = "═══════════════════════════════════════",
		id = "__separator0__",
	})

	-- Add Tab Templates section
	if tab_templates then
		local templates = tab_templates.load_templates()
		local has_templates = templates and next(templates) ~= nil

		if has_templates then
			table.insert(choices, {
				label = "─── 📋 TAB TEMPLATES ───",
				id = "__templates_header__",
			})

			-- Sort templates by name
			local sorted_names = {}
			for name, _ in pairs(templates) do
				table.insert(sorted_names, name)
			end
			table.sort(sorted_names)

			-- Add each template
			for _, name in ipairs(sorted_names) do
				local template = templates[name]
				local display = "  " .. (template.full_title or template.title or name)
				if template.tmux_session then
					display = display .. " [tmux: " .. template.tmux_session .. "]"
				end

				table.insert(choices, {
					label = display,
					id = "template:" .. name,
				})
			end
		end
	end

	-- Add Tmux Sessions section
	if tmux_sessions and tmux_sessions.is_tmux_available() then
		local sessions = tmux_sessions.list_sessions()

		if #sessions > 0 then
			table.insert(choices, {
				label = "─── 📺 TMUX SESSIONS ───",
				id = "__tmux_header__",
			})

			-- Add each session
			for _, session in ipairs(sessions) do
				local status_icon = session.attached and "📌" or "○"
				local display = string.format("  %s %s (%d windows)", status_icon, session.name, session.windows)

				table.insert(choices, {
					label = display,
					id = "tmux:" .. session.name,
				})
			end
		end
	end

	-- Add management options
	table.insert(choices, {
		label = "═══════════════════════════════════════",
		id = "__separator1__",
	})

	table.insert(choices, {
		label = "➕ Create new tmux session",
		id = "__create_tmux__",
	})

	table.insert(choices, {
		label = "⬅️  Back to Tab Manager",
		id = "__back__",
	})

	-- Show the menu
	window:perform_action(
		act.InputSelector({
			title = "📋 Tab Templates & 📺 Tmux Sessions",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				if not id then
					return
				end

				-- Handle special actions
				if id:sub(1, 2) == "__" then
					if id == "__create_tmux__" then
						if tmux_sessions then
							tmux_sessions.prompt_create_session(win, p)
						end
					elseif id == "__back__" then
						local tab_manager = safe_require("modules.tab_manager")
						if tab_manager then
							tab_manager.show_main_menu(win, p)
						end
					end
					return
				end

				-- Handle tab template selection
				if id:sub(1, 9) == "template:" then
					local template_name = id:sub(10)
					if tab_templates then
						local templates = tab_templates.load_templates()
						local template = templates[template_name]

						if template then
							wezterm.log_info("Loading template: " .. template_name)

							-- Check if template has tmux session
							if template.tmux_session then
								-- Spawn new tab with tmux session
								if tmux_sessions then
									local tab = tmux_sessions.spawn_tab_with_custom_session(
										win,
										p,
										template.tmux_session,
										template.title,
										template.icon,
										true -- create if missing
									)

									if tab then
										win:toast_notification(
											"Tab Template",
											"Loaded " .. (template.full_title or template.title) .. " with tmux: " .. template.tmux_session,
											nil,
											2000
										)
									end
								end
							else
								-- No tmux session, just apply template to current tab
								if not wezterm.GLOBAL.custom_tabs then
									wezterm.GLOBAL.custom_tabs = {}
								end

								local tab_id = tostring(win:active_tab():tab_id())
								wezterm.GLOBAL.custom_tabs[tab_id] = {
									title = template.title,
									icon_key = template.icon,
								}

								win:toast_notification(
									"Tab Template",
									"Applied template: " .. (template.full_title or template.title),
									nil,
									2000
								)
							end
						end
					end

				-- Handle tmux session selection
				elseif id:sub(1, 5) == "tmux:" then
					local session_name = id:sub(6)
					if tmux_sessions then
						-- Spawn tab with selected session
						local tab = tmux_sessions.spawn_tab_with_session(win, p, session_name, false)
						if tab then
							win:toast_notification("Tmux", "Attached to session: " .. session_name, nil, 2000)
						end
					end
				end
			end),
		}),
		pane
	)
end

-- Quick attach to tmux session via FZF browser
function M.browse_tmux_with_fzf(window, pane)
	if not tmux_sessions or not tmux_sessions.is_tmux_available() then
		window:toast_notification("Tmux", "tmux not available", nil, 3000)
		return
	end

	local script = wezterm.config_dir .. "/scripts/tmux-browser/browser.sh"

	-- Spawn a temporary pane to run the browser
	window:perform_action(
		act.SpawnCommandInNewTab({
			args = { "bash", "-c", script .. "; read -p 'Press enter to close...'" },
		}),
		pane
	)
end

return M
