-- ~/.core/cfg/wezterm/config/init.lua
-- Modular configuration system for WezTerm

local wezterm = require("wezterm")
local debug_config = require("config.debug")

---@class Config
---@field options table
local Config = {}

---Initialize Config
---@return Config
function Config:init()
	local o = {}
	self = setmetatable(o, { __index = Config })
	self.options = {}
	return o
end

---Append to `Config.options`
---@param new_options table new options to append
---@return Config
-- function Config:append(new_options)
--   for k, v in pairs(new_options) do
--     if self.options[k] ~= nil then
--       wezterm.log_warn(
--         'Duplicate config option detected: ',
--         { old = self.options[k], new = new_options[k] }
--       )
--       goto continue
--     end
--     self.options[k] = v
--     ::continue::
--   end
--   return self
-- end
--
-- function Config:append(new_options)
-- 	for k, v in pairs(new_options) do
-- 		if self.options[k] ~= nil then
-- 			-- Log the duplicate, but do NOT skip the assignment.
-- 			wezterm.log_warn("Duplicate config option detected: ", { old = self.options[k], new = new_options[k] })
-- 		end
-- 		-- The new value (v) is assigned, overwriting the old one.
-- 		self.options[k] = v
-- 		-- Remove the ::continue:: label and the goto statement.
-- 	end
-- 	return self
-- end
--
-- return Config
--
-----Append to `Config.options`
---@param new_options table new options to append
---@param source_name string name of the module/file being appended (e.g., "colors")
---@return Config
function Config:append(new_options, source_name) -- ADD source_name HERE
	source_name = source_name or "Unknown Source" -- Use a default if not provided
	local DEBUG_DUPLICATES = debug_config.debug_config_duplicates or debug_config.debug_all

	for k, v in pairs(new_options) do
		if self.options[k] ~= nil then
			if DEBUG_DUPLICATES then
				wezterm.log_warn(
					"Duplicate config option detected from " .. source_name .. ": " .. k, -- Log the key (k) and source
					{
						old = self.options[k],
						new = v,
					}
				)
			end
			-- DANGER: Your previous logic was set to prevent overwrites using 'goto continue'.
			-- We will change this to allow overwrites, as is standard merge behavior.
			-- If you want to PREVENT overwrites, uncomment 'goto continue'.

			-- goto continue
		end
		self.options[k] = v
		-- ::continue::
	end
	return self
end

return Config

-- ---@class Config
-- ---@field options table
-- local Config = {}
-- Config.__index = Config
--
-- ---Initialize Config
-- ---@return Config
-- function Config:init()
-- 	local config = setmetatable({
-- 		options = wezterm.config_builder and wezterm.config_builder() or {},
-- 	}, self)
-- 	return config
-- end
--
-- ---Append to `Config.options`
-- ---@param new_options table new options to append
---@return Config
-- function Config:append(new_options)
-- 	for k, v in pairs(new_options) do
-- 		if self.options[k] ~= nil then
-- 			wezterm.log_warn("Duplicate config option detected: " .. k, { old = self.options[k], new = v })
-- 		end
-- 		self.options[k] = v
-- 	end
-- 	return self
-- end
--
-- ---Load module by name
-- ---@param module_name string
-- ---@return Config
-- function Config:load(module_name)
-- 	local ok, module = pcall(require, "config." .. module_name)
-- 	if ok then
-- 		self:append(module)
-- 	else
-- 		wezterm.log_error("Failed to load config module: " .. module_name)
-- 	end
-- 	return self
-- end
--
-- ---Build final config
-- ---@return table
-- function Config:build()
-- 	return self.options
-- end
--
-- return Config

-- ---@class Config
-- ---@field options table
-- local Config = {}
-- Config.__index = Config
--
-- ---Initialize Config
-- ---@return Config
-- function Config:init()
-- 	local config = setmetatable({
-- 		options = wezterm.config_builder and wezterm.config_builder() or {},
-- 	}, self)
-- 	return config
-- end
--
-- ---Append to `Config.options`
-- ---@param new_options table new options to append
-- ---@return Config
-- function Config:append(new_options)
-- 	for k, v in pairs(new_options) do
-- 		if self.options[k] ~= nil then
-- 			wezterm.log_warn("Duplicate config option detected: " .. k, { old = self.options[k], new = v })
-- 		end
-- 		self.options[k] = v
-- 	end
-- 	return self
-- end
--
-- ---Load module by name
-- ---@param module_name string
-- ---@return Config
-- function Config:load(module_name)
-- 	local ok, module = pcall(require, "config." .. module_name)
-- 	if ok then
-- 		self:append(module)
-- 	else
-- 		wezterm.log_error("Failed to load config module: " .. module_name)
-- 	end
-- 	return self
-- end
--
-- ---Build final config
-- ---@return table
-- function Config:build()
-- 	return self.options
-- end
--
-- return Config
