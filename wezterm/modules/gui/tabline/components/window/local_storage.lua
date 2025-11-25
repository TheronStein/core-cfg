local wez = require("wezterm")
local util = require("tabline.util")

---@private
---@class bar.local_storage
local M = {}

local last_update = 0
local stored_storage = ""

-- Throttle updates
local _wait = function(throttle, last_update_time)
	local current_time = os.time()
	return current_time - last_update_time < throttle
end

-- Storage type icons
local STORAGE_ICONS = {
	nvme = "󰨆",
	nvme2 = "",
	ssd = "󰨊",
	hdd = "󰋊",
}

-- Get icon based on device name
local get_storage_icon = function(device)
	if device:match("nvme") then
		if device:match("nvme1") then
			return STORAGE_ICONS.nvme2
		else
			return STORAGE_ICONS.nvme
		end
	elseif device:match("sd[a-z]") then
		return STORAGE_ICONS.hdd -- Could enhance with SSD detection
	else
		return STORAGE_ICONS.hdd
	end
end

-- Get color based on usage percentage
local get_usage_color = function(percent, colors)
	if percent >= 90 then
		return colors.ansi[2] -- Red
	elseif percent >= 75 then
		return "#F78C6C" -- Orange
	elseif percent >= 50 then
		return "#FFCB6B" -- Yellow
	elseif percent >= 35 then
		return "#E5D68A" -- Sandy yellow
	elseif percent >= 15 then
		return "#B5E48C" -- Lime green
	else
		return "#81f8bf" -- Mint green
	end
end

-- Parse df output and build storage display
M.get_local_storage = function(show_icons)
	local success, stdout, stderr = wez.run_child_process({ "df", "-h" })

	if not success or not stdout then
		return ""
	end

	local storage_items = {}
	local seen_devices = {}

	-- Parse df output (skip header)
	for line in stdout:gmatch("[^\r\n]+") do
		-- Skip header line
		if not line:match("^Filesystem") then
			-- Parse: Filesystem Size Used Avail Use% Mounted
			local device, size, used, avail, percent, mountpoint = line:match("^(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(.+)$")

			if device and mountpoint then
				-- Filter: only real devices (sd*, nvme*, vd*)
				if (device:match("^/dev/sd") or device:match("^/dev/nvme") or device:match("^/dev/vd")) and not device:match("loop") then
					-- Skip boot/efi partitions
					if not mountpoint:match("^/boot") and not mountpoint:match("^/recovery") then
						-- For btrfs subvolumes, only keep root mount
						local is_root_mount = (mountpoint == "/")

						-- Skip duplicates (btrfs subvolumes), but always include first occurrence
						if not seen_devices[device] or is_root_mount then
							if is_root_mount then
								-- If we find root mount, replace any previous entry for this device
								seen_devices[device] = true
							elseif not seen_devices[device] then
								seen_devices[device] = true
							else
								-- Skip this duplicate
								goto continue
							end

							-- Extract numeric percentage
							local percent_num = tonumber(percent:match("(%d+)"))

							if percent_num then
								local icon = get_storage_icon(device)

								-- Sort key: root partition first
								local sort_key = is_root_mount and "0" or "1"

								table.insert(storage_items, {
									sort_key = sort_key,
									device = device,
									icon = icon,
									percent = percent_num,
									mountpoint = mountpoint,
								})
							end
						end
					end
					::continue::
				end
			end
		end
	end

	-- Sort: root first, then alphabetically
	table.sort(storage_items, function(a, b)
		if a.sort_key ~= b.sort_key then
			return a.sort_key < b.sort_key
		end
		return a.device < b.device
	end)

	-- Build simple string (colors handled by tabline theme)
	local parts = {}
	for i, item in ipairs(storage_items) do
		local part = ""
		if show_icons then
			part = item.icon .. " " .. item.percent .. "%"
		else
			part = item.percent .. "%"
		end
		table.insert(parts, part)
	end

	local result = table.concat(parts, "  ")
	return result ~= "" and result or ""
end

return {
	default_opts = {
		throttle = 5, -- Update every 5 seconds
		show_icons = true,
	},
	update = function(window, opts)
		if _wait(opts.throttle or 5, last_update) then
			return stored_storage or ""
		end

		local storage = M.get_local_storage(opts.show_icons)

		if storage and storage ~= "" then
			stored_storage = storage
			last_update = os.time()
			return storage
		end

		return ""
	end,
}
