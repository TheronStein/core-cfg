local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.setup(config)
	-- Get domain name helper
	local function get_domain_name()
		-- Try to get from environment (for mux servers)
		local domain = os.getenv("MUX_DOMAIN")
		if domain then
			return domain
		end

		-- Fallback to hostname for local
		local hostname = wezterm.hostname()
		return hostname:gsub("%..*", "") -- Strip domain suffix
	end

	-- Keybinding: Open workspace launcher
	table.insert(config.keys, {
		key = "w",
		mods = "CTRL|ALT",
		action = wezterm.action_callback(function(window, pane)
			local domain_name = get_domain_name()
			local defaults = require("mux.utils.defaults")
			local workspace_names = defaults.get_workspace_names(domain_name)

			local choices = {}

			-- Add option to create new workspace
			table.insert(choices, {
				id = "__create_new__",
				label = "[+] Create New Workspace",
			})

			-- Add existing default workspaces
			for _, name in ipairs(workspace_names) do
				table.insert(choices, {
					id = name,
					label = "📁 " .. name,
				})
			end

			window:perform_action(
				act.InputSelector({
					action = wezterm.action_callback(function(win, pane, id, label)
						if not id then
							return
						end

						if id == "__create_new__" then
							-- Prompt for new workspace name
							win:perform_action(
								act.PromptInputLine({
									description = "Enter new workspace name:",
									action = wezterm.action_callback(function(w, p, line)
										if line and line ~= "" then
											local cwd = pane:get_current_working_dir()
											local cwd_path = cwd and cwd.file_path or (os.getenv("HOME") .. "/.core")

											defaults.add_workspace(domain_name, line, cwd_path)
											w:toast_notification("Wezterm", "Created workspace: " .. line, nil, 3000)

											-- Switch to new workspace
											local workspace_manager = require("mux.utils.workspace_manager")
											workspace_manager.switch_to(domain_name, line)
										end
									end),
								}),
								pane
							)
						else
							-- Switch to selected workspace
							local workspace_manager = require("mux.utils.workspace_manager")
							workspace_manager.switch_to(domain_name, id)
						end
					end),
					title = "Workspaces",
					choices = choices,
					fuzzy = true,
				}),
				pane
			)
		end),
	})

	-- Keybinding: Update current workspace cwd
	table.insert(config.keys, {
		key = "W",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local domain_name = get_domain_name()
			local workspace_manager = require("mux.utils.workspace_manager")
			local current_workspace = workspace_manager.get_current_workspace()

			if not current_workspace then
				window:toast_notification("Wezterm", "No active workspace", nil, 3000)
				return
			end

			local cwd = pane:get_current_working_dir()
			local cwd_path = cwd and cwd.file_path or os.getenv("HOME")

			local defaults = require("mux.utils.defaults")
			if defaults.update_cwd(domain_name, current_workspace, cwd_path) then
				window:toast_notification(
					"Wezterm",
					"Updated " .. current_workspace .. " cwd to: " .. cwd_path,
					nil,
					3000
				)
			end
		end),
	})

	-- Keybinding: Delete workspace from defaults
	table.insert(config.keys, {
		key = "D",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action_callback(function(window, pane)
			local domain_name = get_domain_name()
			local defaults = require("mux.utils.defaults")
			local workspace_names = defaults.get_workspace_names(domain_name)

			if #workspace_names == 0 then
				window:toast_notification("Wezterm", "No workspaces to delete", nil, 3000)
				return
			end

			local choices = {}
			for _, name in ipairs(workspace_names) do
				table.insert(choices, {
					id = name,
					label = "🗑️  " .. name,
				})
			end

			window:perform_action(
				act.InputSelector({
					action = wezterm.action_callback(function(win, p, id, label)
						if id then
							defaults.remove_workspace(domain_name, id)
							win:toast_notification("Wezterm", "Deleted workspace: " .. id, nil, 3000)
						end
					end),
					title = "Delete Workspace",
					choices = choices,
					fuzzy = true,
				}),
				pane
			)
		end),
	})
end

return M
