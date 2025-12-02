local emoji_labels = (require 'plugins/tunicodes/transformers/available/emoji_labels').Transform
local hexbytes = (require 'plugins/tunicodes/transformers/available/hexbytes').Transform
local codepoints = (require 'plugins/tunicodes/transformers/available/codepoints').Transform
local digraphs = (require 'plugins/tunicodes/transformers/available/vim_digraphs').Transform
local class_names = (require 'plugins/tunicodes/transformers/available/class_names').Transform

local enabled_transforms = {
	emoji_labels,
	hexbytes,
	codepoints,
	digraphs,
	class_names,
}

local function Fancify (s)
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
