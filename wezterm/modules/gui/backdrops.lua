local wezterm = require("wezterm")
local colors = require("themes.custom")

-- Load debug configuration
local debug_config = require("config.debug")
local DEBUG = debug_config.debug_mods_backdrops or debug_config.debug_all
local DEBUG_METADATA = debug_config.debug_mods_image_metadata or DEBUG

math.randomseed(os.time())
math.random()
math.random()
math.random()

local GLOB_PATTERN = "*.{jpg,jpeg,png,gif,bmp,ico,tiff,pnm,dds,tga,avif}"

-- Forward declare functions to avoid ordering issues
local load_metadata
local write_imagedata

-- Load metadata from JSON
load_metadata = function(skip_generation)
	if DEBUG_METADATA then
		wezterm.log_info("Loading Image Data Function Init...")
	end
	local metadata_file = os.getenv("HOME") .. "/.core/cfg/wezterm/.data/backgrounds.json"
	local success, stdout = pcall(function()
		local handle = io.popen("cat " .. metadata_file .. " 2>/dev/null")
		if not handle then
			if DEBUG_METADATA then
				wezterm.log_info("Not Handle receieved...")
			end
			return "{}"
		end
		local result = handle:read("*a")
		handle:close()
		if DEBUG_METADATA then
			wezterm.log_info("result is ..." .. result)
		end
		return result
	end)

	if success and stdout and stdout ~= "" then
		if DEBUG_METADATA then
			wezterm.log_info("stdout result is ..." .. stdout)
		end
		return stdout
	end
	if DEBUG_METADATA then
		wezterm.log_info("Return nil..")
	end
	if not skip_generation then
		return write_imagedata()
	end
	return "{}"
end

-- Run metadata generation in background ONLY if file doesn't exist or is old
write_imagedata = function()
	if DEBUG_METADATA then
		wezterm.log_info("Writing Image Data Function Init...")
	end
	local metadata_file = os.getenv("HOME") .. "/.core/cfg/wezterm/.data/backgrounds.json"
	local should_regenerate = false
	-- Check if metadata exists and is recent (less than 1 hour old)
	local handle = io.open(metadata_file, "r")
	if handle then
		handle:close()
		-- Check file age
		local stat = io.popen("stat -c %Y " .. metadata_file .. " 2>/dev/null"):read("*a")
		local file_time = tonumber(stat)
		local current_time = os.time()

		-- Regenerate if older than 1 hour
		if not file_time or (current_time - file_time) > 3600 then
			should_regenerate = true
		end
	else
		should_regenerate = true
	end

	if should_regenerate then
		if DEBUG_METADATA then
			wezterm.log_info("Generating image metadata...")
		end
		os.execute(os.getenv("HOME") .. "/.core/cfg/wezterm/scripts/generate-image-metadata.sh &")
	end
	-- Pass true to skip generation to avoid infinite recursion
	return load_metadata(true)
end

local metadata_json = load_metadata()

-- -- Get image dimensions from metadata
local function get_image_dimensions(image_path)
  if not metadata_json then
      return 1920, 1080
  end

	local pattern = '"'
		.. image_path:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")
		.. '":%s*{%s*"width":%s*(%d+),%s*"height":%s*(%d+)'
	local width, height = metadata_json:match(pattern)

	if width and height then
		return tonumber(width), tonumber(height)
	end

	return 1920, 1080
end

local function calculate_aspect_ratio(width, height)
	return width / height
end

-- BackDrops class
local BackDrops = {}
BackDrops.__index = BackDrops

function BackDrops:init()
	local initial = {
		current_idx = 1,
		images = {},
		images_dir = wezterm.config_dir .. "/backdrops/",
		focus_color = colors.background,
		focus_on = false,
		-- NEW: Option to enable scroll attachment for tall portrait images
		enable_scroll_attachment = false,
		-- NEW: Track if backgrounds are enabled
		backgrounds_enabled = true,
		-- NEW: Track if auto-refresh is running
		refresh_timer_active = false,
		-- NEW: Configurable overlay opacity (default 0.85)
		overlay_opacity = 0.85,
	}
	return setmetatable(initial, self)
end

