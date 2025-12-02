local Mappings = (require 'plugins/tunicodes/transformers/available/class_names/mappings').Mappings

local prefix = "\\C"

local function Transform (s)
	local result = (s
		--> Class names
		:gsub(prefix .. "{([%w%_%-% %,]+)}", function (codestr)
			local newstr = ""
			local success = true
			for match in codestr:gmatch("([%w%_%-]+)") do
				local code = Mappings[match:lower()]
				if code then
					newstr = newstr .. utf8.char(code)
				else
					success = false
				end
			end
			if success then
				return newstr
			else
				return prefix .. "{" .. codestr .. "}"
			end
		end)
	)
	return result
end

return {
	Transform = Transform,
}
