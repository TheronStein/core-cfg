-- Generate keymap data for the keymap browser
-- This script extracts keybindings from active keymaps and organizes them by modifier

local wezterm = require("wezterm")

-- This expects to be run with config already loaded
-- Access global config via _G if it exists
local config = _G.config or {
	keys = {},
	key_tables = {},
	leader = { key = "Space", mods = "SUPER", timeout_milliseconds = 1000 },
}

-- Helper to normalize modifier names
local function normalize_mods(mods)
	if not mods or mods == "" or mods == "NONE" then
		return "NONE"
	end
	return mods
end

-- Helper to get action description
local function get_action_description(action)
	if type(action) == "string" then
		-- Handle string actions
		if action == "ActivateCopyMode" then
			return "Enter copy mode (vim-like text selection)"
		elseif action == "PopKeyTable" then
			return "Exit current key table/mode"
		else
			return action
		end
	elseif type(action) == "table" then
		-- Handle wezterm.action types
		if action.CopyTo then
			return "Copy to " .. action.CopyTo
		elseif action.PasteFrom then
			return "Paste from " .. action.PasteFrom
		elseif action.ActivatePaneDirection then
			return "Activate pane " .. action.ActivatePaneDirection
		elseif action.ActivateTabRelative then
			return "Activate tab " .. (action.ActivateTabRelative > 0 and "next" or "previous")
		elseif action.MoveTabRelative then
			return "Move tab " .. (action.MoveTabRelative > 0 and "right" or "left")
		elseif action.ScrollByPage then
			return "Scroll " .. (action.ScrollByPage > 0 and "down" or "up") .. " by page"
		elseif action.SplitVertical then
			return "Split pane vertically (right)"
		elseif action.SplitHorizontal then
			return "Split pane horizontally (down)"
		elseif action.SplitPane then
			local dir = action.SplitPane.direction or "Unknown"
			local cmd = action.SplitPane.command
			if cmd and cmd.args and cmd.args[1] then
				local app = cmd.args[1]:match("([^/]+)$") or cmd.args[1]
				return "Split pane " .. dir .. " with " .. app
			end
			return "Split pane " .. dir
		elseif action.CloseCurrentPane then
			return "Close current pane"
		elseif action.SpawnTab then
			return "New tab in current domain"
		elseif action.SpawnCommandInNewTab then
			local args = action.SpawnCommandInNewTab.args or {}
			local cmd = args[1] or "command"
			-- Extract just the script name
			local script_name = cmd:match("([^/]+)$") or cmd
			return "Launch: " .. script_name
		elseif action.SendKey then
			local key = action.SendKey.key or "?"
			local mods = action.SendKey.mods or ""
			return "Send literal: " .. (mods ~= "" and mods .. "+" or "") .. key
		elseif action.SendString then
			local str = action.SendString or ""
			if str == "\n" then
				return "Send newline"
			else
				return "Send string: " .. (str:sub(1, 20) .. (str:len() > 20 and "..." or ""))
			end
		elseif action.ActivateKeyTable then
			local mode_name = action.ActivateKeyTable.name or "unknown"
			return "Enter " .. mode_name:gsub("_", " ") .. " mode"
		elseif action.AdjustPaneSize then
			local dir = action.AdjustPaneSize[1] or "Unknown"
			local amount = action.AdjustPaneSize[2] or 1
			return "Resize pane " .. dir .. " by " .. amount
		elseif action.RotatePanes then
			return "Rotate panes " .. action.RotatePanes
		elseif action.TogglePaneZoomState then
			return "Toggle pane zoom (maximize/restore)"
		elseif action.DisableDefaultAssignment then
			return "Disabled/Unbound"
		elseif action.EmitEvent then
			local event_name = action.EmitEvent or "unknown"
			return "Emit event: " .. event_name
		elseif action.InputSelector then
			local title = action.InputSelector.title or "selector"
			return "Show selector: " .. title
		else
			-- Try to get the first key
			for k, v in pairs(action) do
				if type(k) == "string" and k ~= "action" then
					return k
				end
			end
			return "Custom action"
		end
	elseif action == wezterm.action.ShowDebugOverlay then
		return "Show debug overlay"
	elseif action == wezterm.action.PaneSelect then
		return "Visual pane selector"
	elseif action == wezterm.action.ReloadConfiguration then
		return "Reload WezTerm configuration"
	end

	return "Unknown action"