function BackDrops:set_images_dir(path)
	self.images_dir = path
	if not path:match("/$") then
		self.images_dir = path .. "/"
	end
	return self
end

function BackDrops:set_images()
	self.images = wezterm.glob(self.images_dir .. GLOB_PATTERN)
	return self
end

function BackDrops:set_focus(focus_color)
	self.focus_color = focus_color
	return self
end

-- NEW: Enable scrolling attachment for tall images
function BackDrops:set_scroll_attachment(enabled)
	self.enable_scroll_attachment = enabled
	return self
end

-- Function to reload metadata and images
function BackDrops:reload_metadata()
	if DEBUG then
		wezterm.log_info("Reloading backdrop metadata and images...")
	end
	metadata_json = load_metadata()
	self:set_images()
	-- Reset to first image after reload
	self.current_idx = 1
	return self
end

-- Helper function to get a hash identifier for a directory
local function get_dir_hash(dir)
	local handle = io.popen("echo '" .. dir .. "' | sha256sum | cut -c1-8")
	if handle then
		local hash = handle:read("*a"):gsub("%s+", "")
		handle:close()
		return hash
	end
	return "default"
end

-- Helper function to backup metadata with directory hash
local function backup_metadata(current_link)
	local metadata_file = os.getenv("HOME") .. "/.core/cfg/wezterm/.data/backgrounds.json"
	local metadata_backup_dir = os.getenv("HOME") .. "/.core/cfg/wezterm/.data/metadata-backups"

	-- Create backup directory if it doesn't exist
	os.execute("mkdir -p " .. metadata_backup_dir)

	local handle = io.open(metadata_file, "r")
	if handle then
		handle:close()
		local hash = get_dir_hash(current_link)
		local backup_file = metadata_backup_dir .. "/backgrounds-" .. hash .. ".json"
		os.execute("cp " .. metadata_file .. " " .. backup_file)
		if DEBUG_METADATA then
			wezterm.log_info("Backed up metadata to: " .. backup_file)
		end
	end
end

-- Helper function to restore metadata if available
local function restore_metadata(new_dir)
	local metadata_file = os.getenv("HOME") .. "/.core/cfg/wezterm/.data/backgrounds.json"
	local metadata_backup_dir = os.getenv("HOME") .. "/.core/cfg/wezterm/.data/metadata-backups"
	local hash = get_dir_hash(new_dir)
	local backup_file = metadata_backup_dir .. "/backgrounds-" .. hash .. ".json"

	local handle = io.open(backup_file, "r")
	if handle then
		handle:close()
		os.execute("cp " .. backup_file .. " " .. metadata_file)
		if DEBUG_METADATA then
			wezterm.log_info("Restored metadata from: " .. backup_file)
		end
		return true
	else
		if DEBUG_METADATA then
			wezterm.log_info("No previous metadata found for this directory")
		end
		return false
	end
end

