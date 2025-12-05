-- Tab Template Hooks System
-- Automatically applies tab templates when directory patterns match
--
-- Features:
-- - Directory pattern matching using Lua patterns
-- - Automatic template loading on directory change
-- - State tracking to prevent repeated applications
-- - Integration with existing tab template system
-- - User control: enable/disable globally or per-rule

local wezterm = require("wezterm")
local paths = require("utils.paths")
local M = {}

-- Path to hooks configuration file
M.hooks_file = paths.WEZTERM_DATA .. "/tabs/hooks.json"

-- Global state for tracking applied hooks
-- Format: { [pane_id] = { cwd = "/path", hook_name = "rulename", applied_at = timestamp } }
M.applied_hooks = {}

-- Global enable/disable flag
M.hooks_enabled = true

-- ============================================================================
-- CONFIGURATION MANAGEMENT
-- ============================================================================

-- Load hooks configuration from JSON
function M.load_hooks()
	local file = io.open(M.hooks_file, "r")
	if not file then
		wezterm.log_info("[TAB_HOOKS] No hooks file found, using empty configuration")
		return {
			enabled = true,
			rules = {},
		}
	end

	local content = file:read("*a")
	file:close()

	if content == "" then
		return {
			enabled = true,
			rules = {},
		}
	end

	local success, config = pcall(wezterm.json_parse, content)
	if not success then
		wezterm.log_error("[TAB_HOOKS] Failed to parse hooks config: " .. tostring(config))
		return {
			enabled = true,
			rules = {},
		}
	end

	-- Ensure structure is valid
	config.enabled = config.enabled ~= false -- Default to true
	config.rules = config.rules or {}

	return config
end

-- Save hooks configuration to JSON
function M.save_hooks(config)
	-- Ensure directory exists
	os.execute("mkdir -p " .. paths.WEZTERM_DATA .. "/tabs")

	local file = io.open(M.hooks_file, "w")
	if not file then
		wezterm.log_error("[TAB_HOOKS] Failed to open hooks file for writing")
		return false
	end

	local content = wezterm.json_encode(config)
	file:write(content)
	file:close()

	wezterm.log_info("[TAB_HOOKS] Saved hooks configuration")
	return true
end

-- ============================================================================
-- PATH NORMALIZATION
-- ============================================================================

-- Extract clean path from WezTerm's CWD format
-- Handles: file://hostname/path, file:///path, table with file_path, plain string
local function extract_path(cwd)
	if not cwd then
		return nil
	end

	-- Handle table format with file_path
	if type(cwd) == "table" and cwd.file_path then
		return cwd.file_path
	end

	-- Convert to string
	cwd = tostring(cwd)

	-- Handle file:// URLs
	if cwd:match("^file://") then
		-- Remove file://hostname or file://
		local path = cwd:gsub("^file://[^/]+", "") or cwd:gsub("^file://", "")
		return path
	end

	return cwd
end

-- Expand ~ to home directory
local function expand_home(path)
	if path:sub(1, 1) == "~" then
		local home = wezterm.home_dir
		return home .. path:sub(2)
	end
	return path
end

-- Normalize path for comparison
local function normalize_path(path)
	if not path then
		return nil
	end

	path = extract_path(path)
	if not path then
		return nil
	end

	path = expand_home(path)

	-- Remove trailing slashes
	path = path:gsub("/+$", "")

	return path
end

-- ============================================================================
-- PATTERN MATCHING
-- ============================================================================

