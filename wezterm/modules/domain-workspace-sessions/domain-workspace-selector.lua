-- ~/.core/cfg/wezterm/extra/domain_workspace_browser.lua
-- Interactive browser for domains and workspaces

local wezterm = require("wezterm")
-- local mux_manager = require("util.mux_manager")
local domain_manager = require("util.domain_manager")
local workspace_manager = require("util.workspace_manager")

local M = {}

-- Show domain selector
function M.show_domain_selector(window)
	local choices = {}

	-- Add header
	table.insert(choices, {
		label = "=== 🖥️ MUX DOMAINS ===",
	})

	-- Add current domains
	table.insert(choices, {
		label = "=== 📡 ACTIVE DOMAINS ===",
	})

	for _, domain in ipairs(wezterm.mux.all_domains()) do
		local name = domain:name()
		table.insert(choices, {
			id = "attach:" .. name,
			label = string.format("  → %s", name),
		})
	end

	-- Show selector
	window:perform_action(
		wezterm.action.InputSelector({
			title = "Domain Browser",
			choices = choices,
			action = wezterm.action_callback(function(win, pane, id)
				if not id then
					return
				end

				if id:match("^domain:") then
					local domain_name = id:gsub("^domain:", "")
					win:perform_action(wezterm.action.AttachDomain(domain_name), pane)
					wezterm.log_info("Attached to domain: " .. domain_name)
				elseif id:match("^attach:") then
					local domain_name = id:gsub("^attach:", "")
					win:perform_action(wezterm.action.AttachDomain(domain_name), pane)
				end
			end),
		}),
		window:active_pane()
	)
end

-- Show workspace selector
function M.show_workspace_selector(window)
	local choices = {}
	local current_workspace = window:active_workspace()

	-- Add header
	table.insert(choices, {
		label = string.format("=== 📁 WORKSPACES (Current: %s) ===", current_workspace),
	})

	-- List all workspaces in current window
	local workspaces = wezterm.mux.get_workspace_names()
	for _, name in ipairs(workspaces) do
		local marker = name == current_workspace and " ✓" or ""
		table.insert(choices, {
			id = "workspace:" .. name,
			label = string.format("  %s%s", name, marker),
		})
	end

	-- Add create new option
	table.insert(choices, {
		label = "=== ACTIONS ===",
	})

	table.insert(choices, {
		id = "action:new",
		label = "  ➕ Create new workspace",
	})

	table.insert(choices, {
		id = "action:rename",
		label = "  ✏️ Rename current workspace",
	})

	-- Show selector
	window:perform_action(
		wezterm.action.InputSelector({
			title = "Workspace Browser",
			choices = choices,
			action = wezterm.action_callback(function(win, pane, id)
				if not id then
					return
				end

				if id:match("^workspace:") then
					local workspace_name = id:gsub("^workspace:", "")
					win:perform_action(
						wezterm.action.SwitchToWorkspace({
							name = workspace_name,
						}),
						pane
					)
				elseif id == "action:new" then
					win:perform_action(
						wezterm.action.PromptInputLine({
							description = "Enter new workspace name:",
							action = wezterm.action_callback(function(window, pane, line)
								if line then
									window:perform_action(
										wezterm.action.SwitchToWorkspace({
											name = line,
										}),
										pane
									)
								end
							end),
						}),
						pane
					)
				elseif id == "action:rename" then
					win:perform_action(
						wezterm.action.PromptInputLine({
							description = "Rename workspace to:",
							initial_value = current_workspace,
							action = wezterm.action_callback(function(window, pane, line)
								if line and line ~= current_workspace then
									window:perform_action(
										wezterm.action.SwitchToWorkspace({
											name = line,
										}),
										pane
									)
									wezterm.mux.rename_workspace(current_workspace, line)
								end
							end),
						}),
						pane
					)
				end
			end),
		}),
		window:active_pane()
	)
end

-- Show combined browser
function M.show_browser(window)
	local choices = {}
	local current_workspace = window:active_workspace()
	local current_domain = window:active_pane():get_domain_name()

	-- Header
	table.insert(choices, {
		label = string.format("=== 🎮 CURRENT: Domain=%s | Workspace=%s ===", current_domain, current_workspace),
	})

	-- Domains section
	table.insert(choices, {
		label = "=== 🖥️ DOMAINS ===",
	})

	-- Workspaces section
	table.insert(choices, {
		label = "=== 📁 WORKSPACES ===",
	})

	local workspaces = wezterm.mux.get_workspace_names()
	for _, name in ipairs(workspaces) do
		local current = name == current_workspace and " ←" or ""
		table.insert(choices, {
			id = "workspace:" .. name,
			label = string.format("  📂 %s%s", name, current),
		})
	end

	-- Actions
	table.insert(choices, {
		label = "=== ACTIONS ===",
	})

	table.insert(choices, {
		id = "action:new_workspace",
		label = "  ➕ New workspace",
	})

	table.insert(choices, {
		id = "action:list_sessions",
		label = "  📋 List tmux sessions",
	})

	-- Show selector
	window:perform_action(
		wezterm.action.InputSelector({
			title = "Domain & Workspace Browser",
			choices = choices,
			action = wezterm.action_callback(function(win, pane, id)
				if not id then
					return
				end

				if id:match("^domain:") then
					local domain_name = id:gsub("^domain:", "")
					win:perform_action(wezterm.action.AttachDomain(domain_name), pane)
				elseif id:match("^workspace:") then
					local workspace_name = id:gsub("^workspace:", "")
					win:perform_action(
						wezterm.action.SwitchToWorkspace({
							name = workspace_name,
						}),
						pane
					)
				elseif id == "action:new_workspace" then
					win:perform_action(
						wezterm.action.PromptInputLine({
							description = "Enter new workspace name:",
							action = wezterm.action_callback(function(window, pane, line)
								if line then
									window:perform_action(
										wezterm.action.SwitchToWorkspace({
											name = line,
											spawn = {
												args = { "bash", "-c", "tmux new-session -A -s " .. line },
											},
										}),
										pane
									)
								end
							end),
						}),
						pane
					)
				elseif id == "action:list_sessions" then
					pane:send_text("tmux list-sessions\n")
				end
			end),
		}),
		window:active_pane()
	)
end

return M
