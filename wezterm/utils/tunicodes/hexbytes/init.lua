function Transform (s)
	local result = s
		--> hex bytes
		:gsub("\\x{(%x+)}", function (seqs)
			if #seqs % 2 ~= 0 then return "\\d{".. seqs .."}" end
			local result = {}
			for i = 1, #seqs, 2 do
				local pair = seqs:sub(i, i+1)
				local chr = tonumber(pair, 16)
				result[#result + 1] = chr and string.char(chr) or ""
			end
			return table.concat(result)
		end)
		--> hex byte
		:gsub("\\x(%x%x)", function (hex)
			local byte = tonumber(hex, 16)
			if byte then return string.char(byte)
			else return "\\x" .. hex end
		end)
	return result
end

return {
	Transform = Transform,
}
