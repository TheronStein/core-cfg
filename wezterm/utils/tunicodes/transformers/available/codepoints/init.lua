local function __split (s)
	local result = {}
	for _, match in s:gmatch("([^% %,])") do
		table.insert(result, match)
	end
	return result
end

local function __map (l, f)
	local result = {}
	for i, item in ipairs(l) do
		table.insert(result, f(item, i))
	end
	return result
end

local function Transform (s)
	local result = (s
		--> UTF-8 codepoints
		:gsub("\\u{([%x% %,]+)}", function (codestr)
			local newstr = ""
			local success = true
			for match in codestr:gmatch("([%x]+)") do
				local code = tonumber(match, 16)
				if code then
					newstr = newstr .. utf8.char(code)
				else
					success = false
				end
			end
			if success then
				return newstr
			else
				return "\\u{" .. codestr .. "}"
			end
			--local code = tonumber(codestr, 16)
			--if code then
			--	return utf8.char(code)
			--else
			--	return "\\u{" .. codestr .. "}"
			--end
		end)
	)
	return result
end

return {
	Transform = Transform,
}