-- Function to rotate between backdrop directories
function BackDrops:rotate_cycles(window)
	local home = os.getenv("HOME")
	local wallpapers_dir = home .. "/Pictures/wallpapers"
	local backdrops_dir = home .. "/.core/cfg/wezterm/backdrops"
	local wezterm_backdrops = home .. "/.core/cfg/wezterm/backdrops"
	local state_file = home .. "/.core/cfg/wezterm/.data/.backdrop_state"

	-- Read current state (0 = backdrops, 1 = wallpapers)
	local state = 0
	local handle = io.open(state_file, "r")
	if handle then
		state = tonumber(handle:read("*a")) or 0
		handle:close()
	end

	-- Get current symlink target
	local current_link_handle = io.popen("readlink " .. wezterm_backdrops .. " 2>/dev/null")
	local current_link = ""
	if current_link_handle then
		current_link = current_link_handle:read("*a"):gsub("%s+", "")
		current_link_handle:close()
	end

	-- Backup current metadata before switching
	if current_link ~= "" then
		if DEBUG_METADATA then
			backup_metadata(current_link)
		end
	end

	-- Determine new backdrop directory
	local new_dir
	if state == 0 then
		new_dir = wallpapers_dir
		state = 1
	else
		new_dir = backdrops_dir
		state = 0
	end

	if DEBUG then
		wezterm.log_info("Switching backdrops to: " .. new_dir)
	end

	-- Remove old symlink and create new one
	os.execute("rm -rf " .. wezterm_backdrops)
	os.execute("ln -sf " .. new_dir .. " " .. wezterm_backdrops)

	-- Save new state
	local state_handle = io.open(state_file, "w")
	if state_handle then
		state_handle:write(tostring(state))
		state_handle:close()
	end

	-- Try to restore metadata for the new directory
	if not restore_metadata(new_dir) then
		-- If no backup exists, clear current metadata and regenerate
		if DEBUG_METADATA then
			wezterm.log_info("Generating fresh metadata for new backdrop directory...")
		end
		local metadata_file = home .. "/.core/cfg/wezterm/.data/backgrounds.json"
		os.execute("> " .. metadata_file) -- Clear the file
		os.execute(home .. "/.core/cfg/wezterm/scripts/generate-image-metadata.sh")
	end

	-- Reload metadata and refresh images
	self:reload_metadata()

	-- Force a refresh of the current backdrop
	if window then
		self:_set_opt(window, self:_create_opts(window))
	end

	-- Trigger config reload for all windows
	wezterm.reload_configuration()

	if DEBUG then
		wezterm.log_info("Backdrop rotation complete!")
	end
	return self
end

-- Create backdrop options with aspect-ratio-preserving logic
function BackDrops:_create_opts(window)
	if not window then
		if DEBUG then
			wezterm.log_error("BackDrops:_create_opts called with nil window")
		end
		return {}
	end

	local window_dims = window:get_dimensions()
	local window_width = window_dims.pixel_width
	local window_height = window_dims.pixel_height
	local window_aspect = window_width / window_height

	local img_width, img_height = get_image_dimensions(self.images[self.current_idx])
	local img_aspect = calculate_aspect_ratio(img_width, img_height)

	-- Calculate aspect difference
	local aspect_diff = math.abs(window_aspect - img_aspect)

	-- Determine orientations
	local window_is_landscape = window_aspect >= 1.0
	local img_is_landscape = img_aspect >= 1.0
	local same_orientation = window_is_landscape == img_is_landscape

	local width_mode, height_mode
	local attachment = "Fixed"

	-- PHILOSOPHY: Always preserve aspect ratio. Use Cover as default.
	-- Only use Contain when the image is genuinely too small/low-res.
	-- Never mix modes that would squish the image.

	-- Case 1: Similar aspect ratios (within 15%) - perfect match
	if aspect_diff < 0.15 then
		width_mode = "Cover"
		height_mode = "Cover"

	-- Case 2: Portrait image in landscape window
	elseif window_is_landscape and not img_is_landscape then
		-- For portrait images in landscape windows, we need to be smart
		-- The image width will always be < window width, so check resolution quality

		-- Calculate what scale factor would be needed to fill width
		local width_scale = window_width / img_width
		-- Calculate resulting height after width scaling
		local scaled_height = img_height * width_scale

		if scaled_height >= window_height then
			-- Image is tall enough that when width-scaled, it fills or exceeds height
			-- This is ideal - use Cover and it will fill perfectly with cropping
			width_mode = "Cover"
			height_mode = "Cover"

			-- OPTIONAL: Enable scrolling attachment for very tall images
			if self.enable_scroll_attachment and scaled_height > window_height * 2 then
				attachment = { Parallax = 0.3 }
			end
		else
			-- Image is too short - when scaled to fill width, it won't fill height
			-- Check if image has high enough resolution to scale up
			if img_width >= 1440 and img_height >= 1800 then
				-- High-res image - safe to use Cover even with upscaling
				width_mode = "Cover"
				height_mode = "Cover"
			else
				-- Lower-res image - use Contain to avoid pixelation
				width_mode = "Contain"
				height_mode = "Contain"
			end
		end

	-- Case 3: Landscape image in portrait window (rare for typical desktop use)
	elseif not window_is_landscape and img_is_landscape then
		-- Calculate what scale factor would be needed to fill height
		local height_scale = window_height / img_height
		local scaled_width = img_width * height_scale

		if scaled_width >= window_width then
			-- Image is wide enough - use Cover
			width_mode = "Cover"
			height_mode = "Cover"
		else
			-- Check resolution
			if img_width >= 1920 and img_height >= 1080 then
				width_mode = "Cover"
				height_mode = "Cover"
			else
				width_mode = "Contain"
				height_mode = "Contain"
			end
		end

	-- Case 4: Same orientation but different aspect ratios
	elseif same_orientation then
		-- Both landscape or both portrait

		if aspect_diff < 0.3 then
			-- Moderate difference - Cover works well
			width_mode = "Cover"
			height_mode = "Cover"

			-- Enable scroll for very tall portrait images
			if not img_is_landscape and self.enable_scroll_attachment then
				local height_ratio = img_height / window_height
				if height_ratio > 1.5 then
					attachment = { Parallax = 0.3 }
				end
			end
		else
			-- Significant difference (>30%)
			-- Still use Cover to preserve ratio, accepting that more will be cropped

			-- Only fall back to Contain if image is genuinely low-resolution
			local min_dimension = math.min(img_width, img_height)
			local target_dimension = math.min(window_width, window_height)

			if min_dimension < target_dimension * 0.6 then
				-- Image is quite small relative to window
				width_mode = "Contain"
				height_mode = "Contain"
			else
				-- Image has decent resolution - use Cover and accept cropping
				width_mode = "Cover"
				height_mode = "Cover"

				-- For very tall portraits, enable scrolling
				if not img_is_landscape and self.enable_scroll_attachment then
					if img_height > window_height * 1.5 then
						attachment = { Parallax = 0.3 }
					end
				end
			end
		end

	-- Case 5: Fallback - preserve aspect ratio with Cover
	else
		width_mode = "Cover"
		height_mode = "Cover"
	end

	-- Build background layers
	local overlay_mode_picker = require("modules.gui.overlay-mode-picker")
	local overlay_config = overlay_mode_picker.get_overlay_config(colors.background)

	local background_layers = {
		{
			source = { File = self.images[self.current_idx] },
			horizontal_align = "Center",
			vertical_align = "Middle",
			width = width_mode,
			height = height_mode,
			attachment = attachment,
		},
		overlay_config,
	}

	return background_layers
