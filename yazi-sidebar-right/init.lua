-- Minimal init for right preview sidebar
-- Loads only essential plugins, no custom previewers

-- Load full-border for UI
require("full-border"):setup({
	style = "heavy-double",
})

-- Status line
require("yatline")
require("simple-status")

-- That's it - use yazi's built-in preview system
-- No custom directory previewers
