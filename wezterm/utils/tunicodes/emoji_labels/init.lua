local Mappings = (require("utils.tunicodes.emoji_labels.emoji_map")).Mappings

local function Transform(s)
  local result = (
    s
      --> emoji labels
      :gsub("%:([%w%_%-]+)%:", function(seq)
        return Mappings[seq] or (":" .. seq .. ":")
      end)
  )
  return result
end

return {
  Transform = Transform,
}