end

function BackDrops:_create_focus_opts()
	return {
		{
			source = { Color = self.focus_color },
			height = "120%",
			width = "120%",
			vertical_offset = "-10%",
			horizontal_offset = "-10%",
			opacity = 1,
		},
	}
end

function BackDrops:initial_options(focus_on)
	focus_on = focus_on or false
	assert(type(focus_on) == "boolean", "BackDrops:initial_options - Expected a boolean")
	self.focus_on = focus_on

	if focus_on then
		return self:_create_focus_opts()
	end

	-- Return initial backdrop configuration instead of empty array
	-- This requires a dummy window object, so we'll use sensible defaults
	if #self.images > 0 then
		local overlay_mode_picker = require("modules.gui.overlay-mode-picker")
		local overlay_config = overlay_mode_picker.get_overlay_config(colors.background)

		return {
			{
				source = { File = self.images[self.current_idx] },
				horizontal_align = "Center",
				vertical_align = "Middle",
				width = "Cover",
				height = "Cover",
				attachment = "Fixed",
			},
			overlay_config,
		}
	end

	return {}
end

function BackDrops:_set_opt(window, background_opts)
	window:set_config_overrides({
		background = background_opts,
		enable_tab_bar = window:effective_config().enable_tab_bar,
	})
end

function BackDrops:choices()
	local choices = {}
	for idx, file in ipairs(self.images) do
		table.insert(choices, {
			id = tostring(idx),
			label = file:match("([^/]+)$"),
		})
	end
	return choices
end

