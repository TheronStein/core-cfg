local M = {}

---@class Logger
---@field prefix string
---@field debug_enabled boolean
local Logger = {}
Logger.__index = Logger

---@param config {prefix: string, debug_enabled: boolean}
---@return Logger
function M.new(config)
	local self = setmetatable({}, Logger)
	self.prefix = config.prefix or ""
	self.debug_enabled = config.debug_enabled or false
	return self
end

function Logger:log(level, ...)
	local args = { ... }
	local parts = {}
	for _, v in ipairs(args) do
		table.insert(parts, tostring(v))
	end
	local message = table.concat(parts, " ")
	print(string.format("%s [%s] %s", self.prefix, level, message))
end

function Logger:debug(...)
	if self.debug_enabled then
		self:log("DEBUG", ...)
	end
end

function Logger:info(...)
	self:log("INFO", ...)
end

function Logger:warn(...)
	self:log("WARN", ...)
end

function Logger:error(...)
	self:log("ERROR", ...)
end

return M