end

-- Helper to format key display
local function format_key_display(key, mods)
	local mod_str = normalize_mods(mods)
	if mod_str == "NONE" then
		return key
	else
		return "<" .. mod_str:lower():gsub("|", "+") .. ">" .. key
	end
end

-- Categorize keybindings by modifier
local categories = {
	["NONE"] = { name = "Direct Keys", description = "Keys without modifiers", icon = "", keybinds = {} },
	["SHIFT"] = { name = "Shift Keys", description = "Shift + Key combinations", icon = "⇧", keybinds = {} },
	["CTRL"] = { name = "Control Keys", description = "Ctrl + Key combinations", icon = "", keybinds = {} },
	["CTRL|SHIFT"] = {
		name = "Ctrl+Shift Keys",
		description = "Ctrl + Shift + Key combinations",
		icon = "",
		keybinds = {},
	},
	["SUPER"] = { name = "Super Keys", description = "Super/Win + Key combinations", icon = "", keybinds = {} },
	["SUPER|SHIFT"] = {
		name = "Super+Shift Keys",
		description = "Super + Shift + Key combinations",
		icon = "",
		keybinds = {},
	},
	["SUPER|CTRL"] = {
		name = "Super+Ctrl Keys",
		description = "Super + Ctrl + Key combinations",
		icon = "",
		keybinds = {},
	},
	["SUPER|ALT"] = {
		name = "Super+Alt Keys",
		description = "Super + Alt + Key combinations",
		icon = "",
		keybinds = {},
	},
	["LEADER"] = { name = "Leader Keys", description = "Leader + Key combinations", icon = "", keybinds = {} },
	["LEADER|CTRL"] = {
		name = "Leader+Ctrl Keys",
		description = "Leader + Ctrl + Key combinations",
		icon = "",
		keybinds = {},
	},
	["LEADER|SHIFT"] = {
		name = "Leader+Shift Keys",
		description = "Leader + Shift + Key combinations",
		icon = "",
		keybinds = {},
	},
	["LEADER|ALT"] = {
		name = "Leader+Alt Keys",
		description = "Leader + Alt + Key combinations",
		icon = "",
		keybinds = {},
	},
}

-- Process regular keys from config
if config.keys then
	for _, keybind in ipairs(config.keys) do
		local key = keybind.key
		local mods = normalize_mods(keybind.mods)
		local action = keybind.action
		-- Use desc field if available, otherwise get action description
		local description = keybind.desc or get_action_description(action)

		-- Initialize category if it doesn't exist
		if not categories[mods] then
			categories[mods] = {
				name = mods .. " Keys",
				description = mods .. " + Key combinations",
				icon = "⌨",
				keybinds = {},
			}
		end

		table.insert(categories[mods].keybinds, {
			key = key,
			mods = mods,
			display = format_key_display(key, mods),
			description = description,
		})
	end
end

-- Process key tables from config
if config.key_tables then
	for table_name, table_keys in pairs(config.key_tables) do
		-- Skip leader_mode as it's redundant with LEADER modifier keys
		if table_name ~= "leader_mode" then
			-- Create category for this key table
			local category_key = "KEYTABLE_" .. table_name
			categories[category_key] = {
				name = table_name:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
					return first:upper() .. rest:lower()
				end),
				description = "Key table for " .. table_name .. " mode",
				icon = "⚡",
				is_key_table = true,
				keybinds = {},
			}

			for _, keybind in ipairs(table_keys) do
				local key = keybind.key
				local mods = normalize_mods(keybind.mods)
				local action = keybind.action
				local description = get_action_description(action)

				table.insert(categories[category_key].keybinds, {
					key = key,
					mods = mods,
					display = format_key_display(key, mods),
					description = description,
				})
			end
		end
	end
end