-- Cycle to next image, optionally filtering by orientation
function BackDrops:cycle_forward(window, skip_orientation_filter)
	if skip_orientation_filter then
		-- Simple cycling without orientation matching
		if self.current_idx == #self.images then
			self.current_idx = 1
		else
			self.current_idx = self.current_idx + 1
		end
		self:_set_opt(window, self:_create_opts(window))
		return
	end

	-- Try to find an image with matching orientation
	local window_dims = window:get_dimensions()
	local window_aspect = window_dims.pixel_width / window_dims.pixel_height
	local window_is_landscape = window_aspect >= 1.0

	local start_idx = self.current_idx
	local attempts = 0
	local max_attempts = #self.images

	while attempts < max_attempts do
		if self.current_idx == #self.images then
			self.current_idx = 1
		else
			self.current_idx = self.current_idx + 1
		end

		attempts = attempts + 1

		local img_width, img_height = get_image_dimensions(self.images[self.current_idx])
		local img_aspect = calculate_aspect_ratio(img_width, img_height)
		local img_is_landscape = img_aspect >= 1.0

		-- Match orientations OR accept portrait images in landscape if they're high-res
		if window_is_landscape == img_is_landscape then
			break
		elseif window_is_landscape and not img_is_landscape then
			-- Portrait in landscape - check if high-res enough
			if img_width >= 1440 and img_height >= 1800 then
				break
			end
		end

		-- If we've cycled through everything, just use whatever we're at
		if self.current_idx == start_idx then
			break
		end
	end

	self:_set_opt(window, self:_create_opts(window))
end

function BackDrops:cycle_back(window)
	if self.current_idx == 1 then
		self.current_idx = #self.images
	else
		self.current_idx = self.current_idx - 1
	end
	self:_set_opt(window, self:_create_opts(window))
end

function BackDrops:random(window)
	if #self.images == 0 then
		if DEBUG then
			wezterm.log_error("No images available")
		end
		return
	end
	self.current_idx = math.random(1, #self.images)
	self:_set_opt(window, self:_create_opts(window))
end

function BackDrops:set_img(window, idx)
	if idx > #self.images or idx < 0 then
		if DEBUG then
			wezterm.log_error("Index out of range")
		end
		return
	end
	self.current_idx = idx
	self:_set_opt(window, self:_create_opts(window))
end

function BackDrops:toggle_focus(window)
	local background_opts
	if self.focus_on then
		background_opts = self:_create_opts(window)
		self.focus_on = false
	else
		background_opts = self:_create_focus_opts()
		self.focus_on = true
	end
	self:_set_opt(window, background_opts)
end

-- NEW: Toggle backgrounds on/off
function BackDrops:toggle_backgrounds(window)
	self.backgrounds_enabled = not self.backgrounds_enabled

	if self.backgrounds_enabled then
		-- Re-enable backgrounds
		if DEBUG then
			wezterm.log_info("Enabling backgrounds")
		end
		local background_opts
		if self.focus_on then
			background_opts = self:_create_focus_opts()
		else
			background_opts = self:_create_opts(window)
		end
		self:_set_opt(window, background_opts)
	else
		-- Disable backgrounds - set to solid color
		if DEBUG then
			wezterm.log_info("Disabling backgrounds")
		end
		local background_opts = {
			{
				source = { Color = colors.background },
				height = "100%",
				width = "100%",
				opacity = 1.0,
			},
		}
		self:_set_opt(window, background_opts)
	end

	return self.backgrounds_enabled
end

-- NEW: Check if backgrounds are enabled
function BackDrops:are_backgrounds_enabled()
	return self.backgrounds_enabled
end

-- Override cycling functions to respect enabled state
local original_cycle_forward = BackDrops.cycle_forward
function BackDrops:cycle_forward(window, skip_orientation_filter)
	if not self.backgrounds_enabled then
		if DEBUG then
			wezterm.log_info("Backgrounds are disabled, skipping cycle")
		end
		return
	end
	return original_cycle_forward(self, window, skip_orientation_filter)
end

local original_cycle_back = BackDrops.cycle_back
function BackDrops:cycle_back(window)
	if not self.backgrounds_enabled then
		if DEBUG then
			wezterm.log_info("Backgrounds are disabled, skipping cycle")
		end
		return
	end
	return original_cycle_back(self, window)
end

local original_random = BackDrops.random
function BackDrops:random(window)
	if not self.backgrounds_enabled then
		if DEBUG then
			wezterm.log_info("Backgrounds are disabled, skipping random")
		end
		return
	end
	return original_random(self, window)
end

return BackDrops:init()
