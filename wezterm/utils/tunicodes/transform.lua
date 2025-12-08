local emoji_labels = (require("utils.tunicodes.emoji_labels")).Transform
local hexbytes = (require("utils.tunicodes.hexbytes")).Transform
local codepoints = (require("utils.tunicodes.codepoints")).Transform
local digraphs = (require("utils.tunicodes.vim_digraphs")).Transform
local class_names = (require("utils.tunicodes.class_names")).Transform

local enabled_transforms = {
  emoji_labels,
  hexbytes,
  codepoints,
  digraphs,
  class_names,
}

local function Fancify(s)
  local result = s
  --> WARNING: using foreign scope (feels unclean)
  for _, transform in ipairs(enabled_transforms) do
    result = transform(result)
  end
  return result
end

return {
  Fancify = Fancify,
}