-- Check if path matches pattern
-- Supports:
--   - Lua patterns (default)
--   - Exact matches
--   - Prefix matches (ends with /*)
local function path_matches_pattern(path, pattern)
	if not path or not pattern then
		return false
	end

	path = normalize_path(path)
	pattern = expand_home(pattern)

	-- Exact match
	if path == pattern then
		return true
	end

	-- Prefix match: /path/to/dir/* matches /path/to/dir/anything
	if pattern:sub(-2) == "/*" then
		local prefix = pattern:sub(1, -3) -- Remove /*
		prefix = normalize_path(prefix)
		return path:sub(1, #prefix) == prefix
	end

	-- Lua pattern match
	local match_result = path:match(pattern)
	return match_result ~= nil
end

-- Find matching rule for a given path
local function find_matching_rule(path, rules)
	if not path then
		return nil
	end

	for _, rule in ipairs(rules) do
		if rule.enabled ~= false then -- Rules enabled by default
			if path_matches_pattern(path, rule.pattern) then
				wezterm.log_info(
					"[TAB_HOOKS] Path '" .. path .. "' matched pattern '" .. rule.pattern .. "'"
				)
				return rule
			end
		end
	end

	return nil
end

-- ============================================================================
-- TEMPLATE APPLICATION
-- ============================================================================

-- Apply a template to the current tab
local function apply_template(window, pane, template_name)
	-- Load templates
	local tab_templates = require("modules.tabs.tab_templates")
	local templates = tab_templates.load_templates()

	local template = templates[template_name]
	if not template then
		wezterm.log_warn("[TAB_HOOKS] Template '" .. template_name .. "' not found")
		return false
	end

	wezterm.log_info("[TAB_HOOKS] Applying template: " .. template_name)

	-- Apply template to current tab
	if not wezterm.GLOBAL.custom_tabs then
		wezterm.GLOBAL.custom_tabs = {}
	end

	local tab = window:active_tab()
	if not tab then
		return false
	end

	local tab_id = tostring(tab:tab_id())
	wezterm.GLOBAL.custom_tabs[tab_id] = {
		title = template.title,
		icon_key = template.icon,
	}

	-- Apply tab color if saved
	if template.color then
		local tab_color_picker = require("modules.tabs.tab_color_picker")
		tab_color_picker.set_tab_color(tab_id, template.color)
	end

	-- Change to saved working directory if available and different from current
	if template.cwd and template.cwd ~= "" then
		local current_cwd = normalize_path(pane:get_current_working_dir())
		local template_cwd = normalize_path(template.cwd)

		if current_cwd ~= template_cwd then
			pane:send_text("cd " .. wezterm.shell_quote_arg(expand_home(template.cwd)) .. "\n")
			wezterm.log_info("[TAB_HOOKS] Changed directory to: " .. template.cwd)
		end
	end

	-- Handle TMUX sessions if template has one
	if template.tmux_session then
		local ok, tmux_sessions = pcall(require, "modules.tmux.sessions")
		if ok and tmux_sessions then
			wezterm.log_info("[TAB_HOOKS] Template has tmux session: " .. template.tmux_session)
			-- Note: We don't auto-attach to tmux here to avoid disrupting the user
			-- The template was applied for the visual properties (title, icon, color)
		end
	end

	return true
end

-- ============================================================================
-- HOOK DETECTION & APPLICATION
-- ============================================================================

-- Check if hook should be applied to pane
-- Returns: rule if should apply, nil otherwise
local function should_apply_hook(pane, current_cwd, config)
	if not config.enabled or not M.hooks_enabled then
		return nil
	end

	if not current_cwd then
		return nil
	end

	local pane_id = pane:pane_id()

	-- Check if we've already applied a hook to this pane at this location
	local applied = M.applied_hooks[pane_id]
	if applied and applied.cwd == current_cwd then
		-- Already applied hook for this directory
		return nil
	end

	-- Find matching rule
	local rule = find_matching_rule(current_cwd, config.rules)
	if not rule then
		-- No matching rule, but update state to avoid repeated checks
		if applied and applied.cwd ~= current_cwd then
			-- Directory changed but no rule matches - clear previous hook
			M.applied_hooks[pane_id] = nil
		end
		return nil
	end

	return rule
end

-- Main hook detection function - called by update-status event
function M.check_and_apply_hooks(window, pane)
	-- Get current working directory
	local raw_cwd = pane:get_current_working_dir()
	local current_cwd = normalize_path(raw_cwd)

	if not current_cwd then
		return
	end

	-- Load configuration
	local config = M.load_hooks()

	-- Check if hook should be applied
	local rule = should_apply_hook(pane, current_cwd, config)
	if not rule then
		return
	end

	-- Apply the template
	local success = apply_template(window, pane, rule.template)

	if success then
		-- Track that we applied this hook
		local pane_id = pane:pane_id()
		M.applied_hooks[pane_id] = {
			cwd = current_cwd,
			hook_name = rule.name or rule.pattern,
			template = rule.template,
			applied_at = os.time(),
		}

		-- Show notification if enabled
		if rule.notify ~= false then -- Default to true
			local msg = string.format(
				"Applied template '%s' for %s",
				rule.template,
				rule.description or rule.pattern
			)
			window:toast_notification("Tab Hook", msg, nil, 2000)
		end

		wezterm.log_info(
			"[TAB_HOOKS] Successfully applied hook: "
				.. (rule.name or rule.pattern)
				.. " -> "
				.. rule.template
		)
	end
end

-- Cleanup hook state when pane closes
function M.cleanup_pane(pane_id)
	if M.applied_hooks[pane_id] then
		wezterm.log_info("[TAB_HOOKS] Cleaning up hook state for pane " .. tostring(pane_id))
		M.applied_hooks[pane_id] = nil
	end
end

-- ============================================================================
-- USER INTERFACE: HOOK MANAGEMENT
-- ============================================================================

-- Add a new hook rule
function M.add_hook(window, pane)
	-- Step 1: Prompt for pattern
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = "Directory pattern (e.g., ~/projects/myapp or ~/projects/*):",
			action = wezterm.action_callback(function(win, p, pattern)
				if not pattern or pattern == "" then
					return
				end

				-- Step 2: Prompt for template name
				win:perform_action(
					wezterm.action.PromptInputLine({
						description = "Template name to apply:",
						action = wezterm.action_callback(function(win2, p2, template_name)
							if not template_name or template_name == "" then
								return
							end

							-- Verify template exists
							local tab_templates = require("modules.tabs.tab_templates")
							local templates = tab_templates.load_templates()
							if not templates[template_name] then
								win2:toast_notification(
									"Tab Hooks",
									"Template '" .. template_name .. "' not found",
									nil,
									3000
								)
								return
							end

							-- Step 3: Prompt for description
							win2:perform_action(
								wezterm.action.PromptInputLine({
									description = "Description (optional):",
									action = wezterm.action_callback(function(win3, p3, description)
										-- Load config and add rule
										local config = M.load_hooks()

										local new_rule = {
											name = "hook_" .. os.time(),
											pattern = pattern,
											template = template_name,
											description = description or "",
											enabled = true,
											notify = true,
											created_at = os.date("%Y-%m-%d %H:%M:%S"),
										}

										table.insert(config.rules, new_rule)

										if M.save_hooks(config) then
											win3:toast_notification(
												"Tab Hooks",
												"Added hook: " .. pattern .. " -> " .. template_name,
												nil,
												2000
											)
										else
											win3:toast_notification(
												"Tab Hooks",
												"Failed to save hook",
												nil,
												3000
											)
										end
									end),
								}),
								p2
							)
						end),
					}),
					p
				)
			end),
		}),
		pane
	)
end

-- List and manage hooks
function M.show_hooks_menu(window, pane)
	local config = M.load_hooks()

	local choices = {}

	-- Header
	table.insert(choices, {
		label = "Tab Hooks Configuration",
		id = "__header__",
	})
	table.insert(choices, {
		label = "─────────────────────────────",
		id = "__separator_top__",
	})

	-- Global toggle
	local global_status = config.enabled and "✓ Enabled" or "✗ Disabled"
	table.insert(choices, {
		label = "Global Status: " .. global_status .. " (toggle)",
		id = "__toggle_global__",
	})

	-- Add new hook
	table.insert(choices, {
		label = "➕ Add New Hook",
		id = "__add__",
	})

	-- Separator before rules
	if #config.rules > 0 then
		table.insert(choices, {
			label = "─────────────────────────────",
			id = "__separator_rules__",
		})
		table.insert(choices, {
			label = "Existing Hooks:",
			id = "__rules_header__",
		})
	end

	-- List existing rules
	for i, rule in ipairs(config.rules) do
		local status = rule.enabled ~= false and "✓" or "✗"
		local label = string.format(
			"%s %s -> %s (%s)",
			status,
			rule.pattern,
			rule.template,
			rule.description or "no description"
		)
		table.insert(choices, {
			label = label,
			id = "rule_" .. tostring(i),
		})
	end

	-- Show empty state if no rules
	if #config.rules == 0 then
		table.insert(choices, {
			label = "─────────────────────────────",
			id = "__separator_empty__",
		})
		table.insert(choices, {
			label = "No hooks configured yet",
			id = "__empty__",
		})
	end

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Tab Hooks Manager",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				if not id or id:sub(1, 2) == "__" then
					if id == "__toggle_global__" then
						-- Toggle global enabled status
						config.enabled = not config.enabled
						M.save_hooks(config)
						win:toast_notification(
							"Tab Hooks",
							"Hooks " .. (config.enabled and "enabled" or "disabled"),
							nil,
							2000
						)
						-- Refresh menu
						wezterm.time.call_after(0.5, function()
							M.show_hooks_menu(win, p)
						end)
					elseif id == "__add__" then
						M.add_hook(win, p)
					end
					return
				end

				-- Handle rule selection
				local rule_idx = tonumber(id:match("rule_(%d+)"))
				if rule_idx then
					M.show_rule_menu(win, p, rule_idx)
				end
			end),
		}),
		pane
	)
end

-- Show individual rule menu
function M.show_rule_menu(window, pane, rule_idx)
	local config = M.load_hooks()
	local rule = config.rules[rule_idx]

	if not rule then
		window:toast_notification("Tab Hooks", "Rule not found", nil, 2000)
		return
	end

	local choices = {
		{ label = "← Back to Hooks Menu", id = "back" },
		{ label = "─────────────────────────────", id = "__sep1__" },
		{ label = "Rule: " .. rule.pattern, id = "__info1__" },
		{ label = "Template: " .. rule.template, id = "__info2__" },
		{ label = "Description: " .. (rule.description or "none"), id = "__info3__" },
		{ label = "─────────────────────────────", id = "__sep2__" },
	}

	-- Toggle enable
	local toggle_label = rule.enabled ~= false and "✗ Disable this hook" or "✓ Enable this hook"
	table.insert(choices, { label = toggle_label, id = "toggle" })

	-- Toggle notifications
	local notify_label = rule.notify ~= false and "🔕 Disable notifications" or "🔔 Enable notifications"
	table.insert(choices, { label = notify_label, id = "toggle_notify" })

	-- Test hook
	table.insert(choices, { label = "🧪 Test this hook now", id = "test" })

	-- Delete
	table.insert(choices, { label = "🗑️  Delete this hook", id = "delete" })

	window:perform_action(
		wezterm.action.InputSelector({
			title = "Hook: " .. rule.pattern,
			choices = choices,
			fuzzy = false,
			action = wezterm.action_callback(function(win, p, id)
				if id == "back" then
					M.show_hooks_menu(win, p)
				elseif id == "toggle" then
					rule.enabled = not (rule.enabled ~= false)
					config.rules[rule_idx] = rule
					M.save_hooks(config)
					win:toast_notification(
						"Tab Hooks",
						"Hook " .. (rule.enabled and "enabled" or "disabled"),
						nil,
						2000
					)
					wezterm.time.call_after(0.5, function()
						M.show_rule_menu(win, p, rule_idx)
					end)
				elseif id == "toggle_notify" then
					rule.notify = not (rule.notify ~= false)
					config.rules[rule_idx] = rule
					M.save_hooks(config)
					win:toast_notification(
						"Tab Hooks",
						"Notifications " .. (rule.notify and "enabled" or "disabled"),
						nil,
						2000
					)
					wezterm.time.call_after(0.5, function()
						M.show_rule_menu(win, p, rule_idx)
					end)
				elseif id == "test" then
					-- Clear applied hooks state to force re-application
					local pane_id = p:pane_id()
					M.applied_hooks[pane_id] = nil
					-- Trigger immediate check
					M.check_and_apply_hooks(win, p)
					win:toast_notification("Tab Hooks", "Hook test triggered", nil, 2000)
				elseif id == "delete" then
					table.remove(config.rules, rule_idx)
					M.save_hooks(config)
					win:toast_notification("Tab Hooks", "Hook deleted", nil, 2000)
					wezterm.time.call_after(0.5, function()
						M.show_hooks_menu(win, p)
					end)
				end
			end),
		}),
		pane
	)
end

-- Quick add hook for current directory
function M.quick_add_current_directory(window, pane)
	-- Get current directory
	local raw_cwd = pane:get_current_working_dir()
	local current_cwd = normalize_path(raw_cwd)

	if not current_cwd then
		window:toast_notification("Tab Hooks", "Cannot determine current directory", nil, 2000)
		return
	end

	-- Prompt for template name
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = "Template to apply in " .. current_cwd .. ":",
			action = wezterm.action_callback(function(win, p, template_name)
				if not template_name or template_name == "" then
					return
				end

				-- Verify template exists
				local tab_templates = require("modules.tabs.tab_templates")
				local templates = tab_templates.load_templates()
				if not templates[template_name] then
					win:toast_notification(
						"Tab Hooks",
						"Template '" .. template_name .. "' not found",
						nil,
						3000
					)
					return
				end

				-- Add hook for current directory
				local config = M.load_hooks()

				local new_rule = {
					name = "hook_" .. os.time(),
					pattern = current_cwd,
					template = template_name,
					description = "Auto-created for " .. current_cwd,
					enabled = true,
					notify = true,
					created_at = os.date("%Y-%m-%d %H:%M:%S"),
				}

				table.insert(config.rules, new_rule)

				if M.save_hooks(config) then
					win:toast_notification(
						"Tab Hooks",
						"Added hook for current directory",
						nil,
						2000
					)
				else
					win:toast_notification("Tab Hooks", "Failed to save hook", nil, 3000)
				end
			end),
		}),
		pane
	)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Create default hooks configuration if it doesn't exist
function M.initialize()
	local file = io.open(M.hooks_file, "r")
	if file then
		file:close()
		wezterm.log_info("[TAB_HOOKS] Hooks configuration exists")
		return
	end

	-- Create default configuration with examples
	local default_config = {
		enabled = true,
		rules = {
			-- Example rules (disabled by default)
			-- {
			-- 	name = "example_project",
			-- 	pattern = "~/projects/myapp",
			-- 	template = "dev-environment",
			-- 	description = "Development environment for myapp",
			-- 	enabled = false,
			-- 	notify = true,
			-- },
		},
	}

	M.save_hooks(default_config)
	wezterm.log_info("[TAB_HOOKS] Created default hooks configuration")
end

return M