-- Add WezTerm default keybindings as reference categories
local wezterm_defaults = {
	{
		id = "DEFAULT_COPY_MODE",
		name = "Copy Mode (Default)",
		description = "Built-in WezTerm copy mode keybindings",
		icon = "📋",
		is_key_table = true,
		is_default = true,
		keybinds = {
			{ key = "Tab", mods = "NONE", display = "Tab", description = "Move to next placeholder" },
			{ key = "Enter", mods = "NONE", display = "Enter", description = "Copy selection and exit" },
			{ key = "Escape", mods = "NONE", display = "Escape", description = "Exit copy mode" },
			{ key = "q", mods = "NONE", display = "q", description = "Exit copy mode" },
			{ key = "h", mods = "NONE", display = "h", description = "Move left" },
			{ key = "j", mods = "NONE", display = "j", description = "Move down" },
			{ key = "k", mods = "NONE", display = "k", description = "Move up" },
			{ key = "l", mods = "NONE", display = "l", description = "Move right" },
			{ key = "w", mods = "NONE", display = "w", description = "Move forward one word" },
			{ key = "b", mods = "NONE", display = "b", description = "Move backward one word" },
			{ key = "0", mods = "NONE", display = "0", description = "Move to start of line" },
			{ key = "$", mods = "SHIFT", display = "<shift>$", description = "Move to end of line" },
			{ key = "v", mods = "NONE", display = "v", description = "Toggle character selection" },
			{ key = "V", mods = "SHIFT", display = "<shift>V", description = "Toggle line selection" },
			{ key = "G", mods = "SHIFT", display = "<shift>G", description = "Go to end" },
			{ key = "g", mods = "NONE", display = "g", description = "Go to start (press twice)" },
			{ key = "o", mods = "NONE", display = "o", description = "Toggle selection endpoint" },
			{ key = "y", mods = "NONE", display = "y", description = "Copy selection" },
			{ key = "/", mods = "NONE", display = "/", description = "Search forward" },
			{ key = "?", mods = "SHIFT", display = "<shift>?", description = "Search backward" },
			{ key = "n", mods = "NONE", display = "n", description = "Next search match" },
			{ key = "N", mods = "SHIFT", display = "<shift>N", description = "Previous search match" },
		},
	},
	{
		id = "DEFAULT_SEARCH_MODE",
		name = "Search Mode (Default)",
		description = "Built-in WezTerm search mode keybindings",
		icon = "🔍",
		is_key_table = true,
		is_default = true,
		keybinds = {
			{ key = "Enter", mods = "NONE", display = "Enter", description = "Accept search and exit" },
			{ key = "Escape", mods = "NONE", display = "Escape", description = "Cancel search" },
			{ key = "n", mods = "CTRL", display = "<ctrl>n", description = "Next match" },
			{ key = "p", mods = "CTRL", display = "<ctrl>p", description = "Previous match" },
			{ key = "r", mods = "CTRL", display = "<ctrl>r", description = "Toggle regex" },
			{ key = "u", mods = "CTRL", display = "<ctrl>u", description = "Clear search" },
		},
	},
}

-- Build JSON output
local output = {
	leader_key = {
		key = config.leader and config.leader.key or "Space",
		mods = config.leader and config.leader.mods or "SUPER",
		timeout = config.leader and config.leader.timeout_milliseconds or 1000,
	},
	categories = {},
}

-- Convert categories to array and count
for mod, cat in pairs(categories) do
	if #cat.keybinds > 0 then
		table.insert(output.categories, {
			id = mod,
			name = cat.name,
			description = cat.description,
			icon = cat.icon,
			count = #cat.keybinds,
			is_key_table = cat.is_key_table or false,
			keybinds = cat.keybinds,
		})
	end
end

-- Add default WezTerm keybindings at the end
for _, default_cat in ipairs(wezterm_defaults) do
	table.insert(output.categories, default_cat)
end

-- Sort categories
table.sort(output.categories, function(a, b)
	-- Default WezTerm categories last
	if a.is_default and not b.is_default then
		return false
	end
	if b.is_default and not a.is_default then
		return true
	end
	-- Leader keys first
	if a.id:match("^LEADER") and not b.id:match("^LEADER") then
		return true
	end
	if b.id:match("^LEADER") and not a.id:match("^LEADER") then
		return false
	end
	-- Key tables before defaults but after modifiers
	if a.is_key_table and not b.is_key_table and not a.is_default then
		return false
	end
	if b.is_key_table and not a.is_key_table and not b.is_default then
		return true
	end
	-- Otherwise alphabetically
	return a.id < b.id
end)

-- Output JSON
print(wezterm.json_encode(output, { pretty = true, escape_newlines = true }))
return {}
