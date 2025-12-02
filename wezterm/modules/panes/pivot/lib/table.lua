local M = {}

--- Deep extend a table with one or more tables
--- Merges nested tables instead of replacing them
---@param behavior "error"|"keep"|"force" How to handle conflicts
---@param ... table Tables to merge
---@return table
function M.tbl_deep_extend(behavior, ...)
	local tables = { ... }
	local result = {}

	for _, tbl in ipairs(tables) do
		for k, v in pairs(tbl) do
			if type(v) == "table" and type(result[k]) == "table" then
				result[k] = M.tbl_deep_extend(behavior, result[k], v)
			else
				if result[k] ~= nil and behavior == "error" then
					error(string.format("Key '%s' already exists", k))
				elseif result[k] == nil or behavior == "force" then
					result[k] = v
				end
				-- If behavior is "keep", don't override existing values
			end
		end
	end

	return result
end

return M
