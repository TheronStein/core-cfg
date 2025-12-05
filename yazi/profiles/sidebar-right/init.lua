-- RIGHT SIDEBAR PREVIEW PANE - Minimal Init
--
-- This profile uses a minimal plugin set for performance optimization.
-- The preview pane doesn't need navigation plugins, file operation tools,
-- or custom previewers - it only needs basic UI and status display.
--
-- The global init.lua loads 60+ plugins which would slow down the preview pane.
-- This minimal set provides the essential UI while keeping the pane responsive.

-- UI Enhancement: Border styling
require("full-border"):setup({
	style = "heavy-double",
})

-- Status Line: Show current state and info
require("yatline")
require("simple-status")

-- That's it! Yazi's built-in preview system handles everything else.
-- This pane receives `reveal` commands via DDS from the left navigator pane.
