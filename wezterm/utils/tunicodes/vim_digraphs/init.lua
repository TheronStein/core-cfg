local Digraphs = (require("util.tunicodes.vim_digraphs.digraphs")).Digraphs

local function Transform(s)
  local result = (
    s
      --> vim digraphs
      :gsub("\\d{([^{}][^{}]+)}", function(seqs)
        --> TODO: Make digraph function more flexible (allow optional spaces / commas)
        if #seqs % 2 ~= 0 then
          return "\\d{" .. seqs .. "}"
        end
        local results = {}
        for i = 1, #seqs, 2 do
          local pair = seqs:sub(i, i + 1)
          local chr = Digraphs[pair]
          table.insert(results, chr and utf8.char(chr) or "")
        end
        return table.concat(results)
      end)
      --> vim digraph
      :gsub("\\d([^{}][^{}])", function(seq)
        local chr = Digraphs[seq]
        return chr and utf8.char(chr) or ""
      end)
  )
  return result
end

return {
  Transform = Transform,
}
